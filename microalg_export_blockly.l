(de Litteral (content)
  (cond
    ((num? content) (pack "<block type=\"nombre\"><field name=\"TEXT\">"
                          content
                          "</field></block>"))
    ((str? content) (pack "<block type=\"texte\"><field name=\"TEXT\">"
                          content
                          "</field></block>"))
    (T "Littéral de type inconnu.")
  ))
(de Afficher (content)
  (pack "<block type=\"afficher\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Concatener inputs
  (pack "<block type=\"concatener\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (mapcar '((i input) (pack "<value name=\"ADD" i "\">" (eval input) "</value>")) (range 0 (- (length inputs) 1)) inputs)
        "</block>"))
(de Demander ()
  "<block type=\"demander\"></block>")
(de !!! (content)
  (pack "<block type=\"commentaire\"><field name=\"COMZ\">"
        content
        "</field></block>"))