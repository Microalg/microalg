(de Litteral (content)
  (cond
    ((num? content) (pack "<block type=\"nombre_litteral\"><field name=\"NUM\">"
                          content
                          "</field></block>"))
    ((str? content) (pack "<block type=\"texte_litteral\"><field name=\"TEXT\">"
                          content
                          "</field></block>"))
    (T "Littéral de type inconnu.")
  ))
(de insertion_next (src) (car (insertion_next_aux (reverse src))))
(de insertion_next_aux (src)
  (if (<= (length src) 1) src
                          # Déplacement de la tête, enfermée dans un (Next ),
                          # À la fin du deuxième élément.
                          # La queue restant inchangée.
                          (let (tete           (car src)
                                deuxieme_instr (cadr src)
                                reste          (cddr src))
                               (queue 'deuxieme_instr (list 'Next tete))
                               (insertion_next_aux
                                 (cons
                                   deuxieme_instr
                                   reste)
                               )
                          )
  ))
(de Next (content)
  (pack "<next>"
        content
        "</next>"))
(de !!! (content next)
  (pack "<block type=\"commentaire\"><field name=\"COMZ\">"
        content
        "</field>"
        next
        "</block>"))
(de + (A B)
   (pack "<block type=\"operations\"><field name=\"OP\">ADD</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de - (A B)
   (pack "<block type=\"operations\"><field name=\"OP\">MINUS</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de * (A B)
   (pack "<block type=\"operations\"><field name=\"OP\">MULTIPLY</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de / (A B)
   (pack "<block type=\"operations\"><field name=\"OP\">DIVIDE</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de Afficher (content next)
  (pack "<block type=\"afficher\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        next
        "</block>"))
(de Concatener inputs
  (pack "<block type=\"concatener\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (mapcar '((i input) (pack "<value name=\"ADD" i "\">" (eval input) "</value>")) (range 0 (dec (length inputs))) inputs)
        "</block>"))
(de Demander ()
  "<block type=\"demander\"></block>")
(de Nombre (content)
  (pack "<block type=\"nombre\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Nombre? (content)
  (pack "<block type=\"nombre?\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Texte (content)
  (pack "<block type=\"texte\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Texte? (content)
  (pack "<block type=\"texte?\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
