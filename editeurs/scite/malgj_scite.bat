@echo off
REM https://github.com/Microalg/Microalg/blob/latest/INSTALL.md#avec-java
echo MicroAlg (Ersatz)
SET SCITE_DIR=%~dp0
SET MICROALG_DIR=%SCITE_DIR%..\..
SET ERSATZ_DIR=%MICROALG_DIR%\ersatz
java -DPID=42 -jar %ERSATZ_DIR%\picolisp.jar %ERSATZ_DIR%\lib.l %MICROALG_DIR%\microalg.l %1 %2 %3 %4 %5 %6
