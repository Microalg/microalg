@echo off
set NODE_PATH=%USERPROFILE%\AppData\Roaming\npm\node_modules;"%NODE_PATH%"
echo MicroAlg 0.4.07 (NodeJS + EmuLisp)
echo Taper (bye) pour quitter
echo.
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp
node %EMULISP_DIR%\pil-njs %MICROALG_DIR%\microalg.l
