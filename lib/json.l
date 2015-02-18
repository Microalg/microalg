# Adapted from http://rosettacode.org/wiki/JSON#PicoLisp
(setq *JSON "")  # Reset the global before a new construction.
(de append_to_json (fragment)
   (setq *JSON (pack *JSON fragment)) )
(de picolisp_to_json (Item)
   (cond
      ((atom Item) (if Item (append_to_json @) (append_to_json "{}")))
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
               (append_to_json (caar X))
               (append_to_json ": ")
               (picolisp_to_json (cdar X))
               (and (cdr X) (append_to_json ", ")) )
            Item )
         (append_to_json "}") ) ) )
