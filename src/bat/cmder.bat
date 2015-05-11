@echo on
set LOCAL_ROOT=%USERPROFILE%\local
set CMDER_ROOT=%LOCAL_ROOT%\cmder
call %LOCAL_ROOT%\config\variables.bat
set PATH=%LOCAL_PATH%;%PATH%

IF [%1]==[] (start %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe -cur_console:n /icon "%CMDER_ROOT%\vendor\msysgit\etc\git.ico" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd /c ""%CMDER_ROOT%\vendor\msysgit\bin\sh.exe" --login -i && exit") ELSE (start %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe  /icon "%CMDER_ROOT%\vendor\msysgit\etc\git.ico" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd /c ""%CMDER_ROOT%\vendor\msysgit\bin\sh.exe" -c %* && exit")