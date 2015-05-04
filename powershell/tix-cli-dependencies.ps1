##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

$source = 'C:\TixInc\downloads'

$packages = @(
  @{
    title='Git For Windows 1.9.5';
    url='https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20150319/Git-1.9.5-preview20150319.exe';
    dir=$source;
    arguments='/SILENT /SUPPRESSMSGBOXES /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
  },
  @{
    title='Node.js 0.12.2';
    url='http://nodejs.org/dist/v0.12.2/x64/node-v0.12.2-x64.msi';
    dir=$source;
    arguments='/qn'
  },
  @{
    title='TixCli';
    url='https://raw.githubusercontent.com/TixInc/TixCli/master/oneline/tix-cli-install.sh';
    dir=$source;
    arguments=''
  }
)



If (!(Test-Path -Path $source -PathType Container)) {New-Item -Path $source -ItemType Directory | Out-Null}


# Downloads a file from url to directory
function DownloadFile
{
    param( [string]$url, [string]$filePath )

    If (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Downloading $url to $filePath"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile("$url", "$filePath")
    }
}

function InstallMsi ($filePath, $arguments)
{
    $command = "/i $filePath $arguments"
    Write-Host "Installing msi $filePath with $command"
    Start-Process msiexec.exe -ArgumentList $command -Wait -PassThru
    Write-Host "Finished installing $filePath"
}

function Install ($filePath, $arguments)
{

    Write-Host "Installing $filePath with $arguments"
    Start-Process $filePath -ArgumentList $arguments -Wait -PassThru
    Write-Host "Finished installing $filePath"
}




#Once we've downloaded all our files lets install them.
foreach ($package in $packages) {
    $url = $package.url
    $dir = $package.dir
    $fileName = Split-Path $url -Leaf
    $filePath = Join-Path -Path $dir -ChildPath $fileName
    DownloadFile -url $url -filePath $filePath
    $ext = [System.IO.Path]::GetExtension($fileName)
    If ($ext -eq '.msi')
    {
        Write-Host "Installing MSI"
        InstallMsi $filePath $package.arguments | Out-Null
    }
    Else
    {
        Install $filePath $package.arguments
    }
}