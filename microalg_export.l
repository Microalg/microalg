(de proteger_source src (mapcar 'proteger_source_aux src))
(de proteger_source_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) (if (index src '(Vrai Faux Rien Alors Sinon Tant_que Faire En_position))
                      src
                      (list 'Variable src)))
      (T          (cons (car src) (mapcar 'proteger_source_aux (cdr src))))
    )
)