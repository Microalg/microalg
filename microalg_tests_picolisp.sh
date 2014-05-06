#!/bin/sh

if [ -n "${TRAVIS+x}" ]
then
    ./install_picolisp.sh
fi
PATH=$PATH:`pwd`/picolisp
echo "Testing with PicoLisp..."
./malg microalg_tests.malg

