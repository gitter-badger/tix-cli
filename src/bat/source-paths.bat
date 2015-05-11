ENABLEEXTENSIONS
if "%~1"=="" set LOCAL_ROOT=%HOMEPATH%\local
@call %LOCAL_ROOT%\config\variables.bat

@if DEFINED LOCAL_PATH (set PATH=%LOCAL_PATH%;%PATH%) else (echo "No LOCAL_PATH defined")