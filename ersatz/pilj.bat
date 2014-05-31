@echo off
echo Ersatz PicoLisp
REM Inspiration for this file:
REM https://www.mail-archive.com/picolisp@software-lab.de/msg02076.html
REM You have to install Java and/or may have to tweak your PATH.
REM See here: https://www.java.com/en/download/help/path.xml
REM e.g. add ; (separator) then "C:\Program Files (x86)\Java\jre7\bin"
java -DPID=42 -jar %~dp0\picolisp.jar %~dp0\lib.l %1 %2 %3 %4 %5 %6
pause
