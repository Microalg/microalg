#!/bin/sh

PATH=$PATH:`pwd`/emulisp
echo "Testing with NodeJS + Emulisp..."
./malg-njs microalg_tests.malg

