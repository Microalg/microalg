diff -rq . ../microalg.github.io | \
grep -v "Only in .: diff.microalg.info.sh" | \
grep -v swp | \
grep -v /\.git | \
grep -v .gitignore | \
grep -v README | \
grep -v LICENSE | \
grep -v INSTALL | \
grep -v CNAME | \
grep -v "Only in .: editeurs" | \
grep -v "Only in ./emulisp: emulisp_cv.js" | \
grep -v "Only in ./emulisp: emulisp_js.js" | \
grep -v "Only in ./emulisp: piljs.bat" | \
grep -v "Only in ./emulisp: pil-njs" | \
grep -v "Only in ./emulisp: pil-rjs" | \
grep -v "Only in .: ersatz" | \
grep -v "Only in .: ersatz_repl.l" | \
grep -v "Only in .: exemples" | \
grep -v "Only in .: features" | \
grep -v "Only in .: geogebra" | \
grep -v "Only in .: install_scripts" | \
grep -v "Only in .: lib" | \
grep -v "Only in .: malg" | \
grep -v "Only in .: netlogo" | \
grep -v "Only in .: picolisp" | \
grep -v "Only in .: todo" | \
grep -v "Only in .: .travis.yml" | \
grep -v "Only in ../microalg.github.io: 404.html" | \
grep -v "Only in ../microalg.github.io: comparaison.html" | \
grep -v "Only in ../microalg.github.io: images" | \
grep -v "Only in ../microalg.github.io: index.html" | \
grep -v "Only in ../microalg.github.io: logos.html" | \
grep -v "Only in ../microalg.github.io: params.json" | \
grep -v "Only in ../microalg.github.io: rapport_" | \
grep -v "Only in ../microalg.github.io: stylesheets" | \
grep -v "Only in .: microalg_tests" | \
grep -v "Only in .: .gitattributes" | \
tee
