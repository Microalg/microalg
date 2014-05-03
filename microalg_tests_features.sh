#!/bin/sh
if [ -z `which lettuce` ]
then
    pip install lettuce
fi

PATH=$PATH:`pwd`:`pwd`/ersatz:`pwd`/emulisp
lettuce --verbosity=2

