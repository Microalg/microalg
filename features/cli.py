# -*- coding: utf-8 -*-
from __future__ import print_function
from lettuce import world, step, before
import sys
import pexpect

@before.each_scenario
def world_init(scenario):
    world.interp = ''     # name of the interpreter
    world.arg_list = []   # list of strings to provide to the interpreter
    world.process = None  # the process pexpect will spawn
    world.timeout = 5     # timeout in seconds
    world.inputs = []     # list of strings that the user may input
    world.output = ''     # string that will be displayed

@step(u'Le programme (.*)')
def le_programme(step, interp):
    world.interp = interp

@step(u'Avec argument (.*)')
def avec_argument(step, arg):
    world.arg_list.append(arg)

@step(u'Ayant démarré')
def ayant_demarre(step):
    world.process = pexpect.spawn(world.interp, world.arg_list,
                                  timeout=world.timeout)

@step(u'Avec interaction (.*)')
def avec_interaction(step, user_input):
    world.inputs.append(user_input)

@step(u'Doit afficher «([^»]*)(»?)')
def doit_afficher(step, expected, singleline):
    try:
        # send all input lines
        map(world.process.sendline, world.inputs)

        # wait until EOF
        world.process.expect(pexpect.EOF)

        # ?? strip newlines
        given = u''.join(world.process.before.splitlines())

        # test,
        assert given == expected, (
            u"given={given!r}, expected={expected!r}."
            .format(given=given, expected=expected))

    except Exception, err:
        sys.stderr.write('\r\n')
        sys.stderr.write(u"step={step}, "
                         u"expected={expected!r}, "
                         u"singleline={singleline!r}, "
                         u"world.output={world.output!r}, "
                         u"world.process={world.process}\r\n".format(
                             step=step, expected=expected,
                             singleline=singleline, world=world))
        raise err
    finally:
        world.process.close()
