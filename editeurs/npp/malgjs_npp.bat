@echo off
REM Exécuter un script MicroAlg avec EmuLisp (PicoLisp en Javascript) avec Notepad++.
set NODE_PATH=%USERPROFILE%\AppData\Roaming\npm\node_modules;"%NODE_PATH%"
REM Passé depuis Notepad++ "$(FULL_CURRENT_PATH)"
SET SRC_PATH="%1"
SET MICROALG_DIR=%~dp0\..\..
SET EMULISP_DIR=%MICROALG_DIR%\emulsip
%MICROALG_DIR%\malgjs.bat %MICROALG_DIR%\microalg.l %SRC_PATH%
pause>nul|set/p="Une touche pour quitter."&echo(
