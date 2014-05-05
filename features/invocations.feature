# language: fr
Fonctionnalité: Invocation des interpréteurs et leur sortie
    Pour pouvoir utiliser les interpréteurs
    En tant qu’utilisateurs
    Il faut pouvoir les invoquer et en sortir.

    Scénario: Avec l’interpréteur officiel de PicoLisp (écrit en ASM et C).
        Le programme pil
        Ayant démarré
        Avec interaction (bye)
        Doit afficher «: (bye)»

    Scénario: Avec l’interpréteur en Java de PicoLisp (nommé Ersatz).
        Le programme pilj
        Ayant démarré
        Avec interaction (bye)
        Doit afficher «: (bye)»

    Scénario: Avec l’interpréteur en Javascript (NodeJS + Emulisp) de PicoLisp.
        Le programme piljs
        Ayant démarré
        Avec interaction (bye)
        Doit afficher «: (bye)»

    Scénario: Avec l’interpréteur de MicroAlg sur 'pil'.
        Le programme malg
        Ayant démarré
        Avec interaction (bye)
        Doit afficher «: (bye)»

    Scénario: Avec l’interpréteur de MicroAlg sur 'pilj' (Java).
        Le programme malgj
        Ayant démarré
        Avec interaction (bye)
        Doit afficher «: (bye)»

    Scénario: Avec l’interpréteur de MicroAlg sur 'piljs' (Javascript).
        Le programme malgjs
        Ayant démarré
        Avec interaction (bye)
        Doit afficher «: (bye)»

