(setq !symboles '(
+ - * / % \^
!!! = =/ < <= > >= ?
1000Cosinus 1000Sinus
AV BC LC TD TG
Affecter_a Afficher Aide Ajouter_a Alors
Cercle Concatener Contour credit_iterations
Declarer Definir Demander Demander_un_nombre
Ellipse En_position Entier@ Epaisseur Et Exemples_de
Faire Faux Fois
Geler
Initialiser@
Liste Longueur
Millisecondes
Nieme Nieme@ Nombre Non
Ou
Queue
RAZ Rectangle Remplissage Repeter Retirer_de Retourner Rien
sequence_tirages@
Segment Si Sinon
Tant_que Tester Tete Texte Triangle Type
valeur_utilisateur Vide? Vrai
))

(de proteger_source src (mapcar 'proteger_source_aux src))
(de proteger_source_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) (if (index src '(Vrai Faux Rien Alors Sinon Tant_que Faire
                                   En_position De_type Fois))
                      src
                      (list 'Variable src)))
      (T (let (!cmd  (car src)
               !args (mapcar 'proteger_source_aux (cdr src))
              )
              (if (index !cmd !symboles)
                  (cons !cmd !args)
                  (cons 'Commande_utilisateur !cmd !args)
              )
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

(ifn caadr
  (de caadr (arg)
     (car (car (cdr arg)))
  )
)