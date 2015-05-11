param($RootPath=$HOME)
. $RootPath\src\ps1\extensions.ps1 -RootPath $RootPath


# Base paths for src and local (installed) files
$base=@{
  src=Join-Path $RootPath src
  local=Join-Path $RootPath local
}

# Paths within the src directory
$src=@{
  bin=Join-Path $base.src bin
  bat=Join-Path $base.src bat
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



$variablesPath=Join-Path $local.config "variables.bat"
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

Function Add-Path ($path) {
    $env:Path = $path + ';' + $env:Path
    Append-Variable "LOCAL_PATH" $path
}

Add-Variable "LOCAL_PATH" $local.bin
#Append-Variable "LOCAL_ROOT" $RootPath


Write-Host '--extensions-path.ps1 sourced--'