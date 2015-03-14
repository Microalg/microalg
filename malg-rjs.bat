@echo off
REM https://github.com/Microalg/Microalg/blob/latest/INSTALL.md#avec-rhinrhin
echo MicroAlg (RhinoJS + EmuLisp)
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp
java -jar jar\js.jar %EMULISP_DIR%\pil-rjs %MICROALG_DIR%\microalg.l %1 %2 %3 %4 %5 %6
pause>nul|set/p="Une touche pour quitter."&echo(
