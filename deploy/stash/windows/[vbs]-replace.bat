::'@echo off & cls & echo. 
::'set "eDIR_WORK=auto"
::'set "xDEBUG=ON"
::'set "xAPPEND=ON"
::'set "eDIR_INCLUDES="
::'set "eDIR_EXCLUDES=.git; todo; mt5; sqlite3; icons; boost; _*"
::'set "eFILE_INCLUDES=*.cpp; *.hpp; *.h; *.md; *.bat; *.vbs; *.ver; *.cmake; *.wsf; *.c; *.cxx; *.hxx; *.txt; *.root; *.yml; *.gitignore"
::'set "eFILE_EXCLUDES=_*"
::'set "eOLD=2025-12-08 00:00:00"
::'set "eNEW=2025-12-08 00:00:00"
::'cscript //nologo //e:vbscript "%~f0" %*
::'exit /b

'===============================================================================

'--- Kartonagnick/example_gtest                [deploy/stash][[vbs]-replace.bat]
'[2025-12-07][22:10:00] 003 Kartonagnick PRE
'  --- D:\Dropbox\stashes\00-direct                          [[vbs]-replace.bat]
'  [2024-01-18][16:57:59] 002 Kartonagnick
'  [2023-03-07][13:10:00] 001 Kartonagnick

'===============================================================================

set g_list   = CreateObject("System.Collections.ArrayList")
set g_regexp = CreateObject("VBScript.RegExp")
set g_fso    = CreateObject("Scripting.FileSystemObject")
set g_shell  = CreateObject("WScript.Shell")
set g_env    = g_shell.Environment("PROCESS")
dim g_logg 

errorNotFound  = vbObjectError + 14
errorEmptyData = vbObjectError + 12

'===============================================================================
'===============================================================================

g_total = 0
dim g_dirmasks
dim g_filmasks
dim gDIR_SOURCE
dim gDIR_WORK
dim gOLD
dim gNEW

class StampDT
  public yy
  public mo
  public dd
  public hh
  public mm
  public ss
  public ms
  
  function stamp()
    stamp = yy & "-" & mo & "-" & dd & " " & hh & ":" & mm & ":" & ss
    if ms <> empty then
      stamp = stamp & "." & ms
    end if
  end function

  function taskSignature()
    taskSignature = yy & "-" & mo & "-" & dd & " " & hh & ":" & mm & ":" & ss
  end function

  function taskSignatureShort()
    taskSignatureShort = yy & "-" & mo & "-" & dd & " " & hh & ":" & mm
  end function

  function tableSignature()
    tableSignature = yy & "-" & mo & "-" & dd & " | " & hh & ":" & mm & ":" & ss
  end function

  function tableSignatureShort()
    tableSignatureShort = yy & "-" & mo & "-" & dd & " | " & hh & ":" & mm 
  end function
 
  function labelSignature()
    labelSignature = "[" & yy & "-" & mo & "-" & dd & "][" & hh & ":" & mm & ":" & ss & "]"
  end function

  function labelSignatureShort()
    labelSignatureShort = "[" & yy & "-" & mo & "-" & dd & "][" & hh & ":" & mm & "]"
  end function
  
  function shieldsSignature()
    shieldsSignature = "label=" & yy & "-" & mo & "-" & dd & "&message=" & hh & ":" & mm & ":" & ss
  end function

  function shieldsSignatureShort()
    shieldsSignatureShort = "label=" & yy & "-" & mo & "-" & dd & "&message=" & hh & ":" & mm 
  end function
end class

function parseStampDT(deep, src)
    src = Trim(src)
    g_regexp.Pattern = "(\d{4})-(\d{2})m?-(\d{2}) (\d{2}):(\d{2})(.*)"
    set matches = g_regexp.Execute(src)
    if matches.Count = 0 then
      echo deep, "[ERROR] parse error"
      echo deep, "[ERROR] check: " & src
      call err.Raise(errorNotFound, "parseData", "parse error")
    end if

    set dts = new StampDT
    set objMatch = matches.Item(0)      
    set objSubmatches = objMatch.Submatches
    dts.yy = objSubmatches.Item(0)
    dts.mo = objSubmatches.Item(1)
    dts.dd = objSubmatches.Item(2)
    dts.hh = objSubmatches.Item(3)
    dts.mm = objSubmatches.Item(4)
    
    tail = objSubmatches.Item(5)
    if tail <> empty then
      g_regexp.Pattern = "(\d{2})(\.\d{3})?"
      set matches = g_regexp.Execute(tail)
      if matches.Count = 0 then
        echo deep, "[ERROR] parse error"
        echo deep, "[ERROR] check: " & src
        call err.Raise(errorNotFound, "parseData", "parse error")
      end if
      set objMatch = matches.Item(0)      
      set objSubmatches = objMatch.Submatches
      dts.ss = objSubmatches.Item(0)
      dts.ms = objSubmatches.Item(1)    
      dts.ms = Replace(dts.ms, ".", "")
    end if
    set parseStampDT = dts
end function

sub globInit(deep)
  gDIR_SOURCE = fromEnvironment("eDIR_SOURCE", "")

  if gDIR_SOURCE <> Empty then
      dbg deep, "repo by environment: " & gDIR_SOURCE
      exit sub
  end if

  dbg deep, "gDIR_WORK: " & gDIR_WORK

  set d_ = g_fso.GetFolder(gDIR_WORK)
  repo = g_fso.GetAbsolutePathName(d_.Path & "\..\..\" & d_.Name)
  if g_fso.FolderExists(repo) then
    dbg deep, "repo by stash: " & repo
    gDIR_SOURCE = repo
    exit sub
  end if
  gDIR_SOURCE = findRoot(deep + 1, gDIR_WORK, ".git")
  if gDIR_SOURCE = Empty then
    echo deep + 1, "[ERROR] repo not found"
    echo deep + 1, "[ERROR] check: gDIR_SOURCE"
    echo deep + 1, "[ERROR] gDIR_SOURCE = '" & gDIR_SOURCE & "'"
    call err.Raise(errorNotFound, "main", "repo not found")
  end if
  dbg deep, "repo by '.git': " & gDIR_SOURCE
end sub

sub checkStartup(deep)
  if gOLD = Empty then
    echo deep + 1, "[ERROR] 'OLD' text is empty"
    echo deep + 1, "[ERROR] check: gOLD"
    call err.Raise(errorEmptyData, "main", "must be specified: 'gOLD'")
  end if
 
  set gOLD = parseStampDT(deep, gOLD)
  set gNEW = parseStampDT(deep, gNEW)
end sub

function main()
  deep = 0
  echo deep, "main(replace): begin... v0.0.1"

  fp = WScript.ScriptFullName
  d_cur  = g_fso.GetParentFolderName(fp)
  gDIR_WORK = fromEnvironment("eDIR_WORK", d_cur)
  if gDIR_WORK = "auto" then
    gDIR_WORK = d_cur
  end if

  globInit deep + 1

  d_inc = fromEnvironment("eDIR_INCLUDES" , "")
  d_exc = fromEnvironment("eDIR_EXCLUDES" , "")
  f_inc = fromEnvironment("eFILE_INCLUDES", "")
  f_exc = fromEnvironment("eFILE_EXCLUDES", "")

  gOLD = fromEnvironment("eOLD", "")
  gNEW = fromEnvironment("eNEW", "")
  
  checkStartup deep + 1   

  mode_append = fromEnvironment("eAPPEND", "")

  set g_logg = CreateObject("ADODB.Stream")
  with g_logg
    .Open
    .CharSet = "utf-8"
  end with

  f_logg = gDIR_WORK & "\log.txt"

  if mode_append = "ON" then
    if (g_fso.FileExists(f_logg)) then
      with g_logg
        .LoadFromFile f_logg
        .ReadText
      end with
    end if
  end if

  set g_dirmasks = (new MaskExp)(d_inc, d_exc)
  set g_filmasks = (new MaskExp)(f_inc, f_exc)

  echo deep, "---------------------------------------" & timeStamp() & "---"
  logg deep, "---------------------------------------" & timeStamp() & "---"

  dbg  deep + 1, "dir: " & gDIR_WORK
  dbg  deep + 1, "log: " & f_logg
  outd deep + 1, "dir: " & gDIR_WORK
  outd deep + 1, "log: " & f_logg

  dbg deep + 1, "d-includes: " & d_inc
  dbg deep + 1, "d-excludes: " & d_exc
  dbg deep + 1, "f-includes: " & f_inc
  dbg deep + 1, "f-excludes: " & f_exc
  dbg deep + 1, ""
  
  outd deep + 1, "d-includes: " & d_inc
  outd deep + 1, "d-excludes: " & d_exc
  outd deep + 1, "f-includes: " & f_inc
  outd deep + 1, "f-excludes: " & f_exc
  outd deep + 1, ""
  
  echo deep + 1, "old: " & gOLD.stamp()  
  echo deep + 1, "new: " & gNEW.stamp()  
  
  logg deep + 1, "old: " & gOLD.stamp()  
  logg deep + 1, "new: " & gNEW.stamp()  

  set objDir = g_fso.GetFolder(gDIR_SOURCE)
  call dirTree(deep + 1, objDir)
  echo deep, "total processed: " & g_total & " files"
  logg deep, "total processed: " & g_total & " files"
  echo deep, "main(replace): done"

  logg deep, vbCRLF
  g_logg.SaveToFile gDIR_WORK & "\log.txt", 2
end function 

sub dirTree(deep, objDir)
  echo deep, "dir(" & objDir.Files.count & "/" & objDir.SubFolders.count & "): " & objDir 
  logg deep, "dir(" & objDir.Files.count & "/" & objDir.SubFolders.count & "): " & objDir 

  lenpad = len(objDir.Files.Count)
  set f_list = CreateObject("System.Collections.ArrayList")
  for each f in objDir.Files
    f_list.add f.Path
  next
  f_list.sort

  for each f in f_list
    set f = g_fso.GetFile(f)
    if g_filmasks.match(f) then
      call fileProcess(deep + 1, objDir, f, lenpad)
      idx = idx + 1
    else
      dbg  deep + 1, "[f] " & f.name & " -> skip"
      outd deep + 1, "[f] " & f.name & " -> skip"
    end if
  next
  for each d in objDir.SubFolders
    if g_dirmasks.match(d) then
      call dirTree(deep + 1, d)
    else
      dbg  deep + 1, "[d] " & d.name & " -> skip"
      outd deep + 1, "[d] " & d.name & " -> skip"
    end if
  next
end sub

sub fileProcess(deep, objDir, objfile, lenpad)
  echo deep, "processed: " & objfile
  logg deep, "processed: " & objfile
  
  oldv = gOLD.taskSignature()
  newv = gNEW.taskSignature()
  replaceContent objfile, oldv, newv
  
  oldv = gOLD.tableSignature()
  newv = gNEW.tableSignature()
  replaceContent objfile, oldv, newv
 
  oldv = gOLD.labelSignature()
  newv = gNEW.labelSignature()
  replaceContent objfile, oldv, newv
  
  oldv = gOLD.shieldsSignature()
  newv = gNEW.shieldsSignature()
  replaceContent objfile, oldv, newv

  oldv = gOLD.taskSignatureShort()
  newv = gNEW.taskSignatureShort()
  replaceContent objfile, oldv, newv
  
  oldv = gOLD.tableSignatureShort()
  newv = gNEW.tableSignatureShort()
  replaceContent objfile, oldv, newv
 
  oldv = gOLD.labelSignatureShort()
  newv = gNEW.labelSignatureShort()
  replaceContent objfile, oldv, newv
  
  oldv = gOLD.shieldsSignatureShort()
  newv = gNEW.shieldsSignatureShort()
  replaceContent objfile, oldv, newv

  g_total = g_total + 1
end sub

'===============================================================================
'===============================================================================

sub replaceContent(objfile, oldV, newV)
  set inputFile = g_fso.OpenTextFile(objfile, 1, false)
  content = inputFile.ReadAll
  inputFile.Close
  set inputFile = Nothing

  set outputFile = g_fso.OpenTextFile(objfile, 2, true)
  outputFile.Write Replace(content, oldV, newV)
  outputFile.Close
  set outputFile = Nothing
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

function timeStamp()
    dim t: t = Now
    dim yy: yy = Year(t)
    dim mo: mo = Right("0" & Month(t) , 2)
    dim dd: dd = Right("0" & Day(t)   , 2) 
    dim hh: hh = Right("0" & Hour(t)  , 2)
    dim mm: mm = Right("0" & Minute(t), 2) 
    dim ss: ss = Right("0" & Second(t), 2) 
    timeStamp = "[" & yy & "-" & mo & "m-" & dd & "][" & hh & ":" & mm & ":" & ss & "]"
end function

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

sub logg(deep, msg)
  g_logg.WriteText indent(deep) & msg & vbCRLF
end sub

sub outd(deep, msg)
  if not gDEBUG then exit sub
  g_logg.WriteText indent(deep) & msg & vbCRLF
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

function padding(text, count, symbol)
  assert "padding", "can not be < 0" , count >= 0
  assert "padding", "can not be > 20", count < 20
  len_text = len(text)
  if len_text >= count then
    padding = "" & text
  else
    pd = string(count - len_text, symbol)
    padding = pd & text
  end if  
end function

'===============================================================================
'===============================================================================

sub exitByAssert(from, desc)
  WScript.Echo "[ERROR][ASSERT] " & from & ": " & desc
  WScript.Quit 1
end sub

sub assert(from, desc, v)
  if IsNull(v) then
    exitByAssert from, desc
  elseif isArray(v) then
    exitByAssert "assert", "unexpected <Array: " & UBound(v) + 1 & ">"
  elseif IsObject(v) then
    if v is nothing then
      exitByAssert from, desc
    else
      exitByAssert "assert", "unexpected <Object>"
    end if
  elseif vartype(v) = vbString then
    a = UCase(v)
    if a = "ON" or a = "YES" or a = "TRUE" then 
      'test has been successfully passed
    else
      exitByAssert from, desc
    end if
  elseif v = Empty then
    exitByAssert from, desc
  end if
  'test has been successfully passed
end sub

'===============================================================================
'===============================================================================

' [2021y-08m-08d][19:00:00] 002 Kartonagnick
' [2021y-07m-29d][23:30:00] 001 Kartonagnick
'===============================================================================
'===============================================================================

' requirement:
'   sub exitByAssert(from, desc)
'     includeVBS("util/assert.vbs")
'
' functions:
'   function maskToRegexp(mask)
'   function masksToRegexp(masks)
'   function matchByRegexp(text, regex)
'   function matchByInclude(text, list)
'   function matchByExclude(text, list)
'   function checkByRegexp(text, includes, excludes)

'   function matchByMask(text, mask)
'   function matchByMasks(text, masks)
'   function checkByMasks(text, includes, excludes)
'
'   function versionByRegexp(prefix, line)
'
' classes
'   class MaskExp

'===============================================================================
'===============================================================================

' escaping service characters: ( ) { } [ ] | \ / . ^ \ $
' * -> .*
' ? -> .
' add ^ to the beginning: ^mask
' add an $ to the end: mask$
' example: "*.*" -> "^.*\..*$"

function maskToRegexp(mask)
  if mask = Empty then 
    maskToRegexp = ""
  elseif TypeName(mask) = "Folder" then
    exitByAssert "maskToRegexp", "unexpected <Folder> (" & mask.Path & ")"
  elseif TypeName(mask) = "File" then
    exitByAssert "maskToRegexp", "unexpected <File> (" & mask.Path & ")"
  else
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
  set collect = CreateObject("System.Collections.ArrayList")

  if IsNull(masks) then
    set masksToRegexp = collect
  elseif vartype(masks) = vbEmpty then
    set masksToRegexp = collect
  elseif TypeName(mask) = "Folder" then
    exitByAssert "masksToRegexpList", "unexpected <Folder> (" & mask.Path & ")"
  elseif TypeName(mask) = "File" then
    exitByAssert "masksToRegexpList", "unexpected <File> (" & mask.Path & ")"
  elseif vartype(masks) = vbString then
    if masks = Empty then 
      set masksToRegexp = collect
    else
      set masksToRegexp = masksToRegexp(split(masks, ";")) 
    end if
  else
    for each mask in masks
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
  if TypeName(text) = "File" then
    matchByRegexp = matchByRegexp(text.Name, regex)
  elseif TypeName(text) = "Folder" then
    matchByRegexp = matchByRegexp(text.Name, regex)
  else
    initMaskLibrary()
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

'skip empty regexp
'if all list of regexp are skipped -> true
function matchByInclude(text, list)
  if vartype(list) = vbString then
    if list = Empty then
      matchByInclude = true
    else
      arr = Split(list, ";", -1, 0)
      matchByInclude = matchByInclude(arr)
    end if
  else
    matchByInclude = true
    for each rx in list
      rx = trim(rx)
      if rx <> Empty then
        if matchByRegexp(text, rx) then
          matchByInclude = true
          exit function
        else 
          matchByInclude = false
        end if
      end if
    next
  end if
end function

'skip empty regexp
'if all list of regexp are skipped -> false
function matchByExclude(text, list)
  if vartype(list) = vbString then
    if list = Empty then
      matchByExclude = false
    else
      arr = Split(list, ";", -1, 0)
      matchByExclude = matchByExclude(arr)
    end if
  else
    matchByExclude = false
    for each rx in list
      rx = trim(rx)
      if rx <> Empty then
        if matchByRegexp(text, rx) then
          matchByExclude = true
          exit function
        end if
      end if
    next
  end if
end function

'empty-exclude -> ignored
'empty-include -> always true
function checkByRegexp(text, includes, excludes)
  checkByRegexp = false
  if matchByInclude(text, includes) then
    if not matchByExclude(text, excludes) then
      checkByRegexp = true
    end if
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
function matchByMask(text, mask)
  rx = maskToRegexp(mask)
  matchByMask = matchByRegexp(text, rx)
end function

'===============================================================================
'===============================================================================

'skip empty mask
'if all mask are skipped -> true
function matchByMasks(text, masks)
  set rx_list = masksToRegexp(masks)
  matchByMasks = matchByInclude(text, rx_list)
end function

'===============================================================================
'===============================================================================

'empty-include -> always true
'empty-exclude -> ignored
function checkByMasks(text, includes, excludes)
  set rx_includes = masksToRegexp(includes)
  set rx_excludes = masksToRegexp(excludes)
  checkByMasks = checkByRegexp(text, rx_includes, rx_excludes)
end function

'===============================================================================
'===============================================================================

dim gMASK_LIB_INITIALISED
dim gMASK_CONVERTOR
dim gVERSION_REGEXP
dim gMASK_REGEXP

'===============================================================================
'===============================================================================

sub initMaskLibrary()
  if gMASK_LIB_INITIALISED = Empty then
    gMASK_LIB_INITIALISED  = true

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
  end if
end sub

'===============================================================================
'===============================================================================

class MaskExp
  private m_include
  private m_exclude

'  private sub Class_Terminate()
'  end sub

  private sub Class_Initialize()
    set m_include = _
      CreateObject("System.Collections.ArrayList")
    set m_exclude = _
      CreateObject("System.Collections.ArrayList")
  end sub

  public default function init(includes, excludes)
    me.include = includes
    me.exclude = excludes
    set init = me
  end function

'---------------------------

  property Let include(masks)
    set m_include = masksToRegexp(masks)
  end property

  property Let exclude(masks)
    set m_exclude = masksToRegexp(masks)
  end property

  property Get countInclude()
    countInclude = m_include.count
  end property

  property Get countExclude()
    countExclude = m_exclude.count
  end property

  function match(text)
    match = _
      checkByRegexp(text, m_include, m_exclude)
  end function

  function toRegexp(mask)
    toRegexp = maskToRegexp(mask)
  end function

end class

'===============================================================================
'===============================================================================

function versionByRegexp(prefix, line)
  gVERSION_REGEXP.Pattern = prefix & "\bv?\d{1,3}\.\d{1,3}\.\d{1,3}\b"
  set matches = gVERSION_REGEXP.Execute(line)
  if matches.Count = 0 then
    versionByRegexp = ""
  else
    tmp = matches.Item(0)
    gVERSION_REGEXP.Pattern = "\bv?\d{1,3}\.\d{1,3}\.\d{1,3}\b"
    set matches = gVERSION_REGEXP.Execute(tmp)
    tmp = matches.Item(0)
    front = Left(tmp, 1)
    if front = "v" then
      tmp = Right(tmp, Len(tmp) - 1)
    end if
    versionByRegexp = tmp
  end if
end function

'===============================================================================
'===============================================================================

initMaskLibrary()

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
