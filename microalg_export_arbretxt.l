(setq *indent_str "│ ")

(de arbretxt malg_src
  (pack (mapcar 'arbretxt_rec malg_src))
)

(de arbretxt_rec (malg_src !indent_level)
  (ifn !indent_level (setq !indent_level 0))
  (pack
    (need !indent_level *indent_str)
    (cond
      ((atom malg_src) (pack (if (str? malg_src) (pack "\"" malg_src "\"") malg_src) "^J"))
      (T (pack (car malg_src) "^J"
               (mapcar 'arbretxt_rec (cdr malg_src) (need (length malg_src) (inc !indent_level)))))
    )
  )
)