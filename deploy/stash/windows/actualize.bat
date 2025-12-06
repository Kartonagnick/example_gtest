::'@echo off & call :'checkParent || exit /b 1
::'set "eDIRS_EXCLUDE=.git; todo; mt5; sqlite3; factory"
::'cscript //nologo //e:vbscript "%~f0" %*
::'exit /b

'===============================================================================

'--- Kartonagnick/example_gtest                    [deploy/stash][actualize.bat]
'[2025-12-07][22:10:00] 005 Kartonagnick PRE
'  --- D:\Dropbox\stashes\00-direct                              [actualize.bat]
'  [2025-06-26][14:18:44] 005 Kartonagnick
'    --- local/stash                                             [actualize.bat]
'    [2023-03-07][13:10:00] 004 Kartonagnick
'    [2023-02-11][10:00:00] 003 Kartonagnick
'      --- old redaction                                         [actualize.bat]
'      [2022-06-30][16:22:27] 002 Kartonagnick
'        actualize versions

'===============================================================================

'set "eDEBUG=ON"                    on/off debug`s output
'set "eSILENCE=OFF"                 on/off mode of silence
'set "gDIR_SOURCE=C:\work"          path to directory
'set "gEXTENSIONS=bat;md"           list of processing extensions
'set "gDIRS_EXCLUDE=.git"           list of excludes

'===============================================================================
'===============================================================================

set g_list    = CreateObject("System.Collections.ArrayList")
set g_regexp  = CreateObject("VBScript.RegExp")
set g_fso     = CreateObject("Scripting.FileSystemObject")
set g_shell   = CreateObject("WScript.Shell")
set g_env     = g_shell.Environment("PROCESS")

g_regexp.Global = false

errorNotFound = vbObjectError + 14

dim gEXTENSIONS
dim gDIRS_EXCLUDE
dim gDIR_SOURCE

'===============================================================================
'===============================================================================

function main()
  deep = 0
  echo deep, "main: begin... v0.0.4"
  globInit  deep + 1
  if gDIR_SOURCE <> Empty then
    dbg deep + 1, "dir: " & gDIR_SOURCE
    set d = g_fso.GetFolder(gDIR_SOURCE)
    call dirTree(deep + 1, d) 
  else
    dbg deep + 1, "dir: not found"
  end if
  echo deep, "main: done"
end function 

'===============================================================================
'===============================================================================

sub globInit(deep)
  gDIR_SOURCE = fromEnvironment("eDIR_SOURCE", "")
  if gDIR_SOURCE = Empty then
    gDIR_SOURCE = g_shell.CurrentDirectory
    set d_ = g_fso.GetFolder(gDIR_SOURCE)
    repo = g_fso.GetAbsolutePathName(d_.Path & "\..\..\" & d_.Name)
    if g_fso.FolderExists(repo) then
      dbg deep, "repo by stash: " & repo
      gDIR_SOURCE = repo
    end if
    gDIR_SOURCE = findRoot(deep + 1, gDIR_SOURCE, ".git")
  end if

  exts = "cpp; hpp; h; md; bat; vbs; ver; cmake; wsf; c; cxx; hxx; txt; root; yml; gitignore"
  gEXTENSIONS = fromEnvironment("eEXTENSIONS", exts)

  dbg deep, "extensions: " & gEXTENSIONS
  dbg deep, " --"

  arr = split(gEXTENSIONS, ";")
  set gEXTENSIONS = CreateObject("System.Collections.ArrayList")
  for each el in arr
    gEXTENSIONS.add trim(el)
  next

  gDIRS_EXCLUDE = fromEnvironment("eDIRS_EXCLUDE", ".git")
  dbg deep, "exclude: " & gDIRS_EXCLUDE
  dbg deep, " --"

  arr = split(gDIRS_EXCLUDE, ";")
  set gDIRS_EXCLUDE = CreateObject("System.Collections.ArrayList")
  for each el in arr
    gDIRS_EXCLUDE.add trim(el)
  next
end sub

'===============================================================================
'===============================================================================

sub dirTree(deep, objDir)
  dbg deep, "dir(" & objDir.Files.count & "/" & objDir.SubFolders.count & "): " & objDir 

  set f_list = CreateObject("System.Collections.ArrayList")
  for each f in objDir.Files
    f_list.add f.Path
  next
  f_list.sort

  for each f in f_list
    set f = g_fso.GetFile(f)
    ext = g_fso.GetExtensionName(f)

    if contain(ext, gEXTENSIONS) then
      call fileProcess(deep + 1, f)
    else
      'dbg deep + 1, "[f] " & f.name & " -> skip"
    end if
  next

  for each d in objDir.SubFolders
    if contain(d.name, gDIRS_EXCLUDE) then
      'dbg deep + 1, "[d] " & d.name & " -> skip"
    else
      call dirTree(deep + 1, d)
    end if
  next
end sub

'...............................................................................

sub view(deep, text)
  if gDEBUG then
    echo deep, "------------------------------------------------------------ detect: " & text
  else
    echo 1, text
  end if
end sub

sub saveContent(deep, dst, content)
  set dstFile = g_fso.OpenTextFile(dst, 2, true)
  for each line in content
    dstFile.write(line) & vbCrLf
  next
end sub

function loadContent(deep, src, changed)
  changed = false
  set content = CreateObject("System.Collections.ArrayList")
  set input = g_fso.OpenTextFile(src, 1, false)

  set quotation  = CreateObject("VBScript.RegExp")
  quotation.Global = false
        '                1     2     3
  quotation.Pattern = "(.*)(\sPRE"")(.*)"

  set his  = CreateObject("VBScript.RegExp")
  his.Global = false
        '          1   2    3   4    5    6    7
  his.Pattern = "(\s+)(\()(\d*)(\))(\s+)(PRE)(\s*)"

  set pre  = CreateObject("VBScript.RegExp")
  pre.Global = false
  pre.Pattern = "(.*)\b(PRE)\b(.*)"

  set tag  = CreateObject("VBScript.RegExp")
  tag.Global = false
  tag.Pattern = "(\[!\[)(P)(\]\])"

  do while not input.AtEndOfStream
    line = input.Readline

    if quotation.Test(line) then
      changed = true
      view deep, src
      dbg deep, "1) from: " & line
      line = quotation.Replace(line, "$1""$3")
      dbg deep, "1)  to : " & line
    elseif his.Test(line) then
      changed = true
      view deep, src
      dbg deep, "2) from: " & line
      line = his.Replace(line, "$1 $3  ")
      dbg deep, "2)  to : " & line
    elseif pre.Test(line) then
      changed = true
      view deep, src
      dbg deep, "3) from: " & line
      line = pre.Replace(line, "$1   $3")
      dbg deep, "3)  to : " & line
    elseif tag.Test(line) then
      changed = true
      view deep, src
      dbg deep, "4) from: " & line
      line = tag.Replace(line, "$1S$3")
      dbg deep, "4)  to : " & line
    end if
    content.add line
  loop

  set loadContent = content
end function

sub fileProcess(deep, objFile)
  changed = false
  set content = loadContent(deep, objFile, changed)
  if changed then 
    saveContent deep, objFile, content
  end if
end sub

'===============================================================================
'===============================================================================

function findRootImpl(deep, oDir, symptom)
  findRootImpl = ""
  if not g_fso.FolderExists(oDir) then exit function
  d = g_fso.BuildPath(oDir, symptom)
  if g_fso.FolderExists(d) then
    findRootImpl = oDir.Path
    exit function
  end if
  if oDir.IsRootFolder then exit function
  findRootImpl = findRootImpl(deep + 1, oDir.ParentFolder, symptom)
end function

function findRoot(deep, d_start, symptom)
  if typename(d_start) <> "Folder" then
    findRoot = findRootImpl(deep, g_fso.GetFolder(d_start), symptom)  
  else
    findRoot = findRootImpl(deep, d_start, symptom)  
  end if
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

function isBinary(f_path)
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

function isBinaryHeuristic(f_path)
  ext = g_fso.GetExtensionName(f_path)
  arr_txt = array("cpp", "hpp", "h"  , "md" , "bat", "vbs", "cmake", "c", "cxx", "hxx", "root", "yml", "gitignore")
  arr_bin = array("lib", "dll", "exe", "jpg", "png", "mp4", "avi")

  if contain(ext, arr_txt) then
    isBinaryHeuristic = false
  elseif contain(ext, arr_bin) then
    isBinaryHeuristic = true
  elseif isBinary(f_path) then
    isBinaryHeuristic = true
  else
    isBinaryHeuristic = false
  end if
end function

'===============================================================================
'===============================================================================

function fromEnvironment(name, def)
  fromEnvironment = g_env.Item(name)
  if fromEnvironment = empty then 
    fromEnvironment = def
  elseif fromEnvironment = "ON" then
    fromEnvironment = true
  elseif fromEnvironment = "OFF" then
    fromEnvironment = false
  end if
end function

function fromEnvironmentArray(arr_name)
  set result = runCmd("set " & arr_name & "[")
  if result.code <> 0 then
    set fromEnvironmentArray = CreateObject("System.Collections.ArrayList")
    exit function
  end if
  set arr = result.lines
  for i = 0 to arr.count - 1
    where = arr(i)
    pos = Instr(1, where, "=")
    if pos = 0 then
      echo deep, "[ERROR] symbol: '=' not found"
      continue
    end if
    if len(where) <= pos then
      echo deep, "[ERROR] assert(len(where) > pos)"
      continue
    end if
    arr(i) = Right(where, len(where) - pos)
  next
  set fromEnvironmentArray = arr
end function

'===============================================================================
'===============================================================================

dim gDEBUG:   gDEBUG   = false
dim gSILENCE: gSILENCE = false
dim gINDENT:  gINDENT  = 0

function indent(deep)
  indent = Space(deep * 2) & gINDENT
end function

sub initLogging()
  if g_env.Item("eDEBUG") = "ON" then
    gDEBUG = true
  end if
  if g_env.Item("eSILENCE") = "ON" then
    gSILENCE = true
  end if
  gINDENT = g_env.Item("eINDENT")
  if gINDENT <> Empty then 
    gINDENT = Space(gINDENT * 2)
  end if
end sub

initLogging()

sub output(deep, msg)
  if gSILENCE then
    WScript.Echo msg
  else
    WScript.Echo indent(deep) & msg
  end if
end sub

sub echo(deep, msg)
  if gSILENCE then exit sub
  WScript.Echo indent(deep) & msg
end sub

sub dbg(deep, v)
  if not gDEBUG then exit sub
  echo deep, v
end sub 

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
  echo "main(err): " & Err.Source
  echo "main(err): " & Err.Description
  echo "main(err): " & desc & "(" & code & ")"
  WScript.Quit code
end if

'===============================================================================
'===============================================================================
'===============================================================================
'===============================================================================

:'normalizeD
rem^   set "%~1=%~dpfn2"
::'exit /b

:'setOwnerD
::'   if defined eDIR_OWNER (exit /b)
::'   cls & echo. & echo.
::'   call :'normalizeD eDIR_OWNER "%~dp0."
::' exit /b

:'checkParent
::'   if errorlevel 1 (
::'     echo [ERROR] was broken at launch 
::'     exit /b 1
rem^   )
::'   call :'setOwnerD
::'   if errorlevel 1 (echo [ERROR] initialization)
::'exit /b
