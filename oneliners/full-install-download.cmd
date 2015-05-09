#@powershell -NoProfile -ExecutionPolicy unrestricted -Command "wget http://blog.stackexchange.com/ -UseBasicParsing -OutFile out.html"
@powershell -NoProfile -ExecutionPolicy unrestricted -File download-src.ps1


#iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/tix-cli/master/bin/ps1/download.ps1'))"