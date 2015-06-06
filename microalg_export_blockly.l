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
(de Variable inputs
  (let (nom_var (car inputs))
    (if nom_var (pack "<block type=\"variable\"><field name=\"VAR\">"
                               nom_var
                               "</field></block>")
                "<block type=\"texte_litteral\"><field name=\"TEXT\"></field></block>"
    )
  )
)
# Attention, insertion_next ne plonge pas dans les instruction contenant des
# blocs, comme Faire, Tant_que et Si. Ce genre d’instructions doivent utiliser
# insertion_next sur leurs blocs.
(de insertion_next (src) (car (insertion_next_aux (reverse src))))
(de insertion_next_aux (src)
  (ifn (and (<> (length src) 0) (<> (length src) 1)) src  # if (<= len 1)
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
(de = (A B)
   (pack "<block type=\"comparaisons\"><field name=\"COMP\">EQ</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de =/ (A B)
   (pack "<block type=\"comparaisons\"><field name=\"COMP\">NEQ</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de < (A B)
   (pack "<block type=\"comparaisons\"><field name=\"COMP\">INF</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de > (A B)
   (pack "<block type=\"comparaisons\"><field name=\"COMP\">SUP</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de <= (A B)
   (pack "<block type=\"comparaisons\"><field name=\"COMP\">INFEQ</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de >= (A B)
   (pack "<block type=\"comparaisons\"><field name=\"COMP\">SUPEQ</field>"
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
(de Affecter_a inputs
  (let (!var (cadr (car inputs))  # var name is in (Variable ...)
        !val (eval (cadr inputs))
        !next (eval (caddr inputs)))
       (pack "<block type=\"affecter_a\">"
             "<field name=\"VAR\">" !var "</field>"
             "<value name=\"VALUE\">" !val "</value>"
             !next
             "</block>")))
(de Booleen? (content)
  (pack "<block type=\"booleen?\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Concatener inputs
  (pack "<block type=\"concatener\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (if (<> 0 (length inputs))
            (mapcar '((i input) (pack "<value name=\"ITEM" i "\">" (eval input) "</value>"))
                    (range 0 (dec (length inputs)))
                    inputs))
        "</block>"))
(de Demander ()
  "<block type=\"demander\"></block>")
(de Entier@ (MIN MAX)
  (pack "<block type=\"entier_pseudo_aleatoire\">"
        "<value name=\"MIN\">" MIN "</value>"
        "<value name=\"MAX\">" MAX "</value>"
        "</block>"))
(de Et inputs
  (pack "<block type=\"et\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (mapcar '((i input) (pack "<value name=\"BOOL" i "\">" (eval input) "</value>")) (range 0 (dec (length inputs))) inputs)
        "</block>"))
(de Faire inputs
  (let (!splitted (split inputs 'Tant_que)
        !corps    (car !splitted)
        !cond     (car (cadr !splitted))
        # !next est le dernier de la liste inputs, si son car vaut Next.
        !next (let !last (last inputs) (if (= (car !last) 'Next) !last)))
       (pack "<block type=\"faire\">"
             "<statement name=\"INSTR\">" (eval (insertion_next !corps)) "</statement>"
             "<value name=\"COND\">" (eval !cond) "</value>"
             (eval !next)
             "</block>") ))
(de Initialiser inputs
  (let (!var (cadr (car inputs))  # var name is in (Variable ...)
        !val (eval (cadr inputs))
        !next (eval (caddr inputs)))
       (pack "<block type=\"initialiser\">"
             "<field name=\"VAR\">" !var "</field>"
             "<value name=\"VALUE\">" !val "</value>"
             !next
             "</block>")))
(de Initialiser@ (next)
  (pack "<block type=\"initialiser_pseudo_aleatoire\">"
        next
        "</block>"))
(de Liste inputs
  (pack "<block type=\"liste\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (if (<> 0 (length inputs))
            (mapcar '((i input) (pack "<value name=\"ITEM" i "\">" (eval input) "</value>"))
                    (range 0 (dec (length inputs)))
                    inputs))
        "</block>"))
(de Longueur (content)
  (pack "<block type=\"longueur\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Nieme (value index)
  (pack "<block type=\"nieme\">"
        "<value name=\"VALUE\">"
        value
        "</value>"
        "<value name=\"INDEX\">"
        index
        "</value>"
        "</block>"))
(de Nieme@ (value)
  (pack "<block type=\"nieme@\">"
        "<value name=\"VALUE\">"
        value
        "</value>"
        "</block>"))
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
(de Ou inputs
  (pack "<block type=\"ou\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (mapcar '((i input) (pack "<value name=\"BOOL" i "\">" (eval input) "</value>")) (range 0 (dec (length inputs))) inputs)
        "</block>"))
(de Non (content)
  (pack "<block type=\"non\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Queue (content)
  (pack "<block type=\"queue\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Si inputs
  (let (condition (car inputs)
        kw_alors  (cadr inputs)
        splitted  (split (cddr inputs) 'Sinon)
        bloc_vrai (car splitted)
        bloc_faux (cadr splitted)
        # !next est le dernier de la liste inputs, si son car vaut Next.
        !next (let !last (last inputs) (if (= (car !last) 'Next) !last)))
       (pack "<block type=\"si\">"
             (if (n0 (length bloc_faux)) "<mutation else=\"1\"></mutation>")
             "<value name=\"COND\">"
             (eval condition)
             "</value>"
             "<statement name=\"ALORS\">"
             (eval (insertion_next bloc_vrai))
             "</statement>"
             (if bloc_faux (pack
                 "<statement name=\"SINON\">"
                 (eval (insertion_next bloc_faux))
                 "</statement>"))
             (eval !next)
             "</block>")
))
(de Tant_que inputs
  (let (!cond  (car inputs)
        !corps (cddr inputs)
        # !next est le dernier de la liste inputs, si son car vaut Next.
        !next (let !last (last inputs) (if (= (car !last) 'Next) !last)))
       (pack "<block type=\"tant_que\">"
             "<value name=\"COND\">" (eval !cond) "</value>"
             "<statement name=\"INSTR\">" (eval (insertion_next !corps)) "</statement>"
             (eval !next)
             "</block>") ))
(de Tete (content)
  (pack "<block type=\"tete\">"
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
(de Type (content)
  (pack "<block type=\"type\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Vide? (content)
  (pack "<block type=\"vide?\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        "</block>"))
(de Vrai ()
  "<block type=\"vrai\"></block>")
(de Faux ()
  "<block type=\"faux\"></block>")
