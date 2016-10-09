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
  (indent_std !instr))

(de + @ (pack "(" (glue " + " (rest)) ")"))
(de - (A B) (pack "(" A "-" B ")"))
(de * @ (pack "(" (glue " * " (rest)) ")"))
(de / (A B) (pack "(" A "/" B ")"))
(de % (A B) (pack "(" A "%" B ")"))
(de ^ (A B) (pack "Math.pow(" A ", " B ")"))

(de !!! (comz) (pack "// " (cdr (reverse (cdr (reverse (chop comz))))) "^J"))
(de Afficher (obj) (pack "console.log(" obj ");^J"))
(de Declarer !arg_lst
  (let (!splitted (split !arg_lst 'De_type)
        !vars (mapcar 'cadr (car !splitted))  # var name is in (Variable ...)
        !type (cadr (caadr !splitted)))  # type is in (Litteral ...)
        (pack "var " (glue ", " !vars) ";^J")
  )
)
(de Concatener @ (glue " + " (rest)))
(de Affecter_a !arg_lst
  (let (!var (cadr (car !arg_lst))  # var name is in (Variable ...)
        !val (eval (cadr !arg_lst)))
       (pack !var " = " !val ";^J")))
(de Entier@ (A B) (pack "int(" A " + random(" B "-" A "+1))"))
(setq Vrai "true")
(setq Faux "false")
(de Si arg_lst (let (condition (car arg_lst)
                     kw_alors  (cadr arg_lst)
                     splitted  (split (cddr arg_lst) 'Sinon)
                     bloc_vrai (car splitted)
                     bloc_faux (cadr splitted))
                    (pack
                      "if " (eval condition) "^J" "{^J"
                      (mapcar 'eval bloc_vrai)
                      (if bloc_faux (pack "} else {^J" (mapcar 'eval bloc_faux)))
                      "}^J"
                    )
                )
)
(de Non (bool) (pack "!(" bool ")"))
(de Et !arg_lst (pack "(" (glue " && " (mapcar 'eval !arg_lst)) ")"))
(de Ou !arg_lst (pack "(" (glue " || "  (mapcar 'eval !arg_lst)) ")"))
(de Tant_que arg_lst (let (!cond (car arg_lst)
                           !mot-clef (cadr arg_lst)
                           !corps (cddr arg_lst))
                          (pack
                            "while (" (eval !cond) ") {^J"
                            (mapcar 'eval !corps)
                            "}^J"
                          )
                     )
)
(de Faire arg_lst (let (!splitted (split arg_lst 'Tant_que)
                        !corps (car !splitted)
                        !cond (caadr !splitted))
                       (pack
                         "do {^J"
                         (mapcar 'eval !corps)
                         "} while (" (eval !cond) ");^J"
                       )
                  )
)

(de =  (A B) (pack "(" A " === " B ")"))
(de <  (A B) (pack "(" A " < "  B ")"))
(de <= (A B) (pack "(" A " <= " B ")"))
(de >  (A B) (pack "(" A " > "  B ")"))
(de >= (A B) (pack "(" A " >= " B ")"))
(de =/ (A B) (pack "(" A " != " B ")"))

(de Liste @ (pack "[" (glue ", " (rest)) "]"))

(de 1000Cosinus (angle) (pack "Math.cos(" angle "/180*Math.PI)"))
(de 1000Sinus   (angle) (pack "Math.sin(" angle "/180*Math.PI)"))

(de Longueur (A) (pack A ".length"))
(de Nieme (obj idx) (pack obj "[" idx "]"))
(de Millisecondes () "(new Date().getTime())")

(de Demander () "window.prompt()")
(de Demander_un_nombre () "parseFloat(window.prompt())")
(de Type (A) (pack "typeof(" A ")"))

(de Tete (obj) (pack obj "[0]"))
(de Queue (obj) (pack obj ".slice(1)"))
(de Ajouter_a (obj val) (pack obj ".push(" val ");^J"))
(de Retirer_de (obj val) (pack obj ".pop();^J"))
# En_position
(de Nieme@ (obj idx) (pack obj ".[" idx "]"))
(de Texte (obj) (pack "String(" obj ")"))
(de Nombre (obj) (pack "parseFloat(" obj ")"))
(de ... () " (...) ")

(de !no_export (cmd)
  (pack "-- La commande " cmd " ne peut être exportée. --^J"))

(de Initialiser@ () (!no_export "Initialiser@"))
(de Definir () (!no_export "Definir"))
(de Retourner () (!no_export "Retourner"))
(de Exemples_de () (!no_export "Exemples_de"))
(de Tester () (!no_export "Tester"))
(de ? () (!no_export "?"))
# Rien
# Alors Sinon
(de Repeter () (!no_export "Repeter"))

(de AV () (!no_export "AV"))
(de BC () (!no_export "BC"))
(de LC () (!no_export "LC"))
(de TD () (!no_export "TD"))
(de TG () (!no_export "TG"))
(de Cercle () (!no_export "Cercle"))
(de Contour () (!no_export "Contour"))
(de Ellipse () (!no_export "Ellipse"))
(de Epaisseur () (!no_export "Epaisseur"))
(de RAZ () (!no_export "RAZ"))
(de Rectangle () (!no_export "Rectangle"))
(de Remplissage () (!no_export "Remplissage"))
(de Repere () (!no_export "Repere"))
(de Segment () (!no_export "Segment"))
(de Triangle () (!no_export "Triangle"))
