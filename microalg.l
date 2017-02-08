(setq version "0.4.07")
(put 'version 'text (pack "MicroAlg version " version))
(setq apropos
"L’idée de MicroAlg est née lors d’une formation ISN, de la frustration due à
l’abscence d’un langage vraiment axé sur la pédagogie.  
À l’origine pensé comme DSL au sein de Tcl, il est finalement embarqué dans
PicoLisp.  
Voir <http://microalg.info>.")
(put 'apropos 'doc "Symbole contenant des informations sur MicroAlg.")

(setq !sans_declaration T)
(seed (time))

(setq symboles '(
"..." "+" "-" "*" "/" "%" "\^"
"!!!" "=" "=/" "<" "<=" ">" ">=" "?"
"1000Cosinus" "1000Sinus"
"AV" "BC" "LC" "TD" "TG"
"Affecter_a" "Afficher" "Aide" "Ajouter_a" "Alors"
"Carre" "Cercle" "Concatener" "Contour" "credit_iterations"
"Declarer" "Definir" "Demander"
"Demander_un_nombre" "Demander_un_nombre_pour" "Diff"
"Ellipse" "En_position" "Entier@" "Epaisseur" "Et" "Exemples_de"
"Faire" "Faux" "Fois"
"Geler"
"Initialiser@"
"Liste" "Longueur"
"Millisecondes"
"Nieme" "Nieme@" "Nombre" "nombre_demandé" "Non"
"Ou"
"Produit" "Puissance"
"Queue" "Quotient"
"RAZ" "Racine" "Rectangle" "Remplissage" "Repere" "Repeter" "Reste"
"Retirer_de" "Retourner" "Rien"
"sequence_tirages@"
"Segment" "Si" "Sinon" "Somme"
"Tant_que" "Tester" "Tete" "Texte" "texte_demandé" "Triangle" "Type"
"Vide?" "Vrai"
))

# picolisp.l shimz
(ifn caadr
  (de caadr (arg)
     (car (car (cdr arg)))
  )
)
(ifn cdddr
  (de cdddr (arg)
     (cdr (cddr arg))
  )
)
(ifn cddddr
  (de cddddr (arg)
     (cdr (cdddr arg))
  )
)
(ifn cut
  (de cut (n sym acc)
    (let esym (eval sym)
      (cond
        ((=0 n) (reverse acc))
        (T      (let elt (pop sym) (push 'acc elt) (cut (- n 1) sym acc)))
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

# For Ersatz, fix sqrt in lib.l
# (>= N M) is now (ge0 (- N M)) and the same for > with gt0
(if (= *CPU "JVM")
   (prog
      (setq sqrt NIL)
      (de sqrt (N F)
         (cond
            ((lt0 N) (quit "Bad argument" N))
            (N
               (and (num? F) (setq N (* N @)))
               (let (M 1  R 0)
                  (while (ge0 (- N M))
                     (setq M (>> -2 M)) )
                  (loop
                     (if (gt0 (- (inc 'R M) N))
                        (dec 'R M)
                        (dec 'N R)
                        (inc 'R M) )
                     (setq R (>> 1 R)  M (>> 2 M))
                     (T (=0 M)) )
                  (and F (> N R) (inc 'R))
                  R ) ) ) )
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
(de !boolM2P (x)
  (if (<> Faux x) T NIL) )
(de !boolP2M (x)
  (if x Vrai Faux) )
(de !boolCheck (!x)
  (if (or (!egaux !x Vrai) (!egaux !x Faux)) T))
(de !boolCheckM2P (!val !cmd !code_erreur)
  (ifn (!boolCheck !val)
       (!erreur !code_erreur (pack "`" !cmd "` : la condition `" !val
                                   "` n’est pas un booléen."))
       (!boolM2P !val)
  )
)

# Helpers pour affichage:
(de !add_quotes (x)
  (pack "\"" x "\"") )
(de !quote_txt (x)
  (if (or (not x) (!boolM2P (!texte? x)))
      (!add_quotes x)
      x) )
(de !text_n_quote (x)
  (if (or (not x) (!boolM2P (!texte? x)))
      (!add_quotes (!text x))
      (!text x)) )

(de !erreur @
  (let (!code (next))
    (quit (pack (rest) " [erreur n°" !code "]"))))

(de pico_list_to_transient (!lst)
  (pack "(" (glue " " !lst) ")") )

# Vérif qu’une variable est bien initialisée :
(de !inited (!sym !evaled_sym)
    (or
        !sans_declaration
        (not (sym? !sym))  # pas un symbole
        !evaled_sym        # une valeur non NIL, donc initialisée
        (not !sym)         # le symbole non évalué est NIL, donc ""
        (get !sym 'type)   # un symbole contenant une valeur typée
    ) )
(de !inited_sans_sans_declaration (!sym !evaled_sym)
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
(put 'Somme 'doc (get '+ 'doc))
(put 'Somme 'text (get '+ 'text))
(setq Somme '+)
(put '- 'doc
"Commande qui retourne la différence de deux nombres ou l’opposé d’un nombre.

Si deux arguments sont fournis, `-` soustrait le second au premier et
retourne le résultat.

    : (- 7 3)
    -> 4

Si un seul argument est fourni, `-` retourne l’opposé de cet argument.

    : (- 7)
    -> -7
")
(put '- 'text "Commande différence.")
(put 'Diff 'doc (get '- 'doc))
(put 'Diff 'text (get '- 'text))
(setq Diff '-)
(put '* 'doc
"Commande qui multiplie tous ses paramètres et retourne le résultat.

    : (* 2 3)
    -> 6
    : (* 2 3 4)
    -> 24
")
(put '* 'text "Commande produit.")
(put 'Produit 'doc (get '* 'doc))
(put 'Produit 'text (get '* 'text))
(setq Produit '*)
(put '/ 'doc
"Commande qui divise son premier paramètre par son second paramètre et retourne le résultat.

    : (/ 8 2)
    -> 4

**Attention** : le comportement de cette commande diffère suivant les
implémentations.

* Avec `malg` et `malg-j`, la division donnera toujours un entier.
* Avec `malg-njs`, `malg-rjs` (configuration par défaut de SciTE) et dans le
  navigateur, un nombre à virgule flottante peut être retourné.

Dans le premier cas :

    : (/ 9 2)
    -> 4

Sinon :

    : (/ 9 2)
    -> 4.5
")
(put '/ 'text "Commande quotient.")
(put 'Quotient 'doc (get '/ 'doc))
(put 'Quotient 'text (get '/ 'text))
(setq Quotient '/)
(put '% 'doc
"Commande qui retourne le reste de la division euclidienne de son premier paramètre par son second paramètre.

    : (% 7 3)
    -> 1
")
(put '% 'text "Commande reste.")
(put 'Reste 'doc (get '% 'doc))
(put 'Reste 'text (get '% 'text))
(setq Reste '%)
(put '^ 'doc
"Commande qui retourne son premier paramètre à la puissance du second paramètre.

    : (\^ 2 3)
    -> 8

**Attention** : le comportement de cette commande diffère suivant les
implémentations.

* Avec `malg` et `malg-j`, la puissance doit être entière.
* Avec `malg-njs`, `malg-rjs` (configuration par défaut de SciTE) et dans le
  navigateur, la puissance peut être un nombre à virgule flottante et un nombre
  à virgule flottante peut être retourné.

Dans le premier cas :

    : (\^ 2 0.5)
    -> 2

Sinon :

    : (\^ 2 0.5)
    -> 1.4142135623730951
")
(put '^ 'text "Commande puissance.")
(de ^ (!x !y) (** !x !y))
(put 'Puissance 'doc (get '^ 'doc))
(put 'Puissance 'text (get '^ 'text))
(setq Puissance '^)

(put 'Carre 'doc
"Commande qui retourne le carré de son paramètre.

    : (Carre 3)
    -> 9
")
(put 'Carre 'text "Commande Carre.")
(de Carre (!nbre)
  (^ !nbre 2)
)
(setq Carré Carre)

(put 'Racine 'doc
"Commande qui retourne la racine carrée de son paramètre.

    : (Racine 9)
    -> 3

**Attention** : le comportement de cette commande diffère suivant les
implémentations.

* Avec `malg` et `malg-j`, le résultat sera toujours un nombre entier.
* Avec `malg-njs`, `malg-rjs` (configuration par défaut de SciTE) et dans le
  navigateur, le résultat peut être un nombre à virgule flottante.

Dans le premier cas :

    : (Racine 2)
    -> 1

Sinon :

    : (Racine 2)
    -> 1.4142135623730951
")
(put 'Racine 'text "Commande Racine.")
(de Racine !arg_lst
  (if (<> 1 (length !arg_lst))
      (!erreur 109 (pack "`Racine` attend exactement un paramètre. "
                  "Vous en donnez " (length arg_lst) ".")))
  (let (!arg (car !arg_lst)
        !evaled_arg (eval !arg)
        !rladeun "`Racine` : L’argument doit être un nombre")
       (ifn (!inited !arg !evaled_arg)
            (!erreur 112 "`Racine` : la variable `" !arg
                         "` n’a pas été déclarée."))
       (ifn (num? !evaled_arg)
         (!erreur 110 !rladeun ". Vous avez donné `"
                      (!text_n_quote !evaled_arg) "`."))
       (ifn (gt0 !evaled_arg)
         (!erreur 111 !rladeun " positif ou nul. Vous avez donné `"
                      !evaled_arg "`."))
       (sqrt !evaled_arg)
  )
)

# Commentaires
(put '!!! 'doc
"Commande qui ne fait rien et sert pour les commentaires.

Utilisation :

    (!!! \"...\")

Exemple :

    : (!!! \"Ceci est un commentaire.\")
    -> Rien

Notez bien que :

1. l’argument passé à `!!!` doit être un texte et doit donc être entre
   guillemets ;
2. `!!!` ne doit pas être utilisé la place d’un argument ou d’un mot-clé
   intermédiaire. On ne peut donc pas mettre un commentaire dans :
    * un `Si` avant le `Alors` ;
    * un `Repeter` avant le `Fois` ;
    * un `Tant_que` avant le `Faire` ;
    * un `Faire` après le `Faire` ;
    * des opérations sur les nombres, les textes…
    * …
")
(put '!!! 'text "Commande commentaire.")
(de !!! !arg_lst
  (if (<> (length !arg_lst) 1)
    (!erreur 1 "La commande `!!!` n’accepte qu’un argument."))
  (ifn (str? (car !arg_lst))
    (!erreur 2 "Un commentaire doit être du texte (entre guillemets)."))
  Rien)

# Aide
(put 'Aide 'doc
"Commande qui permet d’obtenir de l’aide.

Utilisation :

    (Aide ...)
")
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

Utilisation :

    (Afficher ...)

Exemple :

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
          ((lst? first)
            (!erreur 3 "Parenthèses mal placées dans `"
                       (pico_list_to_transient first) "`."))
          (T (!erreur 4 "Pas de représentation textuelle pour `" first "`."))
         )
     )
)

(de Afficher args
  (let
    (first (car args)
     second (cadr args)
    )
    # Quelques vérifications
    (if second
      (!erreur 6 "`Afficher` n’a qu’un paramètre.")
      (let
        (a_afficher (!text first))
        (ifn (!inited first a_afficher)
             (!erreur 5 "`Afficher` : la variable `" first
                        "` n’a pas été déclarée."))
        # Le boulot
        (setq *LastStdOut (if a_afficher a_afficher ""))
        (ifn !testing
             (println (ifn a_afficher
                           " "
                           a_afficher)))
        Rien  # Pas de valeur de retour
      )
    )
  )
)

# Concatener
(put 'Concatener 'doc
"Commande qui concatène les textes ou les listes passés en paramètre (deux ou plus).

Utilisation :

    (Concatener ... [...])

Exemples :

    : (Concatener \"abra\" \"cadabra\")
    -> \"abracadabra\"
    : (Concatener \"bonjour\" \" \" \"tout\" \" \" \"le\" \" \" \"monde\")
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
                    (!erreur 7 !error_prefix !arg_num ", `" !arg "`, "
                               "est une variable qui n’a pas été déclarée.")
               )
             )
             # Quelques vérifs, puis le calcul :
             (let (!preumz (car !evaled_arg_lst)
                   !type (!type_sym !preumz))
                  # D’abord le type du premier arg :
                  (ifn (index !type '("liste" "texte"))
                       (!erreur 8 "`Concatener` : la valeur `" !preumz "` est "
                                  "de type `\"" !type "\"` et n’est donc pas "
                                  "concaténable."))
                  # Ensuite le type des autres :
                  (for (!arg_num . !arg) !evaled_arg_lst
                    (if (<> !type (!type_sym !arg))
                         (!erreur 9 !error_prefix !arg_num ", "
                                    "`" (!text !arg) "`, "
                                    "doit être de type `\"" !type "\"` "
                                    "mais est de type `\"" (!type_sym !arg) "\"`.")))
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
"Commande qui déclare une variable et lui associe son type.

Utilisation :

    (Declarer ... [...] De_type \"...\")

Pour une liste des types disponibles, voir [cette section](#types).

Exemples :

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
  (off !sans_declaration)
  (let (arg_lst (rest)
        nbr_args (length arg_lst))
       (if (lt0 (- nbr_args 3))
           (!erreur 10 "`Declarer` prend au moins 3 paramètres. "
                       "Vous en donnez " nbr_args ".")
       )
  )
  (let (arg_lst (rest)
        !splitted (split arg_lst 'De_type)
        !vars (car !splitted)
        !kw (cadr (reverse arg_lst))
        !type (car (reverse arg_lst))
        !msg "`Declarer` : ")
       # Le type est-il manquant ?
       (ifn (<> De_type !type)
            (!erreur 94 (pack !msg "le type est manquant.")) )
       # Le type est-t-il bien du texte ?
       (ifn (!boolM2P (!texte? !type))
            (!erreur 12 !msg "le type ne peut pas être `" !type "` "
                        "mais doit être du texte (entre \"\")."))
       (if (<> De_type !kw)
           (!erreur 11 !msg "mot-clef `De_type` manquant."))
       # Le type existe-t-il ?
       (ifn (index !type '("booleen" "liste" "nombre" "rien" "texte"))
            (!erreur 13 !msg "le type `\"" !type "\"` n’existe pas."))
       (for (!var_num . !var) !vars
         # Les variables ont-elles déjà été déclarées ?
         (let (!type (!type_sym !var))
           (if (<> "rien" !type)
               (!erreur 14 !msg "la variable " !var
                           " a déjà été déclarée de type `\"" !type "\"`.")
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
  (!erreur 15 "`Initialiser` a été abandonnée dans la version 0.4. "
              "Merci d’utiliser `Declarer`."))
(put 'Affecter_a 'doc
"Commande qui affecte une valeur à une variable.

Utilisations :

    (Affecter_a ... ...)

ou

    (Affecter_a ... ... En_position ...)

Exemples :

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
`val`.

    : (Declarer mot De_type \"texte\")
    -> Rien
    : (Affecter_a mot \"salut\")
    -> Rien
    : (Afficher mot)
    \"salut\"
    -> Rien
    : (Affecter_a mot \"z\" En_position 1)
    -> Rien
    : (Afficher mot)
    \"zalut\"
    -> Rien
")
(put 'Affecter_a 'text "Commande `Affecter_a`.")
(de !affecter_a (!var val_expr kw idx_expr cinquieme)
    (let (evaled_var (eval !var)
          val (eval val_expr)
          idx (eval idx_expr))
         (if (== val En_position)
             (!erreur 58 "`Affecter_a ... En_position ...` : "
                         "avant `En_position`, il faut la variable "
                         "puis la valeur.") )
         (setq !onppauv "On ne peut pas affecter une valeur ")
         (cond
             ((num? !var) (!erreur 16 !onppauv "à `" !var "`, qui est un nombre."))
             ((str? !var) (!erreur 16 !onppauv "à `" (!add_quotes !var) "`, "
                                      "qui est un texte."))
             ((== !var 'Vrai) (!erreur 16 !onppauv "au booléen `Vrai`."))
             ((== !var 'Faux) (!erreur 16 !onppauv "au booléen `Faux`."))
             ((== !var 'Rien) (!erreur 16 !onppauv "à `Rien`."))
         )
         (if (and
               (not !sans_declaration)
               (atom !var)
               (not (get !var 'type)))
              (!erreur 17 "`Affecter_a` : la variable `" !var "` "
                          "n’a pas été déclarée.")
         )
         (ifn kw
              # Affecter_a sans En_position
              (prog
                 (if (and (== "liste" (!type_sym !var))
                          (not (!liste? val)))
                     (!erreur 18 "`" !var "` est une liste. On ne peut pas lui "
                                 "affecter `" (!text_n_quote val) "` "
                                 "qui n’est pas une liste.")
                 )
                 # Affectation au symbole dans `!var`.
                 (if (or
                       !sans_declaration
                       (not val)  # Pour accepter "" qui est NIL.
                       (== "rien" (get !var 'type))
                       (<> Faux (= (get !var 'type) (Type val))))
                     (set !var val)
                     (!erreur 19 "`Affecter_a` : le type ne correspond pas. "
                                 "`" !var "` est un `\"" (get !var 'type) "\"` "
                                 "et `" (!text val) "` "
                                 "est un `\"" (Type val) "\"`.")
                 )
              )
              # Affecter_a avec En_position
              (prog
                 # Affectation à l’élément `idx` du symbole dans `!var`.
                 # Tout d’abord quelques vérifications:
                 (if (<> 'En_position kw)
                     (!erreur 20 "`Affecter_a` n’est pas bien fermée, "
                                 "ou il manque `En_position`.")
                 )
                 (if cinquieme
                     (!erreur 21 "`Affecter_a` : après `En_position`, "
                                 "il n’y a qu’un paramètre."))
                 (let (!aepli (pack "`Affecter_a ... En_position ...` : "
                                    "après `En_position`, l’indice "))
                   (cond
                     ((not idx_expr)
                       (!erreur 22 !aepli "est manquant."))
                     ((not idx)
                       (!erreur 23 !aepli "est une variable qui n’a pas été "
                                   "déclarée : `" idx_expr "`."))
                     ((!boolM2P (!texte? idx))
                       (!erreur 24 !aepli "doit être un nombre et non un "
                                   "texte. Donc `\"" idx "\"` ne convient pas."))
                     ((== Rien idx)
                       (!erreur 57 !aepli "doit être un nombre. Donc "
                                   "`Rien` ne convient pas."))
                     ((not (num? idx))
                       (!erreur 25 !aepli "doit être un nombre. Donc "
                                   "`" (!text idx_expr) "` ne convient pas."))
                     ((<> idx (format (round idx 0) 0 "." ","))
                       (!erreur 26 !aepli "doit être un nombre entier. "
                                   "Donc `" idx "` ne convient pas."))
                     ((le0 idx)
                       (!erreur 27 !aepli "doit être strictement positif. "
                                   "Donc `" idx "` ne convient pas."))
                     ((lt0 (- (!longueur evaled_var) idx))
                       (!erreur 28 !aepli "est trop grand (position "
                                   idx " dans un objet de longueur "
                                   (!longueur evaled_var) ")."))
                   )
                 )
                 (if (!boolM2P (!texte? evaled_var))  # check pour textes, inutile pour listes
                     (ifn (and (str? val) (not (<> 1 (length val))))  ## pas ==
                          (!erreur 29 "La valeur affectée à un texte doit être "
                                      "un texte de longueur 1 (un caractère) "
                                      "mais vous avez donné `"
                                      (!quote_txt val) "`.")
                     )
                 )
                 # Puis le travail:
                 (cond
                   ((!liste? evaled_var) (put> evaled_var val idx))
                   ((str? evaled_var)
                    (let (chopped (chop evaled_var))
                         (set !var (pack (head (- idx 1) chopped)
                                        val
                                        (tail (- idx) chopped) )) ))
                   ((== Rien evaled_var)
                    (!erreur 56 "Affectation positionnelle impossible sur "
                                  "`Rien`."))
                   (T (!erreur 30 "Affectation positionnelle impossible sur "
                                  "`" (!text !var) "` qui est de type `\""
                                  (Type evaled_var) "\"`."))
                 )
              )
         )
         Rien  # Pas de valeur de retour
    )
)
(de Affecter_a arg_lst
  (if (!boolM2P (< (length arg_lst) 2))
      (!erreur 93 "`Affecter_a` attends au moins deux arguments. "
                  "Vous en donnez " (length arg_lst) ".") )
  (ifn (caddr arg_lst)
    (!affecter_a (car arg_lst) (cadr arg_lst))
    (!affecter_a (car arg_lst) (cadr arg_lst) (caddr arg_lst) (cadddr arg_lst) (car (cddddr arg_lst)))
  )
)
(de Affecter_à arg_lst
  (if (!boolM2P (< (length arg_lst) 2))
      (!erreur 93 "`Affecter_a` attends au moins deux arguments. "
                  "Vous en donnez " (length arg_lst) ".") )
  (ifn (caddr arg_lst)
    (!affecter_a (car arg_lst) (cadr arg_lst))
    (!affecter_a (car arg_lst) (cadr arg_lst) (caddr arg_lst) (cadddr arg_lst) (car (cddddr arg_lst)))
  )
)
(put 'En_position 'doc "Mot-clef intermédiaire pour la commande `Affecter_a`.")
(setq En_position 'En_position)

# Demander.
# Avec EmuLisp, les entrées utilisateur se font au travers de la fonction
# _stdPrompt, surchargée dans ide_injection.js. Dans un navigateur, la dernière
# ligne ayant été affichée précédemment est réutilisée lors de l’appel à
# window.prompt.
(put 'texte_demande 'doc
"Contient le dernier texte donné par l’utilisateur en réponse à la commande
`Demander`.

Exemple :

    : (Demander)
    bonjour   <--- Ici, c’est l’utilisateur qui tape.
    -> \"bonjour\"
    : (Afficher texte_demande)
    \"bonjour\"
    -> Rien
")
(put 'texte_demandé 'doc (get 'texte_demande 'doc))
(put 'texte_demande 'type "texte")
(setq texte_demande 'Rien)
(put 'texte_demandé 'type "texte")
(setq texte_demandé 'Rien)
(put 'nombre_demande 'doc
"Contient le dernier nombre donné par l’utilisateur en réponse à la commande
`Demander_un_nombre`.

Exemple :

    : (Demander_un_nombre)
    42   <--- Ici, c’est l’utilisateur qui tape.
    -> 42
    : (Afficher nombre_demande)
    42
    -> Rien
")
(put 'nombre_demandé 'doc (get 'nombre_demande 'doc))
(put 'nombre_demande 'type "nombre")
(setq nombre_demande 'Rien)
(put 'nombre_demandé 'type "nombre")
(setq nombre_demandé 'Rien)
(put 'Demander 'doc
"Commande qui demande un texte à l’utilisateur et retourne ce texte.

Utilisation :

    (Demander)

Exemples :

    : (Afficher (Demander))
    salut      <--- Ici, c’est l’utilisateur qui tape ;
    \"salut\"  <--- là, c’est MicroAlg qui affiche.
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
* La variable spéciale `texte_demande` (ou `texte_demandé`) contient le
  dernier texte donné par l’utilisateur en réponse à la commande `Demander`.
  Pour `Demander_un_nombre`, c’est la variable `nombre_demande` (ou
  `nombre_demandé`).

**Remarque** : On peut s’en servir pour marquer une pause dans un programme :

    (Afficher \"Pause, appuyez sur Entrée.\")
    (Demander)
")
(put 'Demander 'text "Commande `Demander`.")
(de Demander (!rien_ici)
  (if !rien_ici
      (!erreur 31 "`Demander` ne prend pas de paramètre."))
  (let (!input (in NIL (line T)))
       (setq texte_demande !input)
       (setq texte_demandé !input)
  )
)
(put 'Demander_un_nombre 'doc
"Commande qui demande un nombre à l’utilisateur et retourne ce nombre.

Utilisation :

    (Demander_un_nombre)

Exemples :

    : (Afficher (Demander_un_nombre))
    42  <--- Ici, c’est l’utilisateur qui tape ;
    42  <--- là, c’est MicroAlg qui affiche.
    -> Rien

Pour simplifier cette commande, une facilité a été mise en place :

* La variable spéciale `nombre_demande` (ou `nombre_demandé`) contient le
  dernier nombre donné par l’utilisateur en réponse à la commande
  `Demander_un_nombre`.
")
(put 'Demander_un_nombre 'text "Commande `Demander_un_nombre`.")
(de Demander_un_nombre (!rien_ici)
  (if !rien_ici
      (!erreur 32 "`Demander_un_nombre` ne prend pas de paramètre."))
  (let (!input (in NIL (line T))
        !input_nbre (format !input))
       (ifn !input_nbre
            (!erreur 33 "`Demander_un_nombre` : "
                        "La valeur entrée n’est pas un nombre."))
       (setq nombre_demande !input_nbre)
       (setq nombre_demandé !input_nbre)
  )
)

(put 'Demander_un_nombre_pour 'doc
"Commande qui demande un nombre à l’utilisateur et l’affecte à la variable donnée.

Utilisation :

    (Demander_un_nombre_pour ...)

Exemples :

    : (Demander_un_nombre_pour x)
    42  <--- Ici, c’est l’utilisateur qui tape ;
    -> Rien
    : (Afficher x)
    42  <--- là, c’est MicroAlg qui affiche.
    -> Rien

*Remarque* : La variable spéciale `nombre_demande` (ou `nombre_demandé`) n’est
pas mise à jour.
")
(put 'Demander_un_nombre_pour 'text "Commande `Demander_un_nombre_pour`.")
(de Demander_un_nombre_pour !arg_lst
  (if (<> 1 (length !arg_lst))
      (!erreur 103 "`Ajouter_a` attend exactement un argument. "
                   "Vous en donnez " (length arg_lst) "."))
  (let (!var (car !arg_lst)
        !dunp "`Demander_un_nombre_pour` : "
       )
       (ifn !var
            (!erreur 105 !dunp "le premier argument doit être une variable. "
                               "Vous avez donné le texte vide `\"\"`.") )
       (if (str? !var)
           (!erreur 106 !dunp "le premier argument doit être une variable. "
                               "Vous avez donné le texte `\""!var "\"`.") )
       (ifn (sym? !var)
            (!erreur 107 !dunp "le premier argument doit être une variable. "
                               "Vous avez donné `"!var "`.") )
       (if (and
             (not !sans_declaration)
             (atom !var)
             (not (get !var 'type)))
            (!erreur 108 !dunp "la variable `" !var "` n’a pas été déclarée.")
       )
       (let (!input (in NIL (line T))
             !input_nbre (format !input))
            (ifn !input_nbre
                 (!erreur 104 "`Demander_un_nombre_pour` : "
                              "La valeur entrée n’est pas un nombre."))
            (set !var !input_nbre)
       )
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

Utilisation :

    (Liste ... [...])

Exemple :

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
              (!erreur 34 !error_prefix !arg_num ", `"  !arg "`, "
                          "est une variable qui n’a pas été déclarée.")
         )
       )
       (new '(+Liste) !evaled_arg_lst) ))

# Manipulations de texte et de liste
(put 'Longueur 'doc
"Commande qui retourne la longueur d’un texte ou d’une liste.

Utilisation :

    (Longueur ...)

Exemples :

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
    (if !deuze (!erreur 35 "`Longueur` n’a qu’un paramètre."))
    (ifn (!inited !obj !evaled_obj)
         (!erreur 36 "`Longueur` : la variable `" !obj "` n’a pas été déclarée."))
    (let (!npdl " n’a pas de `Longueur`.")
      (cond
        ((num? !evaled_obj)
          (!erreur 37 "Le nombre " !evaled_obj !npdl))
        ((== !evaled_obj 'Vrai)
          (!erreur 38 "`Vrai`" !npdl))
        ((== !evaled_obj 'Faux)
          (!erreur 39 "`Faux`" !npdl))
        ((== !evaled_obj 'Rien)
          (!erreur 40 "`Rien`" !npdl))
        ((get !obj 'doc)
          (!erreur 41 "`" !obj "`" !npdl))
      )
    )
    # Le calcul
    (!longueur !evaled_obj)
  )
)
(put 'Nieme 'doc
"Permet d’accéder en lecture à un des éléments d’un texte ou d’une liste
(se lit « énième »).

La numérotation commence à 1.

Utilisation :

    (Nieme ... ...)

Exemples :

    : (Nieme \"salut\" 2)
    -> \"a\"
    : (Nieme (Liste 1 3 5 7) 2)
    -> 3
")
(put 'Nieme 'text "Commande `Nieme`.")
(de Nieme arg_lst
  (let (!obj (car arg_lst)
        !evaled_obj (eval !obj)
        !idx (cadr arg_lst)
        !evaled_idx (eval (cadr arg_lst))
        !longueur_arg_lst (length arg_lst))
    # Quelques vérifications
    (if (<> !longueur_arg_lst 2)
        (!erreur 42 "`Nieme` attend exactement deux arguments, vous en donnez "
                    !longueur_arg_lst "."))
    # Vérifications concernant l’objet dont on extrait une valeur
    (ifn (!inited !obj !evaled_obj)
        (!erreur 43 "`Nieme` : la variable `" !obj "` n’a pas été déclarée."))
    (let (!onppeuv "`Nieme` ne peut pas extraire une valeur ")
         (cond
           ((num? !evaled_obj)
             (!erreur 44 !onppeuv "du nombre " !evaled_obj "."))
           ((== !evaled_obj 'Vrai)
             (!erreur 45 !onppeuv "du booléen `Vrai`."))
           ((== !evaled_obj 'Faux)
             (!erreur 46 !onppeuv "du booléen `Faux`."))
           ((== !evaled_obj 'Rien)
             (!erreur 47 !onppeuv "de `Rien`."))
         )
    )
    # Vérifications concernant l’indice
    (let (!nli "`Nieme` : l’indice ")
         (cond
           ((not !idx)
             (!erreur 48 !nli "doit être un nombre "
                         "et non ce qui semble être un texte vide."))
           ((not !evaled_idx)
             (!erreur 49 !nli "est une variable non déclarée : `" !idx "`."))
           ((!boolM2P (!texte? !evaled_idx))
             (!erreur 50 !nli "doit être un nombre et donc le texte "
                         "`\"" !evaled_idx "\"` ne convient pas."))
           ((== Rien !evaled_idx)
             (!erreur 51 !nli "vaut `Rien` et donc ne convient pas. "
                         "Il faut un nombre."))
           ((not (num? !evaled_idx))
             (!erreur 55 !nli "doit être un nombre et donc `"
                         (!text !idx) "` ne convient pas."))
           ((<> !evaled_idx (format (round !evaled_idx 0) 0 "." ","))
             (!erreur 52 !nli "doit être un nombre entier et donc `"
                         (!text !evaled_idx) "` ne convient pas."))
           ((le0 !evaled_idx)
             (!erreur 53 !nli "doit être strictement positif et donc "
                         !evaled_idx " ne convient pas."))
           ((lt0 (- (!longueur !evaled_obj) !evaled_idx))
             (!erreur 54 !nli "est trop grand (position "
                         !evaled_idx " dans un objet de longueur "
                         (!longueur !evaled_obj) ")."))
         )
    )
    # Le calcul
    (cond
      ((!liste? !evaled_obj)
        (nth> !evaled_obj !evaled_idx))
      ((!boolM2P (!texte? !evaled_obj))
        (car (nth (chop !evaled_obj) !evaled_idx)))
      (T
        Rien)
    )
  )
)
(put 'Tete 'doc
"Commande qui retourne le premier élément d’un texte ou d’une liste.

Utilisation :

    (Tete ...)

Exemples :

    : (Tete \"salut\")
    -> \"s\"
    : (Tete (Liste 1 3 5 7))
    -> 1
")
(put 'Tete 'text "Commande `Tete`.")
(de Tete !arg_lst
  (let (!arg (car !arg_lst)
        !evaled_arg (eval !arg))
       # Quelques vérifications
       (cond
          ((not (!inited !arg !evaled_arg))
           (!erreur 60 "`Tete` : la variable `" !arg "` n’a pas été déclarée."))
          ((not (or (!liste? !evaled_arg) (str? !evaled_arg) (not !evaled_arg)))
           (!erreur 61 "Vous cherchez la tête de `"
                       (!text_n_quote !evaled_arg) "`, "
                       "qui n’est ni un texte ni une liste mais de type `\""
                       (Type !evaled_arg) "\"`."))
          ((=0 (!longueur !evaled_arg))
           (!erreur 62 "Un valeur vide n’a pas de tête."))
    )
    # Le calcul
    (cond
      ((!liste? !evaled_arg) (nth> !evaled_arg 1))
      ((str? !evaled_arg)    (car (chop !evaled_arg)))
    )
  )
)
(put 'Queue 'doc
"Commande qui retourne une copie du texte ou de la liste en paramètre,
 mais sans son premier élément.

Utilisation :

    (Queue ...)

Exemples :

    : (Queue \"salut\")
    -> \"alut\"
    : (Afficher (Queue (Liste 1 3 5 7)))
    -> \"(Liste 3 5 7)\"
")
(put 'Queue 'text "Commande `Queue`.")
(de Queue !arg_lst
  (let (!arg (car !arg_lst)
        !evaled_arg (eval !arg))
       # Quelques vérifications
       (cond
          ((not (!inited !arg !evaled_arg))
           (!erreur 63 "`Queue` : la variable `" !arg "` n’a pas été déclarée."))
          ((not (or (!liste? !evaled_arg) (str? !evaled_arg) (not !evaled_arg)))
           (!erreur 64 "Vous cherchez la queue de `"
                       (!text_n_quote !evaled_arg) "`, "
                       "qui n’est ni un texte ni une liste mais de type `\""
                       (Type !evaled_arg) "\"`."))
          ((=0 (!longueur !evaled_arg))
           (!erreur 65 "Un valeur vide n’a pas de queue."))
    )
    # Le calcul
    (cond
      ((!liste? !evaled_arg) (apply Liste (cdr (elts> !evaled_arg))))
      ((str? !evaled_arg)    (pack (cdr (chop !evaled_arg))))
    )
  )
)
(put 'Ajouter_a 'doc
"Commande qui, si le premier argument est un texte ou une liste, affecte un
nouvel élément à la fin de ce texte ou de cette liste (après le dernier élément).

Utilisation :

    (Ajouter_a ... ...)

Exemples avec du texte :

    : (Declarer mot De_type \"texte\")
    -> Rien
    : (Affecter_a mot \"bonjour\")
    -> Rien
    : (Ajouter_a mot \"!\")
    -> Rien
    : (Afficher mot)
    \"bonjour!\"
    -> Rien

Exemples avec une liste :

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
        !elt (eval (cadr arg_lst)))
       # Quelques vérifications
       (if (<> 2 (length arg_lst))
           (!erreur 66 "`Ajouter_a` attend exactement deux arguments. "
                       "Vous en donnez " (length arg_lst) "."))
       (ifn (!inited !sym !evaled_sym)
            (!erreur 67 "`Ajouter_a` : la variable `" !sym "` "
                        "n’a pas été déclarée."))
       (ifn (<> 'Rien !evaled_sym)
            (!erreur 68 "`Ajouter_a` : la variable `" !sym "` n’a pas été "
                        "initialisée. Affectez-lui une valeur de type "
                        "`\"texte\"` ou `\"liste\"`."))
       (ifn (index !type_du_sym '("liste" "texte"))
           (!erreur 69 "`Ajouter_a` : la variable `" !sym "` est de type "
                       "`\"" !type_du_sym "\"` alors qu’elle doit être de type "
                       "`\"texte\"` ou `\"liste\"`."))
       (ifn (<> "texte" !type_du_sym)
           (if (or (not (!boolM2P (!texte? !elt)))
                   (!boolM2P (> (!longueur !elt) 1)) )
               (!erreur 70 "Vous voulez ajouter `" (!text_n_quote !elt) "` à "
                           "`" !sym "` mais on ne peut `Ajouter_a` un texte "
                           "qu’un seul caractère.")))
       # Le calcul
       (cond
         ((!liste? !evaled_sym) (prog (push> !evaled_sym !elt) Rien))
         ((!boolM2P (str? !evaled_sym)) (prog (set !sym (pack !evaled_sym !elt)) Rien))
       )
  )
)
(put 'Retirer_de 'doc
"Commande qui, si le premier paramètre contient un texte ou une liste, retire
 le dernier élément à la fin de ce texte ou de cette liste et le retourne.

Utilisation :

    (Retirer_de ...)

Exemples avec du texte :

    : (Declarer mot De_type \"texte\")
    -> Rien
    : (Affecter_a mot \"bonjour\")
    -> Rien
    : (Retirer_de mot)
    -> \"r\"
    : (Afficher mot)
    \"bonjou\"
    -> Rien

Exemples avec une liste :

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
        !type_du_sym (!type_sym !sym)
        !evaled_sym (eval !sym))
       # Quelques vérifications
       (if (<> 1 (length arg_lst))
           (!erreur 71 "`Retirer_de` attend exactement un argument. "
                       "Vous en donnez " (length arg_lst) "."))
       (ifn (!inited !sym !evaled_sym)
            (!erreur 72 "`Retirer_de` : la variable `" !sym "` "
                        "n’a pas été déclarée."))
       (ifn (<> 'Rien !evaled_sym)
            (!erreur 73 "`Retirer_de` : la variable `" !sym "` n’a pas été "
                        "initialisée. Affectez-lui une valeur de type "
                        "`\"texte\"` ou `\"liste\"`."))
       (ifn (index !type_du_sym '("liste" "texte"))
           (!erreur 74 "`Retirer_de` : la variable `" !sym "` est de type "
                       "`\"" !type_du_sym "\"` alors qu’elle doit être de type "
                       "`\"texte\"` ou `\"liste\"`."))
       # Le calcul
       (cond
         ((!liste? !evaled_sym) (pop> !evaled_sym))
         ((!boolM2P (!texte? !evaled_sym))
             (let (!chopped (chop !evaled_sym)
                   !return_val (last !chopped))
                  (set !sym (pack (head (- (length !evaled_sym) 1) !chopped)))
                  !return_val
             ))
       )
  )
)

# Tirages pseudo-aléatoires.
(put 'sequence_tirages@ 'doc
"Liste contenant les nombres entiers qui seront « tirés au sort », dans l’ordre
indiqué par cette liste et en boucle, par les commandes `Entier@` et `Nieme@`.

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
(setq !shift@ 5)
(setq !space_length@ (/ (- 4294967296 (% 4294967296 !shift@)) !shift@))
(de !prochain_etat@ ()
  (ifn !etat@ (setq !etat@ (% (+ (time) (usec)) 4294967296)))  # 2^32
  # http://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use
  # Dans !rand ci-dessous, on ne garde que le quotient par !shift@.
  (setq !etat@ (% (+ (* !etat@ 1664525) 1013904223) 4294967296)) )
(de !rand (!min !max)
  (ifn !etat@
    (rand !min !max)
    (if (!boolM2P (> (!longueur sequence_tirages@) 0))
        (let !val (car (elts> sequence_tirages@))
          (if (or (gt0 (- !min !val)) (gt0 (- !val !max)))
              (!erreur 75 "Mauvais tirage forcé : " !val " "
                          "n’est pas compris entre " !min " et " !max ".")
          )
          (setq sequence_tirages@ (apply Liste (cdr (elts> sequence_tirages@))))
          (push> sequence_tirages@ !val)
          !val
        )
        (let (!mod (- (+ !max 1) !min)
              !etat (!prochain_etat@)
              !shifted_etat (/ (- !etat (% !etat !shift@)) !shift@))
              (if (gt0 (- !mod !space_length@))
                  (!erreur 76 "L’espace des valeurs possibles dépasse "
                              !space_length@ "."))
              (+ !min (% !shifted_etat !mod))
        )
    )
  )
)
# Définition des commandes.
(put 'Initialiser@ 'doc
"Initialise la séquence des nombres pseudo-aléatoires.

Utilisation :

    (Entier@ ... ...)

En passant une valeur à `Initialiser@` comprise entre 0 (inclus) et 2 puissance
32 (exclus), on initialise l’état du générateur à cette valeur.

Exemples :

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
(de Initialiser@ !arg_lst
    (let (!arg (car !arg_lst)
          !x   (eval !arg))
         (cond
           ((<> 1 (length !arg_lst))
            (!erreur 77 "`Initialiser@` attend exactement un argument. "
                        "Vous en donnez " (length !arg_lst) "."))
           ((not (!inited !arg !x))
            (!erreur 78 "`Initialiser@` : la variable `" !arg "` "
                        "n’a pas été déclarée."))
           ((not (<> 'Rien !x))
            (!erreur 79 "`Initialiser@` : la variable `" !arg "` n’a pas été "
                        "initialisée. Affectez-lui une valeur de type "
                        "`\"nombre\"`."))
           ((not (num? !x))
            (!erreur 80 "`Initialiser@` : l’argument doit être un nombre. "
                        "Vous avez donné `" (!text_n_quote !x) "`."))
           ((or (lt0 (- !x 0)) (le0 (- 4294967296 !x)))  # 2^32
            (!erreur 81 "`Initialiser@` n’accepte que des valeurs entre "
                        "0 (inclus) et 2 puissance 32 (exclus). "
                        "Vous avez donné : " !x "."))
         )
         (setq !etat@ !x)
         Rien
    )
)
(put 'Entier@ 'doc
"Retourne un nombre entier pseudo-aléatoire dans [`min`;`max`] (les deux
paramètres entiers).

Utilisation :

    (Entier@ ... ...)

Exemples :

    : (Entier@ 1 6)
    -> 2
    : (Entier@ 1 6)
    -> 3

Le suffixe `@` indique le caractère pseudo-aléatoire de cette commande.
")
(put 'Entier@ 'text "Commande `Entier@`.")
(de Entier@ !arg_lst
  (let (!min (eval (car !arg_lst))
        !max (eval (cadr !arg_lst)))
       # Quelques vérifications
       (cond
        ((<> 2 (length !arg_lst))
         (!erreur 82 "`Entier@` attend exactement deux arguments. "
                     "Vous en donnez " (length !arg_lst) "."))
        ((<> !min (format (round !min 0) 0 "." ","))
         (!erreur 83 "Le minimum donné à `Entier@` n’est pas un nombre entier "
                     "(vous avez donné " (!text_n_quote !min) ")."))
        ((<> !max (format (round !max 0) 0 "." ","))
         (!erreur 84 "Le maximum donné à `Entier@` n’est pas un nombre entier "
                     "(vous avez donné " (!text_n_quote !max) ")."))
        ((!boolM2P (> !min !max))
         (!erreur 85 "Le minimum et le maximum de `Entier@`, "
                     "ne sont pas dans l’ordre (" !min " > " !max ")."))
       )
       # Le calcul
       (!rand !min !max)
  )
)
(put 'Nieme@ 'doc
"Retourne un élément choisi pseudo-aléatoirement dans la liste ou le texte
 fourni en paramètre.

Utilisation :

    (Nieme' ...)

Exemples :

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
(de Nieme@ !arg_lst
  (let (!arg (car !arg_lst)
        !evaled_arg (eval !arg)
        !type_de_l_arg (!type_sym !evaled_arg)
        !onppeuv "`Nieme@` ne peut pas extraire un élément pseudo-aléatoire ")
       # Quelques vérifications
       (cond
        ((<> 1 (length !arg_lst))
         (!erreur 86 "`Nieme@` attend exactement un argument. "
                     "Vous en donnez " (length !arg_lst) "."))
        ((num? !evaled_arg)
         (!erreur 87 !onppeuv "du nombre " !evaled_arg "."))
        ((== !evaled_arg 'Vrai)
         (!erreur 88 !onppeuv "du booléen `Vrai`."))
        ((== !evaled_arg 'Faux)
         (!erreur 89 !onppeuv "du booléen `Faux`."))
        ((== !evaled_arg 'Rien)
         (!erreur 90 !onppeuv "de la valeur `Rien`."))
        ((not (index !type_de_l_arg '("liste" "texte")))
         (!erreur 91 "`Nieme@` ne peut extraire un élément pseudo-aléatoire "
                     "que d’une liste ou d’un texte. "
                     "Vous avez donné `" (!text_n_quote !evaled_arg) "` "
                     "qui est de type `\"" !type_de_l_arg "\"`."))
       )
       # Le calcul
       (cond
        ((!liste? !evaled_arg)
         (nth> !evaled_arg (!rand 1 (length> !evaled_arg))))
        ((str? !evaled_arg)
         (car (nth (chop !evaled_arg) (!rand 1 (length !evaled_arg)))))
       )
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

Utilisation :

    (Type ...)

Exemples :

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
  (if (<> (length arg_lst) 1)
      (!erreur 92 "`Type` attend exactement un argument. Vous en donnez "
                  (length arg_lst) ".") )
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

Utilisation :

    (Texte ...)

Exemples :

    : (Texte 42)
    -> \"42\"
")
(put 'Texte 'text "Commande `Texte`.")
(de Texte !arg_lst
  (if (<> 1 (length !arg_lst))
      (!erreur 95 (pack "`Texte` attend exactement un paramètre. "
                  "Vous en donnez " (length arg_lst) ".")))
  (let !obj (eval (car !arg_lst))
    (cond
      ((== !obj Vrai) "Vrai")
      ((== !obj Faux) "Faux")
      ((== !obj Rien) "Rien")
      ((!liste? !obj) (!text !obj))  # mettre avant str?
      ((str? !obj) !obj)
      ((num? !obj) (format !obj))
      ((sym? !obj) (pack !obj))
      (T "???")
    )
  )
)
(put 'Nombre 'doc
"Commande qui retourne le nombre correspondant à son paramètre textuel.

Utilisation :

    (Nombre ...)

Exemples :

    : (Nombre \"42\")
    -> 42
")
(put 'Nombre 'text "Commande `Nombre`.")
(de Nombre !arg_lst
  (if (<> 1 (length !arg_lst))
      (!erreur 96 (pack "`Nombre` attend exactement un paramètre. "
                  "Vous en donnez " (length arg_lst) ".")))
  (let (!obj (eval (car !arg_lst))
        !msg "`Nombre` ne peut pas travailler sur ")
    (cond
      ((num? !obj) !obj)
      ((not  !obj) (!erreur 97 (pack !msg "le texte vide.")))
      ((str? !obj) (or (format !obj)
                       (!erreur 97 (pack !msg "le texte `" !obj "`."))))
      (T (!erreur 98 (pack !msg "la valeur `" !obj "`.")))
    )
  )
)

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

Utilisation :

    (Si booléen
     Alors
        instruction_si_Vrai_1
        instruction_si_Vrai_2
        ...
     Sinon
        instruction_si_Faux_1
        instruction_si_Faux_2
        ...
    )

Ou :

    (Si booléen
     Alors
        instruction_si_Vrai_1
        instruction_si_Vrai_2
        ...
    )
")
(put 'Si 'text "Commande `Si`.")
(de Si arg_lst
  (let (condition (car arg_lst)
        kw_alors  (cadr arg_lst)
        splitted  (split (cddr arg_lst) 'Sinon)
        bloc_vrai (car splitted)
        bloc_faux (cadr splitted))
       (if (<> Alors kw_alors)
           (!erreur 99 "`Si` : Le mot-clef `Alors` doit être le deuxième argument."))
       (if (!boolCheckM2P (eval condition) "Si" 100)
           (run bloc_vrai)
           (if (== NIL bloc_faux)
               Rien
               (run bloc_faux)))
  )
)

# Opérations logiques
(put 'Non 'doc
"Non logique.

Utilisation :

    (Non ...)

Exemples :

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

Utilisation :

    (Et ... [...])

Exemples :

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
    (!boolP2M (apply 'and (mapcar '((!x) (!boolM2P (eval !x))) !arg_lst)))
)
(put 'Ou 'doc
"Ou logique.

Utilisation :

    (Ou ... [...])

Exemples :

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
    (!boolP2M (apply 'or (mapcar '((!x) (!boolM2P (eval !x))) !arg_lst)))
)

# Structures itératives
(put 'credit_iterations 'doc
"Variable stockant le nombre d’itérations possibles restantes.

    : (Tant_que Vrai Faire (Afficher credit_iterations))
    1000
    999
    998
    997
    [...]
    3
    2
    1
    Erreur :
    Crédit d’itérations épuisé (1 001 par défaut).
    Vous pouvez recharger votre crédit en affectant une valeur
    à la variable `credit_iterations`.

Pour des programmes ayant besoin de plus d’itérations, il faudra
ajouter en tête de programme :

    (Affecter_a credit_iterations 50000)
")
(setq credit_iterations 1001)
(put 'credit_iterations 'type "nombre")
(setq credit_iterations_message
      (pack "Crédit d’itérations épuisé (1 001 par défaut). Vous pouvez "
            "recharger votre crédit en affectant une valeur à la variable "
            "`credit_iterations`."))
(put 'Tant_que 'doc
"Structure itérative de type « tant que ... faire ... ».

Utilisation :

    (Tant_que booléen
     Faire
        instruction_1
        instruction_2
        ...
    )

Exemple :

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

Remarque :

Par défaut, les commandes `Tant_que` et `Repeter` sont bridées à 1 001 tours (au
total, c’est-à-dire en cumulant les différents `Tant_que` et `Repeter` tout au
long du programme, même s’ils sont imbriqués). Voir la variable
[credit_iterations](#sym-credit_iterations).
")
(put 'Tant_que 'text "Commande `Tant_que`.")
(de Tant_que arg_lst
  (let (!cond (car arg_lst)
        !mot-clef (cadr arg_lst)
        !corps (cddr arg_lst))
       (if (<> 'Faire !mot-clef) (quit "Commande `Tant_que` sans mot-clé `Faire`."))
       (while (!boolCheckM2P (eval !cond) "Tant_que" 101)
              (if (=0 (dec 'credit_iterations))
                  (!erreur 114 credit_iterations_message))
              (run !corps))
       Rien
  )
)
(put 'Faire 'doc
"Structure itérative de type « faire ... tant que ... ».

Utilisation :

    (Faire
        instruction_1
        instruction_2
        ...
     Tant_que booléen
    )

Exemple :

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
(de Faire arg_lst
  (let (!splitted (split arg_lst 'Tant_que)
        !corps (car !splitted)
        !cond (caadr !splitted))
       (ifn (<> arg_lst !corps)
            (quit "Commande `Faire` sans mot-clé `Tant_que`."))
       (if  (!boolM2P (> (length (cadr !splitted)) 1))
            (quit "Il ne faut qu’un seul élément après le mot-clé `Tant_que`."))
       (run !corps)
       (let !evaled_cond (eval !cond)
         (if (!boolCheckM2P !evaled_cond) "Faire" 102)
           (while (!boolCheckM2P !evaled_cond "Faire" 102)
                  (if (=0 (dec 'credit_iterations))
                      (!erreur 114 credit_iterations_message))
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

Utilisation :

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

Remarque :

Par défaut, les commandes `Tant_que` et `Repeter` sont bridées à 1 001 tours (au
total, c’est-à-dire en cumulant les différents `Tant_que` et `Repeter` tout au
long du programme, même s’ils sont imbriqués). Voir la variable
[credit_iterations](#sym-credit_iterations).
")
(put 'Repeter 'text "Commande `Repeter`.")
(de !repeter @
  (let (!cmd_pref "`Repeter` : "
        !arg_lst (rest))
       (if (<> 2 (index 'Fois !arg_lst))
           (quit (pack !cmd_pref "le mot-clef `Fois` doit être en 2ème position.")) )
       (let (!nb_repetitions (car !arg_lst)
             !nb_repetitions_evaled (eval !nb_repetitions)
             !corps (conc (cddr !arg_lst)
                          '((if (=0 (dec 'credit_iterations))
                                (!erreur 114 credit_iterations_message))))
            )
            (ifn (!inited !nb_repetitions !nb_repetitions_evaled)
                 (quit (pack !cmd_pref "`" !nb_repetitions "` "
                             "n’a pas été déclarée.")))
            (let (!lnr "le nombre de répétitions ")
                 (ifn (num? !nb_repetitions_evaled)
                      (quit (pack !cmd_pref !lnr
                                  "doit être de type \"nombre\".")
                            !nb_repetitions_evaled))
                 (if (<> !nb_repetitions_evaled
                         (format (round !nb_repetitions_evaled 0) 0 "." ","))
                     (quit (pack !cmd_pref !lnr
                                 "doit être un nombre entier.")
                           !nb_repetitions_evaled))
                 (if (le0 (+ !nb_repetitions_evaled 1))
                     (quit (pack !cmd_pref !lnr
                                 "doit être strictement positif.")
                           !nb_repetitions_evaled))
            )
            (if (le0 (- (length !arg_lst) 2))
                (quit (pack !cmd_pref "il n’y a pas d’instruction à répéter.")) )
            (do !nb_repetitions_evaled (run !corps))
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
  (let
    (arg_lst (rest)
     signature (car arg_lst))
    (ifn (lst? signature)
         (quit (pack "Le premier argument de `Definir` doit être de la forme "
                     "`(commande arg1 arg2 ...)`.")))
    (ifn signature
         (quit "`Definir` a au moins deux paramètres."))
    (let
       (nom       (car signature)
        params    (cdr signature)
        sig_as_txt (pack "(" (apply 'glue (cons " " (list signature))) ")")
        corps     (cdr arg_lst))
       # Le nom doit être un symbole et non un texte.
       (let (msg1 "`Definir` : le nom de commande `"
             msg2 "` ne convient pas.")
            (if (or (not (sym? nom)) (str? nom))
                                 (quit (pack msg1 nom msg2))))
       # Les params doivent être des symboles non textes.
       (let (msg1 "`Definir` : le paramètre `"
             msg2 "` ne convient pas.")
            (mapcar '((!sym) (if (or (not (sym? !sym)) (str? !sym))
                                 (quit (pack msg1 !sym msg2))))
                    params))
       # Le nom de la commande ne doit pas être un symbole...
       (let (msg1 "`Definir` : le nom de commande `"
             msg2 "` est le nom d’un symbole prédéfini de MicroAlg."
             msg3 "` est déjà utilisé dans votre programme.")
            # ...prédéfini de MicroAlg
            (if (index nom symboles)
                (quit (pack msg1 nom msg2)))
            # ...utilisé dans le programme
            (if (eval nom)
                (quit (pack msg1 nom msg3))))
       (ifn corps
         (quit (pack "`Definir` : le corps de `" sig_as_txt "` est vide.")))
       # Empêcher la collision entre paramètres et variables déjà déclarées.
       (let (msg1 "`Definir` : le paramètre `"
             msg2 "` est un symbole prédéfini ou a déjà été déclaré comme variable.")
            (mapcar '((!sym) (if (!inited_sans_sans_declaration !sym (eval !sym))
                                 (quit (pack msg1 !sym msg2))))
                    params))
    (let (
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
    )
    )
  )
  Rien
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
    (Exemples_de Cmd_2 (Exemples_de Cmd_1))

Pour lancer les tests, utiliser la commande `Tester`.
")
(put 'Exemples_de 'text "Commande `Exemples_de`.")
(de Exemples_de arg_lst
  (let (commande (car arg_lst)
        exemples (eval (cadr arg_lst))
        troize (caddr arg_lst))
       (if troize (quit "`Exemples_de` n’a pas de troisième paramètre."))
       (ifn exemples
            (get commande 'exemples)
            (ifn (!liste? exemples)
                 (quit "Les exemples fournis ne forment pas une liste."))
            (put commande 'exemples exemples)
       )
  )
  Rien
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
(de !tester_paire (!paire)
  (let (!args (cdr (car !paire))
        !got (apply (eval !commande) !args)
        !expected (cadr !paire))
       (if (not (!egaux !got !expected))
           (Afficher (pack "Erreur: (" !commande " "
                           (glue " " (mapcar '!text !args)) ")"
                           " retourne " (!text_n_quote !got)
                           " au lieu de " (!text_n_quote !expected) ".")))
  )
)
(de Tester arg_lst
  (let (!commande (car arg_lst)
        !deuze (cadr arg_lst)
        !exemples (get !commande 'exemples))
       (ifn !commande (quit "Vous n’avez rien donné à `Tester`."))
       (if !deuze (quit "`Tester` n’a qu’un paramètre."))
       (cond
         ((not (eval !commande))
            (Afficher (pack "Il faut définir la commande `" !commande "` "
                            "avant de la tester.")))
         ((not !exemples)
            (Afficher (pack "La commande `" !commande "` "
                            "n’a pas d’exemples.")))
         ((not (!liste? !exemples))
            (Afficher (pack "La commande `" !commande "` "
                            "n’a pas d’exemples valables.")))
         (T (mapcar !tester_paire (!paires (elts> !exemples))))
       )
  )
  Rien
)

# Prédicats
(de !texte? (!obj)  # helper évaluant son arg
  (cond
   ((not !obj) Vrai)                       # Possiblement "" en direct.
   ((num? !obj) Faux)                      # Un nombre en direct.
   ((!liste? !obj) Faux)                   # Liste.
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
# Factorisation du test du nombre des arguments des comparaisons
(de !check_2_args (!arg_lst)
  # On passe aussi le nom de la commande, d’où la soustraction
  (let (!nb_args (- (length !arg_lst) 1)
        !cmd (car !arg_lst)
        !adamv " attend deux arguments mais vous ")
       (cond
         ((=0 !nb_args)
            (quit (pack "`" !cmd "`" !adamv "n’en donnez aucun.")) )
         ((not (<> 1 !nb_args))
            (quit (pack "`" !cmd "`" !adamv "n’en donnez qu’un seul.")) )
         ((ge0 (- !nb_args 3))
            (quit (pack "`" !cmd "`" !adamv "en donnez au moins trois.")) )
       )
  )
)
# Factorisation du test de la déclaration des variables
(de !check_inited_args (!cmd !x_sym !x_evaled !y_sym !y_evaled)
  (let (!euvqnped "` est une variable qui n’a pas été déclarée.")
       (ifn (!inited !x_sym !x_evaled)
            (quit (pack "`" !cmd "` : le premier argument `" !x_sym !euvqnped)) )
       (ifn (!inited !y_sym !y_evaled)
            (quit (pack "`" !cmd "` : le second argument `" !y_sym !euvqnped)) )
  )
)
# Factorisation du test du type des arguments des comparaisons
(de !check_args_numeriques (!cmd !primz !deuz)
  # On passe aussi le nom de la commande, d’où la soustraction
  (let (!adnml " attend des nombres mais le "
        !ade   " argument donné est `")
       (if (not (num? !primz))
           (quit (pack "`" !cmd "`" !adnml "premier" !ade
                       (!text_n_quote !primz) "`.")) )
       (if (not (num? !deuz))
           (quit (pack "`" !cmd "`" !adnml "second" !ade
                      (!text_n_quote !deuz) "`.")) )
  )
)
(de !egaux (!x !y)
   (ifn (<> !x !y)
        (if (or (== !x Vrai) (== !x Faux) (== !x Rien)
                (== !y Vrai) (== !y Faux) (== !y Rien))
            (if (== !x !y) T NIL)
            # test == pour les vals ci-dessus
            # pour les autres, c’est not <> :
            T
        )
        # ici, ils sont <>
        NIL
   )
)
(put '= 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont égales,
et `Faux` sinon.

    : (= 42 42)
    -> Vrai
")
(put '= 'text "Prédicat `=`.")
(de = !arg_lst
  (!check_2_args (cons "=" !arg_lst))
  (let (!x_sym    (car  !arg_lst)
        !x_evaled (eval !x_sym)
        !y_sym    (cadr !arg_lst)
        !y_evaled (eval !y_sym))
       (!check_inited_args "=" !x_sym !x_evaled !y_sym !y_evaled)
       (!boolP2M (!egaux !x_evaled !y_evaled))
  )
)
(put '=/ 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
différentes, et `Faux` sinon.

    : (=/ 42 42)
    -> Faux
")
(put '=/ 'text "Prédicat `=/`.")
(de =/ !arg_lst
  (!check_2_args (cons "=/" !arg_lst))
  (let (!x_sym    (car  !arg_lst)
        !x_evaled (eval !x_sym)
        !y_sym    (cadr !arg_lst)
        !y_evaled (eval !y_sym))
       (!check_inited_args "=/" !x_sym !x_evaled !y_sym !y_evaled)
       (!boolP2M (not (!egaux !x_evaled !y_evaled)))
  )
)
(put '< 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre croissant (strictement), et `Faux` sinon.

    : (< 42 42)
    -> Faux
    : (< 42 43)
    -> Vrai
")
(put '< 'text "Prédicat `<`.")
(de < !arg_lst
  (!check_2_args (cons "<" !arg_lst))
  (let (!x_sym    (car  !arg_lst)
        !x_evaled (eval !x_sym)
        !y_sym    (cadr !arg_lst)
        !y_evaled (eval !y_sym))
       (!check_inited_args "<" !x_sym !x_evaled !y_sym !y_evaled)
       (!check_args_numeriques "<" !x_evaled !y_evaled)
       (ifn (ge0 (- !x_evaled !y_evaled)) Vrai Faux)
  )
)
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
(de <= !arg_lst
  (!check_2_args (cons "<=" !arg_lst))
  (let (!x_sym    (car  !arg_lst)
        !x_evaled (eval !x_sym)
        !y_sym    (cadr !arg_lst)
        !y_evaled (eval !y_sym))
       (!check_inited_args "<=" !x_sym !x_evaled !y_sym !y_evaled)
       (!check_args_numeriques "<=" !x_evaled !y_evaled)
       (if (le0 (- !x_evaled !y_evaled)) Vrai Faux)
  )
)
(put '> 'doc
"Prédicat retournant `Vrai` si les valeurs de ses deux arguments sont
dans l’ordre décroissant (strictement), et `Faux` sinon.

    : (> 42 42)
    -> Faux
    : (> 43 42)
    -> Vrai
")
(put '> 'text "Prédicat `>`.")
(de > !arg_lst
  (!check_2_args (cons ">" !arg_lst))
  (let (!x_sym    (car  !arg_lst)
        !x_evaled (eval !x_sym)
        !y_sym    (cadr !arg_lst)
        !y_evaled (eval !y_sym))
       (!check_inited_args ">" !x_sym !x_evaled !y_sym !y_evaled)
       (!check_args_numeriques ">" !x_evaled !y_evaled)
       (ifn (le0 (- !x_evaled !y_evaled)) Vrai Faux)
  )
)
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
(de >= !arg_lst
  (!check_2_args (cons ">=" !arg_lst))
  (let (!x_sym    (car  !arg_lst)
        !x_evaled (eval !x_sym)
        !y_sym    (cadr !arg_lst)
        !y_evaled (eval !y_sym))
       (!check_inited_args ">=" !x_sym !x_evaled !y_sym !y_evaled)
       (!check_args_numeriques ">=" !x_evaled !y_evaled)
       (if (ge0 (- !x_evaled !y_evaled)) Vrai Faux)
  )
)
(put 'Vide? 'doc
"Prédicat retournant `Vrai` si l’argument est considéré comme vide.

* **Textes** : le seul texte vide est `\"\"`.
* **Listes** : la seule liste vide est `(Liste)`.
* Les valeurs des autres types se sont jamais vide.

Utilisation :

    (Vide? ...)

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
(put '... 'doc "Commande permettant de présenter les exercices à trous.

Exemple :

    : (...)
    Erreur: Les trois points et/ou les parenthèses `(...)` doivent être
    remplacés pour que le programme fonctionne.
    ")
(de ... ()
  (quit (pack "Les trois points et/ou les parenthèses `(...)` doivent être "
              "remplacés pour que le programme fonctionne.")) )

# Mesure du temps d’exécution
(put 'Millisecondes 'doc
"Retourne le nombre de millisecondes écoulées depuis le début du programme.

Utilisation :

    (Millisecondes)

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
(de grad_list (!min !max !scl)
  (let (!mod_min (% !min !scl)
        !mod_max (% !max !scl)
        !petit (if (gt0 !mod_min)
                   (+ (- !min !mod_min) !scl)
                   (- !min !mod_min))
        !grand (if (lt0 !mod_max)
                   (- (- !max !mod_max) !scl)
                   (- !max !mod_max))
        !nb_grad (+ (/ (- !grand !petit) !scl) 1))
       (mapcar '((x) (+ !petit (* x !scl))) (range 0 (- !nb_grad 1)))
  )
)
(put 'Repere 'doc
"Dans la sortie graphique, permet de choisir un nouveau repère.

Utilisations :

    (Repere x_min x_max y_min y_max)

ou

    (Repere x_min x_max y_min y_max x_grad y_grad)

Cette commande peut s’utiliser avec 4 ou 6 paramètres.

* Les quatre premiers paramètres sont parfois appelés Xmin, Xmax, Ymin et Ymax.
  Ils valent par défaut 0, 600, 0 et 600.  
* Le cinquième et le sixième sont facultatifs et représentent l’écart entre,
  respectivement, les graduations sur l’axe des abscisses et les graduations
  sur l’axe des ordonnées.  
  S’ils sont fournis, les axes et les graduations sont dessinés.

**Exemples** :

`(Repere -1 3 -2 2)`  
Avec ces valeurs, le carré graphique 600×600 permettra de visualiser les points
d’abscisses comprises entre -1 et 3 et d’ordonnées comprises entre -2 et 2.

`(Repere -10 10 -2 2 1 0.5)`  
Avec ces valeurs, le carré graphique 600×600 permettra de visualiser les points
d’abscisses comprises entre -10 et 10 et d’ordonnées comprises entre -1 et 1.  
De plus, des axes gradués seront dessinés, toutes les unités sur l’axe des
abscisses, et toutes les demies unités sur l’axe des ordonnées.  
Attention, les proportions ne seront pas respectées.

`(Repere -10 10 -2 2 11 3)`  
Idem, mais les axes seront dessinés sans graduations.

**Attention** :  
La commande `Epaisseur` et les commandes de la tortue ne sont pas
  affectées par le changement de repère.

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Repere 'text "Commande `Repere`.")
(de Repere !arg_lst
  (let (!nb_args (length !arg_lst)
        !err_prefix "`Repere` prend 4 ou 6 paramètres. Vous en donnez ")
    (cond
      ((gt0 (- !nb_args 6))
            (quit (pack !err_prefix "plus que 6.")))
      ((lt0 (- !nb_args 4))
            (quit (pack !err_prefix "moins que 4.")))
      ((not (<> !nb_args 5))
            (quit (pack !err_prefix "5.")))
      (T (let (xmin (eval (car !arg_lst))
               xmax (eval (cadr !arg_lst))
               ymin (eval (caddr !arg_lst))
               ymax (eval (cadddr !arg_lst))
               xscl (eval (car (cddddr !arg_lst)))
               yscl (eval (cadr (cddddr !arg_lst))))
              (if (not (apply 'and (mapcar 'num? (list xmin xmax ymin ymax))))
                  (quit "Tous les arguments de `Repere` doivent être des nombres.") )
              (if (not (<> xmin xmax))
                  (quit "x_min et x_max doivent être différents.") )
              (if (not (<> ymin ymax))
                  (quit "y_min et y_max doivent être différents.") )
              (!processing (pack "Repere " xmin " " xmax " " ymin " " ymax))
              (if (not (<> 6 !nb_args))
                  (prog
                    (if (not (apply 'and (mapcar 'num? (list xscl yscl))))
                        (quit "Tous les arguments de `Repere` doivent être des nombres.") )
                    (if (lt0 (* ymin ymax))
                        (Segment (Liste xmin 0) (Liste xmax 0)) )
                    (if (lt0 (* xmin xmax))
                        (Segment (Liste 0 ymin) (Liste 0 ymax)) )
                    (let (!x_grad '((x e) (Segment (Liste x (- e))
                                                   (Liste x e)))
                          !y_grad '((y e) (Segment (Liste (- e) y)
                                                   (Liste e y)))
                          !x_grads (grad_list xmin xmax xscl)
                          !y_grads (grad_list ymin ymax yscl)
                          !x_e (/ (* 2 (- ymax ymin)) 600)
                          !y_e (/ (* 2 (- xmax xmin)) 600)
                         )
                         (mapcar '!x_grad !x_grads (need (length !x_grads) !x_e))
                         (mapcar '!y_grad !y_grads (need (length !y_grads) !y_e))
                    )
                  )
              )))
    )
  )
  Rien
)
(de !check_couleur (!liste !cmd)
  (if (<> (!type_sym !liste) "liste")
      (quit (pack "`" !cmd "` : l’argument doit être une liste.")) )
  (let (!len_couleur (!longueur !liste))
       (if (and (<> !len_couleur 3) (<> !len_couleur 4))
           (quit (pack "`" !cmd "` : l’argument "
                       "doit être une liste de longueur 3 ou 4.")) )
  )
  (mapcar '((x) (ifn (num? x)
                     (quit (pack "`" !cmd "` : les valeurs de la liste "
                                 "doivent tous être des nombres.")) ))
          (elts> !liste) )
)
(put 'Contour 'doc
"Dans la sortie graphique, permet de choisir la couleur du contour des tracés.

Exemple : `(Contour (Liste 255 0 0))` ou `(Contour (Liste 255 0 0 127))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>
et <http://microalg.info/doc.html#couleurs>.")
(put 'Contour 'text "Commande `Contour`.")
(de Contour (couleur)
  (!check_couleur couleur "Contour")
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
  (!check_couleur couleur "Remplissage")
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
  (ifn (num? epaisseur)
       (quit "`Epaisseur` : l’argument doit être un nombre.") )
  (!processing (pack "Epaisseur " epaisseur))
  Rien
)
(de !check_coords (!liste !cmd !arg_num)
  (if (<> (!type_sym !liste) "liste")
      (quit (pack "`" !cmd "` : l’argument n°" !arg_num
                  " doit être une liste.")) )
  (if (<> 2 (!longueur !liste))
      (quit (pack "`" !cmd "` : l’argument n°" !arg_num
                  " doit être une liste de longueur 2.")) )
  (let (!lpvdla " valeur de l’argument n°"
        !deun " doit être un nombre.")
       (ifn (num? (nth> !liste 1))
            (quit (pack "`" !cmd "` : la première" !lpvdla !arg_num !deun)) )
       (ifn (num? (nth> !liste 2))
            (quit (pack "`" !cmd "` : la seconde" !lpvdla !arg_num !deun)) )
  )
)
(put 'Segment 'doc
"Dans la sortie graphique, trace un segment.

Les deux paramètres sont les listes des coordonnées des deux extrémités
du segment.

Exemple : `(Segment (Liste 300 300) (Liste 450 600))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Segment 'text "Commande `Segment`.")
(de Segment (point1 point2 !troize)
  (ifn point1
       (quit "`Segment` : il manque les deux extrémités.") )
  (!check_coords point1 "Segment" 1)
  (ifn point2
       (quit "`Segment` : il manque la seconde extrémité.") )
  (!check_coords point2 "Segment" 2)
  (if !troize
      (quit "`Segment` : vous donnez un argument de trop.") )
  (!processing (pack "Segment " (nth> point1 1) " " (nth> point1 2) " "
                                (nth> point2 1) " " (nth> point2 2)))
  Rien
)
(put 'Cercle 'doc
"Dans la sortie graphique, trace un cercle.

Le premier paramètre est la liste des coordonnées du centre du cercle,  
le second paramètre est le rayon du cercle.

Exemple : `(Cercle (Liste 300 300) 100)`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Cercle 'text "Commande `Cercle`.")
(de Cercle (centre rayon !troize)
  (ifn centre
       (quit "`Cercle` : il manque le centre et le rayon.") )
  (!check_coords centre "Cercle" 1)
  (ifn rayon
       (quit "`Cercle` : il manque le rayon.") )
  (ifn (num? rayon)
       (quit "`Cercle` : le rayon doit être un nombre.") )
  (if !troize
      (quit "`Cercle` : vous donnez un argument de trop.") )
  (!processing (pack "Cercle " (nth> centre 1) " " (nth> centre 2)
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
(de Ellipse (centre rayon1 rayon2 !quatrz)
  (ifn centre
       (quit "`Ellipse` : il manque le centre et les rayons.") )
  (!check_coords centre "Ellipse" 1)
  (ifn rayon1
       (quit "`Ellipse` : il manque les rayons.") )
  (ifn (num? rayon1)
       (quit "`Ellipse` : le premier rayon doit être un nombre.") )
  (ifn rayon2
       (quit "`Ellipse` : il manque le second rayon.") )
  (ifn (num? rayon2)
       (quit "`Ellipse` : le second rayon doit être un nombre.") )
  (if !quatrz
      (quit "`Ellipse` : vous donnez un argument de trop.") )
  (!check_coords centre "Ellipse" 1)
  (!processing (pack "Ellipse " (nth> centre 1) " " (nth> centre 2)
                     " " (* 2 rayon1) " " (* 2 rayon2)))
  Rien
)
(put 'Rectangle 'doc
"Dans la sortie graphique, trace un rectangle.

Les deux paramètres sont les listes des coordonnées des deux coins du rectangle.

Exemple : `(Rectangle (Liste 300 300) (Liste 450 600))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Rectangle 'text "Commande `Rectangle`.")
(de Rectangle (point1 point2 !troize)
  (ifn point1
       (quit "`Rectangle` : il manque les deux coins.") )
  (!check_coords point1 "Rectangle" 1)
  (ifn point2
       (quit "`Rectangle` : il manque le second coin.") )
  (!check_coords point2 "Rectangle" 2)
  (if !troize
      (quit "`Rectangle` : vous donnez un argument de trop.") )
  (!processing (pack "Rectangle " (nth> point1 1) " " (nth> point1 2) " "
                                  (nth> point2 1) " " (nth> point2 2)))
  Rien
)
(put 'Triangle 'doc
"Dans la sortie graphique, trace un triangle.

Les trois paramètres sont les listes des coordonnées des sommets du triangle.

Exemple : `(Triangle (Liste 200 300) (Liste 400 300) (Liste 300 400))`

Voir <http://microalg.info/doc.html#utilisationdescommandesgraphiques>.")
(put 'Triangle 'text "Commande `Triangle`.")
(de Triangle (point1 point2 point3 !quatrz)
  (ifn point1
       (quit "`Triangle` : il manque les trois sommets.") )
  (!check_coords point1 "Triangle" 1)
  (ifn point2
       (quit "`Triangle` : il manque les deux derniers sommet.") )
  (!check_coords point2 "Triangle" 2)
  (ifn point3
       (quit "`Triangle` : il manque le troisième sommet.") )
  (!check_coords point3 "Triangle" 3)
  (if !quatrz
      (quit "`Triangle` : vous donnez un argument de trop.") )
  (!processing (pack "Triangle " (nth> point1 1) " " (nth> point1 2) " "
                                 (nth> point2 1) " " (nth> point2 2) " "
                                 (nth> point3 1) " " (nth> point3 2)))
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
