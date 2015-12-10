// Some defs.

// Use an existing jQuery (like in Dokuwiki).
if(typeof $ === "undefined") var $ = jQuery;

// Helpers to fetch the content of lisp source files.
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
var lisp_srcs = {};
function getLispSource(what) {
    if (typeof lisp_srcs[what] == 'undefined') {
        var file = {
        '0.3.17':     'microalg-0.3.17.l',
        'microalg':   'microalg.l',
        'export':     'microalg_export.l',
        'blockly':    'microalg_export_blockly.l',
        'casio':      'microalg_export_casio.l',
        'processing': 'microalg_export_processing.l',
        'ti':         'microalg_export_ti.l',
        'arbretxt':   'microalg_export_arbretxt.l',
        'arbresvg':   'microalg_export_arbresvg.l',
        'arbreninja': 'microalg_export_arbreninja.l'
        }[what];
        if (typeof file == 'undefined') {
            alert("Lisp file unavailable: " + what);
            return "";
        }
        lisp_srcs[what] = EMULISP_CORE.getFileSync(root_path + file);
    }
    return lisp_srcs[what];
}

// Better base 64 functions.
function mybtoa(x) {
    return btoa(unescape(encodeURIComponent(x)));
}
function myatob(x) {
    return decodeURIComponent(escape(window.atob(x)));
}

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
    if (typeof state.context == 'undefined') {
        console.log(text);
        return;
    }
    var target = $('#' + state.context.display_elt);
    var suffix_length = "-displaytarget".length;
    var root_id = state.context.display_elt.slice(0, -suffix_length);
    var output_type_id = root_id + '-output-type';
    var output_type = $('#' + output_type_id).val();
    text = cleanTransient(text);
    if (state.context.type == 'editor') {
        // Create or append to state.context.output.
        if (typeof state.context.output === "undefined") {
            state.context.output = text;
        } else {
            state.context.output += '\n' + text;
        }
        var output_as_html = '';
        switch (output_type) {
            case 'HTML':
                output_as_html = state.context.output;
                break;
            case 'MD':
                // Convert to HTML if Showdown available.
                output_as_html = new Showdown.converter()
                                     .makeHtml(state.context.output);
                break;
            case 'brut':
            default:
                output_as_html = state.context.output
                                   .replace(/[<>]/g,
                                     function (a) {
                                       return {'<': '&lt;', '>': '&gt;'}[a];
                                     })
                                   .replace(/\n/g, '<br>');
                output_as_html = '<pre class="brut">' + output_as_html + '</pre>';
        }
        target.html(output_as_html);
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
    var last_line_displayed = cleanTransient(EMULISP_CORE.eval('*LastStdOut').toString());
    if (last_line_displayed == "NIL") last_line_displayed = "?";
    var user_input = window.prompt(last_line_displayed, '');
    if (user_input !== null) return user_input;
    else throw new Error("Commande `Demander` annulée.")
}

function onCtrl(elt, f, config_64) {
    elt.keydown(function (e) {
        if (e.ctrlKey) {
            if (e.keyCode == 10 || e.keyCode == 13) {
                f(elt, config_64);
            } else if (e.keyCode == 66) {
                e.preventDefault();
                // Voir aussi dans editeurs/scite/malg_abbrev.properties.
                var abbrevs = {
                  "(Af":  "(Affecter_a |)",
                  "(Afe": "(Affecter_a | En_position )",
                  "(A":   "(Afficher |)",
                  "(Aj":  "(Ajouter_a |)",
                  "(Al":  "(!!! \"Algo |\")\n(!!! \"Fin algo \")",
                  "(At":  "(Afficher \"|\")",
                  "(Co":  "(Concatener |)",
                  "(D":   "(Definir |\n    \"...\"\n    \"...\"\n    (Retourner )\n)",
                  "(De":  "(Declarer | De_type \"\")",
                  "(Dm":  "(Demander)|",
                  "(E":   "(Exemples_de |\n    (Liste\n        (? )\n        (? )\n    )\n)",
                  "(E@":  "(Entie@ |)\n",
                  "(F":   "(Faire\n    (|)\n    ()\n Tant_que ()\n)",
                  "(I@":  "(Initialiser@ |)\n",
                  "(Li":  "(Liste |)",
                  "(Lo":  "(Longueur |)",
                  "(M":   "(Millisecondes)|",
                  "(Ni":  "(Nieme |)",
                  "(N@":  "(Nieme@ |)",
                  "(No":  "(Nombre |)",
                  "(R":   "(Repeter | Fois\n    ()\n)",
                  "(Rd":  "(Retirer_de |)",
                  "(Re":  "(Retourner |)",
                  "(Rp":  "(Repere |)",
                  "(S":   "(Si (|) Alors\n    ()\n)",
                  "(Ss":  "(Si (|)\n Alors ()\n Sinon ()\n)",
                  "(Te":  "(Tester |)",
                  "(Tq":  "(Tant_que (|)\n Faire\n    ()\n    ()\n)"
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

function ide_action(editor_elt, config_64) {
    // Compute the target HTML elt.
    var elt_id = editor_elt.attr('id').slice(0, -('-malg-editor'.length));
    var display_target_id = elt_id + '-displaytarget';
    var processing_id = elt_id + '-processing';
    // Decode config_64.
    var config = JSON.parse(myatob(config_64));
    // Init the state and load it with MicroAlg.
    EMULISP_CORE.init();
    var lisp_source = 'microalg';
    if (config.version === '0.3.17') lisp_source = '0.3.17';
    EMULISP_CORE.eval(getLispSource(lisp_source));
    // Custom state for a custom display in the page.
    EMULISP_CORE.currentState().context = {
        type: 'editor',
        display_elt: display_target_id,
        processing_elt: processing_id,
        };
    // Prepare the display areas:
    // The editor is in a hiddable div,
    // createRichInput put the editor in a sub div,
    // that's why we use parent().parent().parent()
    var error_elt = editor_elt.parent().parent().parent().find('.malg-error').first();
    var display_elt = editor_elt.parent().parent().parent().find('.malg-display').first();
    display_elt.html('&nbsp;');
    // Process pre src.
    var presrc = config.presrc || '';
    EMULISP_CORE.eval(presrc);
    // Process src.
    var src = editor_elt.val();
    try {
        error_elt.text('');
        EMULISP_CORE.eval(src);
    } catch(e) {
        var link = '<a target="_blank" href="http://microalg.info/doc.html#erreursfrquentes">Voir les erreurs fréquentes.</a>';
        var msg = e.message.replace('<', '&lt;');
        error_elt.html(msg + ' <span class="malg-freq-error">' + link + '</span>');
    }
    EMULISP_CORE.eval('(setq *LastStdOut "?")');
    if (config.localStorage && typeof(Storage) !== "undefined") {
        var key = 'microalg_src_' + elt_id;
        localStorage[key] = src;
    }
}

/* Inject an editor + display in the relevant element.

This is done injecting in the element identified by `elt_id` some html
according to `config` which may have these keys :

* `src` is a string defining the content displayed at first load,  
  empty if not provided,
* `version` is a string defining the version of microalg.l to load,
  currently only "0.3.17" is available and, if not set, the default will be
  the latest version of the microalg.l file,
* `localStorage` is a boolean telling to remember last program if possible,  
  false if not provided,
* `blockly` is a boolean telling to also display code as blocks,  
  false if not provided,
* `blockly_only` is a boolean telling to not display the textual editor but
  only blocks,  
  false if not provided,
* `processing` is a boolean telling to load processing.js in the page and
  to display a processing window,  
  false if not provided,

*/
function inject_microalg_editor_in(elt_id, config) {
    /* Some id suffix hacking. */
    var export_id = elt_id + '-export';
    var editor_id = elt_id + '-malg-editor';
    var display_target_id = elt_id + '-displaytarget';
    var output_type_id = elt_id + '-output-type';
    var blockly_id = elt_id + '-blockly';
    var processing_id = elt_id + '-processing';
    var src = '';
    var blockly_src = '';
    var config_64 = mybtoa(JSON.stringify(config));
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
        blockly_src = src.replace(/(\r\n|\n|\r)/gm, "")
        // On contre-échappe les backslashes car ce code sera inséré dans
        // une iframe.
                         .replace(/\\/g, "\\\\")
        // On échappe les ':
                         .replace("'", "\\'")
    }
    // Build the html and bind to ide_action.
    var script_container = $('#' + elt_id);
    var hidden = config.blockly_only ? ' style="display:none;"' : '';
    var link_snippet =
        '<div class="link-snippet">' +
        ((config.version === '0.3.17') ?
         '<strong>⚠</strong> MicroAlg 0.3.17 ':'') +
        '<select onchange="export_action(\'' + elt_id + '\', this);">' +
        '<option>exporter</option>' +
        '<option>Casio</option>' +
        '<option>TI</option>' +
        '<option>Processing</option>' +
        '<option>Arbre 1</option>' +
        '<option>Arbre 2</option>' +
        '<option>Arbre 3</option>' +
        '</select> ' +
        '<a target="_blank" title="Documentation" href="http://microalg.info/doc.html">doc</a> ' +
        '<a title="Lien vers cet extrait" href="#' + elt_id + '">∞</a></div>';
    var script_string =
        link_snippet +
        '<div id="' + export_id + '"></div>' +
        ((config.blockly || config.blockly_only) ? '<div id="' + blockly_id + '"></div>' : '') +
        '<div ' + hidden + '><textarea id="' + editor_id + '" ' +
                                      'class="tabIndent malg-editor" cols="80" rows="2"' +
                                      'spellcheck="false">' + src + '</textarea></div>' +
        '<select id="' + output_type_id + '" class="malg-output-type">' +
        '<option' + ((config.output == 'brut')?' selected':'') + '>brut</option>' +
        '<option' + ((config.output == 'HTML')?' selected':'') + '>HTML</option>' +
        ((typeof Showdown === 'undefined') ? '' : '<option' + ((config.output == 'MD')?' selected':'') + '>MD</option>') +
        '</select> ' +
        '<input type="button" value="OK" class="malg-ok-editor" ' +
                'onclick="ide_action($(\'#' + elt_id + '-malg-editor\'), ' +
                                     "'" + config_64 + "'" + ')" />' +
        '<div class="malg-error"></div>' +
        '<div id="' + display_target_id + '" class="malg-display">&nbsp;</div>' +
        ((config.autorun && !config.processing)?
          "<script>ide_action($('#" + editor_id + "'), '" + config_64 +"');</script>\n":
          "") +
        '';
    if (config.processing) {
        if (typeof Processing == "undefined") {
            script_string += '<script src="' + root_path + 'web/processing-1.4.15.min.js"></script>';
        }
        script_string = script_string +
        '<div style="text-align:center;">' +
        '    <canvas id="' + processing_id + '"' +
        '            class="malg-sketch"' +
        '            data-processing-sources="' + root_path + 'pde/microalg/microalg.pde">' +
        '    </canvas>' +
        '</div>' + "\n" +
        '<script>' + "\n" +
        '    if (typeof processing_sketches == "undefined") processing_sketches = {};' + "\n" +
        '    if (typeof processing_tIds == "undefined") processing_tIds = {};' + "\n" +
        '    processing_tIds["' + processing_id + '"] = 0;' + "\n" +
        '    $(document).ready(function() {' + "\n" +
        '        if (!processing_sketches["' + processing_id + '"]) {' + "\n" +
        '            processing_tIds["' + processing_id + '"] = setInterval(function() {' + "\n" +
        '                processing_sketches["' + processing_id + '"] = Processing.getInstanceById("' + processing_id + '");' + "\n" +
        '                if (processing_sketches["' + processing_id + '"]) {' + "\n" +
        '                    clearInterval(processing_tIds["' + processing_id + '"]);' + "\n" +
        (config.autorun?
          "ide_action($('#" + editor_id + "'), '" + config_64 +"');\n":
          "") +
        '                }' + "\n" +
        '            }, 500);' + "\n" +
        '        }' + "\n" +
        '    });' + "\n" +
        '</script>' + "\n";
    }
    script_container.html('<div class="microalg">' + script_string + '</div');
    if (config.blockly || config.blockly_only) {
        // Injection de HTML dans une iframe car besoin de plusieurs Blockly.
        // http://stackoverflow.com/questions/13214419/alternatives-to-iframe-srcdoc
        var toolbox_string =
                '<xml id="' + elt_id + '-toolbox" style="display: none">' +
                ' <category name="Valeurs">' +
                '  <block type="texte_litteral"></block>' +
                '  <block type="nombre_litteral"></block>' +
                '  <block type="variable"></block>' +
                '  <block type="valeur_utilisateur"></block>' +
                '  <block type="vrai"></block>' +
                '  <block type="faux"></block>' +
                '  <block type="liste"></block>' +
                '  <block type="rien"></block>' +
                '  <block type="credit_iterations"></block>' +
                '  <block type="sequence_tirages"></block>' +
                ' </category>' +
                ' <category name="Cmdes sans retour">' +
                '  <block type="commentaire"></block>' +
                '  <block type="afficher"></block>' +
                '  <block type="repeter"></block>' +
                '  <block type="si"></block>' +
                '  <block type="faire"></block>' +
                '  <block type="tant_que"></block>' +
                '  <block type="declarer"></block>' +
                '  <block type="affecter_a"></block>' +
                '  <block type="initialiser_pseudo_aleatoire"></block>' +
                ' </category>' +
                ' <category name="Cmdes avec retour">' +
                '  <block type="concatener"></block>' +
                '  <block type="demander"></block>' +
                '  <block type="demander_un_nombre"></block>' +
                '  <block type="operations"></block>' +
                '  <block type="comparaisons"></block>' +
                '  <block type="entier_pseudo_aleatoire"></block>' +
                '  <block type="longueur"></block>' +
                '  <block type="vide?"></block>' +
                '  <block type="nieme"></block>' +
                '  <block type="nieme@"></block>' +
                '  <block type="tete"></block>' +
                '  <block type="queue"></block>' +
                '  <block type="millisecondes"></block>' +
                ' </category>' +
                ' <category name="Types et conversions">' +
                '  <block type="type"></block>' +
                '  <block type="texte"></block>' +
                '  <block type="nombre"></block>' +
                ' </category>' +
                ' <category name="Opérat. logiques">' +
                '  <block type="et"></block>' +
                '  <block type="ou"></block>' +
                '  <block type="non"></block>' +
                ' </category>' +
                ' <category name="Cmdes graphiques">' +
                '  <block type="raz"></block>' +
                '  <block type="cercle"></block>' +
                '  <block type="ellipse"></block>' +
                '  <block type="rectangle"></block>' +
                '  <block type="triangle"></block>' +
                '  <block type="segment"></block>' +
                '  <block type="epaisseur"></block>' +
                '  <block type="contour-p"></block>' +
                '  <block type="contour"></block>' +
                '  <block type="contour-alpha"></block>' +
                '  <block type="remplissage-p"></block>' +
                '  <block type="remplissage"></block>' +
                '  <block type="remplissage-alpha"></block>' +
                '  <block type="repere"></block>' +
                '  <block type="repere_grad"></block>' +
                ' </category>' +
                ' <category name="Cmdes tortue">' +
                '  <block type="av"></block>' +
                '  <block type="td90"></block>' +
                '  <block type="td"></block>' +
                '  <block type="tg90"></block>' +
                '  <block type="tg"></block>' +
                '  <block type="bc"></block>' +
                '  <block type="lc"></block>' +
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
    onCtrl(editor, ide_action, config_64);
}

function export_action(elt_id, select) {
    if (typeof Processing !== "undefined" && Processing.instances.length > 0) {
        Processing.instances[0].exit();
    }
    if (select.selectedIndex == 0) {
        $('#' + elt_id + '-export').html('');
        select.options[0].innerHTML = "exporter";
    } else {
        var langs = [undefined, 'casio', 'ti', 'processing', 'arbretxt', 'arbresvg', 'arbreninja'];
        var lang = langs[select.selectedIndex];
        var src = $('#' + elt_id + '-malg-editor').val();
        var exported_src = malg2other(lang, src);
        var export_target = $('#' + elt_id + '-export');
        if (lang == 'arbresvg') {
            export_target.html($('<div/>', {id: elt_id + '-export-svg'}));
            var tree = new TreeDrawer(elt_id + '-export-svg',
                JSON.parse(exported_src));
            tree.root.extended = false;
            tree.draw();
        } else if (lang == 'processing') {
            export_target.html('');
            if (typeof Processing === "undefined") {
                var msg = "Erreur : Processing n’est pas activé pour l’échantillon.";
                export_target.html(msg);
                select.options[0].innerHTML = "pas d’export";
                return;
            }
            exported_src =
                  "void setup() {\n" +
                  "  size(600, 600);\n" +
                  "  background(255);\n" +
                  "  strokeWeight(1);\n" +
                  "  stroke(color(0, 0, 0));\n" +
                  "  fill(1, 0, 0, 0);\n" +
                  "  rectMode(CORNERS);\n" +
                  // TODO "  turtle = new Turtle();\n" +
                  "}\n" +
                  "void draw() {\n" +
                  "  // EXPORTÉ DEPUIS MicroAlg\n" +
                  exported_src.trim().split("\n")
                              .map(function (l) {return '  ' + l;})
                              .join("\n") + "\n" +
                  "}\n" +
                  "";
            var msg = "Notez que les procédures <code>setup</code> (où la " +
                      "taille est forcée à 600×600, entre autres choses) et " +
                      "<code>draw</code> (contenant l’export) ont été ajoutées.";
            var doc = $('<p/>', {html: msg});
            export_target.append(doc);
            var source = $('<div/>', {html: exported_src,
                                      class: 'malg-export'});
            export_target.append(source);
            var sketch = $('<script/>', {html: exported_src,
                                         type: "application/processing"});
            export_target.append(sketch);
            var canvas = $('<canvas/>', {class: "malg-sketch"});
            export_target.append(canvas);
            var reload = $('<script/>', {html: "Processing.reload();"});
            export_target.append(reload);
        } else {
            export_target.html($('<div/>', {html: exported_src,
                                            class: 'malg-export'}));
        }
        select.options[0].innerHTML = "pas d’export";
    }
}

function malg2other(lang, src) {
    EMULISP_CORE.init();
    EMULISP_CORE.eval(getLispSource('export'));
    EMULISP_CORE.eval(getLispSource(lang));
    if (lang == 'arbretxt') {
        var raw_tree = cleanTransient(EMULISP_CORE.eval('(arbretxt ' + src + ')').toString());
        var colored = raw_tree.replace(/([│├└─])/g,'<span class="malg-guide">$1</span>');
        return colored;
    } else if (lang == 'arbresvg') {
        var raw = EMULISP_CORE.eval('(arbresvg ' + src + ')').toString();
        var clean = cleanTransient(raw);
        var json_src = clean.replace(/&quot;/ig, '"');
        return json_src;
    } else if (lang == 'arbreninja') {
        var raw = EMULISP_CORE.eval('(arbreninja ' + src + ')').toString();
        var clean = cleanTransient(raw);
        return clean;
    } else {
        var source_protegee = EMULISP_CORE.eval("(proteger_source  " + src + ")").toString();
        // On récupère une liste d’instructions.
        var source_preparee = '(pack ' + source_protegee.slice(1, -1) + ')';
        var exported_src = '';
        try {
            exported_src = cleanTransient(EMULISP_CORE.eval(source_preparee).toString());
        } catch(e) {
            var prefix = "Error: ";
            var suffix = " -- Undefined";
            var msg = e.toString();
            if (msg.slice(0, prefix.length) === prefix &&
                msg.slice(-suffix.length) === suffix) {
                var cmd = msg.slice(prefix.length, -suffix.length);
                exported_src = "Impossible d’exporter " +
                               "à cause de l’appel à la commande " +
                               cmd + " (définie dans le programme).";
            } else {
                exported_src = msg;
            }
        }
        EMULISP_CORE.init();
        EMULISP_CORE.eval(getLispSource('microalg'));
        return exported_src;
    }
}

function repl_action(repl_elt) {
    // Fetch the relevant state.
    EMULISP_CORE.init(emulisp_states[repl_elt.attr('id')]);
    var result;
    var repl_content = repl_elt.val();
    var src = repl_content.slice(EMULISP_CORE.currentState().old_src.length,
                                 repl_content.length);
    try {
        result = EMULISP_CORE.eval(src).toString();
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
    EMULISP_CORE.eval(getLispSource('microalg'));
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
    onCtrl(repl, repl_action, null);
    EMULISP_CORE.currentState().old_src = malg_prompt;
}

function inject_microalg_jrepl_in(elt_id, msg) {
    $('#' + elt_id).terminal(function(command, term) {
        if (command !== '') {
            // Fetch the relevant state.
            EMULISP_CORE.init(emulisp_states[elt_id]);
            try {
                var result = EMULISP_CORE.eval(command).toString();
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
            EMULISP_CORE.eval(getLispSource('microalg'));
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
    EMULISP_CORE.eval(getLispSource('export'));

    var source_protegee = EMULISP_CORE.eval("(proteger_source  " + src + ")").toString();
    EMULISP_CORE.eval(getLispSource('blockly'));
    var avec_des_next = EMULISP_CORE.eval("(insertion_next '" + source_protegee + ")").toString();
    // Le car pour récupérer l’unique élément de la liste finale.
    var xml = EMULISP_CORE.eval('(pack (car ' + avec_des_next + ')').toString();
    xml = '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="programme"><value name="VALUE">' +
          xml.slice(1,-1).replace(/\\"/g, '"') +
          '</value></block></xml>';
    EMULISP_CORE.init();
    EMULISP_CORE.eval(getLispSource('microalg'));
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
