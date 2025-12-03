@echo off & call :checkParent || exit /b

rem --- Kartonagnick/example_gtest            [deploy][mingw][build_project.bat]
rem [2024-12-03][19:10:00] 001 Kartonagnick PRE
rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :setDepth
  call :echo0 [MAKE] run... v0.0.1 PRE

  call :echo1 --1-- prepare  
  call :prepare || goto :failed

  call :echo1 --2-- generate projects
  call :generate "810" "64" "debug"   "mt" || goto :failed
  call :generate "810" "64" "debug"   "md" || goto :failed
  call :generate "810" "32" "debug"   "mt" || goto :failed
  call :generate "810" "32" "debug"   "md" || goto :failed
  call :generate "810" "64" "release" "mt" || goto :failed
  call :generate "810" "64" "release" "md" || goto :failed
  call :generate "810" "32" "release" "mt" || goto :failed
  call :generate "810" "32" "release" "md" || goto :failed

  call :echo1 --3-- build projects
  call :build    "810" "64" "debug"   "mt" || goto :failed
  call :build    "810" "64" "debug"   "md" || goto :failed
  call :build    "810" "32" "debug"   "mt" || goto :failed
  call :build    "810" "32" "debug"   "md" || goto :failed
  call :build    "810" "64" "release" "mt" || goto :failed
  call :build    "810" "64" "release" "md" || goto :failed
  call :build    "810" "32" "release" "mt" || goto :failed
  call :build    "810" "32" "release" "md" || goto :failed

  call :echo1 --4-- install projects
  call :install  "810" "64" "debug"   "mt" || goto :failed
  call :install  "810" "64" "debug"   "md" || goto :failed
  call :install  "810" "32" "debug"   "mt" || goto :failed
  call :install  "810" "32" "debug"   "md" || goto :failed
  call :install  "810" "64" "release" "mt" || goto :failed
  call :install  "810" "64" "release" "md" || goto :failed
  call :install  "810" "32" "release" "mt" || goto :failed
  call :install  "810" "32" "release" "md" || goto :failed

:success
  call :echo0 [MAKE] completed successfully
  exit /b 0
:failed
  call :echo0 [MAKE] finished with erros
exit /b 1

:prepare
  set "PATH=%PATH%;C:\Program Files\CMake\bin"
  call :normalizeD eDIR_WORK "%~dp0..\..\.."
  call :normalizeD eDIR_SOURCE "%~dp0..\.."
  set "ePREFIX_EXTERNAL=_external"
  set "ePREFIX_READY=_product"
  set "ePREFIX_BUILD=_build"
  set "ePROJECT=sample"
  set "eGTEST=gtest"
  call "%~dp0path.bat"
exit /b 

:configure
  set "shared="
  if "%crt%" == "md" (set shared=-D"gRUNTIME_CPP=dynamic")
  if "%crt%" == "mt" (set shared=-D"gRUNTIME_CPP=static")
  if "%crt%" == ""   (set shared=-D"gRUNTIME_CPP=static")

  set "eGENERATOR=MinGW Makefiles"
  set "eCOMPILER_TAG=mingw%tag%"
  set "eADDRESS_MODEL=%bit%"

  set "eDIR_BUILD=%eDIR_WORK%\%ePREFIX_BUILD%\%ePROJECT%-%eCOMPILER_TAG%-%bit%-%typ%-%crt%"
  set "eDIR_READY=%eDIR_WORK%\%ePREFIX_READY%\%ePROJECT%-%eCOMPILER_TAG%-%bit%-%crt%"
  set "GTEST_DIR=%eDIR_WORK%\%ePREFIX_EXTERNAL%\%eGTEST%-%eCOMPILER_TAG%-%bit%-%crt%"

  call set "dir_mingw=%%eMINGW%tag%_%bit%%%" 
  set "PATH=%dir_mingw%;%PATH%"
exit /b

:generate
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "typ=%~3"
  set "crt=%~4"
  call :configure || exit /b 1

  call :echo1 ------------------- generate [mingw%tag%-%bit%-%typ%-%crt%]

  cmake                                   ^
    -S"%eDIR_SOURCE%"                     ^
    -B"%eDIR_BUILD%"                      ^
    -G"%eGENERATOR%"                      ^
    -D"CMAKE_INSTALL_PREFIX=%eDIR_READY%" ^
    -D"CMAKE_DEBUG_POSTFIX=_d"            ^
    -D"CMAKE_BUILD_TYPE=%typ%"            ^
    %append% %shared%

  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] can not generate project
  call :echo1 [ERROR] cmake was failed
exit /b

:build
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "typ=%~3"
  set "crt=%~4"
  call :configure || exit /b 1

  call :echo1 ------------------- build [mingw%tag%-%bit%-%typ%-%crt%]

  cmake --build "%eDIR_BUILD%"
  if errorlevel 1 (goto :build-err "%typ%")
  exit /b
:build-err
  call :echo1 [ERROR] can not build project
  call :echo1 [ERROR] %~1: cmake was failed
exit /b 1

:runtest
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "typ=%~3"
  set "crt=%~4"
  call :configure || exit /b 1

  call :echo1 ------------------- test [mingw%tag%-%bit%-%typ%-%crt%]

  ctest                       ^
    --test-dir "%eDIR_BUILD%" ^
    --output-on-failure       ^
    --stop-on-failure         ^
    --build-config %typ%      ^
    --timeout 10

  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] %typ%: tests failed
exit /b 1

:install
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "typ=%~3"
  set "crt=%~4"
  call :configure || exit /b 1

  call :echo1 ------------------- install [mingw%tag%-%bit%-%typ%-%crt%]

  cmake --install "%eDIR_BUILD%" 
  if errorlevel 1 (goto :install-err "%typ%")
  exit /b
:install-err
  call :echo1 [ERROR] can not install project
  call :echo1 [ERROR] %~1: cmake was failed
exit /b 1

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
  echo %eDEEP1%%* & exit /b
:debug2
  if not defined eDEBUG (exit /b)
  echo %eDEEP2%%* & exit /b
exit /b

rem ............................................................................

:normalizeD
  set "%~1=%~dpfn2"
exit /b

rem ............................................................................

:checkParent
  if errorlevel 1 (echo [ERROR] was broken at launch &  exit /b 1)
  call :setOwnerD
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  echo off & cls & echo. & echo.
  call :normalizeD eDIR_OWNER "%~dp0."
exit /b
