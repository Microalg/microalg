(put 'version 'text "MicroAlg version 0.1.0")
(setq version "0.1.0")
(setq apropos (pack
"L’idée de MicroAlg est née lors d’une formation ISN, de la frustration due à "
"l’abscence d’un langage vraiment axé sur la pédagogie.<br />"
"À l’origine pensé comme DSL au sein de Tcl, il est finalement embarqué dans "
"PicoLisp.<br />"
"Voir <a href=\"http://microalg.info\">microalg.info</a>."))
(put 'apropos 'doc "Symbole contenant des informations sur MicroAlg.")

# Aide
(put 'Aide 'doc (pack
"Commande qui permet d’obtenir de l’aide."))
(de Aide syms (let truc (car syms)
              (let doc (get truc 'doc)
                  (cond
                    ((== truc NIL) (get 'Aide 'text))
                    (doc (pack "Aide pour `" truc "’:<br />" doc))
                    ((eval truc) (pack "Pas d’aide pour " truc "."))
                    (T (pack "`" truc "’ n’existe pas."))
                  ))))
(put 'Aide 'text (pack
"MicroAlg permet de s’initier à l’algorithmique et à la programmation.<br />"
"Pour valider une commande, taper <code>Ctrl</code>+<code>Entrée</code>.<br />"
"<ul>"
"<li><code>(Aide commande)</code> pour de l’aide sur une commande,</li>"
"<li><code>version</code> ou <code>apropos</code> pour des informations sur"
"    MicroAlg.</li>"
"<ul>"))

# L’affichage se fait au travers de la variable globale *StdOut.
(put 'Affecter_a 'doc (pack
"Commande qui permet d’afficher l’argument qu’on lui passe."))
(setq *StdOut "")
(de Afficher (obj) (setq *StdOut (pack *StdOut obj)))

# Gestion des variables
(put 'Affecter_a 'doc (pack
"Commande qui permet d’affecter une valeur à une variable."))
(de Affecter_a arg_lst (set (car arg_lst) (cadr arg_lst)))

# Structure conditionnelle
(put 'Vrai 'doc (pack "Booléen valant Vrai."))
(setq Vrai 'Vrai)
(put 'Vrai 'doc (pack "Booléen valant Faux."))
(setq Faux 'Faux)
(de Si arg_lst (let (condition (car arg_lst)
                     bloc_vrai (cadr arg_lst)
                     bloc_faux (caddr arg_lst))
                    (if (= Vrai (eval condition))
                        (eval bloc_vrai) (eval bloc_faux))))

# Prédicats
(de Vrai? (x) (if (= x Vrai) Vrai Faux))
(de Faux? (x) (if (= x Faux) Vrai Faux))
