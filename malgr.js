// Rhino file, to be merged with piljs

// Override _stdPrint with the official mechanism.
function stdPrint(text) {
	print(text.replace(/\n$/g,''));
}
// Override _warn with the official mechanism.
function warn(msg) {
	print(msg);
}

var NO_DEBUG = "piljs -> no debug yet";

// Load EmuLisp.
// Trick to give Rhino the MicroAlg path:
var before_rhino_regex = new RegExp('^(.*)js\.jar.*');
var matches = before_rhino_regex.exec(environment["sun.java.command"]);
var abs_path = matches[1] + "../";
load(abs_path + 'emulisp/emulisp_core.js');

// Process command line args.
// TODO http://www.software-lab.de/doc/refL.html#load
var arglist = arguments;
while (true) {
    var arg = arglist.shift();
    if (typeof arg == 'undefined') {
        // Now all command line args have been consumed.
        break;
    }
    var src;
    if (arg.slice(0, 1) == '-') {
        // Interpret arg as source code.
        src = '(' + arg.slice(1) + ')';
    } else {
        // Interpret arg as a file to read.
        var f = new java.io.File(arg)
        if(f.exists()) {
            src = readFile(arg);
        } else {
            if (arg == '+') {
                print("+ not supported (yet)");
            } else {
                print(arg + " not found.");
            }
        }
    }
    try {
        EMULISP_CORE.eval(src);
    } catch(e) {
        print(e.message)
        EMULISP_CORE.eval("(run *Err)");
        print("? (" + NO_DEBUG + ")");
    }
}

EMULISP_CORE.eval('(Afficher "salut MicroAlg !!!!!!!!")');

// REPL
importPackage(java.io);
importPackage(java.lang);
var stdin = new BufferedReader(new InputStreamReader(System['in']));
var user_input;
while (true) {
    print(': ');
    user_input = stdin.readLine();
    try {
        var result = EMULISP_CORE.eval(user_input);
        print('-> ' + result);
    } catch(e) {
        print("!? " + user_input)
        print(e.message)
        EMULISP_CORE.eval("(run *Err)");
        print("? (" + NO_DEBUG + ")");
    }
}
