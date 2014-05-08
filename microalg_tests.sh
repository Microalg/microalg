#!/bin/sh
sh microalg_tests_picolisp.sh
EXIT_MALG=$?
sh microalg_tests_ersatz.sh
EXIT_MALGJ=$?
sh microalg_tests_emulisp.sh
EXIT_MALGJS=$?
#sh microalg_tests_features.sh
EXIT_FEATURES=0
exit $(($EXIT_MALG | $EXIT_MALGJ | $EXIT_MALGJS | $EXIT_FEATURES))
