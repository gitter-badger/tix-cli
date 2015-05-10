# Declare objects to store paths of source files (~/src) and install (~/local) paths
$base=@{
  src=Join-Path $HOME src
  local=Join-Path $HOME local
}

$src=@{
  bin=Join-Path $base.src bin
  cmd=Join-Path $base.src cmd
  ps1=Join-Path $base.src ps1
  sh=Join-Path $base.src sh
}

$local=@{
  bin=Join-Path $base.local bin
}

$env:Path = $local.bin + ';' + $env:Path