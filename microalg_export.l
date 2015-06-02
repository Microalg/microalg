(de proteger_source src (mapcar 'proteger_source_aux src))
(de proteger_source_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) src)
      (T          (cons (car src) (mapcar 'proteger_source_aux (cdr src))))
    )
)