(setq version "0.2.1")
(put 'version 'text (pack "MicroAlg version " version))
(setq apropos
"L’idée de MicroAlg est née lors d’une formation ISN, de la frustration due à
l’abscence d’un langage vraiment axé sur la pédagogie.  
À l’origine pensé comme DSL au sein de Tcl, il est finalement embarqué dans
PicoLisp.  
Voir <http://microalg.info>.")
(put 'apropos 'doc "Symbole contenant des informations sur MicroAlg.")

(setq symboles '(
"+" "-" "*" "/" "%" "**"
"!!!" "=" "=/" "<" "<=" ">" ">="
"Affecter_a" "Afficher" "Aide" "Alors"
"Booleen?"
"Concatener"
"Definir" "Demander"
"Et"
"Faire"
"Faux" "Faux?"
"Initialiser"
"Longueur"
"Nieme" "Nombre" "Nombre?" "Non"
"Ou"
"Queue"
"Retourner" "Rien"
"Si" "Sinon"
"Tant_que" "Tete" "Texte" "Texte?" "Type"
"Vide?" "Vrai" "Vrai?"
))

# picolisp.l shimz
(ifn caadr
  (de caadr (arg)
     (car (car (cdr arg)))
  )
)
(ifn glue
  (de glue (c l)
    (cond
      ((= 0 (length l)) "")
      ((= 1 (length l)) (car l))
      (T                (pack (car l) c  (glue c (cdr l))))
    )
  )
)
(ifn member
  (de member (elt lst)
    (let (result lst)
         (while (not (or (not (<> elt (car result)))
                         (not (n0 (length result)))))
                (pop 'result))
    result)
  )
)

# Vérif et conversions de booléens MicroAlg <-> PicoLisp:
(de !boolM2P (x) (if (<> Faux x) T NIL))
(de !boolP2M (x) (if x Vrai Faux))
(de !boolCheck (x) (if (member x '(Vrai Faux)) T))
(de !boolCheckM2P (x msg)
    (ifn (!boolCheck x) (quit msg x))
    (!boolM2P x) )

# Doc pour les fonctions PicoLisp
(put '+ 'doc
"Commande qui ajoute tous ses paramètres et retourne le résultat.")
(put '- 'doc
"Commande qui soustrait son second paramètre à son premier paramètre et retourne le résultat.")
(put '* 'doc
"Commande qui multiplie tous ses paramètres et retourne le résultat.")
(put '/ 'doc
"Commande qui divise son premier paramètre par son second paramètre et retourne le résultat.")
(put '% 'doc
"Commande qui retourne le reste de la division euclidienne de son premier paramètre par son second paramètre.")
(put '** 'doc
"Commande qui retourne son premier paramètre à la puissance du second paramètre.")

# Commentaires
(put '!!! 'doc
"Commande qui ne fait rien et sert pour les commentaires.")
(de !!! () Rien)

# Aide
(put 'Aide 'doc
"Commande qui permet d’obtenir de l’aide.")
(de Aide syms (let (truc (car syms)
                    doc (get truc 'doc))
                   (cond
                    ((== truc NIL) (get 'Aide 'text))
                    ((== truc 'symboles) (glue " " symboles))
                    (doc (pack "Aide pour `" truc "` :  ^J" doc))
                    ((eval truc) (pack "Pas d’aide pour " truc "."))
                    (T (pack "`" truc "’ n’existe pas."))
                   )))
(put 'Aide 'text
"MicroAlg permet de s’initier à l’algorithmique et à la programmation.  
Si vous ne l’avez pas déjà fait, commencez par le
[tutoriel](http://microalg.info/tuto.html).  

* `(Aide symboles)` pour une liste des symboles prédéfinis,
* `(Aide «quoi»)` (sans «») pour de l’aide sur quelque chose en particulier,
* `version` ou `apropos` pour des informations sur MicroAlg.")

# Afficher.
# Avec EmuLisp, l’affichage se fait au travers de la fonction _stdPrint,
# surchargée par stdPrint dans piljs ou ide_injection.js
# On garde une trace du dernier affichage dans la variable globale *LastStdOut.
(put 'Afficher 'doc
"Commande qui évalue son premier argument et l’affiche.  
Attention, certains symboles particuliers comme `aide` ou `version` ont des
comportements différents suivant qu’on les évalue, qu’on les affiche ou qu’on
les appelle.")
(put 'Afficher 'text "Commande `Afficher`.")
(setq *LastStdOut "?")
(de Afficher args
  (let (first (car args)
         second (cadr args)
         text (if (num? first) first (get first 'text))
         a_afficher (if text text (eval first)))
        (if second (quit (pack "`Afficher` n’accepte qu’un paramètre, faites "
                               "plusieurs affichages ou utilisez `Concaténer`." )))
        (setq *LastStdOut (if a_afficher a_afficher "?"))
        (ifn !testing
             (println (ifn a_afficher
                           (if (<> *EMUENV "browser")
                               " "
                               "&nbsp;")
                           a_afficher)))
        Rien  # Pas de valeur de retour
  )
)

# Concatener
(put 'Concatener 'doc
"Commande qui concatène les textes passés en paramètre.")
(put 'Concatener 'text "Commande `Concatener`.")
(de Concatener @ (let (
                       result (pack (rest))
                      )
                      (if result
                          result
                          ""
                      )))

# Gestion des variables
(put 'Initialiser 'doc
"Commande qui permet d’initialiser une variable avec une valeur.")
(put 'Initialiser 'text "Commande `Initialiser`.")
(de Initialiser arg_lst (let (nbr_args (length arg_lst))
                             (if (<> 2 nbr_args)
                                 (quit (pack "`Initialiser` prend 2 paramètres. "
                                             "Vous en donnez " nbr_args ".") )
                             )  # Du coup un deuxième arg NIL ne peut être que "".
                        )
                        (let (var (car arg_lst)
                              val (eval (cadr arg_lst))
                              type_var (get var 'type)
                              type_val (Type val))
                             (if (and type_var (<> type_val type_var))
                                 (quit (pack "Valeur de type " type_val ", ne peut initialiser "
                                             var " qui est de type " type_var "."))
                             )
                             (set var val)
                             (put var 'type (ifn val "texte" type_val))
                             Rien  # Pas de valeur de retour
                        ))
(put 'Affecter_a 'doc
"Commande qui permet d’affecter une valeur à une variable.")
(put 'Affecter_a 'text "Commande `Affecter_a`.")
(de Affecter_a arg_lst
    (let (preums (car arg_lst)
          deuz   (eval (cadr arg_lst))
          troiz  (eval (caddr arg_lst))
          var    preums
          val    (ifn troiz deuz troiz)
          idx    troiz)
         (ifn idx
              (prog
                 # Affectation au symbole dans `var`.
                 (ifn (get var 'type)
                      (quit "Variable non initialisée." var)
                 )
                 (if (or (not val)  # Pour accepter "" qui est NIL.
                         (<> Faux (= (get var 'type) (Type val))))
                     (set var val)
                     (quit "Le type ne correspond pas."
                           (list var 'est 'un (get var 'type) '; val 'un (Type val))
                     )
                 )
              )
              (prog
                 # Affectation à l’élément `idx` du symbole dans `var`.
              )
         )
         Rien  # Pas de valeur de retour
    )
)

# Tirages pseudo-aléatoires.
(put 'Decimal@ 'doc
"Retourne un nombre décimal pseudo-aléatoire dans [0;1[.

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.")
(put 'Decimal@ 'text "Commande `Decimal@`.")
(de Decimal@ () (/ (+ 2147483648 (rand)) 4294967296))
(put 'Entier@ 'doc
"Retourne un nombre entier pseudo-aléatoire dans [`min`;`max`].

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.")
(put 'Entier@ 'text "Commande `Entier@`.")
(de Entier@ arg_lst (let (nbr_args (length arg_lst))
                         (if (<> 2 nbr_args)
                             (quit (pack "`Entier@` prend 2 paramètres. "
                                         "Vous en donnez " nbr_args ".") )
                         )
                    )
                    (let (min (eval (car arg_lst))
                          max (eval (cadr arg_lst)))
                         (ifn (num? min) (quit "Le premier paramètre de `Entier@` doit être un nombre."))
                         (ifn (num? max) (quit "Le second paramètre de `Entier@` doit être un nombre."))
                         (rand min max)
                    )
)

# Demander.
# Avec EmuLisp, les entrées utilisateur se font au travers de la fonction
# _stdPrompt, surchargée dans ide_injection.js. Dans un navigateur, la dernière
# ligne ayant été affichée précédemment est réutilisée lors de l’appel à
# window.prompt.
(put 'Demander 'doc
"Commande qui permet de demander une valeur à l’utilisateur.")
(put 'Demander 'text "Commande `Demander`.")
(de Demander () (in NIL (read " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")))
# Références:
# https://fr.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange#Table_des_128_caract.C3.A8res_ASCII
# https://en.wikipedia.org/wiki/ASCII#ASCII_printable_character_code_chart
# >>> ''.join([chr(i) for i in range(32, 127) if not chr(i).isalnum()])
# ' !"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'                                       "

# Manipulations de texte
(put 'Longueur 'doc
"Commande qui retourne la longueur d’une liste.")
(put 'Longueur 'text "Commande `Longueur`.")
(de Longueur (obj)
    (length obj))
(put 'Nieme 'doc
"Permet d’accéder en lecture à un des éléments d’une liste (se lit « énième »).

La numérotation commence à 1.")
(put 'Nieme 'text "Commande `Nieme`.")
(de Nieme (obj idx)
    # Quelques vérifications
    (let (len (length obj))
      (cond
        ((not idx) (quit "Il manque le deuxième paramètre : l’indice."))
        ((<> idx (format (round idx 0))) (quit "Indice non entier." idx))
        ((le0 idx) (quit "Indice négatif ou nul." idx))
        ((le0 (- (length obj) idx)) (quit "Indice trop grand." (list idx '> len)))
      )
    )
    # Le calcul
    (cond
      ((str? obj) (car (nth (chop obj) idx)))
      #((lst? obj) (nth obj idx))
      (T Rien)
    ))
(put 'Tete 'doc
"Commande qui retourne le premier élément d’une liste.")
(put 'Tete 'text "Commande `Tete`.")
(de Tete (obj)
    # Quelques vérifications
    (if (!boolM2P (Vide? obj))
        (quit "Un objet vide n’a pas de tête.")
    )
    # Le calcul
    (cond
      ((str? obj) (car (chop obj)))
      #((lst? obj) (car obj))
      (T Rien)
    ))
(put 'Queue 'doc
"Commande qui retourne une copie du texte ou de la liste en paramètre `obj`, mais sans son premier élément.")
(put 'Queue 'text "Commande `Queue`.")
(de Queue (obj)
    # Quelques vérifications
    (if (!boolM2P (Vide? obj))
        (quit "Un objet vide n’a pas de queue.")
    )
    # Le calcul
    (cond
      ((str? obj) (pack (cdr (chop obj))))
      #((lst? obj) (cdr obj))
      (T Rien)
    ))

# Types et conversions
(put 'Type 'doc
"Commande qui retourne le type de son paramètre (sous forme de texte et
en minuscule).")
(put 'Type 'text "Commande `Type`.")
(de Type arg_lst
  (let (!x (car arg_lst)
        !evaled_x (eval !x))
       (cond
         ((<> Faux (Texte?   !evaled_x)) "texte")
         ((<> Faux (Booleen? !evaled_x)) "booleen")
         ((<> Faux (Nombre?  !evaled_x)) "nombre")
         ((<> Faux (== Rien  !evaled_x)) "rien")
         ((sym? x) (get !x 'type))
         (T Rien)
       ) ) )
(put 'Texte 'doc
"Commande qui retourne le texte correspondant à son paramètre.")
(put 'Texte 'text "Commande `Texte`.")
(de Texte (x) (cond
                ((str? x) x)
                ((num? x) (format x))
                (T NIL)
              ))
(put 'Nombre 'doc
"Commande qui retourne le nombre correspondant à son paramètre textuel.")
(put 'Nombre 'text "Commande `Nombre`.")
(de Nombre (x) (cond
                ((num? x) x)
                ((str? x) (or (format x) Rien))
                (T NIL)
              ))

# Structure conditionnelle
(put 'Vrai 'doc "Booléen valant Vrai.")
(setq Vrai 'Vrai)
(put 'Faux 'doc "Booléen valant Faux.")
(setq Faux 'Faux)
(put 'Alors 'doc "Mot-clef intermédiaire pour la commande `Si`.")
(setq Alors 'Alors)
(put 'Sinon 'doc "Mot-clef intermédiaire pour la commande `Si`.")
(setq Sinon 'Sinon)
(put 'Si 'doc
"Structure conditionnelle, de la forme `Si ... Alors ... Sinon ...` où le
`Sinon` est facultatif.")
(put 'Si 'text "Commande `Si`.")
(de Si arg_lst (let (condition (car arg_lst)
                     kw_alors  (cadr arg_lst)
                     splitted  (split (cddr arg_lst) 'Sinon)
                     bloc_vrai (car splitted)
                     bloc_faux (cadr splitted))
                    (if (<> Alors kw_alors) (quit "Mot-clef `Alors` manquant."))
                    (if (!boolCheckM2P (eval condition) "La condition n’est pas un booléen.")
                        (run bloc_vrai)
                        (if (== NIL bloc_faux)
                            Rien
                            (run bloc_faux)))))

# Opérations logiques
(put 'Non 'doc
"Non logique.

Voir <http://fr.wikipedia.org/wiki/Fonction_NON>.")
(put 'Non 'text "Commande `Non`.")
(de Non (P)
    (ifn (!boolCheck P) (quit "`Non` prend un paramètre booléen."))
    (!boolP2M (not (!boolM2P P))) )
(put 'Et 'doc
"Et logique.

Voir <http://fr.wikipedia.org/wiki/Fonction_ET>.")
(put 'Et 'text "Commande `Et`.")
(de Et (P Q)
    (ifn (!boolCheck P) (quit "Le premier paramètre de `Et` doit être un booléen."))
    (ifn (!boolCheck Q) (quit "Le second paramètre de `Et` doit être un booléen."))
    (!boolP2M (and (!boolM2P P) (!boolM2P Q))) )
(put 'Ou 'doc
"Ou logique.

Voir <http://fr.wikipedia.org/wiki/Fonction_OU>.")
(put 'Ou 'text "Commande `Ou`.")
(de Ou (P Q)
    (ifn (!boolCheck P) (quit "Le premier paramètre de `Ou` doit être un booléen."))
    (ifn (!boolCheck Q) (quit "Le second paramètre de `Ou` doit être un booléen."))
    (!boolP2M (or (!boolM2P P) (!boolM2P Q))) )

# Structures itératives
(put 'Tant_que 'doc
"Structure itérative de type « tant que ... faire ... ».")
(put 'Tant_que 'text "Commande `Tant_que`.")
(de Tant_que arg_lst (let (Bool (car arg_lst)
                           Mot-Clef (cadr arg_lst)
                           Corps (cddr arg_lst))
                          (if (<> 'Faire Mot-Clef) (quit "Commande `Tant_que` sans mot-clé `Faire`."))
                          (while (!boolCheckM2P (eval Bool) "La condition n’est pas un booléen.")
                                 (run Corps))
                          Rien
                     )
)
(put 'Faire 'doc
"Structure itérative de type « faire ... tant que ... ».")
(put 'Faire 'text "Commande `Faire`.")
(de Faire arg_lst (let (Splitted (split arg_lst 'Tant_que)
                        Corps (car Splitted)
                        Bool (caadr Splitted))
                       (ifn (<> arg_lst Corps) (quit "Commande `Faire` sans mot-clé `Tant_que`."))
                       (run Corps)
                       (if (!boolCheckM2P (eval Bool) "La condition n’est pas un booléen.")
                           (while (!boolCheckM2P (eval Bool) "La condition n’est pas un booléen.")
                                  (run Corps)))
                       Rien
                  )
)

# Procédures utilisateur
(put 'Definir 'doc
"Permet de définir une nouvelle commande (fonction mathématique ou procédure).

La syntaxe de cette commande est :

    (Definir (Nom_de_la_nouvelle_commande arg1 arg2 ...)
        \"Une phrase expliquant le rôle de cette commande.\"
        \"L’auteur de cette commande.\"
        (...    ici les     ...)
        (...  instructions  ...)
        (... de la commande ...)
        (Retourner la_valeur_de_retour)
    )

Il peut être intéressant de signer ses créations avec le pseudo utilisé sur
[les questions/réponses](http://qr.microalg.info).

Exemple 1 :

    (Definir (Double x)
        \"Retourne le double du nombre (paramètre `x`).\"
        \"anonyme\"
        (Retourner (* 2 x))
    )

Exemple 2 :

    (Definir (Crier texte)
        \"Affiche le texte (paramètre `texte`) avec un point d’exclamation.\"
        \"ProfGra\"
        (Afficher (Concatener texte \" !\"))
        (Retourner Rien)
    )
")
(put 'Definir 'text "Commande `Definir`.")
(de Definir arg_lst
  (let (signature (car arg_lst)
        nom       (car signature)
        params    (cdr signature)
        corps     (cdr arg_lst)
        doc       (car corps)
        auteur    (cadr corps))
       (ifn (str? doc)
            (put nom 'doc Rien)
            (put nom 'doc (pack "`(" (str signature) ")` : " doc)))
       (ifn (str? auteur) (setq auteur "un auteur anonyme"))
       (put nom 'text (pack "Commande `"
                            (str nom)
                            "`, définie par *"
                            auteur
                            "*."))
       (set nom (list params (list 'run (cons 'quote corps))))
       Rien  # Pas de valeur de retour
  )
)
(put 'Retourner 'doc
"Dernière instruction du corps d’une commande définie avec `Definir`.
Indique la valeur que cette commande va retourner.

Utiliser `(Retourner Rien)` pour ne rien retourner.

**Attention !** Cette instruction doit être la dernière de la commande créée car
`Retourner` n’en interrompt pas l’exécution.")
(put 'Retourner 'text "Commande `Retourner`.")
(de Retourner (val) val)

# Prédicats
(put 'Vrai? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est `Vrai`,
et `Faux` sinon.")
(put 'Vrai? 'text "Prédicat `Vrai?`.")
(de Vrai? (x) (if (<> x Faux) Vrai Faux))
(put 'Faux? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est `Faux`,
et `Faux` sinon.")
(put 'Faux? 'text "Prédicat `Faux?`.")
(de Faux? (x) (if (<> x Vrai) Vrai Faux))
(put 'Texte? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est du texte,
et `Faux` sinon.")
(put 'Texte? 'text "Prédicat `Texte?`.")
(de Texte? (x) (if (str? x) Vrai Faux))
(put 'Nombre? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est un nombre,
et `Faux` sinon.")
(put 'Nombre? 'text "Prédicat `Nombre?`.")
(de Nombre? (x) (if (num? x) Vrai Faux))
(put 'Booleen? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est un booleen,
et `Faux` sinon.")
(put 'Booleen? 'text "Prédicat `Booleen?`.")
(de Booleen? (x) (if (or (== Vrai x) (== Faux x)) Vrai Faux))
# Sans le suffixe '?'
# Éviter le message « redefined »
(setq = NIL)
(setq < NIL)
(setq <= NIL)
(setq > NIL)
(setq >= NIL)
(put '= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont égales,
et `Faux` sinon.")
(put '= 'text "Prédicat `=`.")
(de = (x y) (ifn (<> x y) Vrai Faux))
(put '=/ 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
différentes, et `Faux` sinon.")
(put '=/ 'text "Prédicat `=/`.")
(de =/ (x y) (if (<> x y) Vrai Faux))
(put '< 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre croissant (strictement), et `Faux` sinon.")
(put '< 'text "Prédicat `<`.")
(de < (x y) (ifn (ge0 (- x y)) Vrai Faux))
(put '<= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre croissant.")
(put '<= 'text "Prédicat `<=`.")
(de <= (x y) (if (le0 (- x y)) Vrai Faux))
(put '> 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre décroissant (strictement), et `Faux` sinon.")
(put '> 'text "Prédicat `>`.")
(de > (x y) (ifn (le0 (- x y)) Vrai Faux))
(put '>= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre décroissant.")
(put '>= 'text "Prédicat `>=`.")
(de >= (x y) (if (ge0 (- x y)) Vrai Faux))
(put 'Vide? 'doc
"Prédicat retournant `Vrai` si l’argument est considéré comme vide.

* **Textes** : le seul texte vide est `\"\"`.
")
(put 'Vide? 'text "Prédicat `Vide?`.")
(de Vide? (obj)
    (if (<> 0 (length obj)) Faux Vrai))

# Rien
(put 'Rien 'doc
"Valeur de contenant aucune information, représentant l’absence de valeur.")
(setq Rien 'Rien)

# Ignorer les balises de la galerie (http://galerie.microalg.info) si utilisées
# par inadvertance, ou une fois de trop dans la galerie.
(de MicroAlg arg_lst
    (Afficher
        (pack "L’instruction `(MicroAlg ...)` est une instruction fantôme.  ^J"
              "Merci de la supprimer, elle ne sert que pour la galerie  ^J"
              "(<http://galerie.microalg.info>).") ) )
(de /MicroAlg arg_lst
    (Afficher
        (pack "L’instruction `(/MicroAlg)` est une instruction fantôme.  ^J"
              "Merci de la supprimer, elle ne sert que pour la galerie  ^J"
              "(<http://galerie.microalg.info>).") ) )
