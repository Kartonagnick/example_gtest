@echo off & call :checkParent || exit /b 1

rem --- Kartonagnick/example_gtest                [deploy/stash][git-rebase.bat]
rem [2025-12-07][22:10:00] 004 Kartonagnick PRE
rem   --- local/stash                                           [git-rebase.bat]
rem   [2023-05-22][19:00:00] 001 Kartonagnick
rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :setDepth
  set "title=GIT-REBASE"
  call :view [%title%] run... 0.0.4 PRE    

::set "eDEBUG=ON"
::set "eTRACE=ON"

  call :view1 --1-- prepare
  call :prepare || goto :failed

::git rebase -i --root   --rebase-merges & exit 
::git rebase -i HEAD~11  --rebase-merges & exit
  git rebase -i master~2 --rebase-merges

::  git push   --force
::  git rebase --edit-todo
::  git rebase --continue

::  git stash push --keep-index
::  git rebase --abort
::  git rebase --quit

rem renormalize eol:
::  git add --renormalize .
::  git add --update --renormalize

rem Windows:
::  git config --global core.autocrlf true
::  git config --global core.eol native

rem Linux:
::  git config --local core.eol native
::  git config --local core.autocrlf input

rem removal all files end restore its original state
::  git rm -rf --cached .
::  git reset --hard HEAD

rem show oel:
rem index  |  work  |  attr value  |  file
rem git ls-files --eol

rem squash initial commit
rem  git rebase -i --root

  if errorlevel 1 (goto :failed)
:success
  call :view [%title%] completed successfully
  exit /b 0
:failed
  call :view [%title%] finished with erros
exit /b 1

rem ============================================================================
rem ============================================================================

:prepare
  if defined eTRACE (set "eDEBUG=ON")

  set "eMODE_SILENT="
  set "FILTER_BRANCH_SQUELCH_WARNING=1"

  call :getName eNAME "%~dp0."
  set "eDIR_REPO=%~dp0..\..\%eNAME%"
  call :normalizeD eDIR_REPO "%eDIR_REPO%"

  if not exist "%eDIR_REPO%\.git" (call :errNotFoundRepo & exit /b 1)
  pushd "%eDIR_REPO%" || (call :errAccess & exit /b 1)

  for /f "tokens=3" %%a in ('git --version') do (set "eGIT_VERSION=%%a")

  set "eGIT_LAST_FULL_COMMIT="
  for /f %%a in ('git log -1 --pretty^=format:"%%H"') do (
    set "eGIT_LAST_FULL_COMMIT=%%a"
  )

  set "eGIT_LAST_SHORT_COMMIT="
  for /f %%a in ('git log -1 --pretty^=format:"%%h"') do (
    set "eGIT_LAST_SHORT_COMMIT=%%a"
  )

  rem git branch
  rem git branch --show-current
  set "eGIT_LAST_BRANCH="
  for /f "delims=* tokens=*" %%a in ('git branch --contains %eGIT_LAST_FULL_COMMIT%') do (
    call :trim eGIT_LAST_BRANCH %%~a
  )

  set "eGIT_LAST_COMMENT="
  for /f "delims=* tokens=*" %%a in ('git log --format^="%%s" -n 1 %eGIT_LAST_FULL_COMMIT%') do (
    call :trim eGIT_LAST_COMMENT %%~a
  )
  if errorlevel 1 (echo [ERROR] git is broken & exit /b 1)

  set eOUT=1^>nul 2^>nul

  if not defined eDEBUG goto :prepare-1
  call :view2 eNAME .................... %eNAME%
  call :view2 eDIR_REPO ................ %eDIR_REPO%
  call :view2 eGIT_VERSION ............. %eGIT_VERSION%
  call :view2 eGIT_LAST_FULL_COMMIT .... %eGIT_LAST_FULL_COMMIT%
  call :view2 eGIT_LAST_SHORT_COMMIT ... %eGIT_LAST_SHORT_COMMIT%
  call :view2 eGIT_LAST_BRANCH ......... %eGIT_LAST_BRANCH%
  call :view2 eGIT_LAST_COMMENT ........ %eGIT_LAST_COMMENT%
  set eOUT=
:prepare-1
  call :view2 eDIR_REPO ................ %eDIR_REPO%
  exit /b
:errNotFoundRepo
  echo [ERROR] .git not found
  echo [ERROR] check: eDIR_REPO
  echo [ERROR] eDIR_REPO: %eDIR_REPO%
  exit /b 1
:errAccess
  echo [ERROR] can not access to directory
  echo [ERROR] check: eDIR_REPO
  echo [ERROR] eDIR_REPO: %eDIR_REPO%
exit /b 1

rem ============================================================================
rem ============================================================================

:setDepth
  set "eDEEP0="
  if defined eINDENT (set /a "eINDENT+=1") else (set "eINDENT=0")
  for /l %%i in (1, 1, %eINDENT%) do (call set "eDEEP0=  %%eDEEP0%%")
  set "eDEEP1=  %eDEEP0%"
  set "eDEEP2=  %eDEEP1%"
  set "eDEEP3=  %eDEEP2%"
  exit /b
:view
  echo %eDEEP0%%*
  exit /b
:view1
  echo %eDEEP1%%*
  exit /b
:view2
  echo %eDEEP2%%*
  exit /b
:debug1
  if not defined eDEBUG (exit /b)
  echo %eDEEP1%%*
  exit /b
:debug2
  if not defined eDEBUG (exit /b)
  echo %eDEEP2%%*
  exit /b
:debug3
  if not defined eDEBUG (exit /b)
  echo %eDEEP3%%*
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
  call :setOwnerD
  call :findGit
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  cls & echo. & echo.
  call :normalizeD eDIR_OWNER "%~dp0."
  exit /b
:findGit
  set "PATH_GIT1=C:\Program Files\Git\bin"
  set "PATH_GIT2=C:\Program Files\SmartGit\git\bin"
  set "PATH=%PATH_GIT1%;%PATH_GIT2%;%PATH%"
  where git.exe >nul 2>nul && exit /b
  echo [ERROR] git.exe not found
exit /b
