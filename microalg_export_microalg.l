(de Litteral (content)
  (cond
    ((num? content) content)
    ((str? content) (pack "\"" content "\""))
    (T "Littéral de type inconnu.")
  ))
(de Variable inputs
  (let (nom_var (car inputs))
    (if nom_var nom_var "")
  )
)
(de indent (!instr)
  (let (!lines_with_final_NIL (mapcar pack (split (chop !instr) "^J"))
        !lines (reverse (cdr (reverse !lines_with_final_NIL))))
       (mapcar (list '(!line)
                     (list 'pack "    " '!line "^J")) !lines)
  )
)

(de + @ (pack "(+ " (glue " " (rest)) ")"))
(de - (A B) (pack "(- " A " " B ")"))
(de * @ (pack "(* " (glue " " (rest)) ")"))
(de / (A B) (pack "(/ " A " " B ")"))
(de % (A B) (pack "(%" A " " B ")"))
(de ^ (A B) (pack "(\^ " A " " B ")"))

(de !!! (comz) (pack "(!!! " comz ")^J"))
(de Afficher (obj) (pack "(Afficher " obj ")^J"))
(de Declarer !arg_lst
  (let (!splitted (split !arg_lst 'De_type)
        !vars (mapcar 'cadr (car !splitted))  # var name is in (Variable ...)
        !type (cadr (caadr !splitted)))  # type is in (Litteral ...)
       (pack "(Declarer "
             (glue " " !vars)
             " De_type \""
             !type "\")^J"
       )
  )
)
(de Concatener @ (pack "(Concatener "(glue " " (rest)) ")"))
(de Affecter_a !arg_lst
  (let (!var (cadr (car !arg_lst))  # var name is in (Variable ...)
        !val (eval (cadr !arg_lst)))
       (pack "(Affecter_a " !var " " !val ")^J")))
(de Entier@ (A B) (pack "(Entier@ " A " " B ")"))
(setq Vrai "Vrai")
(setq Faux "Faux")
(de Si arg_lst (let (condition (car arg_lst)
                     kw_alors  (cadr arg_lst)
                     splitted  (split (cddr arg_lst) 'Sinon)
                     bloc_vrai (car splitted)
                     bloc_faux (cadr splitted))
                    (pack
                      "(Si " (eval condition) "^J"
                      " Alors^J    "
                      (mapcar 'eval bloc_vrai)
                      (if bloc_faux (pack " Sinon^J    "
                      (mapcar 'eval bloc_faux)))
                      ")^J"
                    )
                )
)
(de Non (bool) (pack "(Non " bool ")"))
(de Et @ (pack "(Et " (glue " " (rest)) ")"))
(de Ou @ (pack "(Ou " (glue " " (rest)) ")"))
(de Tant_que arg_lst (let (!cond (car arg_lst)
                           !mot-clef (cadr arg_lst)
                           !corps (cddr arg_lst))
                          (pack
                            "(Tant_que " (eval !cond) ")^J"
                            " Faire^J"
                            (mapcar 'eval !corps)
                            ")^J"
                          )
                     )
)
(de Faire arg_lst (let (!splitted (split arg_lst 'Tant_que)
                        !corps (car !splitted)
                        !cond (caadr !splitted))
                       (pack
                         "(Faire^J"
                         (mapcar 'eval !corps)
                         " Tant_que " (eval !cond) "^J"
                         ")^J"
                       )
                  )
)

(de =  (A B) (pack "(= "  A " " B ")"))
(de <  (A B) (pack "(< "  A " " B ")"))
(de <= (A B) (pack "(<= " A " " B ")"))
(de >  (A B) (pack "(> "  A " " B ")"))
(de >= (A B) (pack "(>= " A " " B ")"))
(de =/ (A B) (pack "(=/"  A " " B ")"))

(de Liste @ (pack "(Liste " (glue " " (rest)) ")"))

(de 1000Cosinus (angle) (pack "(1000Cosinus " angle ")"))
(de 1000Sinus   (angle) (pack "(1000Sinus " angle ")"))

(de Longueur (A) (pack "(Longueur " A ")"))
(de Nieme (obj idx) (pack "(Nieme " obj " " idx ")"))
(de Millisecondes () "(Millisecondes)")

(de RAZ () "(RAZ)^J")
(de Cercle inputs
  (let (origine (eval (car inputs))
        r       (eval (cadr inputs)))
       (pack "(Cercle " origine " " r ")^J")
  )
)
(de Contour (coul)
  (pack "(Contour " coul ")^J"))
(de Remplissage (coul)
  (pack "(Remplissage " coul ")^J"))
(de Ellipse inputs
  (let (origine (eval (car inputs))
        r1      (eval (cadr inputs))
        r2      (eval (caddr inputs)))
       (pack "(Ellipse " origine " " r1 " " r2 ")^J")
  )
)
(de Epaisseur (e)
  (pack "(Epaisseur" e ")^J")
)
(de Rectangle (p1 p2)
  (pack "(Rectangle " p1 " " p2 ")^J")
)
(de Segment (p1 p2)
  (pack "(Segment " p1 " " p2 ")^J")
)
(de Triangle (p1 p2 p3)
  (pack "(Triangle " p1 " " p2 " " p3 ")^J")
)
(de Repere (xmin xmax ymin ymax xscl yscl)
  (pack "(Repere " xmin " " xmax " " ymin " " ymax
        (if xscl (pack " " xscl " " yscl))
        ")^J"
  )
)

(de Tete (obj) (pack "(Tete " obj ")"))
(de Queue (obj) (pack "(Queue " obj ")"))
(de Ajouter_a (obj val) (pack "(Ajouter_a " obj " " val ")"))
(de Retirer_de (obj) (pack "(Retirer_de " obj ")"))
# En_position
(de Nieme@ (obj) (pack "(Nieme@ " obj ")"))
(de Texte (obj) (pack "(Texte " obj ")"))
(de Nombre (obj) (pack "(Nombre " obj ")"))
# Alors Sinon
(de Repeter !inputs
  (let (nb (eval (car !inputs))
        prg (cddr !inputs))
       (pack "(Repeter " nb " Fois^J"
             (mapcar 'eval prg)
             ")^J"
       )
  )
)
(de ... () "(...)")
(de Demander () (pack "(Demander)"))
(de Demander_un_nombre () (pack "(Demander_un_nombre)"))
(de Initialiser@ () (pack "(Initialiser@)^J"))
(de Type (obj) (pack "(Type " obj ")"))
(de AV (n) (pack "(AV " n ")^J"))
(de BC () (pack "(BC)^J"))
(de LC () (pack "(LC)^J"))
(de TD (a) (pack "(TD" (if a (pack " " @)) ")^J"))
(de TG (a) (pack "(TG" (if a (pack " " @)) ")^J"))

(de !no_export (cmd)
  (pack "-- La commande " cmd " ne peut être exportée. --^J"))

(de Definir () (!no_export "Definir"))
(de Retourner () (!no_export "Retourner"))
(de Exemples_de () (!no_export "Exemples_de"))
(de Tester () (!no_export "Tester"))
(de ? () (!no_export "?"))
# Rien
