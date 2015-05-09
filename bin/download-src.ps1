##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

#Invoke-WebRequest [-Uri] <Uri> [-Body <Object> ] [-Certificate <X509Certificate> ] [-CertificateThumbprint <String> ] [-ContentType <String> ] [-Credential <PSCredential> ] [-DisableKeepAlive] [-Headers <IDictionary> ] [-InFile <String> ] [-InformationAction <System.Management.Automation.ActionPreference> {SilentlyContinue | Stop | Continue | Inquire | Ignore | Suspend} ] [-InformationVariable <System.String> ] [-MaximumRedirection <Int32> ] [-Method <WebRequestMethod> {Default | Get | Head | Post | Put | Delete | Trace | Options | Merge | Patch} ] [-OutFile <String> ] [-PassThru] [-Proxy <Uri> ] [-ProxyCredential <PSCredential> ] [-ProxyUseDefaultCredentials] [-SessionVariable <String> ] [-TimeoutSec <Int32> ] [-TransferEncoding <String> {chunked | compress | deflate | gzip | identity} ] [-UseBasicParsing] [-UseDefaultCredentials] [-UserAgent <String> ] [-WebSession <WebRequestSession> ] [ <CommonParameters>]

#$links = Invoke-WebRequest -Uri https://github.com/TixInc/tix-cli/tree/master/bin|Select -exp Links|Where{$_.class -eq "js-directory-link"}|Select -exp href

$baseUri = 'https://github.com'
$srcUri = '/TixInc/tix-cli/tree/master/bin'
$fileFilter = '*.*'
$classFilter = 'js-directory-link'

Function Scrape-Files-Recursive ($relativeUri, $relativePath) {
  $links = Invoke-WebRequest -Uri "$baseUri$relativeUri" -TimeoutSec 20|Select -Exp Links|Where{$_.class -Eq "js-directory-link"}


  ForEach ($dirLink in $links|Where{$_.innerText -NotLike $fileFilter}) {
    # gets the url of the directory
    $dirUrl = $dirLink|Select -Exp href
    # gets the path name and joins it to the current recursive relative path for the directory.
    $dirPath = $dirLink|Select -Exp innerText|%{ "$relativePath\$_" }
    Scrape-Files-Recursive $dirUrl $dirPath
  }

  # Gets file urls and pipes them back up the chain
  $fileLinks = $links|Where{$_.innerText -Like $fileFilter}
  $filePath = $fileLinks|Select -Exp innerText|%{ "$relativePath\$_" }
  $fileUrl = $fileLinks|Select -Exp href|%{ "$baseUri$_" }


  # Return an object with the absolute url of the resource and the path that it should map to
  New-Object PSObject -Property @{
    FileUrl=$fileUrl;
    FilePath= $filePath;
  }

}

$fileMaps=Scrape-Files-Recursive $srcUri ''

Write-Host $fileMaps
#Write-Host ($fileMaps | Format-Table | Out-String)
