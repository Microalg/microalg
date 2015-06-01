(de proteger_source src (proteger_source_aux src))
(de proteger_source_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) src)
      (T          (mapcar 'proteger_source_aux src))
    )
)