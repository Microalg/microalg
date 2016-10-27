@echo off
echo MicroAlg 0.4.07 (Rhino + EmuLisp)
echo Taper (bye) pour quitter
echo.
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp
java -jar %MICROALG_DIR%\jar\js.jar %EMULISP_DIR%\pil-rjs %MICROALG_DIR%\microalg.l
