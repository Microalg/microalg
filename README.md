Microalg
========

<a href="https://travis-ci.org/Microalg/Microalg" style="float:right;">
<img src="https://travis-ci.org/Microalg/Microalg.svg?branch=master"></a>

Langage et environnements dédiés à l’algorithmique.

<img src="http://www.art-decor.org/mediawiki/images/9/9f/Attention_icon.svg"
     alt="En travaux" height="50"/>&nbsp;&nbsp;**En cours de développement!**

[Site officiel](http://microalg.info/)

MicroAlg est une sorte de [pseudo-code](https://fr.wikipedia.org/wiki/Pseudo-code)
en français et exécutable sur machine. C’est un [langage
embarqué](https://fr.wikipedia.org/wiki/Langage_d%C3%A9di%C3%A9#Langages_d.C3.A9di.C3.A9s_internes_et_externes)
dans [PicoLisp](http://picolisp.com). Donc :

* c’est un [Lisp](http://fr.wikipedia.org/wiki/Lisp), donc il n’y a pas de
  syntaxe à apprendre, juste des commandes,
* elle peut *tourner* sur plusieurs plateformes :
    * Javascript (navigateurs ou NodeJS) grâce à
      [EmuLisp](http://grahack.github.io/EmuLisp),
    * là où PicoLisp (ASM, C) peut tourner nativement,
    * la JVM grâce à Ersatz (une implémentation en Java de Picolisp, par
      l’auteur de Picolisp),
* il est toujours possible si on se sent limité par ce langage, d’utiliser
  directement PicoLisp dans du code MicroAlg voir par exemple le fichier de
  tests `microalg_tests.malg`.

Voir le [site officiel](http://microalg.info/) pour plus de détails.

Fichiers
========

* `emulisp` : implémentation de Picolisp en JS
    * voir [le site semi-officiel](https://github.com/grahack/emulisp)
    * la version utilisée ici est une version expérimentale, qui guide le
      développement de la version semie-officielle
* `exemples` : quelques fichiers `.malg` (MicroAlg) ou `.l` (PicoLisp) en
  exemples, qui servent aussi pour les tests
* `features` : tests de fonctionnalité pour les interpréteurs, rédigés en
  [Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin)
    * `cli.py` fait le lien entre les mots-clef des tests Gherkin et les
      actions à prendre pour exécuter concrètement ces tests
* `ide.html` : un IDE web de fortune, accessible [ici](http://microalg.info/ide.html)
* scripts d’installation :
    * `install_ersatz.sh` : pour Ersatz
      (d’où peut-être le répertoire `ersatz` qui traîne)
      l’interpréteur officiel de PicoLisp écrit en Java
    * `install_picolisp.sh` : pour l’interpréteur officiel de PicoLisp écrit en
      assembleur et C
      (d’où peut-être le répertoire `picolisp` qui traîne)
* `LICENSE` : la licence
* `malg` : exécutable permettant d’exécuter un `.malg` avec PicoLisp (ASM/C)
* `malgj` : exécutable permettant d’exécuter un `.malg` avec Ersatz (Java)
* `malgjs` : exécutable permettant d’exécuter un `.malg` avec Node et Emulisp
* `microalg.l` : implémentation de MicroAlg en PicoLisp, le cœur de ce projet
* tests :
    * `microalg_tests.malg` : les tests des commandes MicroAlg testables avec
      PicoLisp/MicroAlg seulement
    * `microalg_tests_features.sh` : de quoi lancer les tests de fonctionnalité
    * `microalg_tests_emulisp.sh` :  de quoi lancer les tests avec Node et EmuLisp
    * `microalg_tests_ersatz.sh` :   de quoi lancer les tests avec Ersatz
    * `microalg_tests_picolisp.sh` : de quoi lancer les tests avec Ersatz
    * `microalg_tests.sh` :  de quoi lancer les tests sur toutes les
                             plateformes possibles, features non comprises
* `README.md` : ce fichier (j’ai toujours rêvé d’écrire ça)
* `tuto.html` : une page web interactive pour apprendre MicroAlg, et plus
  généralement à faire ses premiers pas en algorithmique et en programmation
* `web` : des fichiers de complément pour les `.html` de ce projet
