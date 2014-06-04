// Keep a state where microalg is loaded.
// (We cannot load from here because we'd need ../)
var microalg_fresh_state = EMULISP_CORE.currentState();

// Editor states are stored with key = div id to print
var editor_states = {};

function stdPrint(text, state) {
    var target = $('#' + state.context.display_div);
    text = text.replace(/\n$/,'');  // remove last newline
    text = text.slice(1, -1);       // remove enclosing quotes
    if (target.html() == "&nbsp;" && text != "") {
        target.html("");            // clean the target
    }
    text = text + '<br>';           // add the web new line
    target.html(target.html() + text);
}

function stdPrompt() {
    return window.prompt(EMULISP_CORE.eval('*LastStdOut').slice(1, -1));
}

function onCtrlEnter(elt, f) {
    elt.keydown(function (e) {
        if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
            f(elt);
        }
    });
}

function inject_microalg_editor_in(elt_id, config, msg) {
    // New state for this editor.
    var display_target_id = elt_id + '-displaytarget';
    var state_clone = jQuery.extend(true, {}, microalg_fresh_state);
    EMULISP_CORE.init(state_clone);
    EMULISP_CORE.currentState().context = {display_div: display_target_id};
    editor_states[elt_id] = EMULISP_CORE.currentState();
    // Build the html and bind to ide_action.
    var script_container = $('#' + elt_id);
    var script_string = '<textarea id="' + elt_id + '-malg-editor" class="malg-editor" cols="80" rows="2" >' + msg + '</textarea>' +
            '<div class="malg-error" style="color: red;"></div>' +
            '<div id="' + display_target_id + '" class="malg-display">&nbsp;</div>';
    script_container.html(script_string);
    var editor = script_container.find('.malg-editor').first();
    // Load local storage in the editor.
    if (config.localStorage && typeof(Storage)!=="undefined") {
        var key = 'microalg_src_' + elt_id;
        if (localStorage[key]) {
            editor.val(localStorage[key]);
        }
    }
    createRichInput(editor);
    onCtrlEnter(editor, ide_action);
    function ide_action(editor_elt) {
        // Fetch the relevant state.
        EMULISP_CORE.init(editor_states[editor_elt.attr('id').slice(0, -('-malg-editor'.length))]);
        // Process src.
        var src = editor_elt.val();
        // createRichInput put the editor in a sub div, that's why we use
        // parent().parent()
        var error_elt = editor_elt.parent().parent().find('.malg-error').first();
        var display_elt = editor_elt.parent().parent().find('.malg-display').first();
        display_elt.html('&nbsp;');
        try {
            EMULISP_CORE.eval(src).toString();
            error_elt.text('');
        } catch(e) {
            error_elt.text(e.toString());
        }
        if (config.localStorage && typeof(Storage) !== "undefined") {
            localStorage[key] = src;
        }
    }
}

function inject_microalg_repl_in(elt_id, msg) {
    var malg_prompt = ": ";
    var repl_container = $('#' + elt_id);
    var repl_string = '<textarea id="malg-repl" class="malg-repl" rows="2" >' + malg_prompt + msg + '</textarea>';
    repl_container.html(repl_string);
    var repl = repl_container.find('.malg-repl').first();
    createRichInput(repl);
    onCtrlEnter(repl, repl_action);
    var old_src = malg_prompt;
    function repl_action(repl_elt) {
        var result = '';
        var repl_content = repl_elt.val();
        var src = repl_content.slice(old_src.length, repl_content.length);
        try {
            result = EMULISP_CORE.eval(src).toString();
        } catch(e) {
            if (e.toString() == "Error: Function 'bye' not supported") {
                repl_container.html('');
            } else {
                repl_elt.val(repl_elt.val() + "\n" + e.toString());
            }
        }
        if (result != '' && result != 'NIL') {
            repl_elt.val(repl_elt.val() + "\n-> " + result);
            $.modal('<div class="web-ide">' + result + '</div>',
                    {onClose: function (dialog) {$.modal.close();repl_elt.focus();}});
        }
        var stdout = EMULISP_CORE.currentState().iSym['*StdOut'].cdr.name;
        if (stdout != '' && stdout != 'NIL') {
            repl_elt.val(repl_elt.val() + "\n" + stdout);
        }
        repl_elt.val(repl_elt.val() + "\n" + malg_prompt);
        EMULISP_CORE.currentState().iSym['*StdOut'].cdr.name = '';
        old_src = repl_elt.val();
    }
}
