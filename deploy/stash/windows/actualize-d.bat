@echo off & call :checkParent || exit /b 1

rem --- Kartonagnick/example_gtest               [deploy/stash][actualize-d.bat]
rem [2025-12-07][22:10:00] 002 Kartonagnick PRE
rem   --- local/stash                                          [actualize-d.bat]
rem   [2023-02-11][10:00:00] 002 Kartonagnick
rem     --- old redaction                                      [actualize-d.bat]
rem     [2021-12-24][19:00:00] 001 Kartonagnick
rem ============================================================================
rem ============================================================================
         
:main
  setlocal
  call :setDepth
  call :setValue eDEBUG "ON"
  call :view [ACTUALIZE-DEBUG] run... v0.0.2    

  call :normalize exe "%~dp0actualize.bat"
  call :normalize log "%~dp0\log.txt"

  call "%exe%" > "%log%" 2>&1
  if errorlevel 1 (goto :failed)
:success
  call :view [ACTUALIZE-DEBUG] completed successfully
  exit /b 0
:failed
  call :view [ACTUALIZE-DEBUG] finished with erros
exit /b 1

rem ============================================================================
rem ============================================================================

:setDepth
  set "eDEEP0="
  if defined eINDENT (set /a "eINDENT+=1") else (set "eINDENT=0")
  for /l %%i in (1, 1, %eINDENT%) do (call set "eDEEP0=  %%eDEEP0%%")
  set "eDEEP1=  %eDEEP0%"
  exit /b
:view
  echo %eDEEP0%%*
exit /b

:setValue
  if defined %~1 (exit /b)
  set "%~1=%~2"
  exit /b
:trim
  for /F "tokens=1,*" %%a in ("%*") do (call set "%%a=%%b")
  exit /b
:normalize
  set "%~1=%~dpfn2"
exit /b

:checkParent
  if errorlevel 1 (echo [ERROR] was broken at launch & exit /b 1)
  call :setOwnerD
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  cls & echo. & echo.
  call :normalize eDIR_OWNER "%~dp0."
exit /b
