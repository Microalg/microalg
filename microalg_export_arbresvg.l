(de arbresvg malg_src
  (push 'malg_src 'Programme)
  (arbresvg_rec  malg_src)
)

(de arbresvg_rec (malg_src !indent_level !node_str)
  (cond
    ((atom malg_src) (pack "{\"label\":\""
                           (ifn (str? malg_src) malg_src
                                (pack "« " malg_src " »") )
                           "\"}"))
    (T (let (cmd  (car malg_src)
             args (cdr malg_src))
            (pack "{\"label\":\""
                  cmd
                  "\", \"children\": ["
                  (glue ", " (mapcar 'arbresvg_rec args))
                  "]}"
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