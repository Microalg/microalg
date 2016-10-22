(setq !cmdes_sans_retour
  '(!!! AV BC LC TD TG Affecter_a Afficher Ajouter_a Cercle Contour
    Declarer Definir Ellipse Epaisseur Exemples_de
    Faire Initialiser@ RAZ Rectangle Remplissage Repere Repeter Retirer_de
    Retourner Segment Si Tant_que Tester Triangle) )

(de proteger_source src (mapcar 'proteger_source_aux src (need (length src) T)))
(de proteger_source_aux (src premier_niveau)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) (if (index src '(Vrai Faux Rien Alors Sinon Tant_que Faire
                                   En_position De_type Fois))
                      src
                      (list 'Variable src)))
      (T          (if (and (not premier_niveau)
                           (index (car src) !cmdes_sans_retour))
                      (list 'indent
                            (cons (car src)
                                  (mapcar 'proteger_source_aux (cdr src))))
                      (cons (car src) (mapcar 'proteger_source_aux (cdr src)))
                  )
      )
    )
)

(de proteger_source_sans_indentation src (mapcar 'proteger_source_sans_indentation_aux src))
(de proteger_source_sans_indentation_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) (if (index src '(Vrai Faux Rien Alors Sinon Tant_que Faire
                                   En_position De_type Fois))
                      src
                      (list 'Variable src)))
      (T          (cons (car src) (mapcar 'proteger_source_sans_indentation_aux (cdr src))))
    )
)

# Default implementation, should be reimplemented for every textual language:
(de indent (!instr) !instr)
# Standard implementation, if needed:
(de indent_std (!instr)
  (let (!lines_with_final_NIL (mapcar pack (split (chop !instr) "^J"))
        !lines (reverse (cdr (reverse !lines_with_final_NIL))))
       (mapcar (list '(!line)
                     (list 'pack "  " '!line "^J")) !lines)
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

(ifn caadr
  (de caadr (arg)
     (car (car (cdr arg)))
  )
)

(setq Somme     '+)
(setq Diff      '-)
(setq Produit   '*)
(setq Quotient  '/)
(setq Reste     '%)
(setq Puissance '^)