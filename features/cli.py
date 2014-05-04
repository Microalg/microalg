# -*- coding: utf-8 -*-
from lettuce import world, step, before, after
from subprocess import Popen, PIPE
import signal

@before.each_scenario
def world_init_for_Popen(scenario):
    world.cmd_list = []   # list of strings to provide to Popen
    world.process = None  # the process Popen will give us
    world.inputs = []     # list of strings that the user may input
    world.output = ''     # string that may be printed
    world.errors = []     # errors that may occur

@after.each_scenario
def kill_any_remaining_process(scenario):
    if world.process.poll() is None:  # not terminated
        print "Killing a remaining process..."
        world.process.kill()

class TimeoutException(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutException()

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

@step(u'Doit afficher «([^»]*)(»?)')
def doit_afficher(step, expected, singleline):
    timeout = 2
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout)  # timeout in seconds
    if not world.inputs:
        pass
    else:
        for user_input in world.inputs:
            try:
                # in
                world.process.stdin.write(user_input + '\n')
                # out
                output = world.process.stdout.readline()
                world.output += output + user_input
                # error
                error = world.process.stderr.readline()
                if error:
                    world.errors.append(error)
                # Restore default handling for alarm signal.
                signal.signal(signal.SIGALRM, signal.SIG_DFL)
            except TimeoutException:
                world.process.kill()
                tpl = "L’exécution aurait du durer moins de %d seconde(s)."
                raise AssertionError(tpl % timeout)
    if not singleline:
        expected = step.multiline
    if world.output != expected:
        tpl = "Devait afficher %s, mais on a eu: %s."
        raise AssertionError(tpl % (expected, world.output))

@step(u'Sans erreur')
def sans_erreur(step):
    if world.errors:
        tpl = "Aucune erreur ne devait se produire, mais on a eu: %s."
        raise AssertionError(tpl % ('\n'.join(world.errors)))

