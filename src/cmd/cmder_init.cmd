/dir "%USERPROFILE%" /icon "%CMDER_ROOT%\vendor\msysgit\etc\git.ico"



>SET CMDER_ROOT=%USERPROFILE%\local\cmder & cmd /k ""C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 & "%CMDER_ROOT%\vendor\msysgit\bin\sh.exe" --login -i" -new_console:t:"bash"




>SET CMDER_ROOT="%USERPROFILE%\local\cmder" & CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 & cmd /k ""%CMDER_ROOT%\vendor\msysgit\bin\bash.exe" --login -i" -new_console:t:"bash"