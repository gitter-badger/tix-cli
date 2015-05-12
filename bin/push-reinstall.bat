set INSTALL_ROOT=%USERPROFILE%
call %INSTALL_ROOT%\local\config\variables.bat
set PATH=%LOCAL_PATH%;%PATH%
call %INSTALL_ROOT%\tixinc\tix-cli-src\bin\push-all.bat

pushd $INSTALL_ROOT%\tixinc\tix-cli-src
npm adduser
npm version patch
npm publish
git push origin master
popd

REM rmdir /s /q %INSTALL_ROOT%\local
REM rmdir /s /q %INSTALL_ROOT%\src\bat
REM call %INSTALL_ROOT%\tixinc\tix-cli-src\src\cmd\download-install-src.cmd
