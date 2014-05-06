#!/bin/sh
echo "Installing Ersatz..."
wget http://www.software-lab.de/ersatz.tgz
tar xzf ersatz.tgz
mv ersatz/pil ersatz/pilj  # Avoid conflicts with picolisp/pil.
rm ersatz.tgz
