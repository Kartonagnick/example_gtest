::'@echo off & cls & echo.
::'chcp 65001 >nul
::'set "eDEBUG=ON"
::'set "eDIR_REPO=%~dp0..\..\stash [auto detect]"
::'set "eDIR_COMMIT[0]=new\boost"
::'set "eDIR_COMMIT[1]=old\boost"
::'set "eDIR_COMMIT[2]=icons"
::'set "eDIR_COMMIT[3]=sandbox-1"
::'set "eDIR_COMMIT[4]=sandbox-2"
::'set "eDIR_COMMIT[5]=sandbox-3"
::'set "eBIN_EXTENSION_=jpg;png;exe;graphml"
::'set "eTXT_EXTENSION_=cpp;hpp;txt;md;bat;h;hpp;hxx;cpp;cxx;yml;.gitignore"
::'set "eFILE_EXCLUDES=*.c"
::'cscript //nologo //e:vbscript "%~f0" %*
::'exit /b

'===============================================================================

'--- Kartonagnick/example_gtest                  [deploy/stash][git-commits.bat]
'[2025-12-07][22:10:00] 006 Kartonagnick PRE
'  --- local/stash                                             [git-commits.bat]
'  [2025-07-29][02:30:19] 006 Kartonagnick
'  [2023-05-24][15:48:15] 005 Kartonagnick
'  [2023-03-17][04:00:00] 004 Kartonagnick
'  [2023-02-11][10:00:00] 003 Kartonagnick
'    --- old redaction                                         [git-commits.bat]
'    [2022-10-09][03:17:20] 002 Kartonagnick
'    [2021-02-03][19:00:00] 001 Kartonagnick

'===============================================================================

' функция sortFiles содержит баг
'
' служит для автоматической фиксации изменений в репозитории.  
'
'   1. `eDEBUG`: вкл отладочный вывод.  
'
'   2. `eDIR_WORK`: задает рабочий каталог.  
'       - по умолчанию: значение текущего такалога (%CD%)  
'
'   3. `eDIR_COMMIT[n]`: каталог, файлы которого 
'       нужно фиксировать в одном коммите.
'
'   4. `eTXT_EXTENSION`: список известных текстовых файлов
'       - по умолчанию: `cpp;h pp; h; md; bat; vbs; cmake; c; cxx; hxx; txt`
'
'   5. `eBIN_EXTENSION`: список известных бинарных файлов
'       - по умолчанию: `lib; dll; exe; jpg; png; mp4; avi`

' алгоритм работы:
'   1. запрашивает список untracked файлов
'   2. переводит untracked в состояние staged
'   3. запрашивает статус репозитория
'   4. исполняет commit для всех staged-файлов:
'   4.1. исполняет commit для всех renamed-файлов
'   4.2. исполняет commit для всех removed-файлов
'   4.3. исполняет commit для всех changed-файлов
'
'   5. коммит может фиксировать одиночный файл или множество.
'   5.1. для одиночного файла:
'     - комментарий - относительный путь к файлу.
'     - для версионированных файлов указывается версия.
'   5.2. для множества файлов:
'     - "множество" - файлыв одного каталога.
'     - комментарий - относительный путь к родительскому каталогу, 
'       за которым следуют три точки.
'   6. настройка для множества файлов:
'      - список каталогов, все файлы которых 
'        нужно фиксировать одним коммитом    
'      - например: `new/boost` означает что все файлы данного каталога
'        необходимо коммитеть с комментарием `fix: new/boost ...`
'   7. все файлы, которые не попадают под правило множества файлов,
'      считаются одиночными (один коммит - один файл)

' тэги коммита одиночного файла:
'  - `add` добавлен новый файл.    `add: repo/file.ext (001) PRE`
'  - `upd` версия файла обновлена. `upd: repo/file.ext (002) PRE` 
'  - `ren` файл переименован:      `ren: foo.ext -> repo/bar.ext (001) PRE`
'  - `mov` файл переимещен:        `mov: bar.ext -> repo/new/foo.ext (002) PRE`
'  - `del` файл удален             `del: repo/foo.ext (002) PRE`
'  - `fix` версия не изменилась.   `fix: repo/baz.ext (001) PRE`
'  - `chg` версия не изменилась.   `chg: repo/baz.ext (001) PRE`
'  - `bug` исправление бага        `bug: repo/baz.ext (002) PRE`
'
' 1. в коммитах фигурируют пути относительно корня репозитория.
'
' 2. для `ren` и `mov` указываем имя исходного файла,
'    и относительный путь назначения
'
' 3. для множества файлов используются точно такие же тэги
'    только после относительного пути добавляется троеточие:
'    например: `add: repo/gtest... (001) PRE`

'===============================================================================

set g_list    = CreateObject("System.Collections.ArrayList")
set g_regexp  = CreateObject("VBScript.RegExp")
set g_fso     = CreateObject("Scripting.FileSystemObject")
set g_shell   = CreateObject("WScript.Shell")
set g_env     = g_shell.Environment("PROCESS")

dim g_bin_extensions
dim g_txt_extensions
dim g_dirs_commit
dim g_excludes

errorNotFound = vbObjectError + 14

'===============================================================================
'===============================================================================

function main()
  deep = 0
  echo deep, "main(git-commits): begin... v0.0.4"

  initMaskLibrary

  initExtensions g_bin_extensions, "eBIN_EXTENSION", _
    "lib; dll; exe; jpg; png; mp4; avi; graphml"

  initExtensions g_txt_extensions, "eTXT_EXTENSION", _
    "cpp; hpp; h; md; bat; vbs; cmake; c; cxx; hxx; txt; yml"

  initExcludes g_excludes, "eFILE_EXCLUDES", _
    "shell.c; sqlite3.c"

  dbg deep + 1, "bin: " & join(g_bin_extensions, "; ")
  dbg deep + 1, "txt: " & join(g_txt_extensions, "; ")
  dbg deep + 1, "exc: " & join(g_excludes, "; ")

  set g_excludes = masksToRegexp(g_excludes)

  set g_dirs_commit = initDirCommit()
  for each el in g_dirs_commit
    dbg deep + 1, "commit all directory: " & el
  next 
  gitInit deep + 1

  d_work = fromEnvironment("eDIR_REPO", "")

  if d_work = Empty or InStr(d_work, "[auto detect]") Then 
    d_work = g_shell.CurrentDirectory
    set cur = g_fso.GetFolder(d_work)
    repo = g_fso.GetAbsolutePathName(cur.Path & "\..\..\" & cur.Name)
    if g_fso.FolderExists(repo) then
      dbg deep + 1, "repo by stash: " & repo
      d_work = repo
    end if
  end if

  g_shell.CurrentDirectory = d_work
  d_work = gitTopLevel()
  d_work = g_fso.GetAbsolutePathName(d_work)
  dbg deep + 1, "work in: " & d_work
  dbg deep + 1, ""

  commitUntracked deep + 1

  set map = CreateObject("Scripting.Dictionary")
  set changes = getGitChanges(deep + 1)
  for each e in changes
    if e.unstaged then
      'echo deep + 1, "[" & e.command & "] " & e.f_path
      if not map.exists(e.command) then
        map.add e.command, CreateObject("System.Collections.ArrayList")
      end if
      map(e.command).add e.f_path
    end if
  next

  for each k in map
    for each f in map(k)
      'echo deep + 1, "process: [" & k & "] " & f

      comment = "err: "

      if k = " D" then
        comment = "del: " & f
      elseif k = " M" then
        ver_info = ""
        
        set v = getVersion(deep + 1, f)
        if v.version <> empty then
          ver_info = " (" & v.version & ")"
          if v.tag <> empty then
            ver_info = ver_info & " " & v.tag
          end if
        end if
        if v.tag = empty and not v.bin then
          comment = "fix: " & f & ver_info
        else
          comment = "upd: " & f & ver_info
        end if
      else
        echo deep, "[WARNING] [" & k & "] " & f
        echo deep, "[WARNING] operation '" & k & "' not support" 
      end if

      gitStage deep + 2, f    
      echo deep + 1, comment
      gitCommit deep + 2, comment
    next
  next

  echo deep, "main(git-commits): done"
end function 

'===============================================================================
'===============================================================================

Function recodeText(strText)
  With CreateObject("ADODB.Stream")
    .Type = 2
    .Mode = 3
    .Charset = "windows-1251"
    .Open
    .WriteText (strText)
    .Position = 0
    .Charset = "utf-8"
    recodeText = .ReadText
    .Close
  end with
end function

'===============================================================================
'===============================================================================

function initDirCommit()
  set result = runCmd("set eDIR_COMMIT[")
  if result.code <> 0 then
    call err.Raise(errorNotFound, "initDirCommit", "command: 'set' was failed")
  end if
  set arr = result.lines
  for i = 0 to arr.count - 1
    arr(i) = mid(arr(i), 15 + len(i))
  next
  set initDirCommit = arr
end function

sub initExtensions(dst, name, def)
  dst = fromEnvironment(name, def)
  dst = split(dst, ";")
  for i = 1 to ubound(dst)
    dst(i) = trim(dst(i))
  next
end sub

sub initExcludes(dst, name, def)
  dst = fromEnvironment(name, def)
  dst = split(dst, ";")
  for i = 1 to ubound(dst)
    dst(i) = trim(dst(i))
  next
end sub

sub gitInit(deep)
  dbg deep, "find git.exe..."
  path = g_env.item("PATH")
  add1 = "C:\Program Files\Git\bin"
  add2 = "C:\Program Files\SmartGit\git\bin"
  g_env("PATH") = add1 & ";" & add2 & ";" & path
  set result = runCmd("where git.exe")
  if result.code <> 0 then
    call err.Raise(errorNotFound, "initGit", "git.exe not found")
  end if
  dbg deep + 1, "found: " & result.lines(0)
end sub

function getFromMap(key, map)
  if not isObject(map(key)) then
    map(key) = CreateObject("System.Collections.ArrayList")
  end if
  getFromMap = map(key)
end function

function isIgnored(f_path)
  isIgnored = false
  if f_path = "log.txt" then
    isIgnored = true
  elseif f_path = "cmdlog.txt" then
    isIgnored = true
  end if
end function

sub commitUntracked(deep)
  dbg deep, "commitUntracked: begin"

  set f_list = getUntrackedList(deep + 1)
  if f_list.count = 0 then
    dbg deep + 1, "[Untracked] not found"
    dbg deep, "commitUntracked: done!"
    exit sub
  end if

  set map = getMapOfSort()
  set alone = CreateObject("System.Collections.ArrayList")
  sortFiles deep, map, alone, f_list

  set map = applyMapFiles(deep, map, f_list)
  for each d in map
    set f_list = map(d)
    if f_list.count > 0 then 
      comment = "add: " & d & " ..."
      echo deep + 1, comment
      for each f in f_list
        dbg deep + 2, "stage: " & f
        gitStage deep + 2, f
      next
      gitCommit deep + 2, comment
   end if
  next

  for each f in alone
    if isIgnored(f) then
      echo deep + 2, "ignore: " & f
    else
      ver_info = ""
      set v = getVersion(deep + 1, f)
      if v.version <> empty then
        ver_info = " (" & v.version & ")"
        if v.tag <> empty then
          ver_info = ver_info & " " & v.tag
        end if
      end if
      comment = "add: " & f & ver_info
      echo deep + 1, comment
      gitStage  deep + 2, f    
      gitCommit deep + 2, comment
    end if
  next

  dbg deep, "commitUntracked: done!"
end sub

function getUntrackedList(deep)
  dbg deep, "getUntrackedList: begin"
  set result = runCmd("git ls-files --others --exclude-standard")
  if result.code <> 0 then
    call err.Raise(errorNotFound, "getUntrackedList", result.stderr)
  end if
  set f_list = CreateObject("System.Collections.ArrayList")
  for each f in result.lines
    f = trim(f)
    if f <> empty then f_list.add recodeText(f)
  next
  set getUntrackedList = f_list
  dbg deep, "getUntrackedList: done!"
end function

function getMapOfSort()
  set map = CreateObject("Scripting.Dictionary")
  for each d in g_dirs_commit
    map.add d, CreateObject("System.Collections.ArrayList")
  next
  set getMapOfSort = map
end function

sub sortFiles(deep, map, alone, f_list)
  for each f in f_list
    f = replace(f, "\", "/")
    lenF = len(f): pos = 0
    for each d in map
      d = replace(d, "\", "/")
      pos = Instr(1, f, d, 0)
      if pos = 1 then
        lenD = len(d)
        back = mid(f, pos + lenD, 1)
        if back = "/" then
          echo deep + 1, "[Untracked][" & d & "] " & f & " -> back = " & back
          map(d).add f
          exit for
        else
          echo deep + 1, "[Untracked][" & d & "] " & f & " -> skip"
          pos = 0
        end if
      elseif pos > 0 then
        lenD = len(d)
        front = mid(f, pos - 1, 1)
        if front = "/" then
          back = mid(f, pos + lenD, 1)
          if back = "/" or back = "" then
            echo deep + 1, "[Untracked][" & d & "] " & f & " -> back = " & back
            map(d).add f
            exit for
          else
            echo deep + 1, "[Untracked][" & d & "] " & f & " -> skip 2"
            pos = 0
          end if
        else
          echo deep + 1, "[Untracked][" & d & "] " & f & " -> skip 1"
          pos = 0
        end if
      end if
    next
    if pos = 0 then
      echo deep + 1, "[Untracked][..alone..] " & f
      alone.add f
    end if
  next
end sub

function applyMapFiles(deep, map, f_list)
  set map_relative = CreateObject("Scripting.Dictionary")
  for each d in map
    set f_list = map(d)
    for each f in f_list
      pos = inStr(1, f, d, 0)
      key = left(f, pos + len(d) - 1)
      if not map_relative.Exists(key) then
        'dbg deep + 1, "[" & key & "] ..."
        map_relative.add key, CreateObject("System.Collections.ArrayList")
      end if
      'dbg deep + 2, "add: " & f 
      map_relative(key).add f
    next
  next
  set applyMapFiles = map_relative
end function

function gitCommit(deep, comment)
  param = Chr(34) & comment & Chr(34)
  set result = runCmd("git commit -m " & param)
  if result.code <> 0 then
    echo deep, "[ERROR] " & result.stderr
  end if
  set gitCommit = result
end function

function gitStageAll()
  set result = runCmd("git add .")
  if result.code <> 0 then
    echo deep, "[ERROR] " & result.stderr
  end if
  set gitStageAll = result
end function

function gitStage(deep, f_path)
  param = Chr(34) & f_path & Chr(34)
  set result = runCmd("git add " & param)
  if result.code <> 0 then
    echo deep, "[ERROR] " & result.stderr
  end if
  set gitStage = result
end function

function gitStatus(deep, f_path)
  param = Chr(34) & f_path & Chr(34)
  set result = runCmd("git status --short " & param)
  if result.code <> 0 then
    echo deep, "[ERROR] " & result.stderr
  end if
  gitStatus = result.lines(0)
end function

function gitTopLevel()
  set result = runCmd("git rev-parse --show-toplevel")
  if result.code <> 0 then
    echo deep, "[ERROR] " & result.stderr
  end if
  gitTopLevel = result.lines(0)
end function

'===============================================================================
'===============================================================================

class VerTokens
  public date
  public time
  public version
  public author
  public tag
  public bin
end class

function parseVersionMD(line)
  p = "!\[(.*)\]\].*\s*v?(\d{1,3})\.(\d{1,3})\.(\d{1,3})"
  g_regexp.Pattern = p
  g_regexp.Global = false
  set ret = new VerTokens
  set matches = g_regexp.Execute(line)
  if matches.Count > 0 then
    set objMatch      = matches.Item(0)      
    set objSubmatches = objMatch.Submatches
    tag = objSubmatches.Item(0)
    major = objSubmatches.Item(1)
    minor = objSubmatches.Item(2)
    patch = objSubmatches.Item(3)
    if UCase(tag) = "P" then ret.tag = "PRE"
    ret.version = major & minor & patch
  end if
  set parseVersionMD = ret
end function


function parseVersionMacro(deep, src)
  set re = new VerTokens
  p = "(\d{4}y?-\d{2}m?-\d{2}d?)\s+(\d{2}:\d{2}:\d{2})\s+(\w+)\s+(\d+)\s+(.*)"
  g_regexp.Global = false
  g_regexp.Pattern = p
  set matches = g_regexp.Execute(src)
  if matches.Count > 0 then
    set objMatch      = matches.Item(0)      
    set objSubmatches = objMatch.Submatches
    re.date = objSubmatches.Item(0)
    re.time = objSubmatches.Item(1)
    re.version = objSubmatches.Item(3)
    re.author = "Kartonagnick"
    tail = objSubmatches.Item(4)

    g_regexp.Pattern = "(.*)\+"
    set matches = g_regexp.Execute(tail)
    if matches.Count > 0 then
      set objMatch      = matches.Item(0)      
      set objSubmatches = objMatch.Submatches
      text = objSubmatches.Item(0)
      text = trim(text)
      re.author = trim(text)
      echo deep, "parse: " & text

      g_regexp.Pattern = "^(.*)\s+(\w+)\s*$"
      set matches = g_regexp.Execute(text)
      if matches.Count > 0 then
        set objMatch      = matches.Item(0)      
        set objSubmatches = objMatch.Submatches
        re.author = trim(objSubmatches.Item(0))
        re.tag = objSubmatches.Item(1)
      else
        t =  LCase(re.author)
        if t = "pre" or t = "rel" or t = "bug" or t = "doc" or t = "tst"  or t = "ver" then
          re.tag = re.author
          re.author = "Kartonagnick"
        end if
      end if
    else 
      echo deep, "[ERROR]: invalid tail: " & tail
    end if
  end if

  if gDEBUG and re.version <> empty then
    echo deep, "parseVersion: " & line
    echo deep + 1, "date: "    & re.date
    echo deep + 1, "time: "    & re.time
    echo deep + 1, "version: " & re.version
    echo deep + 1, "author: "  & re.author
    echo deep + 1, "tag: "     & re.tag
  end if
  set parseVersionMacro = re
end function

function parseVersion(deep, src) 
  set re = new VerTokens
  p = "\[(\d{4}y?-\d{2}m?-\d{2}d?)\]\s*\[(\d{2}:\d{2}:\d{2})\]\s+(\d+)\s+(.*)"

  line = Replace(src, "<!--", "", 1, 1)
  line = Replace(line, "-->", "", 1, 1)

  g_regexp.Global = false
  g_regexp.Pattern = prefix & p & postfix
  set matches = g_regexp.Execute(line)
  if matches.Count > 0 then
    set objMatch      = matches.Item(0)      
    set objSubmatches = objMatch.Submatches
    re.date = objSubmatches.Item(0)
    re.time = objSubmatches.Item(1)
    re.version = objSubmatches.Item(2)

    tail = objSubmatches.Item(3)

    g_regexp.Pattern = "^(.*)\s+(\w+)\s*$"
    set matches = g_regexp.Execute(tail)
    if matches.Count > 0 then
      set objMatch      = matches.Item(0)      
      set objSubmatches = objMatch.Submatches
      re.author = objSubmatches.Item(0)
      re.tag    = objSubmatches.Item(1)
      re.author = trim(re.author)
    else
      re.author = trim(tail)
    end if
  end if

  if gDEBUG and re.version <> empty then
    echo deep, "parseVersion: " & line
    echo deep + 1, "date: "    & re.date
    echo deep + 1, "time: "    & re.time
    echo deep + 1, "version: " & re.version
    echo deep + 1, "author: "  & re.author
    echo deep + 1, "tag: "     & re.tag
  end if
  set parseVersion = re
end function


function getVersion(deep, objFile)
  set getVersion = new VerTokens
  if not g_fso.FileExists(objFile) then
    exit function
  end if
  ext = g_fso.GetExtensionName(objFile)
  if ext = "md" then
    set getVersion = getVersionMD(deep, objFile)
    exit function
  end if
  'dbg deep, "getVersion: begin (" & objFile & ")"
  
  if excludeThisFile(objFile) then
    dbg deep + 1 , "[excluded] " & objFile 
    exit function
  end if
  
  if IsBinaryHeuristic(objFile) then
    dbg deep + 1 , "[skip binary] " & objFile 
    getVersion.bin = true
    exit function
  end if

  set txtFile = g_fso.OpenTextFile(objFile, 1, false)
  do while not txtFile.AtEndOfStream
    line = txtFile.Readline
    if Instr(1, line, "//+", 1) = 1 then 
      set getVersion = parseVersionMacro(deep + 1, line)     
    else
      set getVersion = parseVersion(deep + 1, line)     
    end if
    if getVersion.version <> empty then
      exit function
    end if
  loop
end function

function getVersionMD(deep, objFile)
  set txtFile = g_fso.OpenTextFile(objFile, 1, false)
  do while not txtFile.AtEndOfStream
    line = txtFile.Readline
    
    set getVersionMD = parseVersion(deep + 1, line)
    if getVersionMD.version <> empty then
      exit function
    end if

    set getVersionMD = parseVersionMD(line)
    if getVersionMD.version <> empty then
      exit function
    end if
  loop
  set getVersionMD = new VerTokens
end function

'===============================================================================
'===============================================================================

class Change
  public command
  public unstaged
  public f_path
end class

function getGitChanges(deep)
  dbg deep, "getGitChanges: begin"
  set result = runCmd("git.exe status --short")
  if result.code <> 0 then
    call err.Raise(errorNotFound, "getGitChanges", result.stderr)
  end if
  set list_changes = CreateObject("System.Collections.ArrayList")
  for each line in result.lines
    check = trim(line)
    if check <> empty then
      applyLine deep + 1, line, list_changes
    end if
  next
  set getGitChanges = list_changes
  dbg deep, "getGitChanges: done!"
end function

sub applyLine(deep, line, dst)
  ' echo deep, "line: " & line
  if len(line) < 4 then
    echo deep, "[ERROR] too small: '" & line & "'"
    exit sub
  end if
  set v = new Change
  v.command = left(line, 2)
  v.f_path = mid(line, 4)
  if Left(v.command, 1) = " " then
    v.unstaged = true
  else
    v.unstaged = fakse
  end if
  dst.add v
  'echo deep, "[" & v.command & "] " & v.f_path
end sub

'===============================================================================
'===============================================================================

function fromEnvironment(name, def)
  fromEnvironment = g_env.Item(name)
  if fromEnvironment = empty then 
    fromEnvironment = def
  end if
end function

function indent(deep)
  indent = Space(deep * 2)
end function

sub echo(deep, msg)
  WScript.Echo indent(deep) & msg
end sub

dim gDEBUG: gDEBUG = false
sub initDebug()
  if g_env.Item("eDEBUG") = "ON" then
    gDEBUG = true
  end if
end sub
initDebug()

sub dbg(deep, v)
  if not gDEBUG then exit sub
  echo deep, v
end sub 

'===============================================================================
'===============================================================================

class Executed
  public lines
  public stdout
  public stderr
  public code
end class

'return: object of 'Executed'
'example: command = "ping.exe 127.0.0.1 -n 1 -w 500"
function runCmd(command)
  Const running = 0
  launch = "cmd.exe /c" & Chr(34) & command & Chr(34)
  set exec = g_shell.Exec(launch)
  set ret = new Executed
  set ret.lines = CreateObject("System.Collections.ArrayList")
  while exec.Status = running
    do
      ret.lines.add exec.StdOut.ReadLine()
    loop while not exec.Stdout.atEndOfStream
    'WScript.Sleep 10
  wend
  'ret.stdout = exec.StdOut.ReadAll
  ret.stderr = exec.StdErr.ReadAll
  ret.code   = exec.ExitCode
  set runCmd = ret
end function

'===============================================================================
'===============================================================================

function contain(v, list)
  for each e in list
    if v = e then 
      contain = true
      exit function
    end if
  next
  contain = false
end function

'===============================================================================
'===============================================================================

function IsBinary(f_path)
  set reader = g_fso.OpenTextFile(f_path, 1)
  do while not reader.AtEndOfStream
    line  = reader.Readline
    count = len(line)
    for i = 1 to count
      s = Mid(line, i, 1)
      if Asc(s) = 0 then 
        IsBinary = true
        exit function
      end if
    next
  loop
  reader.Close
  IsBinary = false 
end function

function IsBinaryHeuristic(f_path)
  ext = g_fso.GetExtensionName(f_path)
  arr_txt = array("cpp","hpp", "h", "md", "bat", "vbs", "cmake", "c", "cxx", "hxx")
  arr_bin = array("lib", "dll", "exe", "jpg", "png", "mp4", "avi", "graphml")

  if contain(ext, arr_txt) then
    IsBinaryHeuristic = false
  elseif contain(ext, arr_bin) then
    IsBinaryHeuristic = true
  elseif isBinary(f_path) then
    IsBinaryHeuristic = true
  else
    IsBinaryHeuristic = false
  end if
end function

function excludeThisFile(f_path)
  excludeThisFile = true
  set objF = g_fso.GetFile(f_path)
  for each rx in g_excludes
    if matchByRegexp(objF.Name, rx) then
      exit function
    end if
  next 
  excludeThisFile = false
end function

'===============================================================================
'===============================================================================

dim gMASK_LIB_INITIALISED
dim gMASK_CONVERTOR
dim gVERSION_REGEXP
dim gMASK_REGEXP

sub initMaskLibrary()
  if gMASK_LIB_INITIALISED then exit sub

  set gMASK_CONVERTOR     = new RegExp
  gMASK_CONVERTOR.Pattern = "([\(\)\{\}\[\]\|\\\/\.\^\$])"
  gMASK_CONVERTOR.Global  = true

  set gMASK_REGEXP   = new RegExp
  gMASK_REGEXP.Global      = true
  gMASK_REGEXP.IgnoreCase  = true

  set gVERSION_REGEXP = new RegExp
  gVERSION_REGEXP.Pattern = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\b"
  gVERSION_REGEXP.IgnoreCase  = true
  gVERSION_REGEXP.Global = true

  gMASK_LIB_INITIALISED  = true
end sub

'===============================================================================
'===============================================================================

function maskUnexpected_(mask)
  if typeName(mask) = "Folder" then
    exitByAssertMask_ "maskUnexpected", "unexpected <Folder>", mask.Path
  elseif typeName(mask) = "File" then
    exitByAssertMask_ "maskUnexpected", "unexpected <File>", mask.Path
  end if
  maskUnexpected_ = false
end function

'...............................................................................

' escaping service characters: ( ) { } [ ] | \ / . ^ \ $
' * -> .*
' ? -> .
' add ^ to the beginning: ^mask
' add an $ to the end: mask$
' example: "*.*" -> "^.*\..*$"

function maskToRegexp(mask)
  if mask = Empty then 
    maskToRegexp = ""
  elseif maskUnexpected_(mask) then
    ' nothing
  else
    dim tmp
    tmp = gMASK_CONVERTOR.Replace(mask, "\$1")
    tmp = Replace(tmp, "*", ".*")
    tmp = Replace(tmp, "?", ".")
    maskToRegexp = "^" + tmp + "$"
  end if
end function

'===============================================================================
'===============================================================================

' mask - string, array or System.Collections.ArrayList
' return System.Collections.ArrayList
function masksToRegexp(masks)
  dim collect
  set collect = CreateObject("System.Collections.ArrayList")
  if IsNull(masks) then
    set masksToRegexp = collect
  elseif vartype(masks) = vbEmpty then
    set masksToRegexp = collect
  elseif maskUnexpected_(masks) then
    ' nothing
  elseif vartype(masks) = vbString then
    if masks = Empty then 
      set masksToRegexp = collect
    else
      set masksToRegexp = masksToRegexp(split(masks, ";")) 
    end if
  else
    dim mask
    for each mask in masks
      if maskUnexpected_(mask) then
        ' nothing
      end if
      mask = trim(mask)
      if mask <> Empty then
        collect.Add(maskToRegexp(mask))
      end if
    next  
    set masksToRegexp = collect
  end if
end function

'===============================================================================
'===============================================================================

' IgnoreCase
' Empty VS Value -> check
' Empty VS Once --> false
' Empty VS Empty -> true
' Empty VS Any ---> true
' Value VS Any ---> true
' Value VS Empty -> true
' Value VS Once --> check
' Value VS Value -> check
function matchByRegexp(text, regex)
  if typeName(text) = "File" then
    matchByRegexp = matchByRegexp(text.Name, regex)
  elseif typeName(text) = "Folder" then
    matchByRegexp = matchByRegexp(text.Name, regex)
  else
    gMASK_REGEXP.Pattern = regex
    if gMASK_REGEXP.Test(text) then
      matchByRegexp = true
    else
      matchByRegexp = false
    end if
  end if
end function

'===============================================================================
'===============================================================================
'===============================================================================
'===============================================================================

'On Error Resume Next
Err.Clear

main()
if Err.Number <> 0 Then
  desc = errorString(Err.Number)
  code = Err.Number - vbObjectError
  WScript.Echo "main(err): " & Err.Source
  WScript.Echo "main(err): " & Err.Description
  WScript.Echo "main(err): " & desc & "(" & code & ")"
  WScript.Quit code
end if

'===============================================================================
'===============================================================================
'===============================================================================
'===============================================================================
