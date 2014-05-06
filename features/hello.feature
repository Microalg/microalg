# language: fr
Fonctionnalité: Invocation des interpréteurs sur un script 'Hello World!'
    Pour pouvoir faire travailler les interpréteurs non-interactivement
    En tant qu’utilisateurs
    Il faut pouvoir les invoquer sur un fichier.

    Scénario: Avec «pil»,    je peux lire l’exemple test_read.l.
        Le programme pil
        Avec argument exemples/test_read.l
        Ayant démarré
        Avec interaction tout le monde!
        Doit afficher «
        """
        ""Votre nom ?""
        tout le monde!
        ""Salut tout le monde!""
        """

    Scénario: Avec «pilj»,   je peux lire l’exemple test_read.l.
        Le programme pilj
        Avec argument exemples/test_read.l
        Ayant démarré
        Avec interaction tout le monde!
        Doit afficher «
        """
        ""Votre nom ?""
        tout le monde!
        ""Salut tout le monde!""
        """

    Scénario: Avec «piljs»,  je peux lire l’exemple test_read.l.
        Le programme piljs
        Avec argument exemples/test_read.l
        Ayant démarré
        Avec interaction tout le monde!
        Doit afficher «
        """
        ""Votre nom ?""
        tout le monde!
        ""Salut tout le monde!""
        """

    Scénario: Avec «malg»,   je peux lire l’exemple test_demander.malg.
        Le programme malg
        Avec argument exemples/test_demander.malg
        Ayant démarré
        Avec interaction tout le monde!
        Doit afficher «
        """
        ""Votre nom ?""
        tout le monde!
        ""Salut tout le monde!""
        """

    Scénario: Avec «malgj»,  je peux lire l’exemple test_demander.malg.
        Le programme malgj
        Avec argument exemples/test_demander.malg
        Ayant démarré
        Avec interaction tout le monde!
        Doit afficher «
        """
        ""Votre nom ?""
        tout le monde!
        ""Salut tout le monde!""
        """

    Scénario: Avec «malgjs», je peux lire l’exemple test_demander.malg.
        Le programme malgjs
        Avec argument exemples/test_demander.malg
        Ayant démarré
        Avec interaction tout le monde!
        Doit afficher «
        """
        ""Votre nom ?""
        tout le monde!
        ""Salut tout le monde!""
        """

