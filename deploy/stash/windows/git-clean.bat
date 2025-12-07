@echo off & call :checkParent || exit /b 1

rem --- Kartonagnick/example_gtest                 [deploy/stash][git-clean.bat]
rem [2025-12-07][22:10:00] 003 Kartonagnick    
rem   --- D:\Dropbox\stashes\00-direct                           [git-clean.bat]
rem   [2026-06-26][14:23:24] 003 Kartonagnick
rem   [2025-01-16][02:44:36] 002 Kartonagnick
rem     --- local/stash
rem     [2023-02-11][10:00:00] 001 Kartonagnick
rem       --- old redaction
rem       [2022-06-30][16:22:27] 001 Kartonagnick
rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :setDepth
  set "title=GIT-CLEAN"
  call :echo0 [%title%] run... 0.0.3

::set "eDEBUG=ON"

  set "id=1"
  call :echo1 --%id%-- prepare
  call :prepare         || goto :failed
  call :showUnreachable || goto :failed
  call :echo1 --%id%-- clean garbage... (please wait)
  call :clean.garbage   || goto :failed
  call :echo1 --%id%-- clean repo... (please wait)
  call :clean.repo      || goto :failed
:success
  call :echo0 [%title%] completed successfully
  exit /b 0
:failed
  call :echo0 [%title%] finished with erros
exit /b 1

:showUnreachable
  set /a "id+=1"
  if not defined eDEBUG exit /b
  call :echo1 --%id%-- show unreachable
  git fsck --unreachable 
  set /a "id+=1"
exit /b

rem ============================================================================
rem ============================================================================

:prepare
  set "FILTER_BRANCH_SQUELCH_WARNING=1"
  call :getName eNAME "%~dp0."
  set "eDIR_REPO=%~dp0..\..\%eNAME%"
  call :normalizeD eDIR_REPO "%eDIR_REPO%"
  if not exist "%eDIR_REPO%\.git" (goto :prepare.not_found)
  pushd "%eDIR_REPO%" || (goto :prepare.access)
  set "eOUT="
  if defined eDEBUG exit /b 
  set eOUT=1^>nul 2^>nul
  exit /b
:prepare.not_found
  call :echo1 [ERROR] not found: .git
  call :echo1 [ERROR] check: eDIR_REPO
  call :echo1 [ERROR] eDIR_REPO: %eDIR_REPO%
  exit /b 1
:prepare.access
  call :echo1 [ERROR] can not access to directory
  call :echo1 [ERROR] check: eDIR_REPO
  call :echo1 [ERROR] eDIR_REPO: %eDIR_REPO%
exit /b 1

:clean.garbage
  set /a "id+=1"
  set m1=build; build-*; product; _products; _ready
  set m2=Release; release; release32; release64
  set m3=Debug; debug; debug32; debug64
  set m4=RelWithDebInfo; MinSizeRel
  set m5=.vs; *.suo; *.ncb; *.sdf; ipch; *.VC.db; *.aps;
  set m6=log.txt; cmdlog.txt; debug.txt;
  set m7=_cache*.bat; _cache

  set mask=%m1%; %m1%; %m2%; %m3%; %m4%; %m5%; %m6%; %m7%
  
  set e1=_*; google*; boost*; mingw* 
  set e2=external*; product*; build*; programs; cmake*;
  set exclude=%e1%; %e2%
  call :clean.garbage.run && (
    call :debug2 done
    exit /b
  )
  call :echo1 [ERROR] failed: garbage.exe
  exit /b 1
:clean.garbage.run
  garbage.exe             ^
      "-start: eDIR_REPO" ^
      "--mask: %mask%"    ^
      "--es: %exclude%"   ^
      "--zdebug"          ^
      "--ztest"
exit /b

:clean.repo
  set /a "id+=1"
  git reflog expire --expire=now --all %eOUT% || goto :clean.repo.expire
  git gc --prune=now --aggressive      %eOUT% || goto :clean.repo.prune
  exit /b
:clean.repo.expire
  call :echo1 [ERROR] failed: `git reflog expire --expire=now --all`
  exit /b 1
:clean.repo.prune
  call :echo1 [ERROR] failed: `git gc --prune=now --aggressive`
exit /b 1

rem ............................................................................

:workspaceD
  if defined eDIR_WORKSPACE exit /b
  setlocal
  set "cmd=WMIC LogicalDisk Get Name"
  set "run=%cmd% /value 2^> nul ^| find "=""
  for /f "usebackq tokens=*" %%a in (`%run%`) do (
    call :workspaceD.disk "%%~a" && goto :workspaceD.success
  )
  rem not found
  endlocal & (set "eDIR_WORKSPACE=")
  exit /b 0
:workspaceD.failed
  call :echo2 [ERROR] not found: workspace
  exit /b 1
:workspaceD.success
  endlocal & (set "eDIR_WORKSPACE=%dir%")
  call :trace2 found: %eDIR_WORKSPACE%
  exit /b 0
:workspaceD.disk
  set "%~1"
  call :normalizeD "dir" "%Name%\workspace"
  if not exist "%dir%\3rd_party" exit /b 1
  if not exist "%dir%\programs"  exit /b 1
  if not exist "%dir%\scripts"   exit /b 1
exit /b 0

rem ............................................................................

:git.init
  setlocal
  if defined ProgramFiles(x86) (call :git.init64) else (call :git.init32)
  call :findProgram "git.exe" "eDIR_GIT" || goto :git.not_found
  call :trace2 found: %eDIR_GIT%
  set "PATH=%PATH%;%eDIR_GIT%"
  endlocal & (set "eDIR_GIT=%eDIR_GIT%" & set "PATH=%PATH%")
  exit /b
:git.init32
  set "dir[0]=C:\Program Files\Git\bin"
  set "dir[1]=C:\Program Files\SmartGit\git\bin"
  set "dir[2]=%eDIR_WORKSPACE%\programs\x32\Git\bin"
  set "dir[3]=%eDIR_WORKSPACE%\programs\x32\SmartGit\git\bin" 
  exit /b
:git.init64
  set "dir[0]=C:\Program Files\Git\bin"
  set "dir[1]=C:\Program Files\SmartGit\git\bin"
  set "dir[2]=%eDIR_WORKSPACE%\programs\x64\Git\bin"
  set "dir[3]=%eDIR_WORKSPACE%\programs\x64\SmartGit\git\bin" 
  set "dir[4]=C:\Program Files (x86)\Git\bin"
  set "dir[5]=C:\Program Files (x86)\SmartGit\git\bin"
  set "dir[6]=%eDIR_WORKSPACE%\programs\x32\Git\bin"
  set "dir[7]=%eDIR_WORKSPACE%\programs\x32\SmartGit\git\bin" 
  exit /b
:git.not_found
  call :echo2 [ERROR] not found: git.exe
exit /b 1

rem ............................................................................

:scriptsD
  set "eDIR_SCRIPTS=%eDIR_WORKSPACE%\scripts"
  if not exist "%eDIR_SCRIPTS%" (set "eDIR_SCRIPTS=")
::if not exist "%eDIR_SCRIPTS%" goto :scriptsD.failed
  exit /b
:scriptsD.failed
  call :echo2 [ERROR] not found: eDIR_SCRIPTS
  call :echo2 [ERROR] check: %eDIR_SCRIPTS%
  exit /b 1
:vbsD
  set "eDIR_VBS=%eDIR_SCRIPTS%\vbs"
  if not exist "%eDIR_VBS%" goto :vbsD.failed
  exit /b
:vbsD.failed
  call :echo2 [ERROR] not found: eDIR_VBS
  call :echo2 [ERROR] check: %eDIR_VBS%
  exit /b 1
:cmdD
  set "eDIR_CMD=%eDIR_SCRIPTS%\cmd"
  if exist "%eDIR_CMD%" exit /b
  set "eDIR_CMD=%~dp0cmd"
  if not exist "%eDIR_CMD%" goto :cmdD.failed
  exit /b
:cmdD.failed
  call :echo2 [ERROR] not found: eDIR_CMD
  call :echo2 [ERROR] check: %eDIR_CMD%
  exit /b 1
:garbage.init
  where garbage.exe >nul 2>nul && exit /b 
  if not exist "%eDIR_CMD%\garbage.exe" goto :garbage.failed
  set "PATH=%PATH%;%eDIR_CMD%"
  exit /b 0
:garbage.failed
  call :echo2 [ERROR] not found: garbage.exe
  call :echo2 [ERROR] check: %eDIR_CMD%\garbage.exe
  exit /b 1
:find_in.init
  where garbage.exe >nul 2>nul && exit /b 
  if not exist "%eDIR_CMD%\find_in.exe" goto :find_in.failed
  set "PATH=%PATH%;%eDIR_CMD%"
  exit /b 0
:find_in.failed
  call :echo2 [ERROR] not found: find_in.exe
  call :echo2 [ERROR] check: %eDIR_CMD%\find_in.exe
exit /b 1

rem ............................................................................

:findProgram
  rem usage: 
  rem   call :findProgram "7z.exe" "eDIR_7Z" || goto :zipNotFound
  rem   call :findProgram "7z.exe" "eDIR_7Z" "name_array"
  set "var=%~3"
  if not defined var (set "var=dir")
  for /F "usebackq tokens=2 delims==" %%a in (`set "%var%[" 2^>nul`) do (
    call :checkExist "%%~a" "%~1" "%~2" && exit /b 
  )
  call :echo1 [ERROR] not found: %~1
  exit /b 1
:checkExist
  if not exist "%~1\%~2" (exit /b 1)
  call :normalizeD "%~3" "%~1"
exit /b 0

rem ============================================================================
rem ============================================================================

:setDepth
  set "eDEEP0="
  if defined eINDENT (set /a "eINDENT+=1") else (set "eINDENT=0")
  for /l %%i in (1, 1, %eINDENT%) do (call set "eDEEP0=  %%eDEEP0%%")
  set "eDEEP1=  %eDEEP0%"
  set "eDEEP2=  %eDEEP1%"
  exit /b
:echo0
  echo %eDEEP0%%* & exit /b
:echo1
  echo %eDEEP1%%* & exit /b
:echo2
  echo %eDEEP2%%* & exit /b
:debug1
  if not defined eDEBUG (exit /b)
  echo %eDEEP1%%*
:debug2
  if not defined eDEBUG (exit /b)
  echo %eDEEP2%%*
  exit /b
:trace2
  if not defined eTRACE (exit /b)
  echo %eDEEP2%%*
exit /b

rem ............................................................................

:trim
  for /F "tokens=1,*" %%a in ("%*") do (call set "%%a=%%b")
  exit /b
:normalizeD
  set "%~1=%~dpfn2"
  exit /b
:getName
  set "%~1=%~n2"
  exit /b
:setValue
  if defined %~1 (exit /b)
  set "%~1=%~2"
exit /b

:checkParent
  if errorlevel 1 (echo [ERROR] was broken at launch & exit /b 1)
  call :setOwnerD    || exit /b 1
  call :workspaceD   || exit /b 1
  call :scriptsD     || exit /b 1
  call :cmdD         || exit /b 1
  call :garbage.init || exit /b 1
  call :git.init     || exit /b 1
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  cls & echo. & echo.
  call :normalizeD eDIR_OWNER "%~dp0."
exit /b
