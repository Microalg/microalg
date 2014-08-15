(de proteger_litteraux (src)
   (cond
      ((num? src) (list 'Litteral src))
      ((str? src) (list 'Litteral src))
      ((sym? src) src)
      (T          (mapcar 'proteger_litteraux src))
    )
)