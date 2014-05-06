#!/bin/sh

if [ -n "${TRAVIS+x}" ]
then
    ./install_ersatz.sh
fi
PATH=$PATH:`pwd`/ersatz
echo "Testing with Ersatz..."
./malgj microalg_tests.malg

