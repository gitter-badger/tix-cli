param($RootPath=$HOME)
$localPath=Join-Path $RootPath local
$7zaPath=Join-Path $localPath '7z\7za.exe'
$cmderPath=Join-Path $localPath 'bin\cmder.bat'
$cmderaPath=Join-Path $localPath 'bin\cmdera.bat'


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

Function Execute-Sh($command) {
    Execute $cmderPath $command
}


Function Execute-7z($arguments) {
    Write-Host "$7zaPath $arguments"
    Execute $7zaPath $arguments
}

Function Expand-7z($filePath, $destDir) {
  $destDir|Ensure-Directory
  Execute-7z "x -aoa -o$destDir $filePath"
}

<#
Function Decompress-Xz ($filePath) {
    #$tarName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $tarPath =  $filePath.Substring(0, $filePath.LastIndexOf('.'))
    # Decompress: x (Extract w/ full paths) -aoa (Overwrite files:no prompt)
    $arguments = "x -aoa -so $filePath"
    Execute-7z $arguments > $tarPath
    Write-Output $tarPath
    # Return path of tar on stdout
}

Function Expand-Tar ($filePath, $destDir) {
    $arguments = "x -aoa -si -so -ttar $filePath" | $destDir
    # Unzip: x (Extract w/ full paths) -aoa (Overwrite files:no prompt) -ttar (tar file) -o (dest)
    Execute-7z $arguments
}
#>

## Decompresses, unzips, and installs the contents of a .tar.xz package.
Function Expand-TarXz($filePath, $destDir) {
  $destDir|Ensure-Directory
  Execute-7z "x $filePath -so | $7zaPath x -aoa -si -ttar -o$destDir"
  #7z x "somename.tar.gz" -so | 7z x -aoa -si -ttar -o"somename"
    #$tarPath=Decompress-Xz $filePath
    #Expand-Tar $tarPath $destDir
}

Function Execute-Bat($filePath) {
  . "$filePath"
}

Function Source-Bat($filePath) {
  CMD /c "$filePath && set" | .{process{
    if ($_ -match '^([^=]+)=(.*)') {
        Set-Variable $matches[1] $matches[2]
    }
  }}
}

Function Execute-Ps1($filePath) {
    Execute powershell.exe "-File=$filePath"
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
    If (Test-Path $path) {
      Remove-Item $path
    }
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

Function Pin-Taskbar($fileDir, $fileName) {
  #$sa = new-object -c shell.application
  #$ns = $sa.namespace($fileDir)
  #$pn = parsename($fileName)
  #$pn.invokeverb('taskbarpin')

  $batchName = 'cmder'
  $batchPath=Join-Path $fileDir $fileName
  $taskbarFolder = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\Taskbar\"
  $objShell = New-Object -ComObject WScript.Shell
  $objShortCut = $objShell.CreateShortcut("$taskbarFolder\$batchName.lnk")
  $objShortCut.TargetPath = 'cmd'
  $objShortCut.Arguments="/c ""$batchPath"""
  $objShortCut.Save()
}

Write-Host '--extensions.ps1 sourced--'