#!/bin/sh

PATH=$PATH:`pwd`/emulisp
echo "Testing with Rhino + Emulisp..."
./malg-rjs microalg_tests.malg

