Installation
============

Cette page est accessible
[ici](https://github.com/Microalg/Microalg/blob/latest/INSTALL.md).

Aller directement à :

* Windows :
    * édition avec SciTE :
        * [instructions](#user-content-scite)
        * [lien direct vers le zip](https://github.com/Microalg/Microalg/releases/download/v0.4.07/microalg_0.4.07.zip)
          correspondant aux instructions
* Autre (sauf Mac) :
    * [édition avec SciTE](#user-content-scite-1)
* Android :
    * [page Google Play](https://play.google.com/store/apps/details?id=info.microalg.android)
* [Installer sur son site](#user-content-installer-sur-son-site)
* Développeur :
    * [tout sauf Windows](#user-content-développeur)
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
* Installer [MicroAlg sur son site](#user-content-installer-sur-son-site)
* Installation pour développeur/contributeur…
    * …au [cœur de MicroAlg](#user-content-développeur) (attention, il n’y a pas
      d’environnement de développement pour Windows ou Android),
    * …à la documentation, tutoriels… chercher ci-dessous un lien pour
      « utilisation possible sans connexion » adaptée à votre système
      d’exploitation.
* Installation pour utilisateur
    * Windows
        * simple utilisateur
            * dans un navigateur, mais utilisation possible sans connexion
            * [édition avec SciTE, exécution avec Java](#user-content-scite)
        * utilisateur avancé
            * les mêmes
            * le vrai PicoLisp dans Cygwin
    * Mac
        * dans un navigateur, mais utilisation possible sans connexion
        * Pour le reste, aucune idée, voir peut-être les instructions pour « Autre ».
    * [Application Android](https://play.google.com/store/apps/details?id=info.microalg.android)
    * Autre
        * dans un navigateur, mais utilisation possible sans connexion
        * [édition avec SciTE, exécution avec PicoLisp](#user-content-scite-1)
        * avec le vrai PicoLisp (C et assembleur)
        * avec Ersatz (Java)
        * avec EmuLisp (NodeJS)

## Installer sur son site

* Télécharger [ce zip](https://github.com/Microalg/Microalg/archive/v0.4.07.zip).
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
  NodeJS), mais besoin des plates-formes sous-jacentes :
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
    * Télécharger [ce zip](https://github.com/Microalg/Microalg/releases/download/v0.4.07/microalg_0.4.07.zip).
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

#### SciTE

Vous pouvez télécharger le résultat des instructions suivantes
[directement ici](https://github.com/Microalg/Microalg/releases/download/v0.4.07/microalg_0.4.07.zip).

* MicroAlg
    * Télécharger [ce zip](https://github.com/Microalg/Microalg/archive/v0.4.07.zip).
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
* Si vous ne voulez pas utiliser NodeJS, ou si vous ne savez pas ce que c’est,
  il vous faut Java. Et si votre ordinateur ne dispose pas de Java (cliquer
  [ici](https://www.java.com/en/download/installed.jsp) pour vérifier), il faut
  l’installer (si vous n’avez aucune idée de la marche à suivre, essayez
  [ce lien](http://lmgtfy.com/?q=+windows+installer+java)).
* Si vous voulez utiliser NodeJS, il faut :
    * l’installer ([page téléchargements](http://nodejs.org/download/))
      (`npm` compris, le gestionnaire de modules pour NodeJS).
    * Installer le module `readline-sync`
      ([npm](https://www.npmjs.com/package/readline-sync),
      [github](https://github.com/anseki/readline-sync))
      en tapant dans une console DOS :  
      `npm install -g readline-sync`  
* Et voilà, il ne reste plus qu’à double-cliquer sur `editeurs/scite/SC???.exe`
  (ou sur `00_SciTE.bat` si vous avez téléchargé l’archive).  
  Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#scite).  
  S’il tournait déjà, redémarrer SciTE pour prendre en compte l’installation de
  NodeJS.
* L’implémentation par défaut est lente. Si vous n’utilisez que des nombres
  entiers, vous pouvez utiliser une version de MicroAlg sans nombres à virgule,
  mais plus rapide. Pour cela, allez dans le menu **View** puis **Parameters**,
  indiquer `malg-j` au lieu de `malg-rjs`.  
  Pour une configuration permanente, allez dans `editeurs/scite/microalg.lua`
  et changez
  <pre><code>-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-j-scite.bat $(FilePath)"
-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-njs-scite.bat $(FilePath)"
props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-rjs-scite.bat $(FilePath)"</code></pre>
    en
  <pre><code>props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-j-scite.bat $(FilePath)"
-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-njs-scite.bat $(FilePath)"
-- props["command.go.*.malg"] = "$(SciteDefaultHome)\\malg-rjs-scite.bat $(FilePath)"</code></pre>

Pour la sortie graphique :

* Télécharger Processing depuis [cette page](https://processing.org/download/)
  dans la version qui correspond à votre machine (64 ou 32 bits).
* Désarchiver.
* Renommer le dossier obtenu en `processing`.
* Déplacer le dossier obtenu dans votre installation de MicroAlg.
* Au final, le fichier `processing-java.exe` doit avoir pour chemin relatif :  
  `microalg/processing/processing-java.exe`.
* Démarrer la fenêtre graphique en double-cliquant sur  
  `microalg/start_processing.bat`.
* Démarrer SciTE, puis dans le menu **View** puis **Parameters**, indiquer
  `malg-j` au lieu de `malg-rjs`.
* Dans SciTE, ouvrir le fichier `exemples/test_algues.malg` et l’exécuter en
  appuyant sur `F5`.

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
       * Télécharger [ce zip](https://github.com/Microalg/Microalg/archive/v0.4.07.zip).
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
    * Faire un lien symbolique du fichier `SciTEGlobal.properties` (modifié
      précédemment) dans votre répertoire personnel. Pour cela, taper dans un
      terminal :  
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

Pour la sortie graphique :

* Installer Processing quelque part et ajouter `processing-java` au *PATH*.
    * Si vous n’utilisez pas le JDK de Sun, tapez ceci depuis votre installation
      de Processing :
        * `mv java java-from-processing`
        * `ln -s /usr/lib/jvm/j2sdk1.7-oracle java`
* Démarrer la fenêtre graphique grâce à `microalg/start_processing.sh`
* Démarrer SciTE, puis dans le menu **View** puis **Parameters**, indiquer
  `malg-j` (ou `malg` si vous êtes au top) au lieu de `malg-njs`.
* Dans SciTE, ouvrir le fichier `exemples/test_algues.malg` et l’exécuter en
  appuyant sur `F5`.

##### Version longue pour les confirmés

* MicroAlg
    * Récupérer les fichiers
        * Si vous voulez utiliser git et pouvoir récupérer les dernières
          versions :  
          `git clone http://github.com/Microalg/Microalg.git microalg`
        * Sinon à partir d’une archive inerte :
           * Télécharger [ce zip](https://github.com/Microalg/Microalg/archive/v0.4.07.zip).
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
      un lien symbolique vers votre répertoire personnel en changeant le nom
      du fichier. Pour cela, taper :  
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
    * Une fois l’implémentation choisie, il faut paramétrer SciTE pour qu’il
      utilise la bonne. Pour cela, allez dans le menu **View** puis
      **Parameters** et indiquer `malg`, `malg-j`, `malg-njs` ou `malg-rjs`.  
      Pour une configuration permanente, il faudra ajuster le fichier
      `editeurs/scite/microalg.lua` en conséquence. Il suffit de commenter ou
      décommenter astucieusement des lignes dans `editeurs/scite/SciTEGlobal.properties`,
      vers :
      <pre><code>if uname_s == "Linux" then
        -- props["command.go.\*.malg"] = "$(microalg_path)/malg $(FilePath)"
        -- props["command.go.\*.malg"] = "$(microalg_path)/malg-j $(FilePath)"
        -- props["command.go.\*.malg"] = "$(microalg_path)/malg-njs $(FilePath)"
        props["command.go.*.malg"] = "$(microalg_path)/malg-rjs $(FilePath)"</code></pre>
* Et voilà. Pour plus d’informations sur l’utilisation en elle-même, voir
  [la documentation](http://microalg.info/doc.html#scite). Pour exécuter un
  programme, il faudra taper sur `F5`.

Pour la sortie graphique :

* Installer Processing quelque part et ajouter `processing-java` au *PATH*.
    * Si vous n’utilisez pas le JDK de Sun, tapez ceci depuis votre installation
      de Processing :
        * `mv java java-from-processing`
        * `ln -s /usr/lib/jvm/j2sdk1.7-oracle java`
* Démarrer la fenêtre graphique grâce à `microalg/start_processing.sh`
* Démarrer SciTE, puis dans le menu **View** puis **Parameters**, indiquer
  `malg-j` (ou `malg` si vous êtes au top) au lieu de `malg-njs`.
* Dans SciTE, ouvrir le fichier `exemples/test_algues.malg` et l’exécuter en
  appuyant sur `F5`.


#### En ligne de commande

##### Avec PicoLisp

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

##### Avec Java

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

##### Avec NodeJS

Penser à utiliser `rlwrap` de `readline` pour un terminal plus pratique.

