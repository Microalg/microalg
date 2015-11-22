@echo off
set NODE_PATH=%USERPROFILE%\AppData\Roaming\npm\node_modules;"%NODE_PATH%"
echo Emulisp
node %~dp0\pil-njs %1 %2 %3 %4 %5 %6
pause>nul|set/p="Une touche pour quitter."&echo(
