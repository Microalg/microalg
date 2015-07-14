// http://stackoverflow.com/questions/14043727/auto-resizing-textarea-is-bumpy-highlighting-parentheses
// http://jsfiddle.net/ACF8e/

function getDefaultFontSize(pa){
     pa = pa || document.body;
     var who= document.createElement('span');
     who.className= 'defaultEm';
     who.appendChild(document.createTextNode('M'));
     pa.appendChild(who);
     var fs= [who.offsetWidth, who.offsetHeight];
     pa.removeChild(who);
     return fs;
}
// Elt in parameter needs an id.
function createRichInput(original) {
    if (typeof original == "string") original = $(original);
    var original_id = original.attr('id');
    if (typeof original_id == "undefined") {
        console.log("parenedit: elt with no id!");
        console.log(original);
    }
    var newId = "richtext-" + original_id;
    var newElement = "<div class=\"richtext\" id=\"" + newId + "\"></div>";

    newId = '#' + newId;

    var width = original.width();
    var height = original.height();

    original.wrap(newElement);
    original.before("<pre></pre>");

    $(newId).width(width).css("min-height", height);
    $(newId + '> pre').width(width).css("min-height", height);

    original.css({
        'background': 'transparent',
        'position': 'absolute',
        'z-index': 98,
        'width': width
    });

    fresh = true;
    original.bind('propertychange keydown keyup input paste click', function(e) {
        var code = (e.keyCode ? e.keyCode : e.which);
        var text = original.val();
        if (code == 13) text += '<br>';
        $(newId + " pre").html(colorize(text, original.getCursorPosition()));

        var newHeight = $(newId + " pre").height() + getDefaultFontSize()[1]; //adding a height of line
        $(this).height(newHeight);
        $(newId).height(newHeight);
    });
    original.trigger(jQuery.Event("keydown"));
    fresh = false;
}

function colorize(text, pos) {
    var i = 0, current_times = 0;
    var startc = '(', endc = ')';
    var current = -1;

    var entities = {'>': '&gt;','<':'&lt;'};
    var p2 = 0;
    var regex = new RegExp(Object.keys(entities).join("|"),'g');
    var converted = text.replace(regex, function(x, j) {
        if(pos > j) p2 += entities[x].length - 1;
        return entities[x];
    });

    pos += p2;
    var parens = [], indices = [], o = {};
    var newText = converted.replace(/((?:\\)*)([()])/g, function(full, escape, x, idx) {
        var len = escape.split(/\\/g).length - 1;
        if (len % 2 == 0) {
            indices.push(idx);
            if (x == startc) ++i;
            o[idx] = { selected: false, type: x, depth: i, idx: idx, pair: -1, extra: escape };
            if (idx == pos && !fresh) o[idx].selected = true;
            if (x == startc) parens.push(idx);
            else {
                if (parens.length > 0) {
                    var p = parens.pop();
                    o[idx].pair = p;
                    if (o[p].selected && !fresh) o[idx].selected = true;
                    o[p].pair = idx;
                    if (o[idx].selected && !fresh) o[p].selected = true;
                }
                --i
            }
        }
    });
    newtext = converted;
    indices = indices.sort(function(x,y) { return Number(y) - Number(x); });
    indices.forEach(function(i) {
        newtext = newtext.substr(0,i) + o[i].extra +
        "<span class='" + (o[i].pair == -1 ? "unmatched " : "paren_" + (o[i].depth % 7)) +
        (o[i].selected ? " selected_paren": "") + "'>" + o[i].type + "</span>" +
        newtext.substr(i + 1 + o[i].extra.length)
    });
    newtext = newtext.replace(
        // First parens prevent catching html attributes. The rest is from
        // http://stackoverflow.com/questions/249791/regex-for-quoted-string-with-escaping-quotes#answer-249937
        /([^=])(")((?:[^"\\]|\\.)*)(")/g,
        function(match, prev, q1, txt, q2) {
            return prev + q1 + '<span class="text">' + txt + '</span>' + q2;
        });
    return newtext;
}

(function($) {
    $.fn.getCursorPosition = function() {
        var input = this.get(0);
        if (!input) return; // No (input) element found
        if ('selectionStart' in input) {
            // Standard-compliant browsers
            return input.selectionStart;
        } else if (document.selection) {
            // IE
            input.focus();
            var sel = document.selection.createRange();
            var selLen = document.selection.createRange().text.length;
            sel.moveStart('character', -input.value.length);
            return sel.text.length - selLen;
        }
    }
})(jQuery);

