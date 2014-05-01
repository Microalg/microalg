#!/bin/sh

if [ -n "${TRAVIS+x}" ]
then
    ./install_ersatz.sh
fi
echo "Testing with Ersatz..."
./malgj microalg_tests.malg

