Installation
============

Cette page est accessible
[ici](https://github.com/Microalg/Microalg/blob/latest/INSTALL.md).

Si vous trouvez une faute d’orthographe, ou si vous rencontrez un problème
d’installation, merci de (au choix) :

* proposer une « pull request » en éditant directement un fichier sur
  [Github](https://github.com/Microalg/Microalg),
* poster une « issue » sur
  [Github](https://github.com/Microalg/Microalg),
* m’envoyer [un email](mailto:profgra.org@gmail.com).

## Table des matières

Cette page peut paraître longue, mais c’est uniquement parce qu’il y a
plusieurs façons d’installer MicroAlg. À vous de choisir celle qui vous
convient (sans lien, c’est que la section n’est pas encore rédigée) :

* Utiliser [MicroAlg en ligne](http://microalg.info/ide.html) :
  rien à installer !
* Installer MicroAlg sur son site
* Installation pour développeur/contributeur…
    * …au [cœur de MicroAlg](#développeur) (attention, il n’y a pas
      d’environnement de développement pour Windows ou Android),
    * …à la documentation, tutoriels… chercher ci-dessous un lien pour
      « utilisation possible sans connextion » adaptée à votre système
      d’exploitation.
* Installation pour utilisateur
    * Windows
        * simple utilisateur
            * dans un navigateur, mais utilisation possible sans connexion
            * [avec Java](#avec-java)
            * avec NodeJS
        * utilisateur avancé
            * les mêmes
            * le vrai PicoLisp dans Cygwin
    * Mac
        * dans un navigateur, mais utilisation possible sans connexion
        * Pour le reste, aucune idée, voir peut-être les instructions pour « Autre ».
    * Android
        * En cours de développement (mensonge)
    * Autre
        * dans un navigateur, mais utilisation possible sans connexion
        * avec le vrai PicoLisp (C et assembleur)
        * avec Ersatz (Java)
        * avec EmuLisp (NodeJS)

## Installer sur son site

* Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
* Extraire quelque part dans l’arborescence de votre site.
* Ouvrir `microalg/ide.html`.
    * Si tout fonctionne, vous pouvez essayer d’injecter MicroAlg dans la page
      de votre choix.
    * Sinon, merci de (au choix) :
        * proposer une « pull request » en éditant directement un fichier sur
          [Github](https://github.com/Microalg/Microalg),
        * poster une « issue » sur
          [Github](https://github.com/Microalg/Microalg),
        * m’envoyer [un email](mailto:profgra.org@gmail.com).

## Développeur

> Désolé, il n’y a pas d’environnement de développement pour Windows.

Il faut installer les trois versions : le vrai PicoLisp, la version Java et la
version Javascript (via NodeJS). Plus précisément, installer :

* PicoLisp, pour cela voir le fichier `install_picolisp.sh` (vous aurez par
  exemple besoin d’une chaîne d’outils de base pour la compilation de projets
  en C).
* Pas besoin d’installer les deux autres implémentations de PicoLisp (Java et
  NodeJS), mais besoin des plateformes sous-jacentes :
    * Java (pas besoin de `javac`).
    * [NodeJS](http://nodejs.org/download/) (`npm` compris, le gestionnaire de
      modules pour NodeJS).
* Différents outils, listés dans le fichier `.travis.yml`.
* Cloner [le dépôt](https://github.com/Microalg/Microalg).

## Utilisateur

### Windows

Veuillez noter qu’il n’est pas prévu de fournir d’installateur sour la forme
d’un `.exe`. On est aussi là pour faire un peu d’informatique.

#### Hors ligne

* MicroAlg
    * Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
    * Extraire l’archive quelque part, disons dans un dossier `microalg` de
      façon à avoir `microalg\INSTALL.md`, puis supprimer cette archive.
* Un serveur (au choix)
    * via Python
    * via CivetWeb (pour référence, [le dépôt Github](https://github.com/bel2125/civetweb))
        * Télécharger une version :
            * <http://sourceforge.net/projects/civetweb/files/1.5/civetweb-1.5-win.zip/download>
            * ou voir [ici](http://sourceforge.net/projects/civetweb/files/)
              s’il y mieux que 1.5
* Démarrer le serveur dans `microalg` et ouvrir le fichier `microalg\ide.html`
  dans un navigateur.

#### Avec Java

* Notepad++
    * Installer [Notepad++](http://www.notepad-plus-plus.org/), qui servira
      d’éditeur de fichiers et qui lancera leur exécution d’un simple `F5` (une
      sorte d’environnement de développement intégré,
      ou [IDE](https://fr.wikipedia.org/wiki/Environnement_de_d%C3%A9veloppement_int%C3%A9gr%C3%A9)).
    * Repérer où Notepad++ a été installé. On notera `chemin_NPP\notepad++.exe`.
* MicroAlg
    * Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
    * Extraire l’archive quelque part, puis supprimer cette archive.
    * Obtenir un dossier contenant les différents fichiers de l’archive (et non
      contenant un dossier seul contenant ces fichiers).
    * Renommer ce dernier dossier `microalg` et le déplacer dans `chemin_NPP`.
* Si votre ordinateur ne dispose pas de Java, il faut l’installer (si vous
  n’avez aucune idée de la marche à suivre, essayez
  [ce lien](http://lmgtfy.com/?q=+windows+installer+java)).
* Configurer Notepad++ :
    * Ouvrir un fichier donné en exemple dans l’archive de MicroAlg, par
      exemple `microalg/exemples/test_demander.malg`.
    * Appuyer sur `F5` ou choisir le menu `Run` puis l’action `Run…`.
    * Choisir le fichier qui va exécuter le code :
        * cliquer sur « parcourir » (le bouton `...`),
        * faire apparaître tous les fichiers en choisissant :  
          `Tous les fichiers : (*.*)`,
        * choisir `microalg/malgj_npp.bat`.
    * Ajouter à la main (si possible avec un copier/coller :  
      `"$(NPP_DIRECTORY)" "$(FULL_CURRENT_PATH)"`  
      de façon à obtenir dans la petite boîte :  
      `chemin\vers\malgj_npp.bat "$(NPP_DIRECTORY)" "$(FULL_CURRENT_PATH)"`
    * Valider avec `Entrée` ou le bouton `Run`.
* Et voilà.

#### Avec NodeJS

Pas simple : `sync-prompt` a besoin de Python lors de l’installation. Pour
l’instant pas d’autre module NodeJS pour un prompt synchro :

* `readline-sync` se plaint de la platforme Debian, ne fonctionne pas sous Win,
* `ask` est pour CoffeeScript,
* async :
    * `cli-prompt` <https://github.com/carlos8f/node-cli-prompt>
* rien à voir :
    * `commander` <https://github.com/visionmedia/commander.js> (parse args)
    * `prompter` <https://github.com/substack/node-prompter> (créer des JSON)
    * `promzard` <https://github.com/isaacs/promzard> (spécifique à un truc)

Bref, c’est pas encore ça.

* Installer [NodeJS](http://nodejs.org/download/) (`npm` compris, le
  gestionnaire de modules pour NodeJS)
* Installer le module `readline-sync` (sauf si pas d’utilisation de la commande
  `Demander`) 
    * Dans une console DOS : `npm install sync-prompt` puis `exit`
    <https://github.com/anseki/readline-sync>

### Autre

#### Hors ligne

terminal et python2

Vous savez comment démarrer un serveur web.

pour mac, 
    dl: http://sourceforge.net/projects/civetweb/files/ si > 1.5
    mac http://sourceforge.net/projects/civetweb/files/1.5/Civetweb-1.5.dmg/download

#### Avec PicoLisp

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

#### Avec Java

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

#### Avec NodeJS

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.
