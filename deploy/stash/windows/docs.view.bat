@echo off & call :checkParent || exit /b

rem --- Kartonagnick/example_gtest                 [deploy/stash][docs.view.bat]
rem [2025-12-07][22:10:00] 003 Kartonagnick PRE
rem   --- D:\Dropbox\stashes\00-direct                           [docs.view.bat]
rem   [2025-06-26][14:10:57] 003 Kartonagnick
rem     --- F:\flowers                                           [docs.view.bat]
rem     [2025-06-21][22:01:12] 002 Kartonagnick
rem     [2023-12-25][20:18:50] 001 Kartonagnick
rem ============================================================================
rem ============================================================================

:main
  setlocal
::chcp 65001 >nul
  call :setDepth
  set eMAIN_VERSION=0.0.3 PRE
  call :echo0 [DOCS.VIEW] run... v%eMAIN_VERSION%
  call :browser.init || goto :failed
  call :browser.run  || goto :failed
:success
  call :echo0 [DOCS.VIEW] completed successfully
  exit /b 0
:failed
  call :echo0 [DOCS.VIEW] finished with erros
exit /b 1

rem ============================================================================
rem ============================================================================

:browser.init
  call :chrome.init && (call :browser.chrome & exit /b)
  call :edge.init   && (call :browser.edge   & exit /b)
  call :echo1 [ERROR] not found: browser
  exit /b 1
:browser.chrome
  set "eBROWSER.EXE=chrome.exe"
  exit /b
:browser.edge
  set "eBROWSER.EXE=msedge.exe"
  exit /b
:browser.run
  call :getName name "%~dp0."
  call :normalizeD "eDIR_REPO" "%~dp0..\..\%name%"
  set "readme.md=%eDIR_REPO%\README.md"
  if not exist "%readme.md%" goto :browser.err
  start "%eBROWSER.EXE%" "%eBROWSER.EXE%" "%readme.md%"
  exit /b
:browser.err
  call :echo1 [ERROR] not found: README.md
  call :echo1 [ERROR] check: eDIR_REPO
  call :echo1 [ERROR] - %eDIR_REPO%
exit /b 1

rem ............................................................................

:chrome.init
  setlocal
  set "eDIR_CHROME="
  set "dir[0]=C:\Program Files\Google\Chrome\Application"
  set "dir[1]=C:\Program Files (x86)\Google\Chrome\Application"
  call :findProgram "chrome.exe" "eDIR_CHROME" || exit /b 1
  set "PATH=%PATH%;%eDIR_CHROME%"
  endlocal & (set "eDIR_CHROME=%eDIR_CHROME%" & set "PATH=%PATH%")
exit /b

rem ............................................................................

:edge.init
  setlocal
  set "eDIR_EDGE="
  set "dir[0]=C:\Program Files\Microsoft\Edge\Application"
  set "dir[1]=C:\Program Files (x86)\Microsoft\Edge\Application"
  call :findProgram "msedge.exe" "eDIR_EDGE" || exit /b 1
  set "PATH=%PATH%;%eDIR_EDGE%"
  endlocal & (set "eDIR_EDGE=%eDIR_EDGE%" & set "PATH=%PATH%")
exit /b

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
exit /b

rem ............................................................................

:trim
  for /F "tokens=1,*" %%a in ("%*") do (call set "%%a=%%b")
  exit /b
:getName
  set "%~1=%~n2%~x2"
  exit /b
:normalizeD
  set "%~1=%~dpfn2"
exit /b

rem ............................................................................

:checkParent
  if errorlevel 1 (echo [ERROR] was broken at launch &  exit /b 1)
  call :setOwnerD || exit /b 1
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  echo off & cls & echo. & echo.
  call :normalizeD eDIR_OWNER "%~dp0."
exit /b
