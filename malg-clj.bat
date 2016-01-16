@echo off
echo MicroAlg-clj (Clojure)
echo.
SET MICROALG_DIR=%~dp0
java -jar %MICROALG_DIR%/jar\microalg-clj.jar %1
IF NOT DEFINED NO_PAUSE pause>nul|set/p="Une touche pour quitter."&echo(
