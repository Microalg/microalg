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
var microalg_l_path = this_script_url.slice(0, -this_script_path.length)
                      + 'microalg.l';
var microalg_l_src = EMULISP_CORE.getFileSync(microalg_l_path);

// Editor states are stored with key = div id to print
var emulisp_states = {};

// The marvellous PicoLisp prompt:
var malg_prompt = ": ";

function cleanTransient(text) {
    text = text.replace(/\^J/g,'\n');  // PicoLisp control char
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
    // createRichInput put the editor in a sub div, that's why we use
    // parent().parent()
    var error_elt = editor_elt.parent().parent().find('.malg-error').first();
    var display_elt = editor_elt.parent().parent().find('.malg-display').first();
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
    var script_string = '<textarea id="' + elt_id + '-malg-editor" class="malg-editor" cols="80" rows="2" spellcheck="false">' + msg + '</textarea>' +
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
        '<input type="button" onclick="ide_action($(\'#' + elt_id + '-malg-editor\'))" value="OK" class="malg-ok"/>';
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
