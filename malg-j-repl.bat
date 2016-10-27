@echo off
echo MicroAlg 0.4.07 (Ersatz)
echo Taper (bye) pour quitter.
echo.
SET MICROALG_DIR=%~dp0
SET ERSATZ_DIR=%MICROALG_DIR%\ersatz
java -DPID=42 -jar %ERSATZ_DIR%\picolisp.jar %ERSATZ_DIR%\lib.l %MICROALG_DIR%microalg.l %1
