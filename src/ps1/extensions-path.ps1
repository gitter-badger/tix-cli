param($RootPath=$HOME)
### This file controls all custom paths for the src and local folders of the install.
. $RootPath\src\ps1\extensions.ps1 -RootPath $RootPath


# Base paths for src and local (installed) files
$base=@{
  src=Join-Path $RootPath src
  local=Join-Path $RootPath local
}

# Paths within the src directory
$src=@{
  bin=Join-Path $base.src bin
  cmd=Join-Path $base.src cmd
  ps1=Join-Path $base.src ps1
  sh=Join-Path $base.src sh
  xml=Join-Path $base.src xml
}

# Paths within the local (installed) directory
$local=@{
  bin=Join-Path $base.local bin
  config=Join-Path $base.local config
}



Write-Host '--Creating src and local directories--'
$src.Values|Ensure-Directory -PassThru
$local.Values|Ensure-Directory -PassThru


$variablesPath=Join-Path $local.config "variables.cmd"
if(Test-Path $variablesPath) {
    rm $variablesPath
    "@echo off"|Out-File $variablesPath -encoding ASCII
}

Function Add-Variable($name, $value) {
  "set $name=$value"|Out-File $variablesPath -Append -encoding ASCII
}

Function Append-Variable($name, $value) {
  Add-Variable $name "%$name%;$value"
}

Function Prepend-Path($variableName) {
  Add-Variable "PATH" "%$variableName%;%PATH%"
}

Function Add-Path ($path) {
    $env:Path = $path + ';' + $env:Path
    Append-Variable "LOCAL_PATH" $path
}

### Init with LOCAL_PATH variable
#$VCTargetsPath="C:\Program Files (x86)\MSBuild\12.0\Bin"
#Add-Variable "VCTargetsPath" "$VCTargetsPath"
Add-Variable "LOCAL_PATH" $local.bin

Write-Host '--extensions-path.ps1 sourced--'