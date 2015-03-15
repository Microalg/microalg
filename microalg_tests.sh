#!/bin/sh
sh microalg_tests_picolisp.sh
EXIT_MALG=$?
sh microalg_tests_ersatz.sh
EXIT_MALG_J=$?
sh microalg_tests_nodejs_emulisp.sh
EXIT_MALG_NJS=$?
sh microalg_tests_rhino_emulisp.sh
EXIT_MALG_RJS=$?
#sh microalg_tests_features.sh
EXIT_FEATURES=0
exit $(($EXIT_MALG | $EXIT_MALG_J | $EXIT_MALG_NJS | $EXIT_MALG_RJS | $EXIT_FEATURES))
