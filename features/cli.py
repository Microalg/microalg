# -*- coding: utf-8 -*-
from lettuce import world, step, before
from subprocess import Popen, PIPE

@before.each_scenario
def setup_some_scenario(scenario):
    world.cmd_list = []   # list of strings to provide to Popen
    world.process = None  # the process Popen will give us
    world.inputs = []     # list of strings that the user may input
    world.output = ''     # string that may be printed
    world.error = ''      # errors that may occur

@step(u'Le programme (.*)')
def le_programme(step, interp):
    world.cmd_list = [interp]

@step(u'Avec argument (.*)')
def avec_argument(step, arg):
    world.cmd_list.append(arg)

@step(u'Ayant démarré')
def ayant_demarre(step):
    world.process = Popen(world.cmd_list, stdin=PIPE, stdout=PIPE, stderr=PIPE)

@step(u'Avec interaction (.*)')
def avec_interaction(step, user_input):
    world.inputs.append(user_input)

@step(u'Doit afficher «(.*)»')
def doit_afficher(step, expected):
    input_str = world.inputs and '\n'.join(world.inputs) or None
    world.output, world.error = world.process.communicate(input_str)
    if world.output != expected:
        tpl = "Devait afficher %s, mais on a eu: %s."
        raise AssertionError(tpl % (expected, world.output))

@step(u'Sans erreur')
def sans_erreur(step):
    if world.error:
        tpl = "Aucune erreur ne devait se produire, mais on a eu: %s."
        raise AssertionError(tpl % (world.error))

