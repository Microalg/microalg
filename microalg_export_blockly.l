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
    (cond
      ((== 'valeur_utilisateur nom_var)
        "<block type=\"valeur_utilisateur\"></block>")
      ((== 'credit_iterations  nom_var)
        "<block type=\"credit_iterations\"></block>")
      ((== 'sequence_tirages@  nom_var)
        "<block type=\"sequence_tirages\"></block>")
      ((not nom_var)
        "<block type=\"texte_litteral\"><field name=\"TEXT\"></field></block>")
      (T
        (pack "<block type=\"variable\"><field name=\"VAR\">" nom_var "</field></block>"))
    )
  )
)
(de !num? (x)
  (and (== 'Litteral (car x)) (num? (cadr x)))
)
(de !bytehexapad (x)
  (if (<> 2 (length x))
      (pack "0" x)
      x ))

# Attention, insertion_next ne plonge pas dans les instructions contenant des
# blocs, comme Faire, Tant_que et Si. Ce genre d’instruction doit utiliser
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
(de % (A B)
   (pack "<block type=\"operations\"><field name=\"OP\">MOD</field>"
         "<value name=\"A\">" A "</value>"
         "<value name=\"B\">" B "</value>"
         "</block>"))
(de ^ (A B)
   (pack "<block type=\"operations\"><field name=\"OP\">POW</field>"
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
        !next_raw (cddr inputs))
       (if (<> 'En_position (car !next_raw))
         (pack "<block type=\"affecter_a\">"
               "<field name=\"VAR\">" !var "</field>"
               "<value name=\"VALUE\">" !val "</value>"
               (eval (car !next_raw))
               "</block>")
         (let (!pos (eval (cadr !next_raw)))
              (pack "<block type=\"affecter_a_en_position\">"
                    "<field name=\"VAR\">" !var "</field>"
                    "<value name=\"VALUE\">" !val "</value>"
                    "<value name=\"POS\">" !pos "</value>"
                    (eval (caddr !next_raw))
                    "</block>")
         )
       )
  )
)
(setq Affecter_à 'Affecter_a)
(de Concatener inputs
  (pack "<block type=\"concatener\">"
        "<mutation items=\"" (length inputs) "\"></mutation>"
        (if (<> 0 (length inputs))
            (mapcar '((i input) (pack "<value name=\"ITEM" i "\">" (eval input) "</value>"))
                    (range 0 (dec (length inputs)))
                    inputs))
        "</block>"))
(setq Concaténer 'Concatener)
(de Declarer arg_lst
  (let (!splitted (split arg_lst 'De_type)
        !vars (mapcar 'cadr (car !splitted))  # var name is in (Variable ...)
        !type (caadr !splitted)
        !next (last arg_lst))
       (!declarer_rec !vars !type !next)
  )
)
(setq Déclarer 'Declarer)
(de !declarer_rec (!vars !type !next)
  (ifn !vars
       (eval !next)
       (let (!length_vars (length !vars))
            (pack "<block type=\"declarer\">"
                  "<field name=\"VAR\">" (car !vars) "</field>"
                  "<field name=\"TYPE\">" (eval !type) "</field>"
                  (if (and (<> 0 !length_vars) (<> 1 !length_vars) 2)  # len >= 2
                      (pack "<next>" (!declarer_rec (cdr !vars) !type !next) "</next>")
                      (!declarer_rec (cdr !vars) !type !next)
                  )
                  "</block>")
       )
  )
)
(de Demander ()
  "<block type=\"demander\"></block>")
(de Demander_un_nombre ()
  "<block type=\"demander_un_nombre\"></block>")
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
(de Initialiser@ (etat next)
  (pack "<block type=\"initialiser_pseudo_aleatoire\">"
        "<value name=\"ETAT\">" etat "</value>"
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
(de Millisecondes ()
  "<block type=\"millisecondes\"></block>")
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
(de Repeter inputs
  (let (!repet  (car inputs)
        !corps (cddr inputs)
        # !next est le dernier de la liste inputs, si son car vaut Next.
        !next (let !last (last inputs) (if (= (car !last) 'Next) !last)))
       (pack "<block type=\"repeter\">"
             "<value name=\"REPET\">" (eval !repet) "</value>"
             "<statement name=\"INSTR\">" (eval (insertion_next !corps)) "</statement>"
             (eval !next)
             "</block>") ))
(setq Répéter 'Repeter)
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
(de RAZ (next)
  (pack "<block type=\"raz\">"
        next
        "</block>"))
(de Cercle inputs
  (let (origine (car inputs)
        orig_x (eval (cadr origine))
        orig_y (eval (caddr origine))
        r (eval (cadr inputs))
        next (eval (caddr inputs)))
       (pack "<block type=\"cercle\">"
             "<value name=\"ORIG_X\">"
             orig_x
             "</value>"
             "<value name=\"ORIG_Y\">"
             orig_y
             "</value>"
             "<value name=\"R\">"
             r
             "</value>"
             next
             "</block>")))
(de Contour inputs
  (let (couleur (cdar inputs)  # cadr: extraire RVBA de '((Liste R V B A))
        r (car    couleur)
        v (cadr   couleur)
        b (caddr  couleur)
        a (cadddr couleur)  # Ces quatre valeurs de la forme (Litteral X).
        next (eval (cadr inputs)))
       (if (and (not a) (!num? r) (!num? v) (!num? b))
           (pack "<block type=\"contour-p\">"
                 "<field name=\"COULEUR\">"
                 "#" (!bytehexapad (hex (cadr r)))
                     (!bytehexapad (hex (cadr v)))
                     (!bytehexapad (hex (cadr b)))
                 "</field>"
                 next
                 "</block>")
           (pack "<block type=\"contour" (if a "-alpha") "\">"
                 "<value name=\"R\">"
                 (eval r)
                 "</value>"
                 "<value name=\"V\">"
                 (eval v)
                 "</value>"
                 "<value name=\"B\">"
                 (eval b)
                 "</value>"
                 (if a (pack "<value name=\"A\">" (eval a) "</value>"))
                 next
                 "</block>"))))
(de Ellipse inputs
  (let (origine (car inputs)
        orig_x (eval (cadr origine))
        orig_y (eval (caddr origine))
        r1 (eval (cadr inputs))
        r2 (eval (caddr inputs))
        next (eval (cadddr inputs)))
       (pack "<block type=\"ellipse\">"
             "<value name=\"ORIG_X\">"
             orig_x
             "</value>"
             "<value name=\"ORIG_Y\">"
             orig_y
             "</value>"
             "<value name=\"R1\">"
             r1
             "</value>"
             "<value name=\"R2\">"
             r2
             "</value>"
             next
             "</block>")))
(de Epaisseur (e next)
  (pack "<block type=\"epaisseur\">"
        "<value name=\"E\">"
        e
        "</value>"
        next
        "</block>"))
(de Rectangle inputs
  (let (p1 (car inputs)
        p2 (cadr inputs)
        x1 (eval (cadr  p1))
        y1 (eval (caddr p1))
        x2 (eval (cadr  p2))
        y2 (eval (caddr p2))
        next (eval (caddr inputs)))
       (pack "<block type=\"rectangle\">"
             "<value name=\"X1\">"
             x1
             "</value>"
             "<value name=\"Y1\">"
             y1
             "</value>"
             "<value name=\"X2\">"
             x2
             "</value>"
             "<value name=\"Y2\">"
             y2
             "</value>"
             next
             "</block>")))
(de Remplissage inputs
  (let (couleur (cdar inputs)  # cadr: extraire RVBA de '((Liste R V B A))
        r (car    couleur)
        v (cadr   couleur)
        b (caddr  couleur)
        a (cadddr couleur)  # Ces quatre valeurs de la forme (Litteral X).
        next (eval (cadr inputs)))
       (if (and (not a) (!num? r) (!num? v) (!num? b))
           (pack "<block type=\"remplissage-p\">"
                 "<field name=\"COULEUR\">"
                 "#" (!bytehexapad (hex (cadr r)))
                     (!bytehexapad (hex (cadr v)))
                     (!bytehexapad (hex (cadr b)))
                 "</field>"
                 next
                 "</block>")
           (pack "<block type=\"remplissage" (if a "-alpha") "\">"
                 "<value name=\"R\">"
                 (eval r)
                 "</value>"
                 "<value name=\"V\">"
                 (eval v)
                 "</value>"
                 "<value name=\"B\">"
                 (eval b)
                 "</value>"
                 (if a (pack "<value name=\"A\">" (eval a) "</value>"))
                 next
                 "</block>"))))
(de Repere inputs
  (let (x_min (eval (car inputs))
        x_max (eval (cadr inputs))
        y_min (eval (caddr inputs))
        y_max (eval (cadddr inputs))
        x_grad (eval (car (cddr (cddr inputs))))
        y_grad (eval (cadr (cddr (cddr inputs))))
        next  (if y_grad
                  (eval (caddr (cddr (cddr inputs))))
                  x_grad))
       (pack "<block type=\"repere" (if y_grad "_grad") "\">"
             "<value name=\"X_MIN\">" x_min "</value>"
             "<value name=\"X_MAX\">" x_max "</value>"
             "<value name=\"Y_MIN\">" y_min "</value>"
             "<value name=\"Y_MAX\">" y_max "</value>"
             (if y_grad
                 (pack "<value name=\"X_GRAD\">" x_grad "</value>"
                       "<value name=\"Y_GRAD\">" y_grad "</value>"))
             next
             "</block>")))
(de Segment inputs
  (let (p1 (car inputs)
        p2 (cadr inputs)
        x1 (eval (cadr  p1))
        y1 (eval (caddr p1))
        x2 (eval (cadr  p2))
        y2 (eval (caddr p2))
        next (eval (caddr inputs)))
       (pack "<block type=\"segment\">"
             "<value name=\"X1\">"
             x1
             "</value>"
             "<value name=\"Y1\">"
             y1
             "</value>"
             "<value name=\"X2\">"
             x2
             "</value>"
             "<value name=\"Y2\">"
             y2
             "</value>"
             next
             "</block>")))
(de Triangle inputs
  (let (p1 (car inputs)
        p2 (cadr inputs)
        p3 (caddr inputs)
        x1 (eval (cadr  p1))
        y1 (eval (caddr p1))
        x2 (eval (cadr  p2))
        y2 (eval (caddr p2))
        x3 (eval (cadr  p3))
        y3 (eval (caddr p3))
        next (eval (cadddr inputs)))
       (pack "<block type=\"triangle\">"
             "<value name=\"X1\">"
             x1
             "</value>"
             "<value name=\"Y1\">"
             y1
             "</value>"
             "<value name=\"X2\">"
             x2
             "</value>"
             "<value name=\"Y2\">"
             y2
             "</value>"
             "<value name=\"X3\">"
             x3
             "</value>"
             "<value name=\"Y3\">"
             y3
             "</value>"
             next
             "</block>")))
(de AV (content next)
  (pack "<block type=\"av\">"
        "<value name=\"VALUE\">"
        content
        "</value>"
        next
        "</block>"))
(de BC (next)
  (pack "<block type=\"bc\">"
        next
        "</block>"))
(de LC (next)
  (pack "<block type=\"lc\">"
        next
        "</block>"))
(de !T (inputs type)
  (let (inputs_num (length inputs))
       (cond
         ((not (<> 2 inputs_num))  # 2 args
            (let (content (eval (car inputs))
                  next    (eval (cadr inputs)))
                 (pack "<block type=\"t" type "\">"
                       "<value name=\"VALUE\">"
                       content
                       "</value>"
                       next
                       "</block>")))
         ((not (<> 1 inputs_num))  # 1 arg
            (if (== 'Next (caar inputs))
                (let (next (eval (car inputs)))
                     (pack "<block type=\"t" type "90\">"
                           next
                           "</block>"))
                (let (content (eval (car inputs)))
                     (pack "<block type=\"t" type "\">"
                           "<value name=\"VALUE\">"
                           content
                           "</value>"
                           "</block>"))))
         (T  # 0 arg
            (pack "<block type=\"t" type "90\"></block>"))
       )
  )
)
(de TD inputs (!T inputs "d"))
(de TG inputs (!T inputs "g"))

(de !sans_bloc (cmd next)
  (pack "<block type=\"commentaire\"><field name=\"COMZ\">"
        "La commande `" cmd "` n’a pas de bloc."
        "</field>"
        next
        "</block>"))

(de Definir () (!sans_bloc "Definir"))
(de Définir () (!sans_bloc "Définir"))
