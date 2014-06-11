(put 'version 'text "MicroAlg version 0.1.0")
(setq version "0.1.0")
(setq apropos
"L’idée de MicroAlg est née lors d’une formation ISN, de la frustration due à
l’abscence d’un langage vraiment axé sur la pédagogie.  
À l’origine pensé comme DSL au sein de Tcl, il est finalement embarqué dans
PicoLisp.  
Voir <http://microalg.info>.")
(put 'apropos 'doc "Symbole contenant des informations sur MicroAlg.")

(setq commandes '("Aide" "Affecter_a" "Afficher" "Concaténer" "Demander"
                  "Vrai?" "Faux?"
                 )
)

# picolisp.l shimz
(de glue (c l)
  (cond
    ((= 0 (length l)) "")
    ((= 1 (length l)) (car l))
    (T                (pack (car l) c  (glue c (cdr l))))
  )
)

# Aide
(put 'Aide 'doc
"Commande qui permet d’obtenir de l’aide.")
(de Aide syms (let (truc (car syms)
                    doc (get truc 'doc))
                   (cond
                    ((== truc NIL) (get 'Aide 'text))
                    ((== truc 'commandes) (glue " " commandes))
                    (doc (pack "Aide pour `" truc "`:  ^J" doc))
                    ((eval truc) (pack "Pas d’aide pour " truc "."))
                    (T (pack "`" truc "’ n’existe pas."))
                   )))
(put 'Aide 'text
"MicroAlg permet de s’initier à l’algorithmique et à la programmation.  
Si vous ne l’avez pas déjà fait, commencez par le
[tutoriel](http://microalg.info/tuto.html).  

* `(Aide commandes)` pour une liste des commandes,
* `(Aide «commande»)` (sans «») pour de l’aide sur une commande particulière,
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
(setq *LastStdOut "?")
(de Afficher args (let (first (car args)
                        text (get first 'text)
                        a_afficher (if text text (eval first)))
                       (setq *LastStdOut (if a_afficher a_afficher "?"))
                       (println a_afficher)
                       NIL  # Pas de valeur de retour
                  )
)
(put 'Afficher 'text "Commande 'Afficher'.")

# Concaténer
(put 'Concaténer 'doc
"Commande qui concatène les textes passés en paramètre.")
(de Concaténer @ (let (
                       result (pack (rest))
                      )
                      (if result
                          result
                          ""
                      )))

# Gestion des variables
(put 'Affecter_a 'doc
"Commande qui permet d’affecter une valeur à une variable.")
(de Affecter_a arg_lst (set (car arg_lst) (eval (cadr arg_lst))))

# Demander.
# Avec EmuLisp, les entrées utilisateur se font au travers de la fonction
# _stdPrompt, surchargée dans ide_injection.js. Dans un navigateur, la dernière
# ligne ayant été affichée précédemment est réutilisée lors de l’appel à
# window.prompt.
(put 'Demander 'doc
"Commande qui permet de demander une valeur à l’utilisateur.")
(de Demander () (in NIL (read " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")))
# Références:
# https://fr.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange#Table_des_128_caract.C3.A8res_ASCII
# https://en.wikipedia.org/wiki/ASCII#ASCII_printable_character_code_chart
# >>> ''.join([chr(i) for i in range(32, 127) if not chr(i).isalnum()])
# ' !"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'

# Conversions
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
                ((str? x) (format x))
                (T NIL)
              ))

# Structure conditionnelle
(put 'Vrai 'doc "Booléen valant Vrai.")
(setq Vrai 'Vrai)
(put 'Vrai 'doc "Booléen valant Faux.")
(setq Faux 'Faux)
(de Si arg_lst (let (condition (car arg_lst)
                     bloc_vrai (cadr arg_lst)
                     bloc_faux (caddr arg_lst))
                    (if (= Vrai (eval condition))
                        (eval bloc_vrai) (eval bloc_faux))))

# Prédicats
(put 'Vrai? 'doc
"Prédicat retournant `Vrai` si son argument est `Vrai`, et `Faux` sinon.")
(de Vrai? (x) (if (= x Vrai) Vrai Faux))
(put 'Faux? 'doc
"Prédicat retournant `Vrai` si son argument est `Faux`, et `Faux` sinon.")
(de Faux? (x) (if (= x Faux) Vrai Faux))
(put 'Texte? 'doc
"Prédicat retournant `Vrai` si son argument est du texte, et `Faux` sinon.")
(de Texte? (x) (if (str? x) Vrai Faux))
(put 'Nombre? 'doc
"Prédicat retournant `Vrai` si son argument est un nombre, et `Faux` sinon.")
(de Nombre? (x) (if (num? x) Vrai Faux))
