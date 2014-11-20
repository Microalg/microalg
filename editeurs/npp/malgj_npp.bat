@echo off
REM Exécuter un script MicroAlg avec Ersatz (PicoLisp en Java) avec Notepad++.
REM https://www.mail-archive.com/picolisp@software-lab.de/msg02076.html
REM Passé depuis Notepad++ "$(FULL_CURRENT_PATH)"
SET SRC_PATH="%1"
SET MICROALG_DIR=%~dp0\..\..
SET ERSATZ_DIR=%MICROALG_DIR%\ersatz
java -DPID=42 -jar %ERSATZ_DIR%\picolisp.jar ^
     %ERSATZ_DIR%\lib.l %MICROALG_DIR%\microalg.l %SRC_PATH%
     pause>nul|set/p="Une touche pour quitter."&echo(
