# Adapted from http://rosettacode.org/wiki/JSON#PicoLisp
(setq *JSON "")  # Reset the global before a new construction.
(de append_to_json (fragment quoted)
   (setq *JSON (pack *JSON (if quoted "\"") fragment (if quoted "\""))) )
(de escape_double_quotes (x)
   (if (str? x)
      (pack (mapcar '((c) (if (= "\"" c) (pack "\\" c) c)) (chop x)))
      x) )
(de picolisp_to_json (Item)
   (cond
      ((atom Item) (if Item (append_to_json @ T) (append_to_json "{}")))
      ((=T (car Item))
         (append_to_json "[")
         (map
            '((X)
               (picolisp_to_json (car X))
               (and (cdr X) (append_to_json ", ")) )
            (cdr Item) )
         (append_to_json "]") )
      (T
         (append_to_json "{")
         (map
            '((X)
               (append_to_json (caar X) T)
               (append_to_json ": ")
               (picolisp_to_json (escape_double_quotes (cdar X)))
               (and (cdr X) (append_to_json ", ")) )
            Item )
         (append_to_json "}") ) ) )
