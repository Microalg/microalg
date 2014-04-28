function onCtrlEnter(elt, f) {
    elt.keydown(function (e) {
        if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
            f(elt);
        }
    });
}

function inject_microalg_editor_in(selector, msg) {
    var script_container = $(selector);
    var script_string = '<textarea id="malg-editor" class="malg-editor" cols="80" rows="5" >' + msg + '</textarea>' +
            '<div class="malg-error" style="color: red;"></div>' +
            '<div class="malg-display">&nbsp;</div>';
    script_container.html(script_string);
    var editor = script_container.find('.malg-editor').first();
    // Load local storage in the editor.
    if (typeof(Storage)!=="undefined") {
        if (localStorage.microalg_src) {
            editor.val(localStorage.microalg_src);
        } else {
            editor.val('(Afficher "MicroAlg FTW!")');
        }
    }
    createRichInput(editor);
    onCtrlEnter(editor, ide_action);
    function ide_action(editor_elt) {
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
        var stdout = EMULISP_CORE.currentState().iSym['*StdOut'].cdr.name;
        if (stdout == '') {
            stdout = '&nbsp;';
        }
        display_elt.html(stdout);
        EMULISP_CORE.currentState().iSym['*StdOut'].cdr.name = '';
        localStorage.microalg_src = src;
    }
}

function inject_microalg_repl_in(selector, msg) {
    var malg_prompt = ": ";
    var repl_container = $(selector);
    var repl_string = '<textarea id="malg-repl" class="malg-repl" rows="5" >' + malg_prompt + msg + '</textarea>';
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
            repl_elt.val(repl_elt.val() + "\n" + e.toString());
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
