#!/bin/sh

echo "Testing with Ersatz..."
if [ -n "${TRAVIS+x}" ]
then
    wget http://www.software-lab.de/ersatz.tgz
    tar xvzf ersatz.tgz
fi
ersatz/pil microalg.l microalg_tests.malg

