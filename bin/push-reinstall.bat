@echo off
set INSTALL_ROOT=%USERPROFILE%
call %INSTALL_ROOT%\local\config\variables.bat
set PATH=%LOCAL_PATH%;%PATH%
call %INSTALL_ROOT%\tixinc\tix-cli-src\bin\push-all.bat

pushd ..\
npm version patch
npm publish
git push origin master
popd

rmdir /s /q %INSTALL_ROOT%\local
rmdir /s /q %INSTALL_ROOT%\src\bat
call %INSTALL_ROOT%\tixinc\tix-cli-src\src\cmd\download-install-src.cmd
