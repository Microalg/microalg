@echo off
echo %NO_PAUSE%
echo MicroAlg 0.4.07 (Rhino + EmuLisp)
SET MICROALG_DIR=%~dp0
SET EMULISP_DIR=%MICROALG_DIR%\emulisp

if "%1"=="" goto :REPL

:FILE
echo.

if not defined %NO_PAUSE% ( ^
  java -jar %MICROALG_DIR%\jar\js.jar %EMULISP_DIR%\pil-rjs %MICROALG_DIR%\microalg.l "%1" -bye
) else (
  java -jar %MICROALG_DIR%\jar\js.jar %EMULISP_DIR%\pil-rjs %MICROALG_DIR%\microalg.l "%1"
  echo "--- Une touche pour quitter." ^
  pause>nul
)
goto DONE

:REPL
echo Taper (bye) pour quitter.
java -jar %MICROALG_DIR%\jar\js.jar %EMULISP_DIR%\pil-rjs %MICROALG_DIR%\microalg.l
goto DONE

:DONE