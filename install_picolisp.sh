#!/bin/sh
echo "Installing Picolisp..."
VERSION=3.1.6
wget "http://software-lab.de/picoLisp-$VERSION.tgz"
tar xvzf "picoLisp-$VERSION.tgz"
mv picoLisp picolisp
rm "picoLisp-$VERSION.tgz"

cd picolisp/src
make
cd -
