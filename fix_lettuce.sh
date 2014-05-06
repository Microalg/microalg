#!/bin/sh
sed -i -e 's/self.wrt(str(reason.step))/self.wrt(unicode(reason.step))/' /home/travis/virtualenv/python2.7.6/lib/python2.7/site-packages/lettuce/plugins/reporter.py
