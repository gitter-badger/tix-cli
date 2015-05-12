@echo off
call %USERPROFILE%\local\config\variables.bat
call push-all.bat
call npm-publish.bat
call cleanup.bat
call ..\src\cmd\download-install-src.cmd
