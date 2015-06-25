@echo off
SET MICROALG_DIR=%~dp0
%MICROALG_DIR%\processing_win\processing-java.exe  --run --force --sketch=%MICROALG_DIR%\pde\microalg --output=%MICROALG_DIR%\pde\microalg.out
