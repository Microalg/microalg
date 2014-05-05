# -*- coding: utf-8 -*-
from lettuce import world, step, before, after
import pexpect

@before.each_scenario
def world_init(scenario):
    world.interp = ''     # name of the interpreter
    world.arg_list = []   # list of strings to provide to the interpreter
    world.process = None  # the process pexpect will spawn
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
    world.process = pexpect.spawn(world.interp, world.arg_list, timeout=5)

@step(u'Avec interaction (.*)')
def avec_interaction(step, user_input):
    world.inputs.append(user_input)

@step(u'Doit afficher «([^»]*)(»?)')
def doit_afficher(step, expected, singleline):
    # Append first prompt:
    world.process.expect('.*')
    world.output += world.process.after
    # Process user inputs:
    for user_input in world.inputs:
        world.process.sendline(user_input)
        world.process.expect('.*')
        world.output += world.process.after  # we see input + result
    # The end:
    world.process.expect('.*')
    # We rstrip because Lettuce seems to do the same when parsing multiline.
    world.output += world.process.after.rstrip('\n')
    world.process.expect(pexpect.EOF)
    # Post process output:
    world.output = world.output.replace('\r', '')
    if not singleline:
        expected = step.multiline
    # Final check:
    assert world.output == expected, \
       u"Devait afficher %s, mais on a eu %s." % (expected, world.output)
