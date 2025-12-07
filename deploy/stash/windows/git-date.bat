@echo off & call :checkParent || exit /b 1

rem --- Kartonagnick/example_gtest                  [deploy/stash][git-date.bat]
rem [2025-12-07][22:10:00] 004 Kartonagnick    
rem   --- D:\Dropbox\stashes\00-direct                            [git-date.bat]
rem   [2025-04-16][15:09:07] 004 Kartonagnick
rem   [2025-01-10][02:40:45] 003 Kartonagnick
rem     --- local/stash                                           [git-date.bat]
rem     [2023-05-20][10:00:00] 002 Kartonagnick
rem     [2023-02-11][10:00:00] 001 Kartonagnick
rem       --- old redaction
rem       [2022-06-30][16:22:27] 001 Kartonagnick
rem ============================================================================
rem ============================================================================

:main
  setlocal
  call :setDepth
  chcp 65001 >nul
  call :echo0 [GIT-DATE] run... v0.0.4

::set "eDEBUG=ON"
::set "eMODE_SILENT=ON"
  set "eMODE_WORKSPACE=ON"

  call :prepare         || goto :failed
::call :viewBranch      || goto :failed

  call :updBranch "2025-12-06 14:00:00" "2025-12-06 15:30:00"
    if errorlevel 1 (goto :failed)

  ::call :updLastCommit "2025-12-07 22:10:00"
    if errorlevel 1 (goto :failed)

  ::call :updCommit "2024-09-15 18:53:00" "e286a58a26f58a0599f02c1813de2b36b9d27ef5"
    if errorlevel 1 (goto :failed)

  ::call :updComment "version 0.1.3" "0445874923f051971b37cd36673c14255007fabc"
    if errorlevel 1 (goto :failed)

  ::call :updAnyCommit "2021-06-29 00:25:00" "763b5bf983cde5add0e7957bb567ac20754fa4ce"
    if errorlevel 1 (goto :failed)
:success
  call :saveBranchEx || goto :failed
  call :echo0 [GIT-DATE] completed successfully
  exit /b 0
:failed
  call :echo0 [GIT-DATE] finished with erros
exit /b 1

rem ============================================================================
rem ============================================================================

:prepare
  set "FILTER_BRANCH_SQUELCH_WARNING=1"

  call :getName eNAME "%~dp0."
  set "eDIR_REPO=%~dp0..\..\%eNAME%"
  call :normalizeD eDIR_REPO "%eDIR_REPO%"

  if not exist "%eDIR_REPO%\.git" (goto :errNotFound)

  pushd "%eDIR_REPO%" || (goto :errAccess)

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

  set "eGIT_CURRENT_BRANCH="
  for /f "delims=* tokens=*" %%a in ('git branch --show-current') do (
    call :trim eGIT_CURRENT_BRANCH %%~a
  )

  if errorlevel 1 (call :echo1 [ERROR] git is broken & exit /b 1)
  call :viewDebug
  exit /b
:viewDebug
  if not defined eDEBUG (goto :viewRelease)
  call :echo1 [eGIT_VERSION] ............. %eGIT_VERSION%
  call :echo1 [eGIT_LAST_FULL_COMMIT] .... %eGIT_LAST_FULL_COMMIT%
  call :echo1 [eGIT_LAST_SHORT_COMMIT] ... %eGIT_LAST_SHORT_COMMIT%
  call :echo1 [eGIT_LAST_BRANCH] ......... %eGIT_LAST_BRANCH%
  call :echo1 [eGIT_LAST_COMMENT] ........ %eGIT_LAST_COMMENT%
  echo.
  exit /b
:viewRelease
  call :echo1 BRANCH: %eGIT_CURRENT_BRANCH% 
  exit /b
:errNotFound
  call :echo1 [ERROR] .git not found
  call :echo1 [ERROR] check: eDIR_REPO
  call :echo1 [ERROR] eDIR_REPO: %eDIR_REPO%
  exit /b 1
:errAccess
  call :echo1 [ERROR] can not access do directory
  call :echo1 [ERROR] check: eDIR_REPO
  call :echo1 [ERROR] eDIR_REPO: %eDIR_REPO%
exit /b 1

rem ============================================================================
rem ============================================================================

:viewBranch
  if defined eMODE_WORKSPACE (goto :viewBranchEx)

  set "count=0"
  for /f "tokens=1,2,*" %%a in ('git cherry -v master') do (
    call :addCommit "%%~a" "%%~b" "%%~c"
  )
  if not defined eMODE_SILENT (echo.)
  exit /b
:addCommit
  set "commits[%count%]=%~2"
  set /a "count=count+1"
  if defined eMODE_SILENT (exit /b)
  for /f "tokens=1,*" %%a in ("%~2 %~3") do (
    call :echo1 [%count%][%%~a][%%~b]
  )
exit /b

rem ............................................................................

:viewBranchEx
  set "beg="
  set "count=0"
  set launch=git log --no-merges "--pretty=%%H %%s" --first-parent --reverse
  for /f "tokens=1,*" %%a in ('%launch%') do (
    call :viewCommitEx "%%~a" "%%~b"
  )
  if not defined eMODE_SILENT (echo.)
  exit /b
:viewCommitEx
  if defined beg (goto :viewCommitEx-1)

  set "v=%~2"
  if not defined v exit /b
  set "v=%v:"=%"
  if not "%v%" == "beg: task" (exit /b)
  set "beg=true"

:viewCommitEx-1
  set "commits[%count%]=%~1"
  set /a "count=count+1"
  if defined eMODE_SILENT (exit /b)
  set "N=%count%"
  if %count% lss 10 set "N=0%N%"
  call :echo1 [%N%][%~1][%~2]
exit /b

:saveBranchEx
  echo. > "%~dp0branch.log"
  echo branch: %eGIT_CURRENT_BRANCH% >> "%~dp0branch.log"
  set "id=0"
  set "beg="
  set launch=git log --no-merges "--pretty=%%H %%s" --first-parent --reverse
  for /f "tokens=1,*" %%a in ('%launch%') do (
    call :saveCommitEx "%%~a" "%%~b"
  )
  exit /b
:saveCommitEx
  if defined beg (goto :saveCommitEx-1)

  set "v=%~2"
  if not defined v exit /b
  set "v=%v:"=%"
  if not "%v%" == "beg: task" (exit /b)
  set "beg=true"

:saveCommitEx-1
  set /a id+=1
  set "N=%id%"
  if %id% lss 10 set "N=0%N%"
  echo [%N%][%~1][%~2] >> "%~dp0branch.log"
exit /b

:loopBranchDebug
  set index=0
  if not defined count (exit /b)
  if %count% equ 0     (exit /b)
:loopBranchDebugRun
  call set "commit=%%commits[%index%]%%"
  call set "stamp=%%stamps[%index%]%%"
  call :echo1 [debug][%commit%]
  set /a "index+=1"
  if %index% equ %count% (exit /b)
  goto :loopBranchDebugRun
exit /b

rem ============================================================================
rem ============================================================================

:viewTitle
  if not defined index   (goto :viewTitleS)
  if not defined eETALON (goto :viewTitleS)
  set /a "cur=index+1"
  call :echo1 [%cur%/%eETALON%]------------------------------------[%new_date%][%id_commit%]
  exit /b
:viewTitleS
  call :echo1 ------------------------------------[%new_date%][%id_commit%]
exit /b

:updCommit
  set "new_date=%~1"
  set "id_commit=%~2"
  call :viewTitle

  set "eTMP_BRANCH=temp-rebasing-branch"
  set "GIT_COMMITTER_DATE=%new_date%" 
  set "GIT_AUTHOR_DATE=%new_date%"

  set arguments=--committer-date-is-author-date ^
    "%id_commit%" --onto "%eTMP_BRANCH%"

  if defined eDEBUG (
    set silent=
  ) else (
    set silent=1^>nul
  )

  git checkout -b "%eTMP_BRANCH%" "%id_commit%"      %silent%
  git commit --amend --no-edit --date "%new_date%"   %silent%
  git checkout "%eGIT_CURRENT_BRANCH%"               %silent%
  git rebase --autostash  %arguments%                %silent%
  git branch -d "%eTMP_BRANCH%"                      %silent%
  call :echo1 --- & echo.
exit /b

:updComment
  set "new_comment=%~1"
  set "id_commit=%~2"
  call :viewTitle

  set "eTMP_BRANCH=temp-rebasing-branch"
::set "GIT_COMMITTER_DATE=%new_date%" 
::set "GIT_AUTHOR_DATE=%new_date%"

  set arguments=--committer-date-is-author-date ^
    "%id_commit%" --onto "%eTMP_BRANCH%"

  if defined eDEBUG (
    set silent=
  ) else (
    set silent=1^>nul
  )

  git checkout -b "%eTMP_BRANCH%" "%id_commit%"      %silent%
  git commit --amend -m "%new_comment%"              %silent%
  git checkout "%eGIT_CURRENT_BRANCH%"               %silent%
  git rebase --autostash  %arguments%                %silent%
  git branch -d "%eTMP_BRANCH%"                      %silent%
  call :echo1 --- & echo.
exit /b

rem ============================================================================
rem ============================================================================

:updBranch
  set "beg_date=%~1"
  set "end_date=%~2"
  call :echo1 started...
  call :echo1 from: %beg_date%
  call :echo1  to : %end_date%
 
  if "%eGIT_CURRENT_BRANCH%" == "master" (goto :wrnMaster)
  if not defined eDEBUG (set "eMODE_SILENT=ON")

  call :viewBranch
  set "eETALON=%count%"

  if "%count%" == "0" (goto :wrnZeroCommits)

  rem call :loopBranchDebug

  set command=cscript.exe /nologo ^
    "%eDIR_VBS%\offset.vbs"       ^
    "%beg_date%"                  ^
    "%end_date%"                  ^
    "%count%"

  set "count=0"
  for /f "usebackq tokens=*" %%a in (`%command%`) do (call :addStamp "%%~a")
  call :echo1 number of commits: %count%
  echo.

  if not defined eDEBUG (set "eMODE_SILENT=ON")
  set "index=0"
:loop
  call :runCommit || (call :echo1 [ERROR] & exit /b 1)
  if not "%eETALON%" == "%count%" (exit /b)
  set /a "index=index+1"
  if %index% equ %count% (exit /b)
  goto :loop
  exit /b
:wrnMaster
  call :echo1 [WARNING] branch 'master' should not be processed
  call :echo1 [WARNING] operation aborted
  exit /b
:wrnZeroCommits
  call :echo1 [WARNING] count = 0
  call :echo1 [WARNING] operation aborted
  exit /b
:addStamp
  if defined eMODE_SILENT (goto :addStampNext)
  call :echo1 [vbs] %~1
:addStampNext
  set "stamps[%count%]=%~1"
  set /a "count=count+1"
  exit /b
:runCommit
  call set "commit=%%commits[%index%]%%"
  call set "stamp=%%stamps[%index%]%%"
  call :updCommit "%stamp%" "%commit%" || exit /b 1
  call :viewBranch
  if not "%eETALON%" == "%count%" (goto :wrnAborted)
  exit /b
:wrnAborted
  call :echo1 [EXTREME STOP] value of count was changed
  call :echo1 [EXTREME STOP] operation aborted
exit /b

rem ============================================================================
rem ============================================================================

:updLastCommit
  set "new_date=%~1"
  if not defined new_date (goto :updLastCommitDefault)
  set "GIT_COMMITTER_DATE=%new_date%"
  set "GIT_AUTHOR_DATE=%new_date%"
  git commit --amend --no-edit --date="%new_date%"
  exit /b
:updLastCommitDefault
  commit --amend --no-edit --date=now
exit /b

:updAnyCommit
  set "new_date=%~1"
  set "com_hash=%~2"
  git rev-parse -q --verify "%com_hash%" || (goto :updAnyCommitError)
  git add -A                             || (goto :updAnyCommitError)
  git commit -m "auto-fixed"             || (goto :updAnyCommitError)
  git filter-branch -f --env-filter ^
    "if [ $GIT_COMMIT = %com_hash% ]; then export GIT_AUTHOR_DATE='%new_date%'; export GIT_COMMITTER_DATE=$GIT_AUTHOR_DATE; fi"
  exit /b
:updAnyCommitError
  call :echo1 [ERROR] hash not found: %com_hash%
  exit /b 1
exit /b1 

:updAuthorLastCommit
  git commit --amend --author="New Author <new@email.com>" -m "new comment"
exit /b

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
  if exist "%eDIR_VBS%" exit /b
  set "eDIR_VBS=%~dp0vbs"  
  exit /b
:cmdD
  set "eDIR_CMD=%eDIR_SCRIPTS%\cmd"
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
  call :git.init     || exit /b 1
  call :vbsD         || exit /b 1
  exit /b
:setOwnerD
  if defined eDIR_OWNER (exit /b)
  cls & echo. & echo.
  call :normalizeD eDIR_OWNER "%~dp0."
exit /b
