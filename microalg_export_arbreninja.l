(setq *id 0)
(de arbreninja malg_src
  (pack "<ol class=\"tree\"><li>"
        (mapcar 'arbreninja_rec malg_src)
        "</li></ol>"
  )
)

(de arbreninja_rec (malg_src)
  (cond
    ((atom malg_src) (pack "<li class=\"file\">"
                           (ifn (str? malg_src) malg_src
                                (pack "« " malg_src " »") )
                           "</li>"))
    (T (let (cmd  (car malg_src)
             args (cdr malg_src))
            (inc '*id)
            (pack "<label for=\"" cmd "-" *id "\">" cmd "</label>"
                  "<input type=\"checkbox\" id=\"" cmd "-" *id "\" checked />"
                  (if args
                      (pack "<ol>" (mapcar 'arbreninja_rec args) "</ol>"))
            )
       )
    )
  )
)