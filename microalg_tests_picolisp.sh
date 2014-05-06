#!/bin/sh

if [ -n "${TRAVIS+x}" ]
then
    ./install_picolisp.sh
fi
echo "Testing with PicoLisp..."
./malg microalg_tests.malg

