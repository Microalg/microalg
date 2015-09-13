(setq version "0.4.05")
(put 'version 'text (pack "MicroAlg version " version))
(setq apropos
"L’idée de MicroAlg est née lors d’une formation ISN, de la frustration due à
l’abscence d’un langage vraiment axé sur la pédagogie.  
À l’origine pensé comme DSL au sein de Tcl, il est finalement embarqué dans
PicoLisp.  
Voir <http://microalg.info>.")
(put 'apropos 'doc "Symbole contenant des informations sur MicroAlg.")

(setq symboles '(
"+" "-" "*" "/" "%" "\^"
"!!!" "=" "=/" "<" "<=" ">" ">=" "?"
"1000Cosinus" "1000Sinus"
"AV" "BC" "LC" "TD" "TG"
"Affecter_a" "Afficher" "Aide" "Ajouter_a" "Alors"
"Cercle" "Concatener" "Contour" "credit_iterations"
"Declarer" "Definir" "Demander" "Demander_un_nombre"
"Ellipse" "En_position" "Entier@" "Epaisseur" "Et" "Exemples_de"
"Faire" "Faux" "Fois"
"Geler"
"Initialiser@"
"Liste" "Longueur"
"Millisecondes"
"Nieme" "Nieme@" "Nombre" "Non"
"Ou"
"Queue"
"RAZ" "Rectangle" "Remplissage" "Repeter" "Retirer_de" "Retourner" "Rien"
"sequence_tirages@"
"Segment" "Si" "Sinon"
"Tant_que" "Tester" "Tete" "Texte" "Triangle" "Type"
"valeur_utilisateur" "Vide?" "Vrai"
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
(de !quote_txt (x) (if (or (not x) (!boolM2P (!texte? x)))
                       (!add_quotes x)
                       x))

# Vérif qu’une variable est bien initialisée :
(de !inited (!sym !evaled_sym)
    (or
        (not (sym? !sym))  # pas un symbole
        !evaled_sym        # une valeur non NIL, donc initialisée
        (not !sym)         # le symbole non évalué est NIL, donc ""
        (get !sym 'type)   # un symbole contenant une valeur typée
    ) )

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

**Attention** : le comportement de cette commande diffère suivant les
implémentations.  

* Avec `malg` et `malg-j`, la division donnera toujours un entier.
* Avec `malg-njs`, `malg-rjs` (configuration par défaut de SciTE) et dans le
  navigateur, un nombre à virgule flottante sera retourné.

Dans le premier cas :

    : (/ 9 2)
    -> 4

Sinon :

    : (/ 9 2)
    -> 4.5
")
(put '/ 'text "Commande quotient.")
(put '% 'doc
"Commande qui retourne le reste de la division euclidienne de son premier paramètre par son second paramètre.

    : (% 7 3)
    -> 1
")
(put '% 'text "Commande reste.")
(put '^ 'doc
"Commande qui retourne son premier paramètre à la puissance du second paramètre.

    : (\^ 2 3)
    -> 8
")
(put '^ 'text "Commande puissance.")
(de ^ (!x !y) (** !x !y))

# Commentaires
(put '!!! 'doc
"Commande qui ne fait rien et sert pour les commentaires.

    : (!!! \"Ceci est un commentaire.\")
    -> Rien

Notez bien que l’argument passé à `!!!` doit être un texte et doit donc être
entre guillemets.
")
(put '!!! 'text "Commande commentaire.")
(de !!! (!comz !deuze)
  (ifn (str? !comz) (quit "Un commentaire doit être du texte (entre guillemets)."))
  (if !deuze (quit "La commande `!!!` n’accepte qu’un argument."))
  Rien)

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
(setq *LastStdOut "")
(de !text (truc)
    (let (
          first truc
          efirst (eval first)
         )
         (cond
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
          # m’est arrivé avec (Liste (0 255 0)) :
          ((and lst? (lst? first)) (quit "Parenthèses mal placées." first))
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
  (ifn (!inited first a_afficher) (quit "`Afficher` : la variable n’a pas été déclarée." first))
  (if second (quit (pack "`Afficher` n’a qu’un paramètre, faites plusieurs "
                         "affichages ou utilisez `Concatener`." )))
  # Le boulot
  (setq *LastStdOut (if a_afficher a_afficher ""))
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
"Commande qui concatène les textes ou les listes passés en paramètre (deux ou plus).

    : (Concatener \"abra\" \"cadabra\")
    -> \"abracadabra\"
    : (Concatener \"bonjour \" \"tout \" \"le \" \"monde\")
    -> \"bonjour tout le monde\"
    : (Afficher (Concatener (Liste 1 2) (Liste 3 4)))
    \"(Liste 1 2 3 4)\"
    -> Rien

")
(put 'Concatener 'text "Commande `Concatener`.")
(de !concatener @
  (let (!arg_lst (rest)
        !evaled_arg_lst (mapcar 'eval !arg_lst)
        !arg_nbre (length !arg_lst)
        !error_prefix "`Concatener` : l’argument n°")
       (if (== 0 !arg_nbre)
           ""  # Attention si travail avec listes
           (prog
             # Quelques vérifications :
             # Variables initialisées ?
             (for (!arg_num . !arg) !arg_lst
               (ifn (!inited !arg (car (nth !evaled_arg_lst !arg_num)))
                    (quit (pack !error_prefix !arg_num " n’a pas été déclaré.") !arg)
               )
             )
             # Quelques vérifs, puis le calcul :
             (let (!preumz (car !evaled_arg_lst)
                   !type (!type_sym !preumz))
                  # D’abord le type du premier arg :
                  (ifn (index !type '("liste" "texte"))
                       (quit (pack "Ce type de valeur : \"" !type
                                   "\" , n’est pas concaténable.") !preumz))
                  # Ensuite le type des autres :
                  (for (!arg_num . !arg) !evaled_arg_lst
                    (if (<> !type (!type_sym !arg))
                         (quit (pack !error_prefix !arg_num " n’est pas de type \""
                                     !type "\".") !arg)))
                  # Le calcul :
                  (ifn (<> 1 !arg_nbre)
                       (car !evaled_arg_lst)  # Légère optimisation
                       (if (<> "liste" !type)
                           (apply 'pack !evaled_arg_lst)
                           (apply 'Liste
                                  (make
                                    (for !arg !evaled_arg_lst
                                      (for !elt (elts> !arg)
                                        (link !elt)))))
                       )
                  )
             )
           )
       )
  )
)
(de Concatener !arg_lst (apply '!concatener !arg_lst))
(de Concaténer !arg_lst (apply '!concatener !arg_lst))

# Gestion des variables
(put 'Declarer 'doc
"Commande qui permet de déclarer une variable, avec son type.

    : (Declarer x De_type \"nombre\")
    -> Rien
    : (Type x)
    -> \"nombre\"

Il est possible de déclarer plusieurs variables en une seule instruction :

    : (Declarer x y z De_type \"texte\")
    -> Rien
    : (Type y)
    -> \"texte\"
")
(put 'Declarer 'text "Commande `Declarer`.")
(put 'De_type 'doc "Mot-clef intermédiaire pour la commande `Declarer`.")
(setq De_type 'De_type)
(de !declarer @
  (let (arg_lst (rest)
        nbr_args (length arg_lst))
       (if (lt0 (- nbr_args 3))
           (quit (pack "`Declarer` prend au moins 3 paramètres. "
                       "Vous en donnez " nbr_args ".") )
       )
  )
  (let (arg_lst (rest)
        !splitted (split arg_lst 'De_type)
        !vars (car !splitted)
        !kw (eval (cadr (reverse arg_lst)))
        !type (eval (caadr !splitted)))
       (if (<> De_type !kw) (quit "Mot-clef `De_type` manquant."))
       (for (!var_num . !var) !vars
         # Le type existe-t-il ?
         (ifn (index !type '("booleen" "liste" "nombre" "rien" "texte"))
              (quit "Ce type n’existe pas." !type))
         # Les variables ont-elles déjà été déclarées ?
         (let (!type (!type_sym !var))
           (if (<> "rien" !type)
               (quit (pack "`Declarer` : la variable " !var
                           " a déjà été déclarée de type \"" !type "\"."))
           )
         )
         # Typer la variable.
         (put !var 'type !type)
         # Initialiser la variable à Rien.
         (set !var Rien)
       )
       Rien  # Pas de valeur de retour
  )
)
(de Declarer !arg_lst (apply '!declarer !arg_lst))
(de Déclarer !arg_lst (apply '!declarer !arg_lst))
(de Initialiser ()
  (quit (pack "`Initialiser` a été abandonnée dans la version 0.4. "
              "Merci d’utiliser `Declarer`.")))
(put 'Affecter_a 'doc
"Commande qui permet d’affecter une valeur à une variable.

    : (Declarer x De_type \"nombre\")
    -> Rien
    : (Afficher x)
    Rien
    -> Rien
    : (Affecter_a x 42)
    -> Rien
    : (Afficher x)
    42
    -> Rien

Si la variable contient un texte ou une liste et qu’une position est fournie,
comme par exemple dans :  
`(Affecter_a var val En_position idx)`  
alors l’élément à la `idx` ième position dans `var` est affecté de la valeur
 `val`.")
(put 'Affecter_a 'text "Commande `Affecter_a`.")
(de !affecter_a (var val_expr kw idx_expr cinquieme)
    (let (evaled_var (eval var)
          val (eval val_expr)
          idx (eval idx_expr))
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
                 (if (and (!liste? (eval var)) (not (!liste? val)))
                     (quit (pack !onppauv "autre qu’une liste à une liste, utiliser `Affecter_a … … En_position …`.") var))
                 # Affectation au symbole dans `var`.
                 (ifn (get var 'type)
                      (quit "Variable non déclarée." var)
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
                 # Tout d’abord quelques vérifications:
                 (if (<> 'En_position kw)
                     (quit "Le mot-clef intermédiaire avant l’indice doit être `En_position`.")
                 )
                 (if cinquieme (quit "Après `En_position`, il n’y a qu’un paramètre."))
                 (let (len (!longueur evaled_var))
                   (cond
                     ((<> idx (format (round idx 0) 0 "." ",")) (quit "Indice non entier." idx))
                     ((le0 idx) (quit "Indice négatif ou nul." idx))
                     ((lt0 (- len idx)) (quit "Indice trop grand." (list idx '> len)))
                   )
                 )
                 # Puis le travail:
                 (cond
                   ((!liste? evaled_var) (put> evaled_var val idx))
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
(de Affecter_a arg_lst
  (ifn (caddr arg_lst)
    (!affecter_a (car arg_lst) (cadr arg_lst))
    (!affecter_a (car arg_lst) (cadr arg_lst) (caddr arg_lst) (cadddr arg_lst))
  )
)
(de Affecter_à arg_lst
  (ifn (caddr arg_lst)
    (!affecter_a (car arg_lst) (cadr arg_lst))
    (!affecter_a (car arg_lst) (cadr arg_lst) (caddr arg_lst) (cadddr arg_lst))
  )
)
(put 'En_position 'doc "Mot-clef intermédiaire pour la commande `Affecter_a`.")
(setq En_position 'En_position)

# Demander.
# Avec EmuLisp, les entrées utilisateur se font au travers de la fonction
# _stdPrompt, surchargée dans ide_injection.js. Dans un navigateur, la dernière
# ligne ayant été affichée précédemment est réutilisée lors de l’appel à
# window.prompt.
(put 'valeur_utilisateur 'doc
"Contient la dernière valeur donnée par l’utilisateur en réponse aux commandes
`Demander` et `Demander_un_nombre`.

Préférer l’utilisation d’une variable classique pour stocker le retour des
commandes `Demander` et `Demander_un_nombre` (voir `Declarer` et `Affecter_a`).")
(put 'valeur_utilisateur 'type "rien")
(setq valeur_utilisateur 'Rien)
(put 'Demander 'doc
"Commande qui permet de demander une valeur à l’utilisateur.

    : (Afficher (Demander))
    salut  <--- Ici, c’est l’utilisateur qui tape ;
    salut  <--- là, c’est MicroAlg qui affiche.
    -> Rien

Comme `Demander` retourne un texte, il est parfois nécessaire de convertir la
valeur avant de la stocker dans une variable. Exemple :

    : (Declarer x De_type \"nombre\")
    -> Rien
    : (Affecter_a x (Nombre (Demander)))
    42   <--- Ici, c’est l’utilisateur qui tape.
    -> Rien
    : x
    -> 42

Pour simplifier cette commande, deux facilités ont été mises en place :

* La commande `Demander_un_nombre` peut remplacer la combinaison
  `(Nombre (Demander))`.
* La variable spéciale `valeur_utilisateur` contient la dernière valeur donnée
  par l’utilisateur en réponse aux commandes `Demander` et `Demander_un_nombre`.

**Remarque** : On peut s’en servir pour marquer une pause dans un programme :

    (Afficher \"Pause, appuyez sur Entrée.\")
    (Demander)
")
(put 'Demander 'text "Commande `Demander`.")
(de Demander (!rien_ici)
  (if !rien_ici (quit "`Demander` ne prend pas de paramètre."))
  (put 'valeur_utilisateur 'type "texte")
  (let (!input (in NIL (line T)))
    (setq valeur_utilisateur !input)
  )
)
(put 'Demander_un_nombre 'doc
"Commande qui permet de demander un nombre à l’utilisateur.

Préférer `(Nombre (Demander))`.

Cette commande est peu documentée et sert uniquement pour faciliter le travail
avec les plus jeunes.")
(put 'Demander_un_nombre 'text "Commande `Demander_un_nombre`.")
(de Demander_un_nombre (!rien_ici)
  (if !rien_ici (quit "`Demander_un_nombre` ne prend pas de paramètre."))
  (put 'valeur_utilisateur 'type "nombre")
  (let (!input (in NIL (line T))
        !input_nbre (format !input))
       (ifn !input_nbre (quit "La valeur entrée n’est pas un nombre."))
       (setq valeur_utilisateur !input_nbre)
  )
)

# Listes
# Implémentation interne des listes (POO)
(class +Liste)
# elts
(dm T (ELTS)
      (=: elts ELTS)
)
(dm list> ()
    T)
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
(de Liste !arg_lst
  (let (!evaled_arg_lst (mapcar 'eval !arg_lst)
        !error_prefix "`Liste` : l’argument n°")
       # Variables initialisées ?
       (for (!arg_num . !arg) !arg_lst
         (ifn (!inited !arg (car (nth !evaled_arg_lst !arg_num)))
              (quit (pack !error_prefix !arg_num " n’a pas été déclaré.") !arg)
         )
       )
       (new '(+Liste) !evaled_arg_lst) ))

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
    (if (!liste? !obj)
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
    (ifn (!inited !obj !evaled_obj) (quit "`Longueur` : la variable n’a pas été déclarée." !obj))
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
    (ifn (!inited !obj !evaled_obj) (quit "`Nieme` : la variable n’a pas été déclarée." !obj))
    (setq !onppeuv "`Nieme` ne peut pas extraire une valeur ")
    (cond
        ((num? !evaled_obj) (quit (pack !onppeuv "d’un nombre.") !evaled_obj))
        ((==   !evaled_obj 'Vrai) (quit (pack !onppeuv "du booléen Vrai.")))
        ((==   !evaled_obj 'Faux) (quit (pack !onppeuv "du booléen Faux.")))
        ((==   !evaled_obj 'Rien) (quit (pack !onppeuv "de Rien.")))
    )
    (let (len (!longueur !evaled_obj))
      (cond
        ((not !idx) (quit "`Nieme` : Il manque le deuxième paramètre : l’indice."))
        ((<> !idx (format (round !idx 0) 0 "." ",")) (quit "Indice non entier." !idx))
        ((le0 !idx) (quit "`Nieme` : Indice négatif ou nul." !idx))
        ((lt0 (- len !idx)) (quit "`Nieme` : Indice trop grand." (list !idx '> len)))
      )
    )
    # Le calcul
    (cond
      ((!liste? !evaled_obj) (nth> !evaled_obj !idx))
      ((!boolM2P (!texte? !evaled_obj)) (car (nth (chop !evaled_obj) !idx)))
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
          ((not (<> 0 (!longueur obj)))
           (quit "Un objet vide n’a pas de tête."))
    )
    # Le calcul
    (cond
      ((!liste? obj) (nth> obj 1))
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
          ((not (<> 0 (!longueur obj)))
           (quit "Un objet vide n’a pas de queue."))
    )
    # Le calcul
    (cond
      ((!liste? obj) (apply Liste (cdr (elts> obj))))
      ((str? obj) (pack (cdr (chop obj))))
      (T (quit "Vous cherchez la queue d’une valeur qui n’est ni un texte ni une liste."
               (list obj (Type obj))))
    ))
(put 'Ajouter_a 'doc
"Commande qui, si le premier argument est un texte ou une liste, affecte un
nouvel élément à la fin de ce texte ou de cette liste (après le dernier élément).

Avec du texte :

    : (Declarer mot De_type \"texte\")
    -> Rien
    : (Affecter_a mot \"bonjour\")
    -> Rien
    : (Ajouter_a mot \"!\")
    -> Rien
    : (Afficher mot)
    \"bonjour!\"
    -> Rien

Avec une liste :

    : (Declarer v De_type \"liste\")
    -> Rien
    : (Affecter_a v (Liste 1 3 5 7))
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
        !type_du_sym (!type_sym !sym)
        !evaled_sym (eval !sym)
        !elt (eval (cadr arg_lst))
        !troize (caddr arg_lst))
       # Quelques vérifications
       (if !troize (quit "`Ajouter_a` n’a que deux paramètres."))
       (ifn (!inited !sym !evaled_sym)
            (quit "`Ajouter_a` : la variable n’a pas été déclarée." !sym))
       (if (and (<> !type_du_sym "texte") (<> !type_du_sym "liste"))
           (quit (pack "`Ajouter_a` : la variable doit être de type "
                       "\"texte\" ou \"liste\".")) )
       (ifn (<> 'Rien !evaled_sym)
            (quit (pack "`Ajouter_a` : la variable n’a pas été initialisée. "
                        "Affectez-lui une valeur de type \"texte\" ou \"liste\".")) )
       (ifn (<> "texte" !type_du_sym)
           (if (or (not (!boolM2P (!texte? !elt)))
                   (!boolM2P (> (!longueur !elt) 1)) )
               (quit "On ne peut `Ajouter_a` un texte qu’un caractère." !elt) ))
       # Le calcul
       (cond
         ((!liste? !evaled_sym) (prog (push> !evaled_sym !elt) Rien))
         ((!boolM2P (str? !evaled_sym)) (prog (set !sym (pack !evaled_sym !elt)) Rien))
         (T (quit "Le premier argument de `Ajouter_a` doit être du texte ou une liste." !sym))
       )
  )
)
(put 'Retirer_de 'doc
"Commande qui, si le premier paramètre contient un texte ou une liste, retire
 le dernier élément à la fin de ce texte ou de cette liste et le retourne.

Avec du texte :

    : (Declarer mot De_type \"texte\")
    -> Rien
    : (Affecter_a mot \"bonjour\")
    -> Rien
    : (Retirer_de mot)
    -> \"r\"
    : (Afficher mot)
    \"bonjou\"
    -> Rien

Avec une liste :

    : (Declarer v De_type \"liste\")
    -> Rien
    : (Affecter_a v (Liste 1 3 5 7))
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
       (ifn (!inited !sym !evaled_sym) (quit "`Retirer_de` : la variable n’a pas été déclarée." !sym))
       # Le calcul
       (cond
         ((!liste? !evaled_sym) (pop> !evaled_sym))
         ((!boolM2P (!texte? !evaled_sym))
             (let (!chopped (chop !evaled_sym)
                   !return_val (last !chopped))
                  (set !sym (pack (head (- (length !evaled_sym) 1) !chopped)))
                  !return_val
             ))
         (T (quit "Le premier argument de `Retirer_de` doit être du texte ou une liste." !sym))
       )
  )
)

# Tirages pseudo-aléatoires.
(put 'sequence_tirages@ 'doc
"Liste contenant les nombres entiers qui seront « tirés au sort » par les
commandes `Entier@` et `Nieme@`, dans cet ordre.

    : (Affecter_a sequence_tirages@ (Liste 1 3 5 7))
    -> Rien
    : (Afficher (Entier@ 1 10))
    1
    -> Rien
    : (Afficher (Nieme@ (Liste \"bonjour\" \"tout\" \"le\" \"monde\")))
    \"le\"
    -> Rien
    : (Afficher (Entier@ 1 10))
    5
    -> Rien
    : (Afficher (Entier@ 1 10))
    7
    -> Rien
    : (Afficher (Entier@ 1 10))
    1
    -> Rien
    : (Afficher (Entier@ 1 10))
    3
    -> Rien
")
(setq sequence_tirages@ (Liste))
(put 'sequence_tirages@ 'type "liste")
(de !prochain_etat@ ()
  (ifn !etat@ (setq !etat@ (% (+ (time) (usec)) 4294967296)))  # 2^32
  # http://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use
  # Dans !rand ci-dessous, on ne garde que le quotient par !shift.
  (setq !etat@ (% (+ (* !etat@ 1664525) 1013904223) 4294967296)) )
(de !rand (!min !max)
  (if (!boolM2P (> (!longueur sequence_tirages@) 0))
      (let !val (car (elts> sequence_tirages@))
        (if (or (gt0 (- !min !val)) (gt0 (- !val !max)))
          (quit (pack "Mauvais tirage forcé : " !val " n’est pas compris entre "
                      !min " et " !max "."))
        )
        (setq sequence_tirages@ (apply Liste (cdr (elts> sequence_tirages@))))
        (push> sequence_tirages@ !val)
        !val
      )
      (let (!mod (- (+ !max 1) !min)
            !etat (!prochain_etat@)
            !shift 5
            !shifted_etat (/ (- !etat (% !etat !shift)) !shift))
            (+ !min (% !shifted_etat !mod))
      )
  )
)
# Définition des commandes.
(put 'Initialiser@ 'doc
"Initialise la séquence des nombres pseudo-aléatoires.

En passant une valeur à `Initialiser@` comprise entre 0 (inclus) et 2 puissance
32 (exclus), on initialise l’état du générateur à cette valeur.

    : (Entier@ 0 1000)
    -> 422  # Cette valeur dépendra du moment où un premier tirage aura été
            # demandé avec `Entier@` ou `Nieme@`, au moins à la milliseconde près.
    : (Initialiser@ 0)
    -> Rien
    : (Entier@ 0 1000)
    -> 266  # Cette valeur dépend uniquement du 0 passé à `Initialiser@` ci-dessus.
            # Avec 0 en argument, MicroAlg retournera toujours 266, puis 104, puis 869…
")
(put 'Initialiser@ 'text "Commande `Initialiser@`.")
(de Initialiser@ (x)
    (ifn x (quit "`Initialiser@` prend un paramètre, mais vous n’en donnez aucun.")
           (if (or (lt0 (- x 0)) (le0 (- 4294967296 x)))  # 2^32
               (quit (pack "Initialiser@ n’accepte que des valeurs entre "
                           "0 (inclus) et 2 puissance 32 (exclus).") x)
               (setq !etat@ x)
           )
    )
    Rien
)
(put 'Entier@ 'doc
"Retourne un nombre entier pseudo-aléatoire dans [`min`;`max`] (les deux
paramètres entiers).

    : (Entier@ 1 6)
    -> 2
    : (Entier@ 1 6)
    -> 3

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.
")
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
    (!rand !min !max)
)
(put 'Nieme@ 'doc
"Retourne un élément choisi pseudo-aléatoirement dans la liste ou le texte
 fourni en paramètre.

    : (Nieme@ (Liste 13 666 2015))
    -> 666
    : (Nieme@ (Liste 13 666 2015))
    -> 2015
    : (Nieme@ \"bonjour\")
    -> b
    : (Nieme@ \"bonjour\")
    -> n

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.
")
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
        ((!liste? obj) (nth> obj (!rand 1 (length> obj))))
        ((str? obj) (car (nth (chop obj) (!rand 1 (length obj)))))
        (T Rien)
    )
)

# Types et conversions
(de !liste? (!x)
  (or (try 'list> !x) (try 'list> !evaled_x)) )
(de !type_sym (!x)
  (let (!evaled_x (eval !x)
        embedded_type (ifn (num? !x) (get !x 'type)))
       (cond
             (embedded_type embedded_type)
             ((num?  !evaled_x) "nombre")
             ((!liste? !x) "liste")
             ((!boolM2P (!texte?  !x))        "texte")  # pour les sym textuels ?
             ((or (== Vrai !evaled_x) (== Faux !evaled_x)) "booleen")
             ((and (sym? !x) (get !x 'type)) (get !x 'type))
             ((!boolM2P (== Rien  !evaled_x)) "rien")
             (T Rien)
       ) ) )
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
       (cond
             (embedded_type embedded_type)
             ((not !x) "texte")  # Possiblement "" en direct.
             ((num?  !evaled_x) "nombre")
             ((!liste? !x) "liste")
             ((!boolM2P (!texte?  !x))        "texte")  # pour les sym textuels ?
             ((!boolM2P (!texte?  !evaled_x)) "texte")
             ((or (== Vrai !evaled_x) (== Faux !evaled_x)) "booleen")
             ((and (sym? !x) (get !x 'type)) (get !x 'type))
             ((!boolM2P (== Rien  !evaled_x)) "rien")
             (T Rien)
       ) ) )
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
                ((!liste? x) (!text x))  # mettre avant str?
                ((str? x) x)
                ((num? x) (format x))
                ((sym? x) (pack x))
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
                ((str? x) (or (format x)
                              (quit "`Nombre` : la valeur ne peut pas être convertie.")))
                (T NIL)
              ))

# Structure conditionnelle
(put 'Vrai 'doc "Booléen valant Vrai.")
(put 'Vrai 'text "Vrai")
(setq Vrai 'Vrai)
(put 'Faux 'doc "Booléen valant Faux.")
(put 'Faux 'text "Faux")
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
                    (if (<> Alors kw_alors) (quit "`Si` : Le mot-clef `Alors` doit être le deuxième argument."))
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
(de Et !arg_lst
    # Quelques vérifications :
    (for (!arg_num . !arg) !arg_lst
        (let (!evaled_arg (eval !arg)
              !error_prefix "`Et` : l’argument n°")
             (ifn (!inited !arg !evaled_arg)
                  (quit (pack !error_prefix !arg_num " n’a pas été déclaré.") !arg) )
             (ifn (!boolCheck !evaled_arg)
                  (quit (pack !error_prefix !arg_num " doit être un booléen.") !arg) )
        )
    )
    # Le calcul :
    (!boolP2M (apply 'and (mapcar '((x) (!boolM2P (eval x))) !arg_lst)))
)
(put 'Ou 'doc
"Ou logique.

    : (Ou Vrai Faux)
    -> Vrai
    : (Ou Faux Faux)
    -> Faux

Voir <http://fr.wikipedia.org/wiki/Fonction_OU>.")
(put 'Ou 'text "Commande `Ou`.")
(de Ou !arg_lst
    # Quelques vérifications :
    (for (!arg_num . !arg) !arg_lst
        (let (!evaled_arg (eval !arg)
              !error_prefix "`Ou` : l’argument n°")
             (ifn (!inited !arg !evaled_arg)
                  (quit (pack !error_prefix !arg_num " n’a pas été déclaré.") !arg) )
             (ifn (!boolCheck !evaled_arg)
                  (quit (pack !error_prefix !arg_num " doit être un booléen.") !arg) )
        )
    )
    # Le calcul :
    (!boolP2M (apply 'or (mapcar '((x) (!boolM2P (eval x))) !arg_lst)))
)

# Structures itératives
(put 'credit_iterations 'doc
"Variable stockant le nombre d’itérations possibles restantes.

    : (Tant_que Vrai Faire (Afficher credit_iterations))
    999
    998
    997
    [...]
    3
    2
    1
    Erreur :
    Crédit d’itérations épuisé (1 000 par défaut).
    Vous pouvez recharger votre crédit en affectant une valeur
    à la variable `credit_iterations`.
")
(setq credit_iterations 1000)
(put 'credit_iterations 'type "nombre")
(setq credit_iterations_message
      (pack "Crédit d’itérations épuisé (1 000 par défaut). Vous pouvez "
            "recharger votre crédit en affectant une valeur à la variable "
            "`credit_iterations`."))
(put 'Tant_que 'doc
"Structure itérative de type « tant que ... faire ... ».

    : (Declarer i De_type \"nombre\")
    -> Rien
    : (Affecter_a i 3)
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
(de Tant_que arg_lst (let (!cond (car arg_lst)
                           !mot-clef (cadr arg_lst)
                           !corps (cddr arg_lst))
                          (if (<> 'Faire !mot-clef) (quit "Commande `Tant_que` sans mot-clé `Faire`."))
                          (while (!boolCheckM2P (eval !cond) "La condition n’est pas un booléen.")
                                 (if (=0 (dec 'credit_iterations))
                                     (quit credit_iterations_message))
                                 (run !corps))
                          Rien
                     )
)
(put 'Faire 'doc
"Structure itérative de type « faire ... tant que ... ».

    : (Declarer i De_type \"nombre\")
    -> Rien
    : (Affecter_a i 3)
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
(de Faire arg_lst (let (!splitted (split arg_lst 'Tant_que)
                        !corps (car !splitted)
                        !cond (caadr !splitted))
                       (ifn (<> arg_lst !corps)
                            (quit "Commande `Faire` sans mot-clé `Tant_que`."))
                       (if  (!boolM2P (> (length (cadr !splitted)) 1))
                            (quit "Il ne faut qu’un seul élément après le mot-clé `Tant_que`."))
                       (run !corps)
                       (let !evaled_cond (eval !cond)
                         (if (!boolCheckM2P !evaled_cond) "La condition n’est pas un booléen.")
                           (while (!boolCheckM2P !evaled_cond "La condition n’est pas un booléen.")
                                  (if (=0 (dec 'credit_iterations))
                                      (quit credit_iterations_message))
                                  (run !corps)
                                  (setq !evaled_cond (eval !cond))
                         )
                       )
                       Rien
                  )
)
(put 'Fois 'doc "Mot-clef intermédiaire pour la commande `Repeter`.")
(setq Fois 'Fois)
(put 'Repeter 'doc
"Structure itérative de type « répéter ... fois : ... ».

    (Repeter nombre Fois
        instruction_1
        instruction_2
        ...
    )

Exemples :

    : (Repeter 3 Fois (Afficher \"Bonjour.\"))
    Bonjour.
    Bonjour.
    Bonjour.
    -> Rien

    : (Repeter 2 Fois (Afficher \"C’est…\") (Afficher \" …bien.\"))
    C’est…
     …bien.
    C’est…
     …bien.
    -> Rien
")
(put 'Repeter 'text "Commande `Repeter`.")
(de !repeter @
  (let (!error_prefix "`Repeter` : "
        !arg_lst (rest))
       (if (<> 2 (index 'Fois !arg_lst))
           (quit "`Repeter` : Le mot-clef `Fois` doit être en 2ème position.") )

       (let (!nb_repetitions (eval (car !arg_lst))
             !corps (cddr !arg_lst))
            (ifn (num? !nb_repetitions)
                 (quit "Le nombre de répétitions doit être de type \"nombre\".") )
            (do !nb_repetitions (run !corps))
       )
       Rien
  )
)
(de Repeter !arg_lst (apply '!repeter !arg_lst))
(de Répéter !arg_lst (apply '!repeter !arg_lst))

# Procédures utilisateur
# Tout d’abord les générateurs d’initialisation
(de !liste_inits_type (!syms)
    (mapcar '((!sym) (list 'put (cons 'quote !sym) ''type (list 'Type !sym))) !syms)
)
(de !liste_inits_val (!syms)
    (mapcar '((!sym) (list 'Affecter_a !sym !sym)) !syms)
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
(de !definir @
  (let (arg_lst (rest)
        signature (car arg_lst)
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
(de Definir !arg_lst (apply '!definir !arg_lst))
(de Définir !arg_lst (apply '!definir !arg_lst))
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
                       (ifn (!liste? exemples)
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
         ((not (!liste? !exemples))
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
(de !texte? (!obj)  # helper évaluant son arg
       (cond
        ((not !obj) Vrai)                       # Possiblement "" en direct.
        ((num? !obj) Faux)                      # Un nombre en direct.
        ((!liste? !obj) Faux)                   # Liste.
        ((if (sym? !obj) (== (get !obj 'type) "texte")) Vrai)  # Un sym textuel.
        ((== (get !obj 'type) "texte") Vrai)    # Un sym textuel.
        ((str? !obj) Vrai)                      # Texte.
        (T Faux)                                # Le reste.
       )
  )
# Sans le suffixe '?'
# Éviter le message « redefined »
(setq = NIL)
(setq < NIL)
(setq <= NIL)
(setq > NIL)
(setq >= NIL)
# Factorisation du test du nbre d’args
(de !check2args (!cmd !primz !deuz !troiz)
  (let !bla " prend 2 paramètres. Vous "
    (ifn !primz (quit (pack "`" !cmd "`" !bla "n’en donnez aucun.")))
    (ifn !deuz  (quit (pack "`" !cmd "`" !bla "n’en donnez qu’un seul.")))
    (if  !troiz (quit (pack "`" !cmd "`" !bla "en donnez au moins trois.")))
  )
)
# Factorisation du test du type des args
(de !check_type_args (!cmd !primz !deuz)
  (if (not (and (num? !primz) (num? !deuz)))
      (quit (pack "Les paramètres de " !cmd " doivent être des nombres"))
  )
)
(put '= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont égales,
et `Faux` sinon.

    : (= 42 42)
    -> Vrai
")
(put '= 'text "Prédicat `=`.")
(de = (x y)
  (ifn (<> x y)
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
(de =/ (x y)
  (if (<> x y) Vrai Faux))
(put '< 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre croissant (strictement), et `Faux` sinon.

    : (< 42 42)
    -> Faux
    : (< 42 43)
    -> Vrai
")
(put '< 'text "Prédicat `<`.")
(de < (x y !troiz)
  (!check2args "<" x y !troiz)
  (!check_type_args "<" x y)
  (ifn (ge0 (- x y)) Vrai Faux))
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
(de <= (x y !troiz)
  (!check2args "<=" x y !troiz)
  (!check_type_args "<=" x y)
  (if (le0 (- x y)) Vrai Faux))
(put '> 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre décroissant (strictement), et `Faux` sinon.

    : (> 42 42)
    -> Faux
    : (> 43 42)
    -> Vrai
")
(put '> 'text "Prédicat `>`.")
(de > (x y !troiz)
  (!check2args ">" x y !troiz)
  (!check_type_args ">" x y)
  (ifn (le0 (- x y)) Vrai Faux))
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
(de >= (x y !troiz)
  (!check2args ">=" x y !troiz)
  (!check_type_args ">=" x y)
  (if (ge0 (- x y)) Vrai Faux))
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
      (ifn (!inited !obj !evaled_obj) (quit "`Vide?` : la variable n’a pas été déclarée." !obj))
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
(put 'Rien 'text "Rien")
(setq Rien 'Rien)
(put '... 'text "Commande `...`.")
(put '... 'doc "Commande permettant de présenter les exercices à trous.")
(de ... ()
  (quit (pack "Les trois points et/ou les parenthèses `(...)` doivent être "
              "remplacés pour que le programme fonctionne.")) )

# Mesure du temps d’exécution
(put 'Millisecondes 'doc
"Retourne le nombre de millisecondes écoulées depuis le début du programme.

Exemples :

    : (Millisecondes)
    -> 4167
    : (Millisecondes)
    -> 9511

Cette commande s’utilise surtout en calculant la différence entre deux appels,
le premier étant stocké dans une variable.

")
(put 'Millisecondes 'text "Commande `Millisecondes`.")
(de Millisecondes (!rien_ici)
  (if !rien_ici (quit "`Millisecondes` ne prend pas de paramètre."))
  (/ (usec) 1000) )

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

# Processing
(de !processing (cmd)
  (cond
    ((not (<> *EMUENV "browser"))
       (js:eval
         (pack "processing_sketches[cst.context.processing_elt].interact('"
               cmd "');")) )
    ((not *EMUENV)
       (let? Sock (connect "127.0.0.1" 12345)
         (out Sock (prinl cmd))
         (close Sock) ) )
    (T (quit "Impossible d’utiliser la sortie graphique avec `malg-njs` ou `malg-rjs`."))
  )
)
(put 'RAZ 'doc
"Dans la sortie graphique, efface l’écran et repositionne la tortue.

Exemple : `(RAZ)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'RAZ 'text "Commande `RAZ`.")
(de RAZ ()
  (!processing "RAZ")
  Rien
)
(put 'Contour 'doc
"Dans la sortie graphique, permet de choisir la couleur du contour des tracés.

Exemple : `(Contour (Liste 255 0 0))` ou `(Contour (Liste 255 0 0 127))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#couleurs>.")
(put 'Contour 'text "Commande `Contour`.")
(de Contour (couleur)
  (!processing (pack "Contour "
                     (Nieme couleur 1)
                     " " (Nieme couleur 2)
                     " " (Nieme couleur 3)
                     (Si (= (Longueur couleur) 4)
                      Alors (pack " " (Nieme couleur 4))
                      Sinon "")
  ))
  Rien
)
(put 'Remplissage 'doc
"Dans la sortie graphique, permet de choisir la couleur du remplissage des tracés.

Exemple : `(Remplissage (Liste 255 0 0))` ou `(Remplissage (Liste 255 0 0 127))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#couleurs>.")
(put 'Remplissage 'text "Commande `Remplissage`.")
(de Remplissage (couleur)
  (!processing (pack "Remplissage "
                     (Nieme couleur 1)
                     " " (Nieme couleur 2)
                     " " (Nieme couleur 3)
                     (Si (= (Longueur couleur) 4)
                      Alors (pack " " (Nieme couleur 4))
                      Sinon "")
  ))
  Rien
)
(put 'Epaisseur 'doc
"Dans la sortie graphique, permet de choisir l’épaisseur des tracés, en pixels.

Exemple : `(Epaisseur 5)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Epaisseur 'text "Commande `Epaisseur`.")
(de Epaisseur (epaisseur)
  (!processing (pack "Epaisseur " epaisseur))
  Rien
)
(put 'Segment 'doc
"Dans la sortie graphique, trace un segment.

Les deux paramètres sont les listes des coordonnées des deux extrémités
du segment.

Exemple : `(Segment (Liste 300 300) (Liste 450 600))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Segment 'text "Commande `Segment`.")
(de Segment (point1 point2)
  (!processing (pack "Segment " (Nieme point1 1) " " (Nieme point1 2) " "
                                (Nieme point2 1) " " (Nieme point2 2)))
  Rien
)
(put 'Cercle 'doc
"Dans la sortie graphique, trace un cercle.

Le premier paramètre est la liste des coordonnées du centre du cercle,  
le second paramètre est le rayon du cercle.

Exemple : `(Cercle (Liste 300 300) 100)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Cercle 'text "Commande `Cercle`.")
(de Cercle (centre rayon)
  (!processing (pack "Cercle " (Nieme centre 1) " " (Nieme centre 2)
                     " " (* 2 rayon)))
  Rien
)
(put 'Ellipse 'doc
"Dans la sortie graphique, trace une ellipse.

Le premier paramètre est la liste des coordonnées du centre de l’ellipse,  
le deuxième paramètre est le rayon horizontal, le troisième le rayon vertical.

Exemple : `(Ellipse (Liste 300 300) 200 100)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Ellipse 'text "Commande `Ellipse`.")
(de Ellipse (centre rayon1 rayon2)
  (!processing (pack "Ellipse " (Nieme centre 1) " " (Nieme centre 2)
                     " " (* 2 rayon1) " " (* 2 rayon2)))
  Rien
)
(put 'Rectangle 'doc
"Dans la sortie graphique, trace un rectangle.

Les deux paramètres sont les listes des coordonnées des deux coins du rectangle.

Exemple : `(Rectangle (Liste 300 300) (Liste 450 600))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Rectangle 'text "Commande `Rectangle`.")
(de Rectangle (point1 point2)
  (!processing (pack "Rectangle " (Nieme point1 1) " " (Nieme point1 2) " "
                                  (Nieme point2 1) " " (Nieme point2 2)))
  Rien
)
(put 'Triangle 'doc
"Dans la sortie graphique, trace un triangle.

Les trois paramètres sont les listes des coordonnées des sommets du triangle.

Exemple : `(Triangle (Liste 200 300) (Liste 400 300) (Liste 300 400))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Triangle 'text "Commande `Triangle`.")
(de Triangle (point1 point2 point3)
  (!processing (pack "Triangle " (Nieme point1 1) " " (Nieme point1 2) " "
                                 (Nieme point2 1) " " (Nieme point2 2) " "
                                 (Nieme point3 1) " " (Nieme point3 2)))
  Rien
)

# Tortue
(put 'AV 'doc
"Dans la sortie graphique, fait avancer la tortue.

Le paramètre est le nombre de pixels que la tortue parcourt.

Exemple : `(AV 100)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#tortue>.")
(put 'AV 'text "Commande `AV` (avance).")
(de AV (!longueur !deuz)
  (ifn !longueur (quit "`AV` a besoin d’un paramètre, mais vous n’en donnez pas."))
  (if !deuz (quit "`AV` n’accepte qu’un seul paramètre, pas plus."))
  (!processing (pack "AV " !longueur))
  Rien
)
(put 'TD 'doc
"Dans la sortie graphique, fait tourner la tortue vers la droite.

Le paramètre est l’angle de rotation en degrés. Si l’angle n’est pas fourni, il
vaudra par défaut 90°.

Exemples :

    (TD 90)  # pour tourner d’un quart de tour vers droite
    (TD)     # idem
    (TD 45)  # pour tourner de 45° vers la droite

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#tortue>.")
(put 'TD 'text "Commande `TD` (tourne à droite).")
(de TD (!angle !deuz)
  (if !deuz (quit "`TD` accepte au plus un paramètre. Vous en donnez deux."))
  (!processing (pack "TD " (if !angle @ 90)))
  Rien
)
(put 'TG 'doc
"Dans la sortie graphique, fait tourner la tortue vers la gauche.

Le paramètre est l’angle de rotation en degrés. Si l’angle n’est pas fourni, il
vaudra par défaut 90°.

Exemples :

    (TG 90)  # pour tourner d’un quart de tour vers gauche
    (TG)     # idem
    (TG 45)  # pour tourner de 45° vers la gauche

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#tortue>.")
(put 'TG 'text "Commande `TG` (tourne à gauche).")
(de TG (!angle !deuz)
  (if !deuz (quit "`TG` accepte au plus un paramètre. Vous en donnez deux."))
  (!processing (pack "TG " (if !angle @ 90)))
  Rien
)
(put 'BC 'doc
"Dans la sortie graphique, baisse le crayon de la tortue.

Exemple : `(BC)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#tortue>.")
(put 'BC 'text "Commande `BC` (baisse crayon).")
(de BC (!primz)
  (if !primz (quit "`BC` ne prend pas de paramètre."))
  (!processing "BC")
  Rien
)
(put 'LC 'doc
"Dans la sortie graphique, lève le crayon de la tortue.

Exemple : `(LC)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#tortue>.")
(put 'LC 'text "Commande `LC` (lève crayon).")
(de LC (!primz)
  (if !primz (quit "`LC` ne prend pas de paramètre."))
  (!processing "LC")
  Rien
)

# Fonctions numériques
(setq !valeurs_trigo '(
  1000 999 999 998 997 996 994 992 990 987 984 981 978 974 970 965 961 956 951
   945 939 933 927 920 913 906 898 891 882 874 866 857 848 838 829 819 809 798
   788 777 766 754 743 731 719 707 694 681 669 656 642 629 615 601 587 573 559
   544 529 515 500 484 469 453 438 422 406 390 374 358 342 325 309 292 275 258
   241 224 207 190 173 156 139 121 104 87 69 52 34 17 0
))
(put '1000Cosinus 'doc
"Retourne un entier proche de 1000 fois le cosinus de l’angle donné en paramètre.

L’angle doit être fourni en degrés.

    : (1000Cosinus 30)
    -> 866
")
(put '1000Cosinus 'text "Commande `1000Cosinus`.")
(de 1000Cosinus (!angle !deuz)
  (ifn !angle (quit "`1000Cosinus` a besoin d’un paramètre, mais vous n’en donnez pas."))
  (if !deuz (quit "`1000Cosinus` n’accepte qu’un seul paramètre, pas plus."))
  (cond
    ((lt0 !angle) (1000Cosinus (- !angle)))
    ((gt0 (- !angle 360)) (1000Cosinus (% !angle 360)))
    ((gt0 (- !angle 180)) (- (1000Cosinus (- !angle 180))))
    ((gt0 (- !angle 90)) (- (1000Sinus (- !angle 90))))
    (T (car (nth !valeurs_trigo (+ !angle 1))))
  )
)
(put '1000Sinus 'doc
"Retourne un entier proche de 1000 fois le sinus de l’angle donné en paramètre.

L’angle doit être fourni en degrés.

    : (1000Sinus 30)
    -> 500
")
(put '1000Sinus 'text "Commande `1000Sinus`.")
(de 1000Sinus (!angle !deuz)
  (ifn !angle (quit "`1000Sinus` a besoin d’un paramètre, mais vous n’en donnez pas."))
  (if !deuz (quit "`1000Sinus` n’accepte qu’un seul paramètre, pas plus."))
  (cond
    ((lt0 !angle) (- (1000Sinus (- !angle))))
    ((gt0 (- !angle 360)) (1000Sinus (% !angle 360)))
    ((gt0 (- !angle 180)) (- (1000Sinus (- !angle 180))))
    ((gt0 (- !angle 90)) (1000Cosinus (- !angle 90)))
    (T (car (nth !valeurs_trigo (- 91 !angle))))
  )
)

(put 'Geler 'doc
"Retourne l’argument qu’on lui passe, sans l’évaluer.

    : (Geler x)
    -> x
")
(put 'Geler 'text "Commande `Geler`.")
(de Geler !arg_lst
    (if (<> 1 (length !arg_lst))
        (quit (pack "`Geler` : prend exactement un paramètre. "
                    "Vous en donnez " (length !arg_lst) ".")) )
    (car !arg_lst)
)
