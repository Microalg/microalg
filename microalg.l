(setq version "0.2.6")
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
"!!!" "=" "=/" "<" "<=" ">" ">=" "?"
"Affecter_a" "Afficher" "Aide" "Ajouter_a" "Alors"
"Booleen?"
"Concatener"
"Definir" "Demander"
"En_position" "Entier@" "Et" "Exemples_de"
"Faire"
"Faux" "Faux?"
"Initialiser" "Initialiser@"
"Liste" "Liste?" "Longueur"
"Nieme" "Nieme@" "Nombre" "Nombre?" "Non"
"Ou"
"Queue"
"Retirer_de" "Retourner" "Rien"
"Si" "Sinon"
"Tant_que" "Tester" "Tete" "Texte" "Texte?" "Type"
"Vide?" "Vrai" "Vrai?"
))

# picolisp.l shimz
(ifn caadr
  (de caadr (arg)
     (car (car (cdr arg)))
  )
)
(ifn cut
  (de cut (n sym acc)
    (let esym (eval sym)
      (cond
        ((not (<> 0 n)) (reverse acc))
        (T              (let elt (pop sym) (push 'acc elt) (cut (- n 1) sym acc)))
      )
    )
  )
)
(ifn glue
  (de glue (c l)
    (cond
      ((not (<> 0 (length l))) "")
      ((not (<> 1 (length l))) (car l))
      (T                       (pack (car l) c  (glue c (cdr l))))
    )
  )
)
(ifn head
  (de head (n l acc)
    (cond
      ((or (=0 n) (=0 (length l))) (reverse acc))
      (T (prog (push 'acc (pop 'l)) (head (- n 1) l acc)))
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

# 26oct14jk
# extracts from PicoLisp lib.l, (c) Software Lab. Alexander Burger

(de recur recurse
   (run (cdr recurse)) )

### OOP ###
(de class Lst
   (let L (val (setq *Class (car Lst)))
      (def *Class
         (recur (L)
            (if (atom (car L))
               (cdr Lst)
               (cons (car L) (recurse (cdr L))) ) ) ) ) )

(de object ("Sym" "Val" . @)
   (putl "Sym")
   (def "Sym" "Val")
   (while (args)
      (put "Sym" (next) (next)) )
   "Sym" )

(de extend X
   (setq *Class (car X)) )

# Class variables
(de var X
   (if (pair (car X))
      (put (cdar X) (caar X) (cdr X))
      (put *Class (car X) (cdr X)) ) )

(de var: X
   (apply meta X This) )

# En cas d’erreur, pas de prompt ? par défaut.
(setq *Err '((bye)))

# Vérif et conversions de booléens MicroAlg <-> PicoLisp:
(de !boolM2P (x) (if (<> Faux x) T NIL))
(de !boolP2M (x) (if x Vrai Faux))
(de !boolCheck (x) (if (member x '(Vrai Faux)) T))
(de !boolCheckM2P (x msg)
    (ifn (!boolCheck x) (quit msg x))
    (!boolM2P x) )

(de !add_quotes (x) (pack "\"" x "\""))
(de !quote_txt (x) (if (or (not x) (!boolM2P (Texte? x)))
                       (!add_quotes x)
                       x))

# Vérif qu’une variable est bien initialisée :
(de !inited (!sym !evaled_sym)
    (or !evaled_sym (get !sym 'type)) )

# Doc pour les fonctions PicoLisp
(put '+ 'doc
"Commande qui ajoute tous ses paramètres et retourne le résultat.

    : (+ 2 2)
    -> 4
    : (+ 1 2 3 4)
    -> 10
")
(put '+ 'text "Commande somme.")
(put '- 'doc
"Commande qui soustrait son second paramètre à son premier paramètre et retourne le résultat.

    : (- 7 3)
    -> 4
")
(put '- 'text "Commande différence.")
(put '* 'doc
"Commande qui multiplie tous ses paramètres et retourne le résultat.

    : (* 2 3)
    -> 6
    : (* 2 3 4)
    -> 24
")
(put '* 'text "Commande produit.")
(put '/ 'doc
"Commande qui divise son premier paramètre par son second paramètre et retourne le résultat.

    : (/ 8 2)
    -> 4

Attention, suivant la version que vous utilisez, les divisions non entières
donnent des résultats différents. En version web (avec Javascript) :

    : (/ 9 2)
    -> 4.5

Sinon :

    : (/ 9 2)
    -> 4
")
(put '/ 'text "Commande quotient.")
(put '% 'doc
"Commande qui retourne le reste de la division euclidienne de son premier paramètre par son second paramètre.

    : (% 7 3)
    -> 1
")
(put '% 'text "Commande reste.")
(put '** 'doc
"Commande qui retourne son premier paramètre à la puissance du second paramètre.

    : (** 2 3)
    -> 8
")
(put '** 'text "Commande puissance.")

# Commentaires
(put '!!! 'doc
"Commande qui ne fait rien et sert pour les commentaires.

    : (!!! \"Ceci est un commentaire.\")
    -> Rien
")
(put '!!! 'text "Commande commentaire.")
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
"Commande qui affiche son unique argument, si besoin après l’avoir évalué.

    : (Afficher \"Bonjour !\")
    Bonjour !
    -> Rien
")
(put 'Afficher 'text "Commande `Afficher`.")
(setq *LastStdOut "?")
(de !text (truc)
    (let (
          first truc
          efirst (eval first)
         )
         (cond
          ((!boolM2P (= Vrai efirst)) "Vrai")
          ((!boolM2P (= Faux efirst)) "Faux")
          ((!boolM2P (= Rien efirst)) "Rien")
          ((and (not (atom efirst)) (!boolM2P (= '? (car efirst))))
           (pack "(" (str efirst) ")"))           # liste commençant par ?
          ((num? first) first)                    # nombre litéral
          ((get first 'text) (get first 'text))   # p.ex. commandes, après num
          ((try 'text> first) (text> first))      # liste évaluée (avec $), avant txt
          ((str? first) first)                    # texte litéral
          ((try 'text> efirst) (text> efirst))    # liste
          ((num? efirst) efirst)                  # expr -> des nbres
          ((str? efirst) efirst)                  # expr -> texte
          ((get efirst 'text) (get efirst 'text)) # expr -> cmd (un jour)
          ((sym? efirst) efirst)                  # expr -> sym (Rien, bool…)
          (T (quit "Pas de représentation textuelle." first))
         )
     )
)

(de Afficher args
  (let (
   first (car args)
   second (cadr args)
   a_afficher (!text first)
  )
  # Quelques vérifications
  (ifn (!inited first a_afficher) (quit "`Afficher` : la variable n’est pas initialisée." first))
  (if second (quit (pack "`Afficher` n’a qu’un paramètre, faites plusieurs "
                         "affichages ou utilisez `Concatener`." )))
  # Le boulot
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
"Commande qui concatène les textes passés en paramètre.

    : (Concatener \"ici\" \" et là\")
    -> \"ici et là\"
")
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
"Commande qui permet d’initialiser une variable avec une valeur.

    : (Initialiser x 2)
    -> Rien
    : (Afficher x)
    2
    -> Rien
")
(put 'Initialiser 'text "Commande `Initialiser`.")
(de Initialiser arg_lst (let (nbr_args (length arg_lst))
                             (if (<> 2 nbr_args)
                                 (quit (pack "`Initialiser` prend 2 paramètres. "
                                             "Vous en donnez " nbr_args ".") )
                             )  # Du coup un deuxième arg NIL ne peut être que "".
                        )
                        (let (!var (car arg_lst)
                              !val (eval (cadr arg_lst))
                              !type_var (get !var 'type)
                              !type_val (Type !val))
                             (if (and (<> "rien" !type_val) !type_var (<> !type_val !type_var))
                                 (quit (pack "Valeur de type " !type_val ", ne peut initialiser "
                                             !var " qui est de type " !type_var "."))
                             )
                             (set !var !val)
                             (put !var 'type (ifn !val "texte" !type_val))
                             Rien  # Pas de valeur de retour
                        ))
(put 'Affecter_a 'doc
"Commande qui permet d’affecter une valeur à une variable.

    : (Initialiser x 2)
    -> Rien
    : (Afficher x)
    2
    -> Rien
    : (Affecter_a x 3)
    -> Rien
    : (Afficher x)
    3
    -> Rien

Si la variable contient un texte ou une liste et qu’une position est fournie,
comme par exemple dans :  
`(Affecter_a var val En_position idx)`  
alors l’élément à la `idx` ième position dans `var` est affecté de la valeur
 `val`.")
(put 'Affecter_a 'text "Commande `Affecter_a`.")
(de Affecter_a arg_lst
    (let (var (car arg_lst)
          val (eval (cadr arg_lst))
          kw  (caddr arg_lst)
          idx (eval (cadddr arg_lst))
          evaled_var (eval var))
         (setq !onppauv "On ne peut pas affecter une valeur ")
         (cond
             ((num? var) (quit (pack !onppauv "à un nombre.") var))
             ((str? var) (quit (pack !onppauv "à un texte.") var))
             ((== var 'Vrai) (quit (pack !onppauv "au booléen Vrai.")))
             ((== var 'Faux) (quit (pack !onppauv "au booléen Faux.")))
             ((== var 'Rien) (quit (pack !onppauv "à Rien.")))
         )
         (ifn kw
              (prog
                 (if (and (!boolM2P (Liste? (eval var))) (not (!boolM2P (Liste? val))))
                     (quit (pack !onppauv "autre qu’une liste à une liste, utiliser `Affecter_a … … En_position …`.") var))
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
                 (let (len (Longueur evaled_var))
                   (cond
                     ((<> idx (format (round idx 0) 0 "." ",")) (quit "Indice non entier." idx))
                     ((le0 idx) (quit "Indice négatif ou nul." idx))
                     ((lt0 (- len idx)) (quit "Indice trop grand." (list idx '> len)))
                   )
                 )
                 (cond
                   ((!boolM2P (Liste? evaled_var)) (put> evaled_var val idx))
                   ((str? evaled_var)
                    (let (chopped (chop evaled_var))
                         (set var (pack (head (- idx 1) chopped)
                                        val
                                        (tail (- idx) chopped) )) ))
                   (T (quit "Affectation positionnelle impossible." (Type evar)))
                 )
              )
         )
         Rien  # Pas de valeur de retour
    )
)
(put 'En_position 'doc "Mot-clef intermédiaire pour la commande `Affecter_a`.")
(setq En_position 'En_position)

# Tirages pseudo-aléatoires.
(put 'Initialiser@ 'doc
"Permet d’obtenir une séquence de nombres pseudo-aléatoires différente.

Cette commande est à appeler une seule fois au début de votre programme et est
inutile si vous utilisez la version Javascript de MicroAlg (en particulier dans
le navigateur). Elle résout le problème suivant :

Dans une session :

    : (Entier@ 0 1000)
    -> 0
    : (Entier@ 0 1000)
    -> 648

Puis dans une autre, plus tard :

    : (Entier@ 0 1000)
    -> 0
    : (Entier@ 0 1000)
    -> 648

Alors que :

    : (Initialiser@)
    -> Rien
    : (Entier@ 0 1000)
    -> 422  # Cette valeur sera différente à chaque seconde de la journée.
")
(put 'Initialiser@ 'text "Commande `Initialiser@`.")
(de Initialiser@ ()
    (seed (time))
    Rien)
(put 'Entier@ 'doc
"Retourne un nombre entier pseudo-aléatoire dans [`min`;`max`] (les deux
paramètres entiers).

    : (Entier@ 1 6)
    -> 2
    : (Entier@ 1 6)
    -> 6

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.")
(put 'Entier@ 'text "Commande `Entier@`.")
(de Entier@ (!min !max !rien_ici)
    # Quelques vérifications
    (ifn (and !min !max) (quit "`Entier@` prend deux paramètres (entiers)."))
    (if !rien_ici (quit "`Entier@` ne prend que deux paramètres (entiers)."))
    (cond
        ((<> !min (format (round !min 0) 0 "." ","))
         (quit "Le minimum de `Entier@` n’est pas entier." !min))
        ((<> !max (format (round !max 0) 0 "." ","))
         (quit "Le maximum de `Entier@` n’est pas entier." !max))
        ((!boolM2P (> !min !max))
         (quit "Le minimum et le maximum de `Entier@` ne sont pas dans l’ordre."))
    )
    # Le calcul
    (rand !min !max)
)
(put 'Nieme@ 'doc
"Retourne un élément choisi pseudo-aléatoirement dans la liste ou le texte
 fourni en paramètre.

    : (Nieme@ (Liste 13 666 2015))
    -> 2015
    : (Nieme@ (Liste 13 666 2015))
    -> 666
    : (Nieme@ \"bonjour\")
    -> n
    : (Nieme@ \"bonjour\")
    -> o

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.")
(put 'Nieme@ 'text "Commande `Nieme@`.")
(de Nieme@ (obj !rien_ici)
    # Quelques vérifications
    (setq !onppeuv "`Nieme@` ne peut pas extraire un élément pseudo-aléatoire ")
    (cond
        ((num? obj) (quit (pack !onppeuv "d’un nombre.") obj))
        ((== obj 'Vrai) (quit (pack !onppeuv "du booléen Vrai.")))
        ((== obj 'Faux) (quit (pack !onppeuv "du booléen Faux.")))
        ((== obj 'Rien) (quit (pack !onppeuv "de Rien.")))
    )
    (if !rien_ici (quit "`Nieme@` ne prend qu’un paramètre (liste ou texte)."))
    # Le calcul
    (cond
        ((!boolM2P (Liste? obj)) (nth> obj (rand 1 (length> obj))))
        ((str? obj) (car (nth (chop obj) (rand 1 (length obj)))))
        (T Rien)
    )
)

# Demander.
# Avec EmuLisp, les entrées utilisateur se font au travers de la fonction
# _stdPrompt, surchargée dans ide_injection.js. Dans un navigateur, la dernière
# ligne ayant été affichée précédemment est réutilisée lors de l’appel à
# window.prompt.
(put 'Demander 'doc
"Commande qui permet de demander une valeur à l’utilisateur.

    : (Afficher (Demander))
    salut  <--- Ici, c’est l’utilisateur qui tape ;
    salut  <--- là, c’est MicroAlg qui affiche.
    -> Rien
")
(put 'Demander 'text "Commande `Demander`.")
(de Demander () (in NIL (line " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")))
# Références:
# https://fr.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange#Table_des_128_caract.C3.A8res_ASCII
# https://en.wikipedia.org/wiki/ASCII#ASCII_printable_character_code_chart
# >>> ''.join([chr(i) for i in range(32, 127) if not chr(i).isalnum()])
# ' !"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'                                       "

# Listes
# Implémentation interne des listes (POO)
(class +Liste)
# elts
(dm T (ELTS)
      (=: elts ELTS)
)
(dm length> ()
    (length (: elts))
)
(dm text> ()
    (pack "(Liste"
          (if (: elts) " ")
          (glue " " (mapcar '((!txt) (!text (!quote_txt !txt))) (: elts)))
          ")"
    )
)
(dm nth> (idx)
    (car (nth (: elts) idx))
)
(dm elts> ()
    (: elts)
)
(dm push> (elt)
    (=: elts (conc (: elts) (list elt)))
)
(dm pop> ()
    (let (!return_val (last (: elts)))
         (=: elts (head (- (length (: elts)) 1) (: elts)))
         !return_val
    )
)
(dm put> (elt idx)
    (=: elts (conc (head (- idx 1) (: elts))
                   (list elt)
                   (tail (- idx) (: elts))
             )
    )
)
# Interface MicroAlg des listes
(put 'Liste 'doc
"Commande qui construit une liste.

    : (Afficher (Liste 1 3 5))
    \"(Liste 1 3 5)\"
    -> Rien
")
(put 'Liste 'text "Commande `Liste`.")
(de Liste @
    (new '(+Liste) (rest)) )

# Manipulations de texte et de liste
(put 'Longueur 'doc
"Commande qui retourne la longueur d’un texte ou d’une liste.

    : (Longueur \"bonjour\")
    -> 7
    : (Longueur (Liste 1 3 5 7))
    -> 4
")
(put 'Longueur 'text "Commande `Longueur`.")
(de !longueur (!obj)
    (if (!boolM2P (Liste? !obj))
        (length> !obj)
        (length  !obj)
    )
)
(de Longueur arg_lst
  (let (!obj (car arg_lst)
        !evaled_obj (eval !obj)
        !deuze (cadr arg_lst))
    # Quelques vérifications
    (if !deuze (quit "`Longueur` n’a qu’un paramètre."))
    (ifn !obj 0  # pour gérer texte vide
      (ifn (!inited !obj !evaled_obj) (quit "`Longueur` : la variable n’est pas initialisée." !obj))
    )
    (setq !npdl " n’a pas de `Longueur`.")
    (cond
        ((num? !evaled_obj) (quit (pack "Un nombre" !npdl) !evaled_obj))
        ((==   !evaled_obj 'Vrai) (quit (pack "Vrai" !npdl)))
        ((==   !evaled_obj 'Faux) (quit (pack "Faux" !npdl)))
        ((==   !evaled_obj 'Rien) (quit (pack "Rien" !npdl)))
    )
    # Le calcul
    (!longueur !evaled_obj)
  )
)
(put 'Nieme 'doc
"Permet d’accéder en lecture à un des éléments d’un texte ou d’une liste
(se lit « énième »).

La numérotation commence à 1.

    : (Nieme \"salut\" 2)
    -> \"a\"
    : (Nieme (Liste 1 3 5 7) 2
    -> 3
")
(put 'Nieme 'text "Commande `Nieme`.")
(de Nieme arg_lst
  (let (!obj (car arg_lst)
        !evaled_obj (eval !obj)
        !idx (eval (cadr arg_lst))
        !troize (caddr arg_lst))
    # Quelques vérifications
    (if !troize (quit "`Nieme` n’a que deux paramètres."))
    (ifn (!inited !obj !evaled_obj) (quit "`Nieme` : la variable n’est pas initialisée." !obj))
    (setq !onppeuv "`Nieme` ne peut pas extraire une valeur ")
    (cond
        ((num? !evaled_obj) (quit (pack !onppeuv "d’un nombre.") !evaled_obj))
        ((==   !evaled_obj 'Vrai) (quit (pack !onppeuv "du booléen Vrai.")))
        ((==   !evaled_obj 'Faux) (quit (pack !onppeuv "du booléen Faux.")))
        ((==   !evaled_obj 'Rien) (quit (pack !onppeuv "de Rien.")))
    )
    (let (len (Longueur !evaled_obj))
      (cond
        ((not !idx) (quit "Il manque le deuxième paramètre : l’indice."))
        ((<> !idx (format (round !idx 0) 0 "." ",")) (quit "Indice non entier." !idx))
        ((le0 !idx) (quit "Indice négatif ou nul." !idx))
        ((lt0 (- len !idx)) (quit "Indice trop grand." (list !idx '> len)))
      )
    )
    # Le calcul
    (cond
      ((!boolM2P (Liste? !evaled_obj)) (nth> !evaled_obj !idx))
      ((!boolM2P (Texte? !evaled_obj)) (car (nth (chop !evaled_obj) !idx)))
      (T Rien)
    )
  )
)
(put 'Tete 'doc
"Commande qui retourne le premier élément d’un texte ou d’une liste.

    : (Tete \"salut\")
    -> \"s\"
    : (Tete (Liste 1 3 5 7))
    -> 1
")
(put 'Tete 'text "Commande `Tete`.")
(de Tete (obj)
    # Quelques vérifications
    (cond ((num? obj)
           (quit "Un nombre n’a pas de tête, il faut un texte ou une liste." obj))
          ((!boolM2P (Vide? obj))
           (quit "Un objet vide n’a pas de tête." obj))
    )
    # Le calcul
    (cond
      ((!boolM2P (Liste? obj)) (nth> obj 1))
      ((str? obj) (car (chop obj)))
      (T (quit "Vous cherchez la tete d’une valeur qui n’est ni un texte ni une liste."
               (list obj (Type obj))))
    ))
(put 'Queue 'doc
"Commande qui retourne une copie du texte ou de la liste en paramètre,
 mais sans son premier élément.

    : (Queue \"salut\")
    -> \"alut\"
    : (Afficher (Queue (Liste 1 3 5 7)))
    -> \"(Liste 3 5 7)\"
")
(put 'Queue 'text "Commande `Queue`.")
(de Queue (obj)
    # Quelques vérifications
    (cond ((num? obj)
           (quit "Un nombre n’a pas de queue, il faut un texte ou une liste." obj))
          ((!boolM2P (Vide? obj))
           (quit "Un objet vide n’a pas de queue." obj))
    )
    # Le calcul
    (cond
      ((!boolM2P (Liste? obj)) (apply Liste (cdr (elts> obj))))
      ((str? obj) (pack (cdr (chop obj))))
      (T (quit "Vous cherchez la queue d’une valeur qui n’est ni un texte ni une liste."
               (list obj (Type obj))))
    ))
(put 'Ajouter_a 'doc
"Commande qui, si le premier argument est un texte ou une liste, affecte un
nouvel élément à la fin de ce texte ou de cette liste (après le dernier élément).

Avec du texte :

    : (Initialiser mot \"bonjour\")
    -> Rien
    : (Ajouter_a mot \"!\")
    -> Rien
    : (Afficher mot)
    \"bonjour!\"
    -> Rien

Avec une liste :

    : (Initialiser v (Liste 1 3 5 7))
    -> Rien
    : (Ajouter_a v 9)
    -> Rien
    : (Afficher v)
    \"(Liste 1 3 5 7 9)\"
    -> Rien
")
(put 'Ajouter_a 'text "Commande `Ajouter_a`.")
(de Ajouter_a arg_lst
  (let (!sym (car arg_lst)
        !evaled_sym (eval !sym)
        !elt (eval (cadr arg_lst))
        !troize (caddr arg_lst))
       # Quelques vérifications
       (if !troize (quit "`Ajouter_a` n’a que deux paramètres."))
       (ifn (!inited !sym !evaled_sym) (quit "`Ajouter_a` : la variable n’est pas initialisée." !sym))
       (if (!boolM2P (!texte? !sym))
           (if (or (not (!boolM2P (Texte? !elt)))
                   (!boolM2P (> (Longueur !elt) 1)) )
               (quit "On peut `Ajouter_a` un texte qu’un caractère." !elt) ))
       # Le calcul
       (cond
         ((!boolM2P (Liste? !evaled_sym)) (prog (push> !evaled_sym !elt) Rien))
         ((!boolM2P (!texte? !sym)) (prog (set !sym (pack !evaled_sym !elt)) Rien))
         (T (quit "Le premier argument de `Ajouter_a` doit être du texte ou une liste." !sym))
       )
  )
)
(put 'Retirer_de 'doc
"Commande qui, si le premier paramètre contient un texte ou une liste, retire
 le dernier élément à la fin de ce texte ou de cette liste et le retourne.

Avec du texte :

    : (Initialiser mot \"bonjour\")
    -> Rien
    : (Retirer_de mot)
    -> \"r\"
    : (Afficher mot)
    \"bonjou\"
    -> Rien

Avec une liste :

    : (Initialiser v (Liste 1 3 5 7))
    -> Rien
    : (Retirer_de v)
    -> 7
    : (Afficher v)
    \"(Liste 1 3 5)\"
    -> Rien
")
(put 'Retirer_de 'text "Commande `Retirer_de`.")
(de Retirer_de arg_lst
  (let (!sym (car arg_lst)
        !evaled_sym (eval !sym)
        !deuze (cadr arg_lst))
       # Quelques vérifications
       (if !deuze (quit "`Retirer_de` n’a qu’un paramètre."))
       (ifn (!inited !sym !evaled_sym) (quit "`Retirer_de` : la variable n’est pas initialisée." !sym))
       # Le calcul
       (cond
         ((!boolM2P (Liste? !evaled_sym)) (pop> !evaled_sym))
         ((!boolM2P (Texte? !evaled_sym))
             (let (!chopped (chop !evaled_sym)
                   !return_val (last !chopped))
                  (set !sym (pack (head (- (length !evaled_sym) 1) !chopped)))
                  !return_val
             ))
         (T (quit "Le premier argument de `Retirer_de` doit être du texte ou une liste." !sym))
       )
  )
)

# Types et conversions
(put 'Type 'doc
"Commande qui retourne le type de son paramètre (sous forme de texte et
en minuscule).

    : (Type \"salut\")
    -> \"texte\"
    : (Type 42)
    -> \"nombre\"
    : (Type Faux)
    -> \"booleen\"
    : (Type (Liste 1 3 5 7))
    -> \"liste\"
")
(put 'Type 'text "Commande `Type`.")
(de Type arg_lst
  (let (!x (car arg_lst)
        !evaled_x (eval !x))
        embedded_type (ifn (num? !x) (get !x 'type))
       (if embedded_type
           embedded_type
           (cond
             ((not !x) "texte")  # Possiblement "" en direct.
             ((!boolM2P (Nombre?  !evaled_x)) "nombre")
             ((!boolM2P (Liste?   !x))        "liste")
             ((!boolM2P (!texte?  !x))        "texte")  # pour les sym textuels ?
             ((!boolM2P (Texte?   !evaled_x)) "texte")
             ((!boolM2P (Liste?   !evaled_x)) "liste")
             ((!boolM2P (Booleen? !evaled_x)) "booleen")
             ((!boolM2P (== Rien  !evaled_x)) "rien")
             ((sym? x) (get !x 'type))
             (T Rien)
           ) ) ) )
(put 'Texte 'doc
"Commande qui retourne le texte correspondant à son paramètre.

    : (Texte 42)
    -> \"42\"
")
(put 'Texte 'text "Commande `Texte`.")
(de Texte (x) (cond
                ((not (<> x 'Vrai)) "Vrai")
                ((not (<> x 'Faux)) "Faux")
                ((not (<> x 'Rien)) "Rien")
                ((!boolM2P (Liste? x)) (!text x))  # mettre avant str?
                ((str? x) x)
                ((num? x) (format x))
                (T "???")
              ))
(put 'Nombre 'doc
"Commande qui retourne le nombre correspondant à son paramètre textuel.

    : (Nombre \"42\")
    -> 42
")
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
`Sinon` est facultatif.

    (Si booleen
     Alors instruction_si_Vrai_1
           instruction_si_Vrai_2
           ...
     Sinon instruction_si_Faux_1
           instruction_si_Faux_2
           ...
    )

Ou :

    (Si booleen
     Alors instruction_si_Vrai_1
           instruction_si_Vrai_2
           ...
    )
")
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

    : (Non Vrai)
    -> Faux
    : (Non Faux)
    -> Vrai

Voir <http://fr.wikipedia.org/wiki/Fonction_NON>.")
(put 'Non 'text "Commande `Non`.")
(de Non (!P !rien_ici)
    (if !rien_ici (quit "`Non` ne prend qu’un paramètre (booléen)."))
    (ifn (!boolCheck !P) (quit "`Non` prend un paramètre booléen."))
    (!boolP2M (not (!boolM2P !P))) )
(put 'Et 'doc
"Et logique.

    : (Et Vrai Faux)
    -> Faux
    : (Et Vrai Vrai)
    -> Vrai

Voir <http://fr.wikipedia.org/wiki/Fonction_ET>.")
(put 'Et 'text "Commande `Et`.")
(de Et (!P !Q !rien_ici)
    (if !rien_ici (quit "`Et` ne prend que deux paramètres (booléens)."))
    (ifn (!boolCheck !P) (quit "Le premier paramètre de `Et` doit être un booléen."))
    (ifn (!boolCheck !Q) (quit "Le second paramètre de `Et` doit être un booléen."))
    (!boolP2M (and (!boolM2P !P) (!boolM2P !Q))) )
(put 'Ou 'doc
"Ou logique.

    : (Ou Vrai Faux)
    -> Vrai
    : (Ou Faux Faux)
    -> Faux

Voir <http://fr.wikipedia.org/wiki/Fonction_OU>.")
(put 'Ou 'text "Commande `Ou`.")
(de Ou (!P !Q !rien_ici)
    (if !rien_ici (quit "`Ou` ne prend que deux paramètres (booléens)."))
    (ifn (!boolCheck !P) (quit "Le premier paramètre de `Ou` doit être un booléen."))
    (ifn (!boolCheck !Q) (quit "Le second paramètre de `Ou` doit être un booléen."))
    (!boolP2M (or (!boolM2P !P) (!boolM2P !Q))) )

# Structures itératives
(setq credit_iterations 1000)
(put 'credit_iterations 'type "nombre")
(setq credit_iterations_message
      (pack "Crédit d’itérations épuisé (1 000 par défaut). Vous pouvez "
            "recharger votre crédit en affectant une valeur à la variable "
            "`credit_iterations`."))
(put 'Tant_que 'doc
"Structure itérative de type « tant que ... faire ... ».

    : (Initialiser i 3)
    -> Rien
    : (Tant_que (>= i 0)
       Faire
           (Afficher i)
           (Affecter_a i (- i 1))
    )
    3
    2
    1
    0
    -> Rien
")
(put 'Tant_que 'text "Commande `Tant_que`.")
(de Tant_que arg_lst (let (Bool (car arg_lst)
                           Mot-Clef (cadr arg_lst)
                           Corps (cddr arg_lst))
                          (if (<> 'Faire Mot-Clef) (quit "Commande `Tant_que` sans mot-clé `Faire`."))
                          (while (!boolCheckM2P (eval Bool) "La condition n’est pas un booléen.")
                                 (if (=0 (dec 'credit_iterations))
                                     (quit credit_iterations_message))
                                 (run Corps))
                          Rien
                     )
)
(put 'Faire 'doc
"Structure itérative de type « faire ... tant que ... ».

    : (Initialiser i 3)
    -> Rien
    : (Faire
          (Afficher i)
          (Affecter_a i (- i 1))
       Tant_que (>= i 0)
    )
    3
    2
    1
    0
    -> Rien
")
(put 'Faire 'text "Commande `Faire`.")
(de Faire arg_lst (let (Splitted (split arg_lst 'Tant_que)
                        Corps (car Splitted)
                        Bool (caadr Splitted))
                       (ifn (<> arg_lst Corps)
                            (quit "Commande `Faire` sans mot-clé `Tant_que`."))
                       (if  (!boolM2P (> (length (cadr Splitted)) 1))
                            (quit "Il ne faut qu’un seul élément après le mot-clé `Tant_que`."))
                       (run Corps)
                       (if (!boolCheckM2P (eval Bool) "La condition n’est pas un booléen.")
                           (while (!boolCheckM2P (eval Bool) "La condition n’est pas un booléen.")
                                  (if (=0 (dec 'credit_iterations))
                                      (quit credit_iterations_message))
                                  (run Corps)))
                       Rien
                  )
)

# Procédures utilisateur
# Tout d’abord les générateurs d’initialisation
(de !liste_inits_type (!syms)
    (mapcar '((!sym) (list 'put (cons 'quote !sym) ''type (list 'Type !sym))) !syms)
)
(de !liste_inits_val (!syms)
    (mapcar '((!sym) (list 'Initialiser !sym !sym)) !syms)
)
(de !liste_resets_type (!syms)
    (mapcar '((!sym) (list 'put (cons 'quote !sym) ''type NIL)) !syms)
)
(de !liste_resets_val (!syms)
    (mapcar '((!sym) (list 'setq !sym NIL)) !syms)
)
# Ensuite le boulot :
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

**Attention** : La commande `Retourner` n’interrompt pas l’exécution des
commandes que vous définissez. Il faut donc pour l’instant la mettre en
dernière position.

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
        aug_corps (conc
                    (!liste_inits_type params)
                    (!liste_inits_val params)
                    (list (list 'let (list '!result (list 'run (cons 'quote corps)))
                      (list 'run (cons 'quote (!liste_resets_type params)))
                      (list 'run (cons 'quote (!liste_resets_val params)))
                      '!result))
                  )
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
       (set nom (list params (list 'run (cons 'quote aug_corps))))
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
(de Retourner (!val !deuze)
  (if !deuze (quit (pack "`Retourner` n’a qu’un paramètre. Si vous voulez "
                         "vraiment retourner plusieurs valeurs, vous pouvez "
                         "essayer de retourner une liste." )))
  !val
)
(put 'Exemples_de 'doc
"Permet de lire ou écrire les exemples-tests d’une commande.

Exemples :

    (!!! \"Pour écrire les exemples de Double\")
    (Exemples_de Double
        (Liste
            (? 1) 2
            (? 2) 4
            (? 3) 6
        )
    )
    -> Rien

    (!!! \"Pour lire les exemples de Double\")
    (Exemples_de Double)
    -> (Liste (? 1) 2 (? 2) 4 (? 3) 6)

    (!!! \"Pour recopier les exemples de Cmd_1 dans Cmd_2.\")
    (Exemples de Cmd_2 (Exemples de Cmd_1))

Pour lancer les tests, utiliser la commande `Tester`.
")
(put 'Exemples_de 'text "Commande `Exemples_de`.")
(de Exemples_de arg_lst
  (let (commande (car arg_lst)
        exemples (eval (cadr arg_lst))
        troize (caddr arg_lst))
       (if troize (quit "`Exemples_de` n’a pas de troisième paramètre."))
       (ifn exemples (get commande 'exemples)
                     (prog
                       (ifn (!boolM2P (Liste? exemples))
                            (quit "Les exemples fournis ne forment pas une liste."))
                       (put commande 'exemples exemples)
                     )
       )
  )
)
(put 'Tester 'doc
"Vérifie que les exemples de la commande passée en paramètre sont conformes.

Voir la commande `Exemples_de`.")
(put '? 'text "Symbole remplaçant la commande à tester dans `Exemples_de`.")
(put '? 'doc "Symbole remplaçant la commande à tester dans `Exemples_de`.")
# Éviter le message « redefined »
(setq ? NIL)
(de ? @ (apply list (conc (list '?) (rest))))
(put 'Tester 'text "Commande `Tester`.")
(de !paires (!list !acc)
    (cond
      ((!boolM2P (= 0 (length !list))) (reverse !acc))
      (T (push '!acc (cut 2 '!list))
         (!paires !list !acc))
    )
)
(de Tester arg_lst
  (let (!commande (car arg_lst)
        !deuze (cadr arg_lst)
        !exemples (get !commande 'exemples))
       (if !deuze (quit "`Tester` n’a qu’un paramètre."))
       (cond
         ((not (eval !commande))
            (Afficher (pack "Il faut définir la commande " !commande " avant de la tester.")))
         ((not !exemples)
            (Afficher (pack "La commande " !commande " n’a pas d’exemples.")))
         ((!boolM2P (Non (Liste? !exemples)))
            (Afficher (pack "La commande " !commande " n’a pas d’exemples valables.")))
         (T (mapcar '((!paire) (let (!args (cdr (car !paire))
                                     !got (apply (eval !commande) !args)
                                     !expected (cadr !paire))
                                    (if (<> !got !expected)
                                        (Afficher (pack "Erreur: (" !commande " "
                                                        (glue " " (mapcar '!text !args)) ")"
                                                        " donne " !got
                                                        " au lieu de " !expected ".")))
                               )
                     ) (!paires (elts> !exemples))))
       )
  )
)

# Prédicats
(put 'Vrai? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est `Vrai`,
et `Faux` sinon.

    : (Vrai? Vrai)
    Vrai
    : (Vrai? 1)
    Faux
")
(put 'Vrai? 'text "Prédicat `Vrai?`.")
(de Vrai? (x) (if (!boolM2P (= x Vrai)) Vrai Faux))
(put 'Faux? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est `Faux`,
et `Faux` sinon.

    : (Faux? Faux)
    Vrai
    : (Faux? 0)
    Faux
")
(put 'Faux? 'text "Prédicat `Faux?`.")
(de Faux? (x) (if (!boolM2P (= x Faux)) Vrai Faux))
(put 'Texte? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est du texte,
et `Faux` sinon.

    : (Texte? 42)
    -> Faux
    : (Texte? \"42\")
    -> Vrai
")
(put 'Texte? 'text "Prédicat `Texte?`.")
(de !texte? (!obj)  # helper évaluant son arg
       (cond
        ((not !obj) Vrai)                       # Possiblement "" en direct.
        ((num? !obj) Faux)                      # Un nombre en direct.
        ((num? !evaled_obj) Faux)               # Un sym numérique.
        ((!boolM2P (Liste? !evaled_obj)) Faux)  # Liste.
        ((if (sym? !obj) (== (get !obj 'type) "texte")) Vrai)  # Un sym textuel.
        ((== (get !obj 'type) "texte") Vrai)    # Un sym textuel.
        ((str? !evaled_obj) Vrai)               # Texte.
        (T Faux)                                # Le reste.
       )
  )
(de Texte? arg_lst
  (let (!obj (car arg_lst)
        !evaled_obj (eval !obj)
        !deuze (cadr arg_lst))
       # Quelques vérifications:
       (if !deuze (quit "`Retirer_de` n’a qu’un paramètre."))
       (!texte? !obj)
  )
)
(put 'Nombre? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est un nombre,
et `Faux` sinon.

    : (Nombre? \"42\")
    -> Faux
    : (Nombre? 42)
    -> Vrai
")
(put 'Nombre? 'text "Prédicat `Nombre?`.")
(de Nombre? (x) (if (num? x) Vrai Faux))
(put 'Booleen? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est un booleen,
et `Faux` sinon.

    : (Booleen? Faux)
    -> Vrai
    : (Booleen? 1)
    -> Faux
")
(put 'Booleen? 'text "Prédicat `Booleen?`.")
(de Booleen? (x) (if (or (== Vrai x) (== Faux x)) Vrai Faux))
(put 'Liste? 'doc
"Prédicat retournant `Vrai` si la valeur de son argument est une liste,
et `Faux` sinon.

    : (Liste? (Liste 1 3 5 7))
    -> Vrai
    : (Liste? 0)
    -> Faux
    : (Liste? \"salut\")
    -> Faux
")
(put 'Liste? 'text "Prédicat `Liste?`.")
(de Liste? (x) (if (or (try 'text> x) (try 'text> (eval x))) Vrai Faux))
# Sans le suffixe '?'
# Éviter le message « redefined »
(setq = NIL)
(setq < NIL)
(setq <= NIL)
(setq > NIL)
(setq >= NIL)
(put '= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont égales,
et `Faux` sinon.

    : (= 42 42)
    -> Vrai
")
(put '= 'text "Prédicat `=`.")
(de = (x y) (ifn (<> x y)
                 (if (or (== x Vrai) (== x Faux) (== x Rien)
                         (== y Vrai) (== y Faux) (== y Rien))
                     (if (== x y) Vrai Faux)  # test == pour les vals ci-dessus
                     Vrai                     # pour les autres, c’est not <>
                 )
                 Faux)  # ici, ils sont <>
)
(put '=/ 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
différentes, et `Faux` sinon.

    : (=/ 42 42)
    -> Faux
")
(put '=/ 'text "Prédicat `=/`.")
(de =/ (x y) (if (<> x y) Vrai Faux))
(put '< 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre croissant (strictement), et `Faux` sinon.

    : (< 42 42)
    -> Faux
    : (< 42 43)
    -> Vrai
")
(put '< 'text "Prédicat `<`.")
(de < (x y) (ifn (ge0 (- x y)) Vrai Faux))
(put '<= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre croissant.

    : (<= 42 42)
    -> Vrai
    : (<= 42 43)
    -> Vrai
    : (<= 43 42)
    -> Faux
")
(put '<= 'text "Prédicat `<=`.")
(de <= (x y) (if (le0 (- x y)) Vrai Faux))
(put '> 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre décroissant (strictement), et `Faux` sinon.

    : (> 42 42)
    -> Faux
    : (> 43 42)
    -> Vrai
")
(put '> 'text "Prédicat `>`.")
(de > (x y) (ifn (le0 (- x y)) Vrai Faux))
(put '>= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre décroissant.

    : (>= 42 42)
    -> Vrai
    : (>= 43 42)
    -> Vrai
    : (<= 42 43)
    -> Faux
")
(put '>= 'text "Prédicat `>=`.")
(de >= (x y) (if (ge0 (- x y)) Vrai Faux))
(put 'Vide? 'doc
"Prédicat retournant `Vrai` si l’argument est considéré comme vide.

* **Textes** : le seul texte vide est `\"\"`.
* **Listes** : la seule liste vide est `(Liste)`.
* Les valeurs des autres types se sont jamais vide.

Exemples :

    : (Vide? 0)
    -> Faux
    : (Vide? Faux)
    -> Faux
    : (Vide? \"a\")
    -> Faux
    : (Vide? \"\")
    -> Vrai
    : (Vide? (Liste 0))
    -> Faux
    : (Vide? (Liste))
    -> Vrai
")
(put 'Vide? 'text "Prédicat `Vide?`.")
(de Vide? arg_lst
  (let (!obj (car arg_lst)
        !evaled_obj (eval !obj)
        !deuze (cadr arg_lst))
    # Quelques vérifications
    (ifn arg_lst (quit "`Vide?` prend un paramètre."))
    (if !deuze (quit "`Vide?` n’a qu’un paramètre."))
    (ifn !obj Vrai  # Pour le texte vide "".
      (ifn (!inited !obj !evaled_obj) (quit "`Vide?` : la variable n’est pas initialisée." !obj))
    )
    (setq !ctnaass "`Vide?` : ce test n’a aucun sens sur ")
    (cond
        ((num? !evaled_obj) (quit (pack !ctnaass "un nombre.") !evaled_obj))
        ((==   !evaled_obj 'Vrai) (quit (pack !ctnaass "Vrai.")))
        ((==   !evaled_obj 'Faux) (quit (pack !ctnaass "Faux.")))
        ((==   !evaled_obj 'Rien) (quit (pack !ctnaass "Rien.")))
    )
    # Le calcul
    (if (<> 0 (!longueur !evaled_obj)) Faux Vrai)
  )
)

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
