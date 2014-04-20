(put 'version 'text "MicroAlg version 0.1.0")
(setq version "0.1.0")

# L’affichage se fait au travers de la variable globale *StdOut.
(setq *StdOut "")
(de Afficher (obj) (setq *StdOut (pack *StdOut obj)))
