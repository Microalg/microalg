@echo off
REM https://github.com/Microalg/Microalg/blob/latest/INSTALL.md#avec-nodejs
set NODE_PATH=%USERPROFILE%\AppData\Roaming\npm\node_modules;"%NODE_PATH%"
echo MicroAlg (EmuLisp)
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp
node %EMULISP_DIR%\piljs %MICROALG_DIR%\microalg.l %1 %2 %3 %4 %5 %6
pause>nul|set/p="Une touche pour quitter."&echo(
