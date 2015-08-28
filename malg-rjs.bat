@echo off
echo MicroAlg 0.4 (Rhino + EmuLisp)
echo.
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp
java -jar %MICROALG_DIR%\jar\js.jar %EMULISP_DIR%\pil-rjs %MICROALG_DIR%\microalg.l "%1" -bye
IF NOT DEFINED NO_PAUSE pause>nul|set/p="Une touche pour quitter."&echo(
