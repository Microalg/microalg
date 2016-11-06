// apparence différent de Sugg pour ESPACE et
// pour commandes sans arg car "RAZ)"
// certaines cmds forcément suivies de SPACE
// pas plus de 10 Sugg?, au moins 2 chars?
// ! commandes à accents (détection slt, pas Sugg)

function valid(char)
{
    return char.match(/\w/);
}
var cmdInfo = {
    "Afficher": {
      "maxArgs": 1,
      "sigs": [["?"]]}
};
function maxArgs(cmd) {
    try {
        return cmdInfo[cmd]['maxArgs'];
    } catch (e) {
        return 666;
    }
}

/* Returns type, prefix

Types can be
?   for no suggestion
val for any value
txt for text
nl  for the need of a new line
sp  for the need of a space
(   for the need of a paren
)   for the need of a paren
cmd for any command
any intermediate keyword
*/
function propo_type(src)
{
    var toReturn = ["?", ""];
    // Split on parens or whitespace
    // and keep separators
    var tokensTmp = src.split(/(\s|\(|\))/)
                       .filter(function (str) { return str.trim(); })
                       .filter(Boolean);
    // Merge text containing spaces -> "texte"
    var tokens = [];
    var inString = false;
    for (var i = 0; i < tokensTmp.length; i++)
    {
        if (!inString) {
            if (tokensTmp[i].slice(0, 1) == '"' &&
                tokensTmp[i].slice(-1) != '"') {
                inString = true;
            } else {
                tokens.push(tokensTmp[i]);
            }
        } else {
            if (tokensTmp[i].slice(0, 1) != '"' &&
                tokensTmp[i].slice(-1) == '"') {
                inString = false;
                tokens.push('"texte"');
            }
        }
    }
    // Trivial cases
    if (tokens.length == 0)
        return ["(", ""];
    if (inString)
        return ["?", ""];
    // Currently in a word?
    var lastChar = src.slice(-1);
    if (valid(lastChar))
    {
        // Set the prefix
        toReturn[1] = tokens.slice(-1);
        // Delete the prefix from the tokens
        tokens = tokens.slice(0, -1);
    }
    var lastToken = tokens.slice(-1);
    // Brand new instruction?
    if (lastToken == "(")
    {
        // TODO: use code below to detect
        // if we are in a sub command for
        // refining the command to return
        toReturn[0] = "cmd";
        return toReturn;
    }
    // We need the command of the instruction
    // Find the last opening solo paren
    var cursor = tokens.length - 1;
    var openParens = 0;
    var openParensOld = 0;
    var tokensAfterLastOpen = 0;
    while (cursor >= 0)
    {
        var token = tokens[cursor];
        if (token == "(") openParens++;
        if (token == ")") openParens--;
        if (openParens == 0 &&
             (token == "(" || token != ")"))
            tokensAfterLastOpen++;
        if (openParens == 1) break;
        cursor--;
    }
    // We already tested if "(" was the last token,
    // so we can safely add 1.
    var cmd = tokens[cursor+1];
    if (lastChar == ")")
    {
        if (openParens == 0)
            return ["nl", ""];
        else if (maxArgs(cmd) == 1)
            return [")", ""];
        else return ["sp", ""];
    }
    else if (lastChar == " ")
    {
        if (openParens == 1 &&
            maxArgs(cmd) + 1 == tokensAfterLastOpen)
            return [")", ""];
        else if (cmd == '!!!')
            return ["txt", ""];
        // TODO: gérer Si avec ses sigs
        else if (cmd == 'Si' && tokensAfterLastOpen == 1)
            toReturn[0] = "bool";
        else if (cmd == 'Si' && tokensAfterLastOpen == 2)
            toReturn[0] = "alors";
        else if (cmd == 'Si' && tokensAfterLastOpen >= 4)
            toReturn[0] = "sinon";
        else
            toReturn[0] = "val";
    }
    else if (lastChar == '"')
    {
        if (lastToken.length != 1 &&
            lastToken.slice(0, 1) == '"')
            return [" ", ""]; // todo check nb args
    }
    // TODO: gérer Si avec ses sigs
    // TODO: gérer aussi les accents
    // Affecter_à
    // Concaténer
    // Déclarer
    // Définir
    // Répéter
    else if (cmd == "Si")
    {
        if (tokens.indexOf("Alors", cursor) == -1) {
            toReturn[0] = "alors";
        } else if (lastToken != "Alors" && tokens.indexOf("Sinon", cursor) == -1) {
            toReturn[0] = "sinon";
        }
    }
    return toReturn;
}

var cmds = "1000Cosinus 1000Sinus AV BC LC TD TG Affecter_a Afficher Aide Ajouter_a Cercle Concatener Contour Declarer Definir Demander Demander_un_nombre Ellipse Entier@ Epaisseur Et Exemples_de Faire Geler Initialiser@ Liste Longueur Millisecondes Nieme Nieme@ Nombre Non Ou Queue RAZ Rectangle Remplissage Repere Repeter Retirer_de Retourner Segment Si Tant_que Tester Tete Texte Triangle Type Vide? Affecter_à Concaténer Déclarer Définir Répéter".split(' ');
var vals = '( " Vrai Faux valeur_utilisateur credit_iterations sequence_tirages@ Rien'.split(' ');
var bools = '( Vrai Faux'.split(' ');

/* predicate generator */
function beginsWith(prefix)
{
    return function(str) {
        var beginning = str.slice(0, prefix.toString().length);
        return beginning == prefix;
    }
}

function matches(prefix, list)
{
    return list.filter(beginsWith(prefix));
}

/* Returns a completion (display and actual text)

*/
function suggestion(propo_type) {
    var type = propo_type[0];
    var prefix = propo_type[1];
    if (type == 'cmd')
        return matches(prefix, cmds);
    if (type == 'val')
        return matches(prefix, vals);
    if (type == 'bool')
        return matches(prefix, bools);
    if (type == ' ')
        return ["Espace"];
    if (type == 'alors')
        return ["Alors"]; // 'Sinon' factoriser!
    return [];
}

// tests

var src_propo_pairs = [
    ["", "("],
    [" ", "("],
    ["(bla)", "nl"],
    ["(bla (", "cmd"],
    ["(bla ( ", "cmd"],
    ["(Demander) (Affi", "cmd"],
    ["(Afficher ", "val"],
    ["(Afficher tavu", "?"],
    ["(Afficher tavu ", ")"],
    ['(Afficher "tavu" ', ")"],
    ["(Afficher (+ 1 1)", ")"],
    ['(Afficher "ta vu ', "?"],
    ["(Afficher tavu)", "nl"],
    ["(Si ", "bool"],
    ["(Si Vrai ", "alors"],
    ["(Si Vrai Al", "alors"],
    ["(Si (Et Vrai Faux)", "sp"],
    ["(Si (Et Vrai Faux) ", "alors"],
    ["(Si Vrai Alors Rien) (Si Vrai ", "alors"],
    ["(Si (Et Vrai Faux) Alors ", "val"],
    ["(Si (Et Vrai Faux) Alors (Afficher 1) ", "sinon"],
    ["(Si (Et (Ou Vrai) Faux) ", "alors"],
    ["ok"]
];

if (typeof console !== "undefined") {
        print = console.log;
}

function callback(elt, i)
{
    var src = elt[0];
    if (src === "ok")
    {
        print("ok");
        return;
    }
    var target_propo = elt[1];
    var attempted_propo = propo_type(src)[0];
    if (target_propo != attempted_propo)
    {
        print (src + ': ' + attempted_propo + ' != ' + target_propo);
    }
}

src_propo_pairs.forEach(callback);