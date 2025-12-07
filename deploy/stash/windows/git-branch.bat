@echo off & call :checkParent || exit /b 1

rem --- Kartonagnick/example_gtest                [deploy/stash][git-branch.bat]
rem [2025-12-07][22:10:00] 001 Kartonagnick    
rem ============================================================================
rem ============================================================================
rem switch to all remote branches

:main
  setlocal
  call :setDepth
  set "title=GIT-BRANCH"
  call :echo0 [%title%] run... 0.0.1

::set eDEBUG=ON

  call :debug1 -1- prepare
  call :prepare || goto :failed

  call :debug1 -2- pull all branches
  call :branch || goto :failed
:success
  call :echo0 [%title%] completed successfully
  exit /b 0
:failed
  call :echo0 [%title%] finished with erros
exit /b 1

:prepare
  set "FILTER_BRANCH_SQUELCH_WARNING=1"

  call :getName eNAME "%~dp0."
  set "eDIR_REPO=%~dp0..\..\%eNAME%"
  call :normalizeD eDIR_REPO "%eDIR_REPO%"
  if not exist "%eDIR_REPO%\.git" (goto :prepare.not_found)
  pushd "%eDIR_REPO%" || (goto :prepare.access)

  call :git.last_commit || exit /b
  call :git.last_branch || exit /b
  call :git.curr_branch || exit /b
  if not defined eDEBUG exit /b
  call :echo1 [CURR] %eGIT_CURR_BRANCH%
  call :echo1 [LAST] %eGIT_LAST_BRANCH%
  call :echo1 [LAST] %eGIT_LAST_COMMIT%
  exit /b
:git.last_commit
  set "eGIT_LAST_COMMIT="
  for /f %%a in ('git log -1 --pretty^=format:"%%H"') do (
    set "eGIT_LAST_COMMIT=%%a"
  )
  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] git.last_commit
  exist /b 1
:git.last_branch
  set "eGIT_LAST_BRANCH="
  for /f "delims=* tokens=*" %%a in ('git branch --contains %eGIT_LAST_COMMIT%') do (
    call :trim eGIT_LAST_BRANCH %%~a
  )
  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] git.last_branch
  exist /b 1
:git.curr_branch
  set "eGIT_CURRENT_BRANCH="
  for /f "delims=* tokens=*" %%a in ('git branch --show-current') do (
    call :trim eGIT_CURR_BRANCH %%~a
  )
  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] git.current_branch
  exist /b 1
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

rem ............................................................................

:branch
  call :git.fetch || exit /b 1
  set "other_branches="
  set "numeric_branches="
  for /f "delims=* tokens=*" %%a in ('git branch -a') do (
    call :branch.process "%%~a"
  )
  call :branch.enumerate "%other_branches%"
  call :branch.enumerate "%numeric_branches%"
  exit /b
:branch.enumerate
  set "enumerator=%~1"
:branch.loop
  for /F "tokens=1* delims=;" %%a in ("%enumerator%") do (
    set "enumerator=%%~b"
    call :branch.switch "%%~a"
  )
  if defined enumerator (goto :branch.loop)
  exit /b
:branch.switch
  set "name=%~1"
  call :echo1 switch ... %name%
  git switch "%name%" >nul 2>nul
  exit /b
:branch.process
  set "text=%~1"
  set "checked=%text:HEAD=%"
  if not "%checked%" == "%text%" (exit /b)

  call :trim text %~1

  set "checked=%text:master=%"
  if not "%checked%" == "%text%" (exit /b)

  set "checked=%text:remotes=%"
  if "%checked%" == "%text%" (
    call :branch.local
  ) else (
    call :branch.remote
  )
  exit /b
:branch.remote
  set "name=%text:remotes/origin/=%"
  call :debug1 remote ... %name%    
  set "checked=%name:~0,1%"
  if "%checked%" == "#" (
    call :branch.remote.numeric
  ) else (
    call :branch.remote.other
  )
  exit /b
:branch.remote.numeric
  set "numeric_branches=%numeric_branches%;%name%"
  exit /b
:branch.remote.other
  set "other_branches=%other_branches%;%name%"
  exit /b
:branch.local
  call :debug1 local .... %text%    
  exit /b
:git.pull
  git pull --all && exit /b  
  call :echo1 [ERROR] git pull
  exit /b 1
:git.fetch
  git fetch && exit /b  
  call :echo1 [ERROR] git fetch
exit /b 1

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
:debug0
  if not defined eDEBUG (exit /b)
  echo %eDEEP0%%*
  exit /b
:debug1
  if not defined eDEBUG (exit /b)
  echo %eDEEP1%%*
  exit /b
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
  call :git.init     || exit /b 1
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  call :normalizeD eDIR_OWNER "%~dp0."
  cls & echo. & echo.
exit /b
