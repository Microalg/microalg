(de proteger_litteraux src (proteger_litteraux_aux src))
(de proteger_litteraux_aux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) src)
      (T          (mapcar 'proteger_litteraux_aux src))
    )
)