# language: fr
Fonctionnalité: Invocation des interpréteurs, interactions puis sortie
    Pour pouvoir faire travailler les interpréteurs interactivement
    En tant qu’utilisateurs
    Il faut pouvoir les invoquer, taper des instructions, et en sortir.

    Scénario: Avec «pil»,    je peux faire une simple addition.
        Le programme pil
        Ayant démarré
        Avec interaction (+ 2 2)
        Avec interaction (bye)
        Doit afficher «
          """
          : (+ 2 2)
          -> 4
          : (bye)
          """

    Scénario: Avec «pilj»,   je peux faire une simple addition.
        Le programme pilj
        Ayant démarré
        Avec interaction (+ 2 2)
        Avec interaction (bye)
        Doit afficher «
          """
          : (+ 2 2)
          -> 4
          : (bye)
          """

    Scénario: Avec «piljs»,  je peux faire une simple addition.
        Le programme piljs
        Ayant démarré
        Avec interaction (+ 2 2)
        Avec interaction (bye)
        Doit afficher «
          """
          : (+ 2 2)
          -> 4
          : (bye)
          """

    Scénario: Avec «malg»,   je peux faire une simple addition.
        Le programme malg
        Ayant démarré
        Avec interaction (+ 2 2)
        Avec interaction (bye)
        Doit afficher «
          """
          : (+ 2 2)
          -> 4
          : (bye)
          """

    Scénario: Avec «malgj»,  je peux faire une simple addition.
        Le programme malgj
        Ayant démarré
        Avec interaction (+ 2 2)
        Avec interaction (bye)
        Doit afficher «
          """
          : (+ 2 2)
          -> 4
          : (bye)
          """

    Scénario: Avec «malgjs», je peux faire une simple addition.
        Le programme malgjs
        Ayant démarré
        Avec interaction (+ 2 2)
        Avec interaction (bye)
        Doit afficher «
          """
          : (+ 2 2)
          -> 4
          : (bye)
          """

