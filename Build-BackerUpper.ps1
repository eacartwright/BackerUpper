$scriptName = "BackerUpper"

$scriptSource = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildSource = "$(Split-Path -Parent $scriptSource)\PS2EXE-GUI\ps2exe.ps1"
$buildInput = "$scriptSource\$scriptName.ps1"
$buildOutput = "$scriptSource\$scriptName.exe"

$buildOptions = "-runtime20 -noConfigfile -requireAdmin -iconFile '$scriptSource\icon.ico' -description '$scriptName' -version '1.0.0.0' -product '$scriptName' -copyright 'NWPHO'"

Invoke-Expression "$buildSource $buildInput $buildOutput $buildOptions"
