@echo off
SET MICROALG_DIR=%~dp0
%MICROALG_DIR%\processing\processing-java.exe  --run --force --sketch=%MICROALG_DIR%\pde\microalg --output=%MICROALG_DIR%\pde\microalg.out
exit