@echo off & call :checkParent || exit /b

rem --- Kartonagnick/example_gtest              [deploy][mingw][build_gtest.bat]
rem [2024-12-03][19:10:00] 001 Kartonagnick PRE
rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :setDepth
  call :echo0 [MAKE] run... v0.0.1 PRE

  call :echo1 --1-- prepare  
  call :prepare || goto :failed

  call :echo1 --2-- clone gtest
  call :clone || goto :failed

  call :echo1 --3-- detect version
  call :detectVersion || goto :failed
  call :echo2 gtest: %eVERSION%

  call :echo1 --4-- generate projects
  call :generate "810" "64" "debug"   "mt" || goto :failed
  call :generate "810" "64" "debug"   "md" || goto :failed
  call :generate "810" "32" "debug"   "mt" || goto :failed
  call :generate "810" "32" "debug"   "md" || goto :failed
  call :generate "810" "64" "release" "mt" || goto :failed
  call :generate "810" "64" "release" "md" || goto :failed
  call :generate "810" "32" "release" "mt" || goto :failed
  call :generate "810" "32" "release" "md" || goto :failed

  call :echo1 --5-- build projects
  call :build    "810" "64" "debug"   "mt" || goto :failed
  call :build    "810" "64" "debug"   "md" || goto :failed
  call :build    "810" "32" "debug"   "mt" || goto :failed
  call :build    "810" "32" "debug"   "md" || goto :failed
  call :build    "810" "64" "release" "mt" || goto :failed
  call :build    "810" "64" "release" "md" || goto :failed
  call :build    "810" "32" "release" "mt" || goto :failed
  call :build    "810" "32" "release" "md" || goto :failed

  call :echo1 --6-- install projects
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

  set "ePREFIX_READY=_external"
  set "ePREFIX_BUILD=_build"
  set "ePREFIX_REPO=_repo"
  set "ePROJECT=gtest"

  set "eURL_GTEST=https://github.com/google/googletest"
  set "eDIR_SOURCE=%eDIR_WORK%\%ePREFIX_REPO%\googletest"
  call "%~dp0path.bat"
exit /b 

:clone
  if exist "%eDIR_SOURCE%" exit /b
  git clone "%eURL_GTEST%" "%eDIR_SOURCE%" && exit /b
  call :echo1 [ERROR] can not clone repo
  call :echo1 [ERROR] check: %eDIR_SOURCE%
exit /b 1

:configure
  set "shared="
  if "%crt%" == "md" (set shared=-D"gtest_force_shared_crt=ON")
  if "%crt%" == ""   (set "crt=mt")

  set "eGENERATOR=MinGW Makefiles"
  set "eCOMPILER_TAG=mingw%tag%"

  set "eDIR_BUILD=%eDIR_WORK%\%ePREFIX_BUILD%\%ePROJECT%-%eCOMPILER_TAG%-%bit%-%typ%-%crt%"
  set "eDIR_READY=%eDIR_WORK%\%ePREFIX_READY%\%ePROJECT%-%eCOMPILER_TAG%-%bit%-%crt%"

  if "%crt%" == "mt" (
    set shared2=-D"CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$<$<CONFIG:Debug>:Debug>"
  )

  if "%typ%" == "debug" (
    set debug_postfix=-D"CMAKE_DEBUG_POSTFIX=_d"
  )

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
    -D"CMAKE_BUILD_TYPE=%typ%"            ^
    %shared% %shared2% %debug_postfix%

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

:detectVersion
  set "eMAJOR=" 
  set "eMINOR=" 
  set "ePATCH="
  set "eVERSION="
  set "file=%eDIR_SOURCE%\CMakeLists.txt"
  for /F "tokens=*" %%a in ('findstr /c:"GOOGLETEST_VERSION" "%file%"') do (
    call :parseVersion "%%~a"
  )
  call :applyVersion
  exit /b
:parseVersion
  set "eVERSION=%~1"
  set "eVERSION=%eVERSION:set=%"
  set "eVERSION=%eVERSION:(=%"
  set "eVERSION=%eVERSION:)=%"
  set "eVERSION=%eVERSION:GOOGLETEST_VERSION=%"
  set "eVERSION=%eVERSION: =%"
  exit /b
:applyVersion
  if not defined eVERSION (exit /b)
  for /F "tokens=1,2,3 delims=." %%a in ("%eVERSION%") do (
    call :trim eMAJOR %%~a
    call :trim eMINOR %%~b
    call :trim ePATCH %%~c
  )
exit /b

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

:trim
  for /F "tokens=1,*" %%a in ("%*") do (call set "%%a=%%b")
  exit /b
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
