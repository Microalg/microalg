#!/bin/sh
sed -i -e 's/self.wrt(str(reason.step))/self.wrt(unicode(reason.step))/' /usr/local/lib/python2.7/dist-packages/lettuce/plugins/reporter.py
