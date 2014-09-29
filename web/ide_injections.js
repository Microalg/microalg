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
    var last_line_displayed = cleanTransient(EMULISP_CORE.eval('*LastStdOut'));
    var user_input = window.prompt(last_line_displayed);
    if (user_input !== null) return user_input;
    else throw new Error("Opération 'Demander' annulée.")
}

function onCtrlEnter(elt, f) {
    elt.keydown(function (e) {
        if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
            f(elt);
        }
    });
}

function ide_action(editor_elt) {
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
        error_elt.text(e.message);
    }
    EMULISP_CORE.eval('(setq *LastStdOut "?")');
    if (typeof(Storage) !== "undefined") {
        var key = 'microalg_src_' + elt_id;
        localStorage[key] = src;
    }
}

function inject_microalg_editor_in(elt_id, config, msg) {
    // Build the html and bind to ide_action.
    var display_target_id = elt_id + '-displaytarget';
    var script_container = $('#' + elt_id);
    var hidden = config.hidden ? ' style="display:none;"' : '';
    var script_string = '<div ' + hidden + '><textarea id="' + elt_id + '-malg-editor" ' +
                        'class="malg-editor" cols="80" rows="2"' +
                        'spellcheck="false">' + msg + '</textarea></div>' +
            '<input type="button" onclick="ide_action($(\'#' + elt_id + '-malg-editor\'))" value="OK" class="malg-ok"/>' +
            '<div class="malg-error" style="color: red;"></div>' +
            '<div id="' + display_target_id + '" class="malg-display">&nbsp;</div>';
    script_container.html(script_string);
    var editor = $('#' + elt_id + '-malg-editor');
    // Load local storage in the editor.
    if (config.localStorage && typeof(Storage)!=="undefined") {
        var key = 'microalg_src_' + elt_id;
        if (localStorage[key]) {
            editor.val(localStorage[key]);
        }
    }
    createRichInput(editor);
    onCtrlEnter(editor, ide_action);
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
    // Build the html and bind to ide_action.
    var repl_container = $('#' + elt_id);
    var rows = msg.split('\n').length;
    var repl_string = '<textarea id="' + repl_id + '" class="malg-repl" rows="' + (rows+2) + '" spellcheck="false">' + malg_prompt + msg + '</textarea>' +
        '<input type="button" onclick="repl_action($(\'#' + elt_id + '-malg-repl\'))" value="OK" class="malg-ok"/>';
    repl_container.html(repl_string);
    var repl = $('#' + repl_id);
    createRichInput(repl);
    onCtrlEnter(repl, repl_action);
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
    var litteraux_proteges = EMULISP_CORE.eval("(proteger_litteraux  " + src + ")");
    EMULISP_CORE.eval(microalg_export_blockly_src);
    var avec_des_next = EMULISP_CORE.eval("(insertion_next '" + litteraux_proteges + ")");
    // Le car pour récupérer l’unique élément de la liste finale.
    var xml = cleanTransient(EMULISP_CORE.eval('(pack (car ' + avec_des_next + ')'));
    xml = '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="programme"><value name="VALUE">' +
          xml +
          '</value></block></xml>';
    EMULISP_CORE.init();
    EMULISP_CORE.eval(microalg_l_src);
    return xml;
}

function inject_microalg_blockly_in(elt_id, editor_id, msg) {
    var blockly_container = $('#' + elt_id);
    // Injection de HTML dans une iframe car besoin de plusieurs Blockly.
    // http://stackoverflow.com/questions/13214419/alternatives-to-iframe-srcdoc
    // Le code MicroAlg doit être sur une ligne pour passer dans le js généré:
    if (typeof msg != "undefined") {
        msg = msg.replace(/(\r\n|\n|\r)/gm, "");
    } else {
        msg = "";
    }
    // Ensuite le contenu de la toolbox:
    var toolbox_string =
            '<xml id="' + elt_id + '-toolbox" style="display: none">' +
            ' <category name="Commandes">' +
            '  <block type="commentaire"></block>' +
            '  <block type="afficher"></block>' +
            '  <block type="concatener"></block>' +
            '  <block type="demander"></block>' +
            '  <block type="operations"></block>' +
            '  <block type="type"></block>' +
            '  <block type="texte?"></block>' +
            '  <block type="texte"></block>' +
            '  <block type="nombre?"></block>' +
            '  <block type="nombre"></block>' +
            ' </category>' +
            ' <category name="Autres">' +
            '  <block type="texte_litteral"></block>' +
            '  <block type="nombre_litteral"></block>' +
            ' </category>' +
            '</xml>';
    // La page:
    var content = '<!DOCTYPE html>' +
'<html>\n' +
'  <head>\n' +
'    <meta charset="utf-8">\n' +
'    <script type="text/javascript" src="web/blockly/blockly_compressed.js"></script>\n' +
'    <script type="text/javascript" src="web/blockly_microalg.js"></script>\n' +
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
'            {path: "../../web/blockly/",\n' +
'             comments: false,\n' +
'             disable: false,\n' +
'             toolbox: document.getElementById("' + elt_id + '-toolbox")});\n' +
'        // Let the top-level application know that Blockly is ready.\n' +
'        window.parent.blocklyLoaded(Blockly, "' + editor_id + '", \'' + msg + '\');\n' +
'      }\n' +
'    </script>\n' +
'  </head>\n' +
'  <body onload="init()">\n' + toolbox_string
'  </body>\n' +
'</html>';
    // Création de l’iframe et injection.
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
