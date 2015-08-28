@echo off
set NODE_PATH=%USERPROFILE%\AppData\Roaming\npm\node_modules;"%NODE_PATH%"
echo MicroAlg 0.4 (NodeJS + EmuLisp)
echo.
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp
node %EMULISP_DIR%\pil-njs %MICROALG_DIR%\microalg.l "%1" -bye
IF NOT DEFINED NO_PAUSE pause>nul|set/p="Une touche pour quitter."&echo(
