': 2>nul & cls & CScript.exe /nologo /e:vbs "%~f0" %* & exit /b

'===============================================================================

'--- Kartonagnick/example_gtest                   [deploy/stash][calcRebase.bat]
'[2025-12-07][22:10:00] 001 Kartonagnick PRE
'  --- local/hybrids                                            [calcRebase.bat]
'  [2024-08-22][15:07:25] 001 Kartonagnick

'===============================================================================

Option Explicit

dim g_shell : set g_shell = CreateObject("WScript.Shell")
dim g_fso   : set g_fso   = CreateObject("Scripting.FileSystemObject")
dim g_env   : set g_env   = g_shell.Environment("PROCESS")

function fromEnvironment(name, def)
  fromEnvironment = g_env.Item(name)
  if fromEnvironment = empty then 
    fromEnvironment = def
  end if
end function

function main()
  dim d_work 
  WScript.Echo "main: begin..."
  d_work = g_shell.CurrentDirectory
  d_work = fromEnvironment("eDIR_WORK", d_work)
  d_work = g_fso.GetAbsolutePathName(d_work)
  WScript.Echo "  work directory: " & d_work
  dim version_beg, version_end, delta, result
  version_end = 3
  version_beg = 2
  delta = version_end - version_beg
  result = delta * 2 + 2
  WScript.Echo "main: result = " & result
  WScript.Echo "main: done"
end function 

main()

'===============================================================================
