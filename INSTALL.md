Installation
============

Cette page est accessible
[ici](https://github.com/Microalg/Microalg/blob/latest/INSTALL.md).

Aller directement à :

* Windows :
    * édition avec SciTE :
        * exécution avec Java
            * [instructions](#scite-avec-java)
            * [lien direct vers le zip](https://github.com/Microalg/Microalg/releases/download/v0.2.6/microalg_0.2.6.zip)
              correspondant aux instructions
    * édition avec Notepad++ :
        * [exécution avec Java](#notepad-avec-java)
        * [exécution avec NodeJS](#notepad-avec-nodejs)
* Autre (sauf Mac) :
    * [édition avec SciTE](#scite) (exécution au choix et facilement configurable)
* Android :
    * [page Google Play](https://play.google.com/store/apps/details?id=info.microalg.android)
* [Installer sur son site](#installer-sur-son-site)
* Développeur :
    * [tout sauf Windows](#développeur)
* Utilisation en ligne (rien à installer !) :
    * [Galerie Web](http://galerie.microalg.info/) (wiki avec code exécutable
      dans le navigateur)
    * [Web IDE](http://microalg.info/ide.html) (un éditeur et une console
      expérimentale)

Si vous trouvez une faute d’orthographe, ou si vous rencontrez un problème
d’installation, merci de (au choix) :

* proposer une « pull request » en éditant directement un fichier sur
  [Github](https://github.com/Microalg/Microalg),
* poster une « issue » sur
  [Github](https://github.com/Microalg/Microalg),
* m’envoyer [un email](mailto:profgra.org@gmail.com).

## Table des matières

Cette page peut paraître longue, mais c’est uniquement parce qu’il y a
beaucoup de façons d’installer MicroAlg. À vous de choisir celle qui vous
convient (sans lien, c’est que la section n’est pas encore rédigée) :

* Utiliser [MicroAlg en ligne](http://microalg.info/ide.html) :
  rien à installer !
* Installer [MicroAlg sur son site](#installer-sur-son-site)
* Installation pour développeur/contributeur…
    * …au [cœur de MicroAlg](#développeur) (attention, il n’y a pas
      d’environnement de développement pour Windows ou Android),
    * …à la documentation, tutoriels… chercher ci-dessous un lien pour
      « utilisation possible sans connexion » adaptée à votre système
      d’exploitation.
* Installation pour utilisateur
    * Windows
        * simple utilisateur
            * dans un navigateur, mais utilisation possible sans connexion
            * [édition avec SciTE, exécution avec Java](#scite-avec-java)
            * [édition avec NotePad++, exécution avec Java](#notepad-avec-java)
            * [édition avec NotePad++, exécution avec NodeJS](#notepad-avec-nodejs)
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
        * [édition avec SciTE, exécution avec PicoLisp](#scite)
        * avec le vrai PicoLisp (C et assembleur)
        * avec Ersatz (Java)
        * avec EmuLisp (NodeJS)

## Installer sur son site

* Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
* Extraire quelque part dans l’arborescence de votre site.
* Ajuster des URLS codées en dur (un jour, elles seront configurables) dans
  `web/ide_injections.js` :
    * si vous déplacez les `*.l` par rapport à `web/ide_injections.js`, il
      faut donner à `this_script_path` le chemin allant des `*.l` vers ce
      fichier JS ;
    * dans le fichier HTML virtuel commençant à  
      `var content = '<!DOCTYPE html>'...`  
      il faut indiquer le chemin allant de la racine de votre site vers les
      fichiers concernant Blockly.
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

Il faut pouvoir tester les quatre versions : le vrai PicoLisp, la version Java
et les versions Javascript (via Rhino et NodeJS). Plus précisément, installer :

* PicoLisp, pour cela voir le fichier `install_picolisp.sh` (vous aurez par
  exemple besoin d’une chaîne d’outils de base pour la compilation de projets
  en C).
* Pas besoin d’installer les trois autres implémentations de PicoLisp (Java et
  NodeJS), mais besoin des plateformes sous-jacentes :
    * Java (pas besoin de `javac`), pour faire tourner Ersatz et Rhino ;
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

Notez que pour être totalement indépendant d’Internet, il vous faudra
télécharger localement une version de *jQuery* [ici](http://jquery.com/download/).
Vous pourrez prendre une version compressée (*compressed*) de jQuery 1.x ou
même, si vos utilisateurs n’ont pas IE 6, 7 ou 8, de jQuery 2.x.

En supposant que vous l’avez téléchargée dans `microalg/web`, remplacez dans
tous vos fichiers `.html`

    src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"

par

    src="web/jquery-version.min.js"

avec le bon numéro de `version` bien sûr.

#### SciTE avec Java

Vous pouvez télécharger le résultat des instructions suivantes
[directement ici](https://github.com/Microalg/Microalg/releases/download/v0.2.6/microalg_0.2.6.zip).

* MicroAlg
    * Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
    * Extraire l’archive quelque part, puis supprimer cette archive.
    * Obtenir un dossier contenant les différents fichiers de l’archive (et non
      contenant un dossier seul contenant ces fichiers).
    * Renommer ce dernier dossier `microalg` et le déplacer dans votre espace
      de travail. Par exemple un lecteur amovible devrait faire l’affaire.
* SciTE
    * Télécharger le « single file executable called Sc1 » sur
      [la page de téléchargement](http://www.scintilla.org/SciTEDownload.html)
      de SciTE, puis le déposer dans le dossier `microalg/editeurs/scite`
      (`microalg` est bien sûr le dossier de l’étape précédente).
* Si votre ordinateur ne dispose pas de Java, il faut l’installer (si vous
  n’avez aucune idée de la marche à suivre, essayez
  [ce lien](http://lmgtfy.com/?q=+windows+installer+java)).
* Et voilà, il ne reste plus qu’à double-cliquer sur `editeurs/scite/SC???.exe`.  
  Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#scite).
* L’implémentation par défaut est lente. Si vous n’utilisez que des nombres
  entiers, allez dans `editeurs/scite/microalg.lua` changer
  <pre><code>-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-j-scite.bat $(FilePath)"
-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-njs-scite.bat $(FilePath)"
props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-rjs-scite.bat $(FilePath)"</code></pre>
    en
  <pre><code>props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-j-scite.bat $(FilePath)"
-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-njs-scite.bat $(FilePath)"
-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-rjs-scite.bat $(FilePath)"</code></pre>

#### Notepad++ avec Java

* Notepad++
    * Installer [Notepad++](http://www.notepad-plus-plus.org/), qui servira
      d’éditeur de fichiers et qui lancera leur exécution d’un simple `F5` (une
      sorte d’environnement de développement intégré,
      ou [IDE](https://fr.wikipedia.org/wiki/Environnement_de_d%C3%A9veloppement_int%C3%A9gr%C3%A9)).
    * Il est tout à fait possible de l’installer sur un disque amovible. Ainsi,
      vous pouvez garder votre environnement de travail avec vous.
* MicroAlg
    * Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
    * Extraire l’archive quelque part, puis supprimer cette archive.
    * Obtenir un dossier contenant les différents fichiers de l’archive (et non
      contenant un dossier seul contenant ces fichiers).
    * Renommer ce dernier dossier `microalg`.
    * Déplacer ce dossier `microalg` afin de ne pas avoir d’espaces dans son
      chemin. Le lecteur amovible devrait faire l’affaire.
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
        * choisir `microalg/editeurs/npp/malgj_npp.bat`.
    * Ajouter à la main (si possible avec un copier/coller) :  
      `"$(FULL_CURRENT_PATH)"`  
      de façon à obtenir dans la petite boîte :  
      `chemin\vers\malgj_npp.bat "$(FULL_CURRENT_PATH)"`
    * Valider avec `Entrée` ou le bouton `Run`.
    * Si cela fonctionne, vous pouvez rappuyer sur `F5` et cette fois-ci
      enregistrer cette commande. Il est très conseillé de cliquer sur `Save…`
      pour ne pas avoir à refaire cette manipulation et d’associer à cette
      commande un nom (comme `malg`) et un raccourci clavier (différent de
      `F5`, par exemple `Ctrl`+`F5`).
* Et voilà. Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#notepad).

#### Notepad++ avec NodeJS

* Installer [NodeJS](http://nodejs.org/download/) (`npm` compris, le
  gestionnaire de modules pour NodeJS).
* Installer le module `readline-sync` (<https://github.com/anseki/readline-sync>)
  en tapant dans une console DOS :  
  `npm install -g readline-sync`  
  Vous devriez obtenir :
  <pre><code>    D:\microalg>npm install -g readline-sync
    npm http GET https://registry.npmjs.org/readline-sync
    npm http 304 https://registry.npmjs.org/readline-sync
    readline-sync@0.2.5 C:\Users\prof\AppData\Roaming\npm\node_modules\readline-sync</code></pre>

<!--
Pour les archives, voici une liste d’autre modules candidats à un prompt
asynchrone :

* `sync-prompt` <https://github.com/shovon/sync-prompt/>  
  A besoin de Python lors de l’installation (et encore, foire sous Windows).
* `ask` est pour CoffeeScript.
* avec callback :
    * <http://nodejs.org/api/readline.html>
    * <https://github.com/flatiron/prompt>
    * <https://github.com/carlos8f/node-cli-prompt>
    * [doc sur nodejitsu](http://docs.nodejitsu.com/articles/command-line/how-to-prompt-for-command-line-input)
* rien à voir :
    * `commander` <https://github.com/visionmedia/commander.js> (parse args)
    * `prompter` <https://github.com/substack/node-prompter> (créer des JSON)
    * `promzard` <https://github.com/isaacs/promzard> (spécifique à un truc)
-->

* Configurer Notepad++ :
    * Ouvrir un fichier donné en exemple dans l’archive de MicroAlg, par
      exemple `microalg/exemples/test_demander.malg`.
    * Appuyer sur `F5` ou choisir le menu `Run` puis l’action `Run…`.
    * Choisir le fichier qui va exécuter le code :
        * cliquer sur « parcourir » (le bouton `...`),
        * faire apparaître tous les fichiers en choisissant :  
          `Tous les fichiers : (*.*)`,
        * choisir `microalg/editeurs/npp/malgjs_npp.bat`.
    * Ajouter à la main (si possible avec un copier/coller) :  
      `"$(FULL_CURRENT_PATH)"`  
      de façon à obtenir dans la petite boîte :  
      `chemin\vers\malgjs_npp.bat "$(FULL_CURRENT_PATH)"`
    * Valider avec `Entrée` ou le bouton `Run`.
    * Si cela fonctionne, vous pouvez rappuyer sur `F5` et cette fois-ci
      enregistrer cette commande et même lui associer un raccourci clavier.
* Et voilà. Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#notepad).

### Autre

#### Hors ligne

Pour démarrer un serveur grâce à Python2 (qui doit être installé par défaut
sur votre machine) :

* Ouvrir un terminal
* Naviguer vers `microalg`
* Lancer la commande `python -m SimpleHTTPServer 8080`
* Vous pouvez accéder par exemple au tutoriel à l’adresse :  
  `http://127.0.0.1:8080/tuto.html`

<!--
pour mac, 
    dl: http://sourceforge.net/projects/civetweb/files/ si > 1.5
    mac http://sourceforge.net/projects/civetweb/files/1.5/Civetweb-1.5.dmg/download
-->

Notez que pour être totalement indépendant d’Internet, il vous faudra
télécharger localement une version de *jQuery* [ici](http://jquery.com/download/).
Vous pourrez prendre une version compressée (*compressed*) de jQuery 1.x ou
même, si vos utilisateurs n’ont pas IE 6, 7 ou 8, de jQuery 2.x.

En supposant que vous l’avez téléchargée dans `microalg/web`, remplacez dans
tous vos fichiers `.html`

    src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"

par

    src="web/jquery-version.min.js"

avec le bon numéro de `version` bien sûr.

#### SciTE

##### Version courte pour les apprentis

* MicroAlg
    * Récupérer les fichiers
       * Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
       * Extraire l’archive quelque part, puis supprimer cette archive.
       * Obtenir un répertoire contenant les différents fichiers de l’archive (et
         non contenant un répertoire seul contenant ces fichiers).
       * Renommer ce dernier répertoire `microalg` et le déplacer dans votre espace
         de travail. Par exemple un lecteur amovible devrait faire l’affaire.
    * Configuration
       * Disons que la récupération des fichiers vous a donné :  
         `/chemin/absolu/vers/microalg`.
       * Dans le fichier
         `/chemin/absolu/vers/microalg/editeurs/scite/SciTEGlobal.properties`,  
         ajuster la valeur de `microalg_path` en lui donnant justement la
         valeur `/chemin/absolu/vers/microalg` (sans le dernier `/`).
* SciTE
    * Utiliser le gestionnaire de paquets de votre distribution (le paquet
      s’appelle bêtement `scite` dans la plupart des cas) ou les liens de
      [la page de téléchargements de SciTE](http://www.scintilla.org/SciTEDownload.html).
    * Faire un lien symbolique du fichier `SciTEGlobal.properties` fourni vers
      votre répertoire personnel. Taper dans un terminal :  
      `ln -sf /chemin/absolu/vers/microalg/editeurs/scite/SciTEGlobal.properties ~/.SciTEUser.properties`
* Relier les deux
    * Java devrait déjà être installé sur votre machine.  
      Taper `which java` dans un terminal pour le vérifier.  Si ça répond,
      c’est que c’est bon. Sinon, il faut
      [installer Java](https://www.java.com/fr/download/) ou passer à la
      version longue des instructions.
* Et voilà. Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#scite). Pour exécuter un
  programme, il faudra taper sur `F5`.

##### Version longue pour les confirmés

* MicroAlg
    * Récupérer les fichiers
        * Si vous voulez utiliser git et pouvoir récupérer les dernières
          versions :  
          `git clone http://github.com/Microalg/Microalg.git microalg`
        * Sinon à partir d’une archive inerte :
           * Télécharger <https://github.com/Microalg/Microalg/archive/latest.zip>.
           * Extraire l’archive quelque part, puis supprimer cette archive.
           * Obtenir un répertoire contenant les différents fichiers de l’archive (et
             non contenant un répertoire seul contenant ces fichiers).
           * Renommer ce dernier répertoire `microalg` et le déplacer dans votre espace
             de travail. Par exemple un lecteur amovible devrait faire l’affaire.
    * Configuration
       * Disons que la récupération des fichiers vous a donné :  
         `/chemin/absolu/vers/microalg`.
       * Par défaut, dans le fichier
         `/chemin/absolu/vers/microalg/editeurs/scite/SciTEGlobal.properties`,  
         la valeur de `microalg_path` est `/opt/microalg`. Deux possibilités :  
           **1)** lui donner la valeur `/chemin/absolu/vers/microalg` (sans le
             dernier `/`), mais à chaque mise à jour, il faudra refaire cette
             modification ;  
           **2)** laisser `/opt/microalg`, mais créer un lien symbolique de
             `/opt/microalg` vers `/chemin/absolu/vers/microalg` (la commande
             ressemblera à :  
             `ln -s /chemin/absolu/vers/microalg /opt/microalg`).
* SciTE
    * Utiliser le gestionnaire de paquets de votre distribution (le paquet
      s’appelle bêtement `scite` dans la plupart des cas) ou les liens de
      [la page de téléchargements de SciTE](http://www.scintilla.org/SciTEDownload.html).
    * Le fichier `SciTEGlobal.properties` fourni dans le dépôt MicroAlg est
      prévu pour vivre dans le même répertoire que l’exécutable `scite`. Faire
      un lien symbolique vers votre répertoire personnel avec :  
      `ln -sf /chemin/absolu/vers/microalg/editeurs/scite/SciTEGlobal.properties ~/.SciTEUser.properties`
* Relier les deux
    * Suivant l’implémentation de PicoLisp que vous voulez utiliser, vous devrez
      installer au choix (un seul suffit) :
        * Java, la solution la plus facile car Java devrait déjà être installé.
          Taper `which java` pour le vérifier.  Si ça répond, c’est que c’est
          bon. Sinon, il faut [installer Java](https://www.java.com/fr/download/).
        * PicoLisp (il faut pour l’instant une installation « à la main », voir
          le fichier `install_scripts/install_picolisp.sh`).
        * NodeJS.
    * Une fois l’implémentation choisie, il faudra ajuster le fichier
      `editeurs/scite/microalg.lua` en conséquence. Il suffit de commenter ou
      décommenter astucieusement des lignes dans `editeurs/scite/SciTEGlobal.properties`,
      vers :
      <pre><code>if uname_s == "Linux" then
        -- props["command.go.*.malg"] = "$(microalg_path)/malg $(FilePath)"
        -- props["command.go.*.malg"] = "$(microalg_path)/malg-j $(FilePath)"
        -- props["command.go.*.malg"] = "$(microalg_path)/malg-njs $(FilePath)"
        props["command.go.*.malg"] = "$(microalg_path)/malg-rjs $(FilePath)"</code></pre>
* Et voilà. Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#scite). Pour exécuter un
  programme, il faudra taper sur `F5`.

#### En ligne de commande

##### Avec PicoLisp

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

##### Avec Java

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

##### Avec NodeJS

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

