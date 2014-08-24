(put 'version 'text "MicroAlg version 0.1.0")
(setq version "0.1.0")
(setq apropos
"L’idée de MicroAlg est née lors d’une formation ISN, de la frustration due à
l’abscence d’un langage vraiment axé sur la pédagogie.  
À l’origine pensé comme DSL au sein de Tcl, il est finalement embarqué dans
PicoLisp.  
Voir <http://microalg.info>.")
(put 'apropos 'doc "Symbole contenant des informations sur MicroAlg.")

(setq symboles '(
"+" "-" "*" "/"
"!!!" "=" "=/" "<" "<=" ">" ">="
"Affecter_a" "Afficher" "Aide" "Alors"
"Booleen?"
"Concatener"
"Definir" "Demander"
"Faire"
"Faux" "Faux?"
"Initialiser"
"Nombre" "Nombre?"
"Retourner" "Rien"
"Si" "Sinon"
"Tant_que" "Texte" "Texte?" "Type"
"Vrai" "Vrai?"
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
(ifn split
  (de split @
    (let (lst   (next)
          seps  (rest)
          result NIL
          tmp    NIL
          elt    NIL)
         (while (setq elt (pop 'lst))
                (ifn (member elt seps)
                     (push 'tmp elt)
                     (push 'result (reverse tmp))
                     (setq tmp NIL)
                )
         )
         (push 'result (reverse tmp))
         (reverse result)
    )
  )
)

# Doc pour les fonctions PicoLisp
(put '+ 'doc
"Commande ajoute tous ses paramètres.")
(put '- 'doc
"Commande qui soustrait son second paramètre à son premier paramètre.")
(put '* 'doc
"Commande multiplie tous ses paramètres.")
(put '/ 'doc
"Commande qui divise son premier paramètre par son second paramètre.")

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
(de Afficher args (let (first (car args)
                        text (if (num? first) first (get first 'text))
                        a_afficher (if text text (eval first)))
                       (setq *LastStdOut (if a_afficher a_afficher "?"))
                       (println a_afficher)
                       NIL  # Pas de valeur de retour
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
(de Initialiser arg_lst (let (var (car arg_lst)
                              val (eval (cadr arg_lst)))
                             (if (get var 'type)
                                 (quit "Variable déjà initialisée." var)
                             )
                             (set var val)
                             (put var 'type (Type (eval var)))
                        ))
(put 'Affecter_a 'doc
"Commande qui permet d’affecter une valeur à une variable.")
(put 'Affecter_a 'text "Commande `Affecter_a`.")
(de Affecter_a arg_lst (let (var (car arg_lst)
                             val (eval (cadr arg_lst)))
                            (ifn (get var 'type)
                                 (quit "Variable non initialisée" var)
                            )
                            (if (<> Faux (= (get var 'type) (get 'val 'type))
                                (set var val)
                                (quit "Le type ne correspond pas"
                                      (list var 'est 'un (Type (eval var)) ', val 'un (Type val)))
                            )
                       )))

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
# ' !"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'

# Types et conversions
(put 'Type 'doc
"Commande qui retourne le type de son paramètre (sous forme de texte et
en minuscule).")
(put 'Type 'text "Commande `Type`.")
(de Type arg_lst
  (let (x (car arg_lst))
       (cond
         ((<> Faux (Texte?   (eval x))) "texte")
         ((<> Faux (Booleen? (eval x))) "booleen")
         ((<> Faux (Nombre?  (eval x))) "nombre")
         ((<> Faux (== Rien  (eval x))) "rien")
         ((sym? x) (get x 'type))
         (T Rien)
       ) ) )
(put 'Texte 'doc
"Commande qui retourne le texte correspondant à son paramètre.")
(de Texte (x) (cond
                ((str? x) x)
                ((num? x) (format x))
                (T NIL)
              ))
(put 'Nombre 'doc
"Commande qui retourne le nombre correspondant à son paramètre textuel.")
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
(de Si arg_lst (let (condition (car arg_lst)
                     kw_alors  (cadr arg_lst)
                     splitted  (split (cddr arg_lst) 'Sinon)
                     bloc_vrai (car splitted)
                     bloc_faux (cadr splitted))
                    (if (<> Alors kw_alors) (quit "Mot-clef `Alors` manquant !" arg_lst))
                    (if (<> Faux (eval condition))  # = retourne Vrai ou Faux
                        (run bloc_vrai)
                        (if (== NIL bloc_faux)
                            Rien
                            (run bloc_faux)))))

# Structures itératives
(put 'Tant_que 'doc
"Structure itérative de type « tant que ... faire ... ».")
(de Tant_que arg_lst (let (Bool (car arg_lst)
                           Mot-Clef (cadr arg_lst)
                           Corps (cddr arg_lst))
                          # Ce if permet de retourner Rien plutôt que NIL
                          # dans le cas où Bool est tout de suite Faux,
                          # mais du coup Bool peut être évalué plusieurs fois.
                          (if (<> Vrai (eval Bool))
                              Rien
                              (while (<> Faux (eval Bool))
                                     (run Corps)))))
(put 'Faire 'doc
"Structure itérative de type « faire ... tant que ... ».")
(de Faire arg_lst (let (Splitted (split arg_lst 'Tant_que)
                        Corps (car Splitted)
                        Bool (caadr Splitted))
                       # Ce let permet de retourner le résultat du premier
                       # tour dans le cas où Bool est tout de suite Faux.
                       (let (resultat-premier-tour (run Corps))
                            (if (<> Vrai (eval Bool))
                                resultat-premier-tour
                                (while (<> Faux (eval Bool))
                                       (run Corps))))))

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
  )
)
(put 'Retourner 'doc
"Dernière instruction du corps d’une commande définie avec `Definir`.
Indique la valeur que cette commande va retourner.

Utiliser `(Retourner Rien)` pour ne rien retourner.")
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

# Rien
(put 'Rien 'doc
"Valeur de contenant aucune information, représentant l’absence de valeur.")
(setq Rien 'Rien)
