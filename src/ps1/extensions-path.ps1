param($RootPath=$HOME)
. $RootPath\src\ps1\extensions.ps1


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
}

# Paths within the local (installed) directory
$local=@{
  bin=Join-Path $base.local bin
  config=Join-Path $base.local config
}


Write-Host '--Creating src and local directories--'
$src.Values|Ensure-Directory -PassThru
$local.Values|Ensure-Directory -PassThru



$path=Join-Path $local.config "path.config"
if(Test-Path $path) {
    rm $path
}

Function Add-Path ($path) {
    $env:Path = $path + ';' + $env:Path
    $dir|Out-File $path -Append
}

Write-Host $local.bin
Add-Path $local.bin

Write-Host '--extensions-path.ps1 sourced--'