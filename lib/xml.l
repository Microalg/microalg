# https://www.mail-archive.com/picolisp@software-lab.de/msg00510.html
# https://www.mail-archive.com/picolisp@software-lab.de/msg04592.html

(de <xmlq> Lst
   (<xml> Lst) )

(de <xml> (Lst)
   (let Tag (pop 'Lst)
      (prin "<" Tag)
      (while (and Lst (atom (car Lst)))
         (prin " " (pop 'Lst) "=\"")
         (escXml (eval (pop 'Lst) 1))
         (prin "\"") )
      (ifn Lst
         (prin "/>")
         (prin ">")
         (run Lst 1)
         (prin "</" Tag ">") ) ) )
(de escXml (X)
   (for C (chop X)
      (case C
         ("\"" (prin "&quot;"))
         ("&" (prin "&amp;"))
         ("<" (prin "&lt;"))
         (">" (prin "&gt;"))
         (T (prin C)) ) ) )
