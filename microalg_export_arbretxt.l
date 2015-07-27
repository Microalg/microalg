(de arbretxt malg_src
  (pack (mapcar 'arbretxt_rec malg_src))
)

(de arbretxt_rec (malg_src !indent_level !node_str)
  (ifn !indent_level (setq !indent_level 0))
  (pack
    (if (gt0 !indent_level) (pack (need (dec !indent_level) "│ ") !node_str))
    (cond
      ((atom malg_src) (pack (if (str? malg_src) (pack "\"" malg_src "\"") malg_src) "^J"))
      (T (let (cmd (car malg_src)
               rev_args (reverse (cdr malg_src))
               args_but_last (reverse (cdr rev_args))
               last_arg (car rev_args)
               length_but_last (length args_but_last))
              (pack cmd "^J"
                    (if rev_args (pack
                      (mapcar 'arbretxt_rec args_but_last (need length_but_last (inc !indent_level)) (need length_but_last "├─"))
                      (arbretxt_rec last_arg (inc !indent_level) "└─")))
              )
         )
      )
    )
  )
)