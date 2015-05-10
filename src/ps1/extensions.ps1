Filter Write-PipeTable {
    Param( [switch]$PassThru )
    Write-Host ($_ | Format-Table | Out-String)
    If($PassThru) {
      Write-Output $_
    }
}

Filter Write-PipeList {
    Param( [switch]$PassThru )
    Write-Host ($_ | Format-List | Out-String)
    if($PassThru) {
      Write-Output $_
    }
}

Filter Ensure-Directory {
  Param( [switch]$PassThru )
  If(!(Test-Path -Path $_ -PathType Container)) {
    New-Item -Path $_ -type Directory | Out-Null
    If($PassThru) {
      Write-Output $_
    }
  }
}

Function Expand-Zip ($zipPath, $destDir) {
  $shell = New-Object -com shell.application
  $zip = $shell.Namespace($zipPath)

  $destDir|Ensure-Directory

  ForEach($item in $zip.items()) {
    $shell.Namespace($destDir).CopyHere($item, 0x10)
  }
} 

Function Execute($filePath, $arguments)
{
    If($arguments) {
        Start-Process $filePath -ArgumentList $arguments -Wait -PassThru
    }
    Else {
        Start-Process $filePath -Wait -PassThru
    }
}


Function Execute-7z($arguments) {
    Write-Host "7za.exe $arguments"
    Execute 7za.exe $arguments
}

Function Expand-7z($filePath, $destDir) {
    Execute-7z "x -aoa -o$destDir $filePath"
}

Function Decompress-Xz ($filePath) {
    # Decompress: x (Extract w/ full paths) -aoa (Overwrite files:no prompt)
    $arguments = "x -aoa $filePath"
    Execute-7z $arguments
    # Return path of tar on stdout
}

Function Expand-Tar ($filePath, $destDir) {
    $arguments = "x -aoa -ttar -o" + $destDir + " " + $filePath
    # Unzip: x (Extract w/ full paths) -aoa (Overwrite files:no prompt) -ttar (tar file) -o (dest)
    Execute-7z $arguments
}

## Decompresses, unzips, and installs the contents of a .tar.xz package.
Function Expand-TarXz($filePath, $destDir) {
    Decompress-Xz $filePath
    $tarPath = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    Expand-Tar $tarPath $destDir
}

Function Execute-Ps1($filePath) {
    Execute powershell.exe "-File=$filePath"
}

Function Execute-Sh($filePath) {
    Execute msys2_shell.bat ""
}

Function Install-Msi ($filePath, $arguments) {
    Execute msiexec.exe "/i $filePath $arguments"
}

Function New-HardLink ($link, $target) {
    Write-Host "Hard linking $target to $link"
    Invoke-Expression "cmd /c mklink /H $link $target"
}

Function New-HardLinkIn ($dir, $target) {
  $fileName = [System.IO.Path]::GetFileName($target)
  $dir|Ensure-Directory
  $link = Join-Path $dir $fileName
  New-HardLink $link $target 
}

Function New-SymLink ($link, $target) {
    $baseCmd='cmd /c mklink'
    If (Test-Path -PathType Container $target) {
        $baseCmd+=' /d'
    }
    Write-Host "Symbolic linking $target to $link"
    Invoke-Expression "$baseCmd $link $target"
}

Function New-SymLinkIn ($dir, $target) {
  $fileName = [System.IO.Path]::GetFileName($target)
  $dir|Ensure-Directory
  $link = Join-Path $dir $fileName
  New-SymLink $link $target 
}

Function Remove-Path ($path) {
    If (Test-Path -PathType Container $path) {
        $command = "cmd /c rmdir"
    }
    Else {
        $command = "cmd /c del"
    }
    Write-Host "Removing link at $path"
    Invoke-Expression "$command $path"
}

# Downloads a file from url to directory
Function Download-File($url, $filePath) {
    If (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Downloading $url to $filePath"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile("$url", "$filePath")
    }
}

Filter Download-Files {
    Download-File $_.fileUrl $_.filePath
}

Write-Host '--extensions.ps1 sourced--'