// Load microalg.l.
// http://stackoverflow.com/questions/984510/what-is-my-script-src-url
var this_script_url = (function(scripts) {
    var scripts = document.getElementsByTagName('script'),
    script = scripts[scripts.length - 1];
    if (script.getAttribute.length !== undefined) {
        return script.src
    }
    return script.getAttribute('src', -1)
}());
var this_script_path = 'web/ide_injections.js';
var root_path = this_script_url.slice(0, -this_script_path.length);
var microalg_l_src =
    EMULISP_CORE.getFileSync(root_path + 'microalg.l');
var microalg_export_src =
    EMULISP_CORE.getFileSync(root_path + 'microalg_export.l');
var microalg_export_blockly_src =
    EMULISP_CORE.getFileSync(root_path + 'microalg_export_blockly.l');

// Editor states are stored with key = div id to print
var emulisp_states = {};

// The marvellous PicoLisp prompt:
var malg_prompt = ": ";

function cleanTransient(text) {
    text = text.replace(/\^J/g,'\n');  // PicoLisp control char
    text = text.replace(/\\"/g,'"');   // unescape double quotes
    text = text.replace(/\\\^/g,'^');  // unescape hat char
    text = text.replace(/\n$/,'');     // remove last newline
    if (text.charAt(0) == '"' && text.charAt(text.length-1) == '"') {
        text = text.slice(1, -1);      // remove enclosing quotes
    }
    return text;
}

function stdPrint(text, state) {
    var target = $('#' + state.context.display_elt);
    text = cleanTransient(text);
    if (state.context.type == 'editor') {
        if (target.html() == "&nbsp;" && text != "") {
            target.html("");            // clean the target
        }
        if (typeof Showdown != 'undefined') {
            text = new Showdown.converter().makeHtml(text);
        }
        target.html(target.html() + text);
    }
    if (state.context.type == 'repl') {
        var repl_elt = $('#' + state.context.display_elt);
        if (text !== undefined && text != '' && text != 'NIL') {
            repl_elt.val(repl_elt.val() + "\n" + text);
        }
    }
    if (state.context.type == 'jrepl') {
        state.context.term.echo(text);
    }
}

function stdPrompt() {
    // Since the prompt appears in the little usual modal window, we need
    // to show the user the last thing displayed (it should be a question).
    var last_line_displayed = cleanTransient(EMULISP_CORE.eval('*LastStdOut'));
    if (last_line_displayed == "NIL") last_line_displayed = "?";
    var user_input = window.prompt(last_line_displayed);
    if (user_input !== null) return user_input;
    else throw new Error("Commande `Demander` annulée.")
}

function onCtrl(elt, f) {
    elt.keydown(function (e) {
        if (e.ctrlKey) {
            if (e.keyCode == 10 || e.keyCode == 13) {
                f(elt);
            } else if (e.keyCode == 66) {
                e.preventDefault();
                // Voir aussi dans editeurs/scite/malg_abbrev.properties.
                var abbrevs = {
                  "(Af": "(Affecter_a |)",
                  "(Afe": "(Affecter_a | En_position )",
                  "(A": "(Afficher |)",
                  "(Aj": "(Ajouter_a |)",
                  "(Al": "(!!! \"Algo |\")\n(!!! \"Fin algo \")",
                  "(At": "(Afficher \"|\")",
                  "(Co": "(Concatener |)",
                  "(D": "(Definir |\n    \"...\"\n    \"...\"\n    (Retourner )\n)",
                  "(Dm": "(Demander)|",
                  "(E": "(Exemples_de |\n    (Liste\n        (? )\n        (? )\n    )\n)",
                  "(E@": "(Entie@ |)\n",
                  "(F": "(Faire (|)\n       ()\n Tant_que ()\n)",
                  "(I": "(Initialiser |)",
                  "(I@":"(Initialiser@)\n|",
                  "(Li": "(Liste |)",
                  "(Lo": "(Longueur |)",
                  "(M": "(Millisecondes)|",
                  "(Ni": "(Nieme |)",
                  "(N@": "(Nieme@ |)",
                  "(No": "(Nombre |)",
                  "(Rd": "(Retirer_de |)",
                  "(R": "(Retourner |)",
                  "(S": "(Si (|) Alors\n    ()\n)",
                  "(Ss": "(Si (|)\n Alors ()\n Sinon ()\n)",
                  "(Te": "(Tester |)",
                  "(Tq": "(Tant_que (|) Faire\n    ()\n    ()\n)"
                };
                // Grab content and split in 'before' and 'after' caret.
                var src = elt.val();
                var current_pos = elt.getCursorPosition();
                var before = src.substring(0, current_pos);
                var after = src.substring(current_pos, src.length);
                // Detect a possible abbreviation: look for the previous '('.
                var last_paren_pos = before.lastIndexOf("(");
                if (last_paren_pos >= 0) {
                    var key = before.substring(last_paren_pos, before.length);
                    var abbrev = abbrevs[key];
                    if (typeof abbrev != 'undefined') {
                        var before_wo_abbrev = before.substring(0, before.length - key.length);
                        elt.val(before_wo_abbrev + abbrev.replace("|", "") + after);
                        // Restore caret position, according to abbrev.
                        var pos = elt.val().length + abbrev.lastIndexOf("|") + 1 - abbrev.length - after.length;
                        elt.selectRange(pos, pos);
                    }
                }
            }
        }
    });
}

function ide_action(editor_elt, store) {
    // Compute the target HTML elt.
    var elt_id = editor_elt.attr('id').slice(0, -('-malg-editor'.length));
    var display_target_id = elt_id + '-displaytarget';
    // Init the state and load it with MicroAlg.
    EMULISP_CORE.init();
    EMULISP_CORE.eval(microalg_l_src);
    // Custom state for a custom display in the page.
    EMULISP_CORE.currentState().context = {type: 'editor', display_elt: display_target_id};
    // Process src.
    var src = editor_elt.val();
    // The editor is in a hiddable div,
    // createRichInput put the editor in a sub div,
    // that's why we use parent().parent().parent()
    var error_elt = editor_elt.parent().parent().parent().find('.malg-error').first();
    var display_elt = editor_elt.parent().parent().parent().find('.malg-display').first();
    display_elt.html('&nbsp;');
    try {
        error_elt.text('');
        EMULISP_CORE.eval(src);
    } catch(e) {
        var link = '<a target="_blank" href="http://microalg.info/doc.html#erreursfrquentes">Voir les erreurs fréquentes.</a>';
        error_elt.html(e.message + ' <span class="malg-freq-error">' + link + '</span>');
    }
    EMULISP_CORE.eval('(setq *LastStdOut "?")');
    if (store && typeof(Storage) !== "undefined") {
        var key = 'microalg_src_' + elt_id;
        localStorage[key] = src;
    }
}

/* Inject an editor + display in the relevant element.

This is done injecting in the element identified by `elt_id` some html
according to `config` which may have these keys :

* `src` is a string defining the content displayed at first load,  
  empty if not provided,
* `localStorage` is a boolean telling to remember last program if possible,  
  false if not provided,
* `blockly` is a boolean telling to display code as blocks,  
  false if not provided,
* `blockly_only` is a boolean telling to not display the textual editor,  
  false if not provided,

*/
function inject_microalg_editor_in(elt_id, config) {
    /* Some id suffix hacking. */
    var editor_id = elt_id + '-malg-editor';
    var display_target_id = elt_id + '-displaytarget';
    var blockly_id = elt_id + '-blockly';
    var src = '';
    var blockly_src = '';
    // According to config.localStorage, load source code (if any) from local
    // storage in the `src` var.
    if (config.localStorage) {
        if (typeof(Storage) == "undefined") {
            console.log("localStorage requested but not available");
        } else {
            var key = 'microalg_src_' + elt_id;
            if (localStorage[key]) {
                src = localStorage[key];
            }
        }
    } else {
        if (config.src) {
            src = config.src;
        }
    }
    if (config.blockly || config.blockly_only) {
        // Le source doit être sur une ligne pour passer dans le js généré:
        blockly_src = src.replace(/(\r\n|\n|\r)/gm, "");
    }
    // Build the html and bind to ide_action.
    var script_container = $('#' + elt_id);
    var hidden = config.blockly_only ? ' style="display:none;"' : '';
    var link_snippet =
        '<div class="link-snippet">' +
        '<a title="Lien vers cet extrait" href="#' + elt_id + '">∞</a></div>';
    var script_string =
        link_snippet +
        ((config.blockly || config.blockly_only) ? '<div id="' + blockly_id + '"></div>' : '') +
        '<div ' + hidden + '><textarea id="' + editor_id + '" ' +
                                      'class="malg-editor" cols="80" rows="2"' +
                                      'spellcheck="false">' + src + '</textarea></div>' +
        '<input type="button" value="OK" class="malg-ok" ' +
                'onclick="ide_action($(\'#' + elt_id + '-malg-editor\'), ' + config.localStorage + ')" />' +
        '<div class="malg-error"></div>' +
        '<div id="' + display_target_id + '" class="malg-display">&nbsp;</div>';
    script_container.html(script_string);
    if (config.blockly || config.blockly_only) {
        // Injection de HTML dans une iframe car besoin de plusieurs Blockly.
        // http://stackoverflow.com/questions/13214419/alternatives-to-iframe-srcdoc
        var toolbox_string =
                '<xml id="' + elt_id + '-toolbox" style="display: none">' +
                ' <category name="Valeurs">' +
                '  <block type="variable"></block>' +
                '  <block type="texte_litteral"></block>' +
                '  <block type="nombre_litteral"></block>' +
                '  <block type="vrai"></block>' +
                '  <block type="faux"></block>' +
                '  <block type="liste"></block>' +
                '  <block type="rien"></block>' +
                ' </category>' +
                ' <category name="Cmdes sans retour">' +
                '  <block type="commentaire"></block>' +
                '  <block type="afficher"></block>' +
                '  <block type="initialiser"></block>' +
                '  <block type="affecter_a"></block>' +
                '  <block type="initialiser_pseudo_aleatoire"></block>' +
                '  <block type="si"></block>' +
                '  <block type="faire"></block>' +
                '  <block type="tant_que"></block>' +
                ' </category>' +
                ' <category name="Cmdes avec retour">' +
                '  <block type="concatener"></block>' +
                '  <block type="demander"></block>' +
                '  <block type="operations"></block>' +
                '  <block type="comparaisons"></block>' +
                '  <block type="entier_pseudo_aleatoire"></block>' +
                '  <block type="longueur"></block>' +
                '  <block type="vide?"></block>' +
                '  <block type="nieme"></block>' +
                '  <block type="nieme@"></block>' +
                '  <block type="tete"></block>' +
                '  <block type="queue"></block>' +
                ' </category>' +
                ' <category name="Types et conversions">' +
                '  <block type="type"></block>' +
                '  <block type="texte?"></block>' +
                '  <block type="nombre?"></block>' +
                '  <block type="booleen?"></block>' +
                '  <block type="texte"></block>' +
                '  <block type="nombre"></block>' +
                ' </category>' +
                ' <category name="Opérat. logiques">' +
                '  <block type="et"></block>' +
                '  <block type="ou"></block>' +
                '  <block type="non"></block>' +
                ' </category>' +
                '</xml>';
        var content = '<!DOCTYPE html>' +
            '<html>\n' +
            '  <head>\n' +
            '    <meta charset="utf-8">\n' +
            '    <script type="text/javascript" src="' + root_path + 'web/blockly/blockly_compressed.js"></script>\n' +
            '    <script type="text/javascript" src="' + root_path + 'web/blockly_microalg.js"></script>\n' +
            '    <style>\n' +
            '      html, body {\n' +
            '        background-color: #fff;\n' +
            '        margin: 0;\n' +
            '        padding: 0;\n' +
            '        overflow: hidden;\n' +
            '        height: 100%;\n' +
            '      }\n' +
            '      .blocklySvg {\n' +
            '        height: 100%;\n' +
            '        width: 100%;\n' +
            '      }\n' +
            '    </style>\n' +
            '    <script>\n' +
            '      function init() {\n' +
            '        Blockly.inject(document.body,\n' +
            '            {path: "' + root_path + 'web/blockly/",\n' +
            '             comments: false,\n' +
            '             disable: false,\n' +
            '             toolbox: document.getElementById("' + elt_id + '-toolbox")});\n' +
            '        // Let the top-level application know that Blockly is ready.\n' +
            '        window.parent.blocklyLoaded(Blockly, "' + editor_id + '", \'' + blockly_src + '\');\n' +
            '      }\n' +
            '    </script>\n' +
            '  </head>\n' +
            '  <body onload="init()">\n' + toolbox_string
            '  </body>\n' +
            '</html>';
        var blockly_container = $('#' + blockly_id);
        var iframe_id = elt_id + '-iframe';
        var style = 'seamless class="malg-blockly-iframe" scrolling="no"';
        blockly_container.html('<iframe id="' + iframe_id + '" ' + style + '></iframe>');
        var iframeDocument = document.querySelector('#' + iframe_id).contentWindow.document;
        iframeDocument.open('text/html', 'replace');
        iframeDocument.write(content);
        iframeDocument.close();
        // La suite se passe dans blocklyLoaded ci-dessous, une fois que chaque
        // iframe est chargée.
    }
    var editor = $('#' + elt_id + '-malg-editor');
    createRichInput(editor);
    onCtrl(editor, ide_action);
}

function repl_action(repl_elt) {
    // Fetch the relevant state.
    EMULISP_CORE.init(emulisp_states[repl_elt.attr('id')]);
    var result;
    var repl_content = repl_elt.val();
    var src = repl_content.slice(EMULISP_CORE.currentState().old_src.length,
                                 repl_content.length);
    try {
        result = EMULISP_CORE.eval(src);
    } catch(e) {
        if (e.message == "Function 'bye' not supported") {
            // Destroy the textarea (parent.parent is because of parenedit).
            repl_elt.parent().parent().html('');
            return;
        } else {
            repl_elt.val(repl_elt.val() + "\n" + e.message);
        }
    }
    if (typeof result != "undefined" && result != '""') {
        repl_elt.val(repl_elt.val() + "\n-> " + cleanTransient(result));
    }
    EMULISP_CORE.eval('(setq *LastStdOut "?")');
    repl_elt.val(repl_elt.val() + "\n" + malg_prompt);
    EMULISP_CORE.currentState().old_src = repl_elt.val();
}

function inject_microalg_repl_in(elt_id, msg) {
    // Compute the target HTML elt.
    var repl_id = elt_id + '-malg-repl';
    // Init the state and load it with MicroAlg.
    EMULISP_CORE.init();
    EMULISP_CORE.eval(microalg_l_src);
    // Custom state for a custom display in the REPL.
    EMULISP_CORE.currentState().context = {type: 'repl', display_elt: repl_id};
    emulisp_states[repl_id] = EMULISP_CORE.currentState();
    // Build the html and bind to repl_action.
    var repl_container = $('#' + elt_id);
    var rows = msg.split('\n').length;
    var repl_string = '<textarea id="' + repl_id + '" class="malg-repl" rows="' + (rows+2) + '" spellcheck="false">' + malg_prompt + msg + '</textarea>' +
        '<input type="button" onclick="repl_action($(\'#' + elt_id + '-malg-repl\'))" value="OK" class="malg-ok"/>';
    repl_container.html(repl_string);
    var repl = $('#' + repl_id);
    createRichInput(repl);
    onCtrl(repl, repl_action);
    EMULISP_CORE.currentState().old_src = malg_prompt;
}

function inject_microalg_jrepl_in(elt_id, msg) {
    $('#' + elt_id).terminal(function(command, term) {
        if (command !== '') {
            // Fetch the relevant state.
            EMULISP_CORE.init(emulisp_states[elt_id]);
            try {
                var result = EMULISP_CORE.eval(command);
                if (result != '""') {
                    term.echo('-> ' + cleanTransient(result.toString()));
                }
            } catch(e) {
                if (e.message == "Function 'bye' not supported") {
                    term.destroy();
                } else {
                    term.error(e.message);
                }
            }
            EMULISP_CORE.eval('(setq *LastStdOut "?")');
        }
    }, {
        greetings: msg,
        name: 'malg_repl',
        height: 150,
        prompt: ': ',
        clear: false,
        exit: false,
        keypress: function(e, term) {
            // http://stackoverflow.com/questions/23817604/how-to-hook-on-keypress-and-grab-the-current-content-of-the-terminal
            setTimeout(function() {
                if (false) console.log(term.html());
            }, 5);
        },
        onInit: function(term) {
            // Init the state and load it with MicroAlg.
            EMULISP_CORE.init();
            EMULISP_CORE.eval(microalg_l_src);
            // Custom state for a custom display in the REPL.
            EMULISP_CORE.currentState().context = {type: 'jrepl', term: term};
            emulisp_states[elt_id] = EMULISP_CORE.currentState();
        },
        keydown: function(e) {
            if (e.which === 76 && e.ctrlKey) { // CTRL+L
                return true;
            }
        }
    });
}

function malg2blockly(src) {
    EMULISP_CORE.init();
    EMULISP_CORE.eval(microalg_export_src);
    var source_protegee = EMULISP_CORE.eval("(proteger_source  " + src + ")");
    EMULISP_CORE.eval(microalg_export_blockly_src);
    var avec_des_next = EMULISP_CORE.eval("(insertion_next '" + source_protegee + ")");
    // Le car pour récupérer l’unique élément de la liste finale.
    var xml = cleanTransient(EMULISP_CORE.eval('(pack (car ' + avec_des_next + ')'));
    xml = '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="programme"><value name="VALUE">' +
          xml +
          '</value></block></xml>';
    EMULISP_CORE.init();
    EMULISP_CORE.eval(microalg_l_src);
    return xml;
}

function blocklyLoaded(blockly, editor_id, msg) {
    if (typeof msg != 'undefined') {
        var xml_text = malg2blockly(msg);
        var xml = blockly.Xml.textToDom(xml_text);
        blockly.Xml.domToWorkspace(blockly.mainWorkspace, xml);
    }
    blockly.addChangeListener(function () {
        var raw_src = blockly.MicroAlg.workspaceToCode();
        // Ne garder que le code entre les marqueurs:
        var src = /.*««««««««««([^]*)»»»»»»»»»».*/.exec(raw_src)[1];
        var textarea = $('#' + editor_id);
        textarea.val(src);
        textarea.click();  // Trigger a parenedit redraw.
    });
}

// http://www.sitepoint.com/jquery-set-focus-character-range/
$.fn.selectRange = function(start, end) {
    return this.each(function() {
        if (this.setSelectionRange) {
            this.focus();
            this.setSelectionRange(start, end);
        } else if (this.createTextRange) {
            var range = this.createTextRange();
            range.collapse(true);
            range.moveEnd('character', end);
            range.moveStart('character', start);
            range.select();
        }
    });
};
