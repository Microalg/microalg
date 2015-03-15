@echo off
echo MicroAlg (Ersatz)
SET MICROALG_DIR=%~dp0
SET ERSATZ_DIR=%MICROALG_DIR%\ersatz
java -DPID=42 -jar %ERSATZ_DIR%\picolisp.jar %ERSATZ_DIR%\lib.l %MICROALG_DIR%microalg.l %1 -bye
IF NOT DEFINED NO_PAUSE pause>nul|set/p="Une touche pour quitter."&echo(
