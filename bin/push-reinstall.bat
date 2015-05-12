@echo off
call %USERPROFILE%\local\config\variables.bat
call push-all.bat
REM call npm-publish.bat
REM call cleanup.bat
call ..\src\cmd\download-install-src.cmd
