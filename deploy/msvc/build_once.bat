@echo off & call :checkParent || exit /b

rem --- Kartonagnick/example_gtest                [deploy][msvc][build_once.bat]
rem [2024-12-03][19:10:00] 001 Kartonagnick    
rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :setDepth
  call :echo0 [MAKE] run... v0.0.1    

  call :echo1 --1-- prepare  
  call :prepare || goto :failed

  call :echo1 --2-- generate projects
  call :generate "2022" "64" "mt" || goto :failed

  call :echo1 --3-- build projects
  call :build    "2022" "64" "mt" || goto :failed

  call :echo1 --4-- test projects
  call :runtest  "2022" "64" "mt" || goto :failed

  call :echo1 --5-- install projects
  call :install  "2022" "64" "mt" || goto :failed

:success
  call :echo0 [MAKE] completed successfully
  exit /b 0
:failed
  call :echo0 [MAKE] finished with erros
exit /b 1

:prepare
  set "PATH=%PATH%;C:\Program Files\CMake\bin"
  set "ePREFIX_EXTERNAL=_external"
  set "ePREFIX_READY=_product"
  set "ePREFIX_BUILD=_build"
  set "ePROJECT=sample"
  set "eGTEST=gtest"

  call :normalizeD eDIR_WORK "%~dp0..\..\.."
  call :normalizeD eDIR_SOURCE "%~dp0..\.."
exit /b 

:configure
  set "shared="
  set "append=-A x64"
  if "%bit%" == "32" (set "append=-A Win32") 
  if "%crt%" == "md" (set shared=-D"gRUNTIME_CPP=dynamic")
  if "%crt%" == "mt" (set shared=-D"gRUNTIME_CPP=static")
  if "%crt%" == ""   (set shared=-D"gRUNTIME_CPP=static")
  call :compiler_tag || exit /b 1

  set "eADDRESS_MODEL=%bit%"
  set "eDIR_BUILD=%eDIR_WORK%\%ePREFIX_BUILD%\%ePROJECT%-%eCOMPILER_TAG%-%bit%-%crt%"
  set "eDIR_READY=%eDIR_WORK%\%ePREFIX_READY%\%ePROJECT%-%eCOMPILER_TAG%-%bit%-%crt%"
  set "GTEST_DIR=%eDIR_WORK%\%ePREFIX_EXTERNAL%\%eGTEST%-%eCOMPILER_TAG%-%bit%-%crt%"

  exit /b
:compiler_tag
  set "eGENERATOR="
  set "eCOMPILER_TAG=msvc%tag%"
  if "%tag%" == "2008" (set "eGENERATOR=Visual Studio 9 2008" )
  if "%tag%" == "2010" (set "eGENERATOR=Visual Studio 10 2010")
  if "%tag%" == "2012" (set "eGENERATOR=Visual Studio 11 2012")
  if "%tag%" == "2013" (set "eGENERATOR=Visual Studio 12 2013")
  if "%tag%" == "2015" (set "eGENERATOR=Visual Studio 14 2015")
  if "%tag%" == "2017" (set "eGENERATOR=Visual Studio 15 2017")
  if "%tag%" == "2019" (set "eGENERATOR=Visual Studio 16 2019")
  if "%tag%" == "2022" (set "eGENERATOR=Visual Studio 17 2022")
  if defined eGENERATOR (exit /b)
  call :echo0 [ERROR] unknown compiler
  call :echo0 [ERROR] check: %eCOMPILER_TAG%
exit /b 1

:generate
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "crt=%~3"
  call :configure || exit /b 1

  call :echo1 ------------------- generate [msvc%tag%-%bit%-%crt%]

  cmake                                   ^
    -S"%eDIR_SOURCE%"                     ^
    -B"%eDIR_BUILD%"                      ^
    -G"%eGENERATOR%"                      ^
    -D"CMAKE_INSTALL_PREFIX=%eDIR_READY%" ^
    -D"CMAKE_DEBUG_POSTFIX=_d"            ^
    %append% %shared%

  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] can not generate project
  call :echo1 [ERROR] cmake was failed
exit /b

:build
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "crt=%~3"
  call :configure || exit /b 1

  call :echo1 ------------------- build [msvc%tag%-%bit%-release-%crt%]

  cmake --build "%eDIR_BUILD%" --config Release  
  if errorlevel 1 (goto :build-err "release")

  call :echo1 ------------------- build [msvc%tag%-%bit%-debug-%crt%]

  cmake --build "%eDIR_BUILD%" --config Debug  
  if errorlevel 1 (goto :build-err "debug")
  exit /b
:build-err
  call :echo1 [ERROR] can not build project
  call :echo1 [ERROR] %~1: cmake was failed
exit /b 1

:runtest
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "crt=%~3"
  call :configure || exit /b 1
  call :runtestConfig "debug"   || exit /b 1
  call :runtestConfig "release" || exit /b 1
  exit /b
:runtestConfig
  set "cfg=%~1"

  call :echo1 ------------------- test [msvc%tag%-%bit%-%cfg%-%crt%]

  ctest                       ^
    --test-dir "%eDIR_BUILD%" ^
    --output-on-failure       ^
    --stop-on-failure         ^
    --build-config %cfg%      ^
    --timeout 10

  if not errorlevel 1 (exit /b)
  call :echo1 [ERROR] %cfg%: tests failed
exit /b 1

:install
  setlocal
  set "tag=%~1" 
  set "bit=%~2"
  set "crt=%~3"
  call :configure || exit /b 1

  call :echo1 ------------------- install [msvc%tag%-%bit%-release-%crt%]

  cmake --install "%eDIR_BUILD%" --config Release  
  if errorlevel 1 (goto :install-err "release")

  call :echo1 ------------------- install [msvc%tag%-%bit%-debug-%crt%]

  cmake --install "%eDIR_BUILD%" --config Debug  
  if errorlevel 1 (goto :install-err "debug")

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
