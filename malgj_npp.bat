@echo off
REM Exécuter un script MicroAlg avec Ersatz (PicoLisp en Java) avec Notepad++.
REM Sont passés depuis Notepad++: "$(NPP_DIRECTORY)" "$(FULL_CURRENT_PATH)"
SET NPP_DIR="%1"
SET DOC_PATH="%2"
SET MICROALG_DIR=%NPP_DIR%\microalg
SET ERSATZ_DIR=%NPP_DIR%\microalg\ersatz
java -DPID=42 -jar %ERSATZ_DIR%\picolisp.jar ^
     %ERSATZ_DIR%\lib.l %MICROALG_DIR%\microalg.l %DOC_PATH%
pause
REM Voir:
REM https://github.com/Microalg/Microalg/blob/latest/INSTALL.md
REM https://www.mail-archive.com/picolisp@software-lab.de/msg02076.html
