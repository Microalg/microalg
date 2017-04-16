#!/bin/sh
set -e
filepath=$(python -c 'import os; import lettuce.plugins.reporter; print(os.path.join(os.path.dirname(lettuce.plugins.__file__),"reporter.py"))')
if [ ! -f $filepath ]; then
	echo "Could not find file for python module lttuce.plugins.reporter, expected: $filepath"
	exit 1
fi
sed -i -e 's/self.wrt(str(reason.step))/self.wrt(unicode(reason.step))/' $filepath
