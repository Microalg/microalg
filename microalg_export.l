(de proteger_source src (mapcar 'proteger_source_aux src))
(de proteger_source_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) (if (index src '(Vrai Faux Rien Alors Sinon Tant_que Faire
                                   En_position De_type Fois))
                      src
                      (list 'Variable src)))
      (T          (cons (car src) (mapcar 'proteger_source_aux (cdr src))))
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