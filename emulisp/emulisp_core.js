/* 12feb14jk
 * (c) Jon Kleiser
 */

var EMULISP_CORE = (function () {

var VERSION = [2, 0, 0, 1],
	BOXNAT_EXP = "Boxed native object expected",
	BOOL_EXP = "Boolean expected", CELL_EXP = "Cell expected", LIST_EXP = "List expected",
	NUM_EXP = "Number expected", SYM_EXP = "Symbol expected", VAR_EXP = "Variable expected",
	EXEC_OR_NUM_EXP = "Executable or Number expected",
	BAD_ARG = "Bad argument", BAD_DOT = "Bad dotted pair", BAD_INPUT = "Bad input", DIV_0 = "Div/0",
	NOT_MAK = "Not making", PROT_SYM = "Protected symbol", UNDEF = "Undefined",
	JS_CTORNAME_EXP = "Constructor name expected", JS_RESERVED = "Reserved word";

function getFileSync(fileUrl) {
	var req = new XMLHttpRequest();
	var OK = fileUrl.match(/^https?:/) ? 200 : 0;
	req.open("GET", fileUrl, false);		// synchronous
	req.overrideMimeType("text/plain; charset=utf-8");
	req.send(null);
	if (req.status == OK) {
		return req.responseText;
	}
	throw new Error("XMLHttpRequest status: " + req.status);
}

var NILTYPE = 0, NUMBERTYPE = 1, SYMBOLTYPE = 2, CELLTYPE = 3, TRUETYPE = 4;

Number.prototype.TYPEVAL = NUMBERTYPE;

function lispToStr(x) {
	//if (!confirm("lispToStr: " + x.toString() + ", " + x.TYPEVAL)) throw new Error("lispToStr aborted");
	return x.toString();
}

function unknown(x) {
	if (!confirm("Unknown Lisp type: " + x)) throw new Error("unknown aborted");
	return "???";
}

function valueToStr(x) {
	//if (!confirm("valueToStr " + lispToStr(x))) throw new Error("valueToStr aborted");
	return (x instanceof Number) ? x.toString() :
		(x instanceof Symbol) ? x.toValueString() :
		(x instanceof Cell) ? x.toValueString() : unknown(x);
}

function Cell(car, cdr) {
	this.car = car;
	this.cdr = cdr;
}

Cell.prototype.TYPEVAL = CELLTYPE;

Cell.prototype.getVal = function() {
	return this.car;
}

Cell.prototype.setVal = function(val) {
	this.car = val;
}

Cell.prototype.toString = function() {
	if (this.car === QUOTE) return "'" + lispToStr(this.cdr);
	var arr = [], c = this;
	do {
		arr.push(lispToStr(c.car));
		c = c.cdr;
		//if (!confirm("Cell.toString: " + lispToStr(c.car))) throw new Error("Cell.toString aborted");
		if (c === this) { arr.push("."); c = NIL; }	// why didn't break work here?
	} while (c instanceof Cell);
	if (c !== NIL) {
		arr.push(".", lispToStr(c));	// last Cell was dotted
	}
	return "(" + arr.join(" ") + ")";
}

Cell.prototype.toValueString = function() {
	var str = "", c = this;
	do {
		str += valueToStr(c.car);
		c = c.cdr;
	} while (c instanceof Cell);
	if (c !== NIL) {
		str += valueToStr(c);	// last Cell was dotted
	}
	return str;
}

function Symbol(name, val) {
	this.name = name;
	this.trans = false;
	this.cdr = (val === undefined) ? NIL : val;
	this.props = NIL;
}

function newTransSymbol(name) {
	var ts = new Symbol(name);
	ts.trans = true;
	ts.cdr = ts;
	return ts;
}

// Creates and returns a new anonymous symbol
function box(val) {
	var ts = new Symbol(null, val);
	ts.trans = true;
	return ts;
}

Symbol.prototype.TYPEVAL = SYMBOLTYPE;

Symbol.prototype.getVal = function() {
	return this.cdr;
}

Symbol.prototype.valueOf = function() {
	return this.name;
}

Symbol.prototype.setVal = function(val) {
	if (this.lock) throw new Error(newErrMsg(PROT_SYM, this));
	this.cdr = val;
}

// Internal symbol names can consist of any printable (non-whitespace) character,
// except for the following meta characters:		" ' ( ) , [ ] ` ~ { }
// It is possible, though, to include these special characters into symbol names
// by escaping them with a backslash '\'.
Symbol.prototype.escName = function() {
	var eName = this.name.replace(/\\/g, "\\\\");
	eName = eName.replace(/\^/g, "\\^");
	eName = eName.replace(/\t/g, "^I");
	eName = eName.replace(/\r/g, "^M");
	eName = eName.replace(/\n/g, "^J");
	//if (eName != this.name) alert("Symbol.escName: " + this.name + " -> " + eName);
	return eName;
}

Symbol.prototype.noName = function() {
	return (this.obj !== undefined) ? "$" + typeof this.obj : "$*";
}

Symbol.prototype.toString = function() {
	return this.trans ? (this.name != null) ? ('"' + this.escName() + '"') : this.noName() : this.name;
}

Symbol.prototype.toValueString = function() {
	return (this === NIL) ? "" : (this.name != null) ? this.name : this.noName();
}

Symbol.prototype.pushValue = function(val) {
	if (this.stack === undefined) this.stack = [];
	this.stack.push(this.cdr);
	this.cdr = val;
}

Symbol.prototype.popValue = function() {
	var pv = this.cdr;
	this.cdr = this.stack.pop();
	//if (this.stack.length === 0) delete this.stack;
	return pv;
}

function getSymbol(name, editMode) {
	if (name in gEmptyObj) throw new Error(newErrMsg(JS_RESERVED, name));
	var s = cst.iSym[name];
	if (s === undefined) {
		s = new Symbol(name, NIL);
		if (! editMode) cst.iSym[name] = s;
	}
	return s;
}

function setSymbolValue(s, val) {
	if (!(s instanceof Symbol)) throw new Error(newErrMsg(VAR_EXP, s));
	s.setVal(val);
}

function Source(text, chars) {
	this.src = text;
	// character limitation for symbols
	if (chars instanceof Symbol) {
		this.charset = chars.valueOf();
	} else if (typeof chars == "string") {
		//alert("Source2: " + chars);
		this.charset = chars;
	}
	this.pos = 0;
	this.trace = null;
}

Source.prototype.CLOSEPAREN = -1;
Source.prototype.CLOSESYM = -2;
Source.prototype.QUOTE2 = -3;
Source.prototype.EOF = null;

Source.prototype.unescMap = {I: "\t", i: "\t", J: "\n", j: "\n", M: "\r", m: "\r"};

Source.prototype.getNextSignificantChar = function() {
	while (this.pos < this.src.length) {
		while (this.src.charAt(this.pos) == "#") {
			var ch;
			do { ch = this.src.charAt(this.pos++); } while ((ch != "\n") && (this.pos < this.src.length));
		}
		if (this.src.charAt(this.pos) == "\\") this.pos++;
		if (" \t\r\n".indexOf(this.src.charAt(this.pos)) == -1) return this.src.charAt(this.pos++);
		this.pos++;
	}
	return this.EOF;
}

Source.prototype.getNextStringChar = function() {
	while (this.pos < this.src.length) {
		var ch = this.src.charAt(this.pos++);
		if (ch == "\"") return this.QUOTE2;
		if (ch == "\\") return this.src.charAt(this.pos++);
		if (ch != "^") return ch;
		ch = this.unescMap[this.src.charAt(this.pos++)];
		if (ch != null) return ch;
	}
	return this.EOF;
}

Source.prototype.getNextSymbolChar = function() {
	if (" \t\r\n('\"".indexOf(this.src.charAt(this.pos)) >= 0) return this.CLOSESYM;
	var ch = this.src.charAt(this.pos++);
	if (ch == ")") return this.CLOSEPAREN;
	if (ch == "\\") return this.src.charAt(this.pos++);
	return ch;
}

Source.prototype.withTrace = function() {
	this.trace = [];
	return this;
}

Source.prototype.traceItemEnd = function(item) {
	if (this.trace) this.trace.push({item: item, endPos: this.pos});
}

Source.prototype.getItemBeforePos = function(endPos) {
	for (var i=this.trace.length-1; i>=0; i--) {
		var t = this.trace[i];
		if ((t.endPos - t.item.toString().length) <= endPos) return {item: t.item, tInd: i};
	}
	return null;
}

Source.prototype.getSymbolBeforePos = function(endPos) {
	for (var i=this.trace.length-1; i>=0; i--) {
		var t = this.trace[i];
		if (((t.endPos - t.item.toString().length) <= endPos) &&
			(t.item instanceof Symbol) && cst.iSym[t.item.name]) return {item: t.item, tInd: i};
	}
	return null;
}

var NIL = new Symbol("NIL");	NIL.car = NIL;	NIL.cdr = NIL;	NIL.props = NIL;
		NIL.lock = true; NIL.TYPEVAL = NILTYPE; NIL.bool = false;
var T = new Symbol("T");	T.cdr = T;	T.lock = true; T.TYPEVAL = TRUETYPE; T.bool = true;
var A1 = new Symbol("@", NIL), A2 = new Symbol("@@", NIL), A3 = new Symbol("@@@", NIL);
var ZERO = new Number(0), ONE = new Number(1);
var gEmptyObj = {};
var cst, QUOTE;

function prepareNewState(optionalState) {
	cst = optionalState || {
		iSym: internalSymbolsInclPrimitives(),
		tSym: {},	// dictionary/index for transient symbols (strings)
		parseCache: {},
		mk: [],	// 'make' stack
		compExprArr: [],	// sort expression stack
		evFrames: NIL,
		trcIndent: "",
		startupMillis: (new Date()).getTime()
	};
	QUOTE = getSymbol("quote");
}

//var gSym = {NIL: NIL, T: T, "@": A1, "@@": A2, "@@@": A3};	// dictionary/index for internal symbols
//var gTrans = {};	// dictionary/index for transient symbols (strings)
//var gParseCache = {};
//var mk = [];	// 'make' stack
//var evFrames = NIL;
//var gTrcIndent = "";
//var startupMillis = (new Date()).getTime();

function mkNew() { cst.mk.unshift({h: NIL, t: NIL}); }
function linkc(c) {
	if (cst.mk.length === 0) throw new Error(newErrMsg(NOT_MAK));
	c = (c !== NIL) ? evalArgs(c) : new Cell(NIL, NIL);
	if (cst.mk[0].h === NIL) { cst.mk[0].h = c; } else { cst.mk[0].t.cdr = c; }
	while (c.cdr !== NIL) { c = c.cdr; }; cst.mk[0].t = c; return c.car;
}
function link(x) {
	if (cst.mk.length === 0) throw new Error(newErrMsg(NOT_MAK));
	var c = new Cell(x, NIL);
	if (cst.mk[0].h === NIL) { cst.mk[0].h = c; } else { cst.mk[0].t.cdr = c; }
	cst.mk[0].t = c; return x;
}
function mkResult() { return cst.mk.shift().h; }

function getString(str, editMode) {
	var s = (str in gEmptyObj) ? undefined : cst.tSym[str];
	if (s === undefined) {
		s = newTransSymbol(str);
		if (! (editMode || (str in gEmptyObj))) cst.tSym[str] = s;
	}
	return s;
}

function newErrMsg(msg, badValue) {
	getSymbol("*Msg").setVal(newTransSymbol(msg));
	return (badValue === undefined) ? msg : lispToStr(badValue) + " -- " + msg;
}

function aTrue(val) { if (val !== NIL) { A1.pushValue(val); return true; } else return false; }

function aPop(val) { A1.popValue(); return val; }

function car(c) { if (c.car) return c.car; else throw new Error(newErrMsg(LIST_EXP)); }
function cdr(c) { if ((c instanceof Cell) || (c === NIL)) return c.cdr;
						else throw new Error(newErrMsg(LIST_EXP)); }

function numeric(val) {
	if (val instanceof Number) return val;
	throw new Error(newErrMsg(NUM_EXP, val));
}

function nth(lst, n) {
	if (lst instanceof Cell) {
		if (n <= 0) return NIL;
		while ((lst !== NIL) && (--n > 0)) { lst = lst.cdr; }
	}
	return lst;
}

function getAlg(c) {
	//alert("getAlg: " + lispToStr(c));
	var s = c.car; c = c.cdr;
	while (c instanceof Cell) {
		var k = c.car;
		if (s instanceof Symbol) {
			if (eqVal(k, ZERO)) {
				s = s.getVal();
			} else {
				var pLst = s.props, p = NIL, pk, pv;
				while (pLst !== NIL) {
					var pc = pLst.car;
					if (pc instanceof Cell) { pk = pc.cdr; pv = pc.car; } else { pk = pc; pv = T; }
//if (!confirm("getAlg: " + lispToStr(pc) + ", " + lispToStr(pk) + ", " + lispToStr(pv))) throw new Error("getAlg aborted");
					if (pk === k) { p = pv; break; }
					pLst = pLst.cdr;
				}
				s = p;	// the symbol or list to use in the next step
			}
		} else if (s instanceof Cell) {
			if (k instanceof Number) {
				if (k >= 0) {
					s = nth(s, k).car;
				} else {
					do { s = s.cdr; } while ((s !== NIL) && (++k < 0));
				}
			}
		} else throw new Error(newErrMsg(SYM_EXP));
		c = c.cdr;
	}
	return s;
}

function prog(c) {
	var v = NIL; while (c instanceof Cell) { v = evalLisp(c.car); c = c.cdr; }; return v;
}

function iter(c) {
	var v = NIL;
	while (c instanceof Cell) {
		var cv = c.car, cond = false, cMatch = false;
		if (cv instanceof Cell) {
			if (cond = (cv.car === NIL)) {
				cMatch = (evalLisp(cv.cdr.car) === NIL);
			} else if (cond = (cv.car === T)) {
				cMatch = aTrue(evalLisp(cv.cdr.car));
			}
		}
		if (cond) {
			if (cMatch) {
				v = prog(cv.cdr.cdr);
				if (cv.car === T) aPop(v);
				return {v: v, m: true};
			}
		} else v = evalLisp(cv);
		c = c.cdr;
	}
	return {v: v, m: false};
}

function div(c, divFn) {
	var t = evalLisp(c.car);
	if (t === NIL) return NIL;
	t = numeric(t);
	while (c.cdr !== NIL) {
		c = c.cdr;
		var v = evalLisp(c.car); if (v === NIL) return NIL;
		if (numeric(v) == 0) throw new Error(newErrMsg(DIV_0));
		t = divFn(t, v);
	}
	return new Number(t);
}

function eqVal(a, b) {
	//alert("eqVal() " + a + ", " + b);
	if (a.TYPEVAL === b.TYPEVAL) {
		if (a === b) return true;
		if (a.TYPEVAL === CELLTYPE) {
			return eqVal(a.car, b.car) ? eqVal(a.cdr, b.cdr) : false;
		}
		return (a.valueOf() == b.valueOf());	// Number or Symbol
	}
	return false;
}

function ltVal(a, b) {
	if (a.TYPEVAL === b.TYPEVAL) {
		if (a === b) return false;
		if (a.TYPEVAL === CELLTYPE) {
			return eqVal(a.car, b.car) ? ltVal(a.cdr, b.cdr) : ltVal(a.car, b.car);
		}
		return a.valueOf() < b.valueOf();	// Number or Symbol
	}
	return a.TYPEVAL < b.TYPEVAL;
}

function idxLookup(owner, v) {
	var tree = owner.getVal();
	if (tree === NIL) return NIL;
	while (!eqVal(v, tree.car)) {
		if (tree.cdr === NIL) return NIL;
		if (ltVal(v, tree.car)) return idxLookup(tree.cdr, v);
		tree = tree.cdr;
		if (tree.cdr === NIL) return NIL;
		tree = tree.cdr;
	}
	return tree;
}

function idxInsert(owner, v) {
	var tree = owner.getVal();
	if (tree === NIL) { owner.setVal(new Cell(v, NIL)); return NIL; }
	while (!eqVal(v, tree.car)) {
		if (tree.cdr === NIL) tree.cdr = new Cell(NIL, NIL);
		if (ltVal(v, tree.car)) return idxInsert(tree.cdr, v);
		tree = tree.cdr;
		if (tree.cdr === NIL) { tree.cdr = new Cell(v, NIL); return NIL; }
		tree = tree.cdr;
		//if (!confirm("idxInsert: " + lispToStr(tree))) throw new Error("idxInsert aborted");
	}
	return tree;
}

function idxDelete(owner, v) {
	var tree = owner.getVal(), pre = NIL;
	if (tree === NIL) return NIL;
	while (!eqVal(v, tree.car)) {
		if (tree.cdr === NIL) return NIL;
		if (ltVal(v, tree.car)) return idxDelete(tree.cdr, v);
		pre = tree; tree = tree.cdr;
		if (tree.cdr === NIL) return NIL;
		pre = tree; tree = tree.cdr;
		//if (!confirm("idxDelete: " + lispToStr(tree))) throw new Error("idxDelete aborted");
	}
	// tree.car is the value to delete
	//var bbc = null;		// cell with "big brother" to replace tree.car, if needed
	if (tree.cdr.car !== NIL) {
		// There are lesser values that need a new "big brother".
		if (tree.cdr.cdr !== NIL) {
			var pbc = tree.cdr, bbc = pbc.cdr;
			if (bbc.cdr.car !== NIL) {
				// There are several "big brother" candidates, get the smallest ...
				do { pbc = bbc; bbc = bbc.cdr.car; } while (bbc.cdr.car !== NIL);
				pbc.cdr.car = NIL;	// brother's old cell replaced by NIL
			} else {
				// Only one candidate. Cut it and following NIL from list ...
				pbc.cdr = pbc.cdr.cdr.cdr;
			}
			//alert("idxDelete: " + lispToStr(bbc));
			tree.car = bbc.car;	// value to delete replaced by "big brother"
		} else {
			// Must promote lesser values
			if (pre === NIL) {
				owner.setVal(tree.cdr.car);
			} else {
				pre.cdr = tree.cdr.car;
			}
		}
	} else {
		// No lesser values following value to delete
		if (pre === NIL) {
			owner.setVal(tree.cdr.cdr);
		} else {
			pre.cdr = tree.cdr.cdr;
		}
	}
	return tree;
}

function idxLinkSorted(tree) {
	while (tree !== NIL)
	{ idxLinkSorted(tree.cdr.car); link(tree.car); tree = tree.cdr.cdr; }
}

/*
 * If 'evaluate' is true, each top level expression will be evaluated, and the result
 * of the last evaluation ('evRes') will be returned. A top level NIL or equivalent
 * will terminate further parsing.
 * If 'evaluate' is false/undefined, the source at the current level will be parsed,
 * and a corresponding tree of cells will be returned (through the 'cdr' at the bottom).
 * If 'editMode' is true, parsed symbols will not be inserted into the dictionaries.
 */
function parseList(src, evaluate, editMode) {
	var ch, s, dotPos = 0, quotes = 0, items = [], cdr = NIL, evRes = NIL, circEnd = null;
	do {
		ch = src.getNextSignificantChar();
		if (ch == "'") {
			quotes++;
		} else if (ch == ")") {
			break;
		} else if ((ch == ".") && (items.length > 0)) {
			if (dotPos > 0) throw new Error(newErrMsg(BAD_DOT,
												"(" + lispToStr(items[items.length-1]) + " . \\.)"));
			dotPos = items.length;
		} else if (ch !== src.EOF) {
			var item;
			if (ch == "(") {
				var tmp = parseList(src, false, editMode);
				if (evaluate && (tmp !== NIL)) evRes = evalLisp(tmp);
				item = tmp;
			} else if (ch == "\"") {
				s = "";
				while (typeof (ch = src.getNextStringChar()) == "string") s += ch;
				item = (s == "") ? NIL : getString(s, editMode);
				src.traceItemEnd(item);		// in case we would like to know item's position
			} else {
				s = ch;
				while (typeof (ch = src.getNextSymbolChar()) == "string") s += ch;
				item = isNaN(s) ? getSymbol(s, editMode) : new Number(s);
				src.traceItemEnd(item);		// in case we would like to know item's position
			}
			if (evaluate && (item === NIL)) return evRes;
			if ((dotPos > 0) && (items.length > dotPos)) throw new Error(newErrMsg(BAD_DOT));
			// TODO: provide a 'badValue' param for newErrMsg(BAD_DOT) above. Case: (1 (2 3) . 4 5)
			while (quotes > 0) { item = new Cell(QUOTE, item); quotes--; }
			items.push(item);
		}
	} while ((ch !== src.CLOSEPAREN) && (ch !== src.EOF));
	if (evaluate) return evRes;
	if (dotPos > 0) {
		if (dotPos == items.length) {
			cdr = new Cell(items.pop(), cdr);
			circEnd = cdr;		// last cell in circular (x y z .) notation
		} else { cdr = items.pop(); }	// normal dot notation
	}
	while (items.length > 0) cdr = new Cell(items.pop(), cdr);
	if (circEnd != null) circEnd.cdr = cdr;
	return cdr;
}

function cachedTextParse(str) {
	var lst = cst.parseCache[str];
	if (lst === undefined) {
		lst = parseList(new Source(str));
		cst.parseCache[str] = lst;
	}
	return lst;
}

function unevalArgs(lst) {
	// Putting elements of lst into anonymous symbols
	mkNew(); while (lst !== NIL) { link(box(lst.car)); lst = lst.cdr; }
	return mkResult();
}

function applyFn(rawFn, lst, more) {
	if (more !== NIL) {
		mkNew(); do { link(evalLisp(more.car)); more = more.cdr; } while (more !== NIL);
		cst.mk[0].t.cdr = lst; lst = mkResult();
	}
	var fn = evalLisp(rawFn); if (! (fn instanceof Symbol)) fn = box(fn);
	return evalLisp(new Cell(fn, unevalArgs(lst)));
}

function printx(c, x) { var arr = [];
	c = evalArgs(c); arr.push(lispToStr(c.car));
	while (c.cdr !== NIL) { c = c.cdr; arr.push(lispToStr(c.car)); }
	_stdPrint(arr.join(" ") + x); return c.car;
}

function ascending(a, b) { return ltVal(a, b) ? -1 : eqVal(a, b) ? 0 : 1; }
//function descending(a, b) { return ltVal(a, b) ? 1 : eqVal(a, b) ? 0 : -1; }

function CompExpr(fn) {
	if (! (fn instanceof Symbol)) fn = box(fn);
	this.arg1Sym = box(NIL);
	this.arg2Sym = box(NIL);
	this.expr = new Cell(fn, new Cell(this.arg1Sym, new Cell(this.arg2Sym, NIL)));
}

CompExpr.prototype.evalTrue = function(a, b) {
	this.arg1Sym.cdr = a;	// faster than this.arg1Sym.setVal(a);
	this.arg2Sym.cdr = b;
	return (evalLisp(this.expr) === T);
}

function lispFnOrder(a, b) { return cst.compExprArr[0].evalTrue(a, b) ? -1 : 1; }

var coreFunctions = {
	"apply": function(c) { return applyFn(c.car, evalLisp(c.cdr.car), c.cdr.cdr); },
	"arg": function(c) { var n = 0, f = cst.evFrames.car;
		if (c !== NIL) {
			n = Math.round(numeric(evalLisp(c.car))); if (n < 1) return NIL;
		}
		while (n-- > 0) f = f.cdr;
		return f.car;
	},
	"args": function(c) { return (cst.evFrames.car.cdr === NIL) ? NIL : T; },
	"bench": function(c) { var t0 = (new Date()).getTime(), r = prog(c);
		_stdPrint(((new Date()).getTime() - t0) / 1000 + " sec\n"); return r;
	},
	"box": function(c) { return box(evalLisp(c.car)); },
	"caar": function(c) { return car(car(evalLisp(c.car))); },
	"caddr": function(c) { return car(cdr(cdr(evalLisp(c.car)))); },
	"cadr": function(c) { return car(cdr(evalLisp(c.car))); },
	"car": function(c) { return car(evalLisp(c.car)); },
	"cdar": function(c) { return cdr(car(evalLisp(c.car))); },
	"cddr": function(c) { return cdr(cdr(evalLisp(c.car))); },
	"cdr": function(c) { return cdr(evalLisp(c.car)); },
	"chop": function(c) { var cv = evalLisp(c.car);
		if ((cv === NIL) || (cv instanceof Cell)) return cv;
		var s = (cv instanceof Symbol) ? cv.valueOf() : cv.toString();
		if (s === null) return NIL;
		var arr = s.split(""), v = NIL;
		while (arr.length > 0) v = new Cell(newTransSymbol(arr.pop()), v);
		return v;
	},
	"cond": function(c) {
		while (c.car instanceof Cell) {
			if (aTrue(evalLisp(c.car.car))) return aPop(prog(c.car.cdr));
			c = c.cdr;
		}
		return NIL;
	},
	"cons": function(c) { var r = new Cell(evalLisp(c.car), evalLisp(c.cdr.car)), t = r;
		c = c.cdr.cdr;
		while (c !== NIL) { var d = new Cell(t.cdr, evalLisp(c.car)); t.cdr = d; t = d; c = c.cdr; }
		return r;
	},
	"de": function(c) { var old = c.car.getVal();
		setSymbolValue(c.car, c.cdr);
		if ((old !== NIL) && !eqVal(c.cdr, old)) _warn("# " + c.car.valueOf() + " redefined");
		return c.car;
	},
	"dec": function(c) {
		if (c === NIL) return NIL;
		var ns = evalLisp(c.car);
		if (ns instanceof Number) return new Number(ns - 1);
		var v = new Number(ns.getVal() - ((c.cdr !== NIL) ? numeric(evalLisp(c.cdr.car)) : 1));
		ns.setVal(v); return v;
	},
	"delete": function(c) { var a = evalLisp(c.car), lst = evalLisp(c.cdr.car);
		if (!(lst instanceof Cell)) return lst;
		if (eqVal(a, lst.car)) return lst.cdr;
		mkNew(); link(lst.car); lst = lst.cdr;
		while (lst instanceof Cell) {
			if (eqVal(a, lst.car)) { cst.mk[0].t.cdr = lst.cdr; return mkResult(); }
			link(lst.car); lst = lst.cdr;
		}
		cst.mk[0].t.cdr = lst;	// taking care of dotted tail
		return mkResult();
	},
	"do": function(c) {
		var n = evalLisp(c.car);
		if (n === NIL) return NIL;
		var step = 1, b = c.cdr, v = NIL;
		if (n === T) { n = 1; step = 0; }
		for (var i=1; i<=n; i+=step) {
			var r = iter(b); v = r.v; if (r.m) break;
		}
		return v;
	},
	"eval": function(c) { return evalLisp(evalLisp(c.car)); },	// TODO: binding env. offset cnt
	"fin": function(c) { c = evalLisp(c.car); while (c instanceof Cell) { c = c.cdr; }; return c; },
	"for": function(c) {
		var s = null, s2 = null, v = NIL;
		if (c.car instanceof Symbol) {
			s = c.car;
		} else if (c.car.cdr instanceof Symbol) {
			s2 = c.car.car; s = c.car.cdr;
		}
		if (s != null) {
			s.pushValue(NIL);	if (s2 != null) s2.pushValue(ZERO);
			var nl = evalLisp(c.cdr.car), b = c.cdr.cdr, i = 0;
			if (nl instanceof Number) {
				//alert("for: 1st form");	// (for I 3 (js:confirm I))
				while (++i <= nl) {
					s.setVal(new Number(i));
					var r = iter(b); v = r.v; if (r.m) break;
				}
			} else {
				//alert("for: 2nd form");	// (for (I . X) (22 33 44) (js:confirm (+ I X)) (+ I X))
				while (nl instanceof Cell) {
					s.setVal(nl.car); if (s2 != null) s2.setVal(new Number(++i));
					var r = iter(b); v = r.v; if (r.m) break;
					nl = nl.cdr;
				}
			}
		} else {
			//alert("for: 3rd form");
			if (c.car.car instanceof Symbol) {
				s = c.car.car;
			} else {
				s2 = c.car.car.car; s = c.car.car.cdr;
			}
			s.pushValue(evalLisp(c.car.cdr.car));	if (s2 != null) s2.pushValue(ZERO);
			var a2p = c.car.cdr.cdr, a2 = a2p.car, b = c.cdr, i = 0;
			var p = (a2p.cdr instanceof Cell) ? a2p.cdr.car : null;
			while (evalLisp(a2) !== NIL) {
				if (s2 != null) s2.setVal(new Number(++i));
				var r = iter(b); v = r.v; if (r.m) break;
				if (p != null) s.setVal(evalLisp(p));
			}
		}
		s.popValue();	if (s2 != null) s2.popValue();
		return v;
	},
	"get": function(c) { return getAlg(evalArgs(c)); },
	"getl": function(c) { var s = getAlg(evalArgs(c));
		if (s instanceof Symbol) return s.props;
		throw new Error(newErrMsg(SYM_EXP, s));
	},
	"idx": function(c) { var s = evalLisp(c.car);
		if (!(s instanceof Symbol)) return NIL;
		if (c.cdr === NIL) { mkNew(); idxLinkSorted(s.getVal()); return mkResult(); }
		var a = evalLisp(c.cdr.car);
		if (c.cdr.cdr === NIL) return idxLookup(s, a);
		return (evalLisp(c.cdr.cdr.car) === NIL) ? idxDelete(s, a) : idxInsert(s, a);
	},
	"if": function(c) { return aTrue(evalLisp(c.car)) ? aPop(evalLisp(c.cdr.car)) : prog(c.cdr.cdr); },
	"ifn": function(c) { return aTrue(evalLisp(c.car)) ? aPop(prog(c.cdr.cdr)) : evalLisp(c.cdr.car); },
	"inc": function(c) {
		if (c === NIL) return NIL;
		var ns = evalLisp(c.car);
		if (ns instanceof Number) return new Number(ns + 1);
		var v = new Number(ns.getVal() + ((c.cdr !== NIL) ? numeric(evalLisp(c.cdr.car)) : 1));
		ns.setVal(v); return v;
	},
	"length": function(c) { var cv = evalLisp(c.car), v = 0;
		if (cv instanceof Number) { v = cv.toString().length; }
		else if (cv instanceof Symbol) { v = cv.lock ? cv.toValueString().length :
			(cv.name === null) ? 0 : cv.name.length; }
		else if (cv instanceof Cell) { var cs = cv;
			while (cs !== NIL) { v++; cs = cs.cdr; if (cs === cv) return T; }}
		return new Number(v);
	},
	"let": function(c) {
		var symArr = [], p = c.cdr;
		if (c.car instanceof Symbol) {
			if (c.car !== NIL) {
				c.car.pushValue(evalLisp(c.cdr.car)); symArr.push(c.car); p = c.cdr.cdr;
			}
		} else if (c.car instanceof Cell) {
			var sv = c.car;
			while (sv !== NIL) {
				sv.car.pushValue(evalLisp(sv.cdr.car)); symArr.push(sv.car); sv = sv.cdr.cdr;
			}
		}
		var v = prog(p);
		while (symArr.length > 0) { symArr.pop().popValue(); }
		return v;
	},
	"link": linkc,
	"list": function(c) { return (c !== NIL) ? evalArgs(c) : new Cell(NIL, NIL); },
	"load": function(c) { var r = NIL;
		while (c instanceof Cell) {
			var cv = evalLisp(c.car);
			if (cv instanceof Symbol) {
				var f = cv.toValueString();
				if (f.charAt(0) == "-") {
					r = parseList(new Source("(" + f.substring(1) + ")"), true);
				} else {
					r = (f.match(/\.js$/)) ? loadJavaScript(f) : loadLisp(f);
				}
			}
			c = c.cdr;
		}
		return r;
	},
	"loop": function(c) {
		var v = NIL; while (true) { var r = iter(c); v = r.v; if (r.m) break; }; return v;
	},
	"make": function(c) { mkNew(); prog(c); return mkResult(); },
	"mapc": function(c) { var r = NIL, fn = evalLisp(c.car), ci = evalArgs(c.cdr);
		if (! (fn instanceof Symbol)) fn = box(fn);
		while (ci.car !== NIL) { var cj = ci; mkNew();
			while (cj !== NIL) { link(cj.car.car); cj.car = cj.car.cdr; cj = cj.cdr; }
			r = evalLisp(new Cell(fn, unevalArgs(mkResult())));
		}
		return r;
	},
	"mapcar": function(c) { var fn = evalLisp(c.car), ci = evalArgs(c.cdr);
		if (! (fn instanceof Symbol)) fn = box(fn);
		mkNew();
		while (ci.car !== NIL) { var cj = ci; mkNew();
			//if (!confirm(lispToStr(cj))) throw new Error("mapcar aborted");
			while (cj !== NIL) { link(cj.car.car); cj.car = cj.car.cdr; cj = cj.cdr; }
			link(evalLisp(new Cell(fn, unevalArgs(mkResult()))));
		}
		return mkResult();
	},
	"next": function(c) { cst.evFrames.car = cst.evFrames.car.cdr; return cst.evFrames.car.car; },
	"not": function(c) { return (evalLisp(c.car) === NIL) ? T : NIL; },
	"nth": function(c) { var lst = evalArgs(c); c = lst.cdr;
		do { lst = nth(lst.car, numeric(c.car)); c = c.cdr; } while(c !== NIL); return lst; },
	// pack has no support for circular lists, same as in PicoLisp
	"pack": function(c) { return (c !== NIL) ? newTransSymbol(valueToStr(evalArgs(c))) : NIL; },
	"pass": function(c) { return applyFn(c.car, cst.evFrames.car.cdr, c.cdr); },
	"pop": function(c) { var cv = evalLisp(c.car);
		if (cv.getVal) {
			var v = cv.getVal();
			if (v instanceof Cell) { cv.setVal(v.cdr); return v.car; }
			if (v === NIL) return NIL;
			if (cv instanceof Cell) return cv.car;
		}
		throw new Error(newErrMsg(VAR_EXP, cv));
	},
	"prin": function(c) {
		c = evalArgs(c); _stdPrint(c.toValueString());
		while (c.cdr !== NIL) { c = c.cdr; }; return c.car;
	},
	"prinl": function(c) {
		c = evalArgs(c); _stdPrint(c.toValueString() + "\n");
		while (c.cdr !== NIL) { c = c.cdr; }; return c.car;
	},	
	"print": function(c) { return printx(c, ""); },
	"println": function(c) { return printx(c, "\n"); },
	"printsp": function(c) { return printx(c, " "); },
	"prog": prog,
	"push": function(c) { var t = evalLisp(c.car), v;
		if (t.getVal) {
			do { c = c.cdr; v = evalLisp(c.car); t.setVal(new Cell(v, t.getVal())); } while (c.cdr !== NIL);
			return v;
		}
		throw new Error(newErrMsg(VAR_EXP, t));
	},
	"put": function(c) {
		var kc, vc;
		c = evalArgs(c); mkNew();
		do { link(c.car); kc = c.cdr; vc = kc.cdr; c = c.cdr; } while (vc.cdr !== NIL);
		var s = getAlg(mkResult()), k = kc.car;
		if (!(s instanceof Symbol)) throw new Error(newErrMsg(SYM_EXP, s));
		if (s === NIL) throw new Error(newErrMsg(PROT_SYM, s));
		if (eqVal(k, ZERO)) {
			s.setVal(vc.car);
		} else {
			var pLst = s.props, pre = NIL;
			while (pLst !== NIL) {
				var pc = pLst.car, pk = (pc instanceof Cell) ? pc.cdr : pc;
				if (pk === k) {
					if (pre === NIL) { s.props = pLst.cdr; } else { pre.cdr = pLst.cdr; }	// removing old
					break;
				}
				pre = pLst; pLst = pLst.cdr;
			}
			if (vc.car !== NIL) {
				var pc = new Cell((vc.car === T) ? k : new Cell(vc.car, k), s.props);
				s.props = pc;
			}
			//alert("put props: " + lispToStr(s.props));
		}
		return vc.car;
	},
	"queue": function(c) { var s = evalLisp(c.car);
		if (s.getVal) {
			var cv = s.getVal(), t = new Cell(evalLisp(c.cdr.car), NIL);
			if (cv === NIL) { s.setVal(t); return t.car; }
			if (cv instanceof Cell) {
				while (cv.cdr !== NIL) cv = cv.cdr;
				cv.cdr = t; return t.car;
			}
		}
		throw new Error(newErrMsg(VAR_EXP, s));
	},
	"quote": function(c) { return c; },
	"rand": function(c) { var r = Math.random();
		if (c === NIL) return new Number(r);	// range 0.0 .. 1.0
		var n = evalLisp(c.car);
		if (n === T) return (r < 0.5) ? NIL : T;
		return new Number((-numeric(n) + numeric(evalLisp(c.cdr.car))) * r + n);
	},
	"range": function(c) {
		var n = numeric(evalLisp(c.car)), n2 = numeric(evalLisp(c.cdr.car)), s = evalLisp(c.cdr.cdr.car);
		if (s === NIL) { s = 1; } else if (numeric(s) <= 0) throw new Error(newErrMsg(BAD_ARG, s));
		if (n > n2) s = -s;
		mkNew(); do { link(n); n = new Number(n + s); } while ((s > 0) ? (n <= n2) : (n >= n2));
		return mkResult();
	},
	"rest": function(c) { return cst.evFrames.car.cdr; },
	"reverse": function(c) { var lst = evalLisp(c.car), r = NIL;
		if (!(lst instanceof Cell)) return NIL;
		do { r = new Cell(lst.car, r); lst = lst.cdr; } while (lst instanceof Cell);
		return r;
	},
	"setq": function(c) {
		var v = NIL;
		while (c instanceof Cell) {
			v = (c.cdr instanceof Cell) ? evalLisp(c.cdr.car) : NIL;
			setSymbolValue(c.car, v);
			c = (c.cdr instanceof Cell) ? c.cdr.cdr : NIL;
		}
		return v;
	},	
	"sort": function(c) {
		var lst = evalLisp(c.car);
		if (lst instanceof Cell) {
			var fn = evalLisp(c.cdr.car), arr = [];
			do { arr.push(lst.car); lst = lst.cdr; } while (lst instanceof Cell);
			if (fn === NIL) {
				arr.sort(ascending);
			} else {
				cst.compExprArr.unshift(new CompExpr(fn));
				arr.sort(lispFnOrder);	// roughly twice as slow as 'ascending' (above), if fn is '>'
				cst.compExprArr.shift();
			}
			lst = NIL;
			while (arr.length > 0) lst = new Cell(arr.pop(), lst);
		}
		return lst;
	},
	"str": function(c) {
		var cv = evalLisp(c.car);
		if (cv instanceof Symbol) {
			var cs = evalLisp(c.cdr.car);
			return (cs === NIL) ? cachedTextParse(cv.valueOf()) :
					parseList(new Source(cv.valueOf(), cs.valueOf()));
		}
		if (cv instanceof Cell) {
			var arr = [];
			do { arr.push(lispToStr(cv.car)); cv = cv.cdr; } while (cv instanceof Cell);
			return newTransSymbol(arr.join(" "));
		}
		if (cv === NIL) return NIL;
		throw new Error(newErrMsg(CELL_EXP, cv));
	},
	"tail": function(c) {
		var cl = evalLisp(c.car), lst = evalLisp(c.cdr.car);
		if (cl instanceof Cell) {
			var cv = cl, arr = []; while (lst !== NIL) { arr.unshift(lst.car); lst = lst.cdr; }
			if (arr.length == 0) return NIL;
			var sub = []; while (cl !== NIL) { sub.unshift(cl.car); cl = cl.cdr; }
			if (arr.length < sub.length) return NIL;
			for (var i=0; i<sub.length; i++) {
				if (!eqVal(sub[i], arr[i])) return NIL;
			}
			return cv;
		}
		if (cl instanceof Number) {
			cl = Math.round(cl);
			if (cl > 0) {
				var arr = []; while (lst !== NIL) { arr.push(lst); lst = lst.cdr; }
				return arr[Math.max(arr.length - cl, 0)];
			}
			if (cl < 0) {
				do { lst = lst.cdr; if (++cl == 0) return lst; } while (lst !== NIL);
			}
			return NIL;	// cl == 0, or we did not return above
		}
		if (cl === NIL) return NIL;
		throw new Error(newErrMsg(NUM_EXP, cl));
	},
	"trace": function(c) { var s = evalLisp(c.car), f = evalLisp(s);
		if (f instanceof Cell) {
			setSymbolValue(s, new Cell(f.car, new Cell(new Cell(cst.iSym["$"], new Cell(s, f)), NIL)));
		} else {
			setSymbolValue(s, new Cell(A1, new Cell(new Cell(cst.iSym["$"], new Cell(s,
				new Cell(A1, new Cell(new Cell(cst.iSym["pass"], new Cell(box(f), NIL)), NIL)))), NIL)));
		}
		return s;
	},
	"untrace": function(c) {
		var s = evalLisp(c.car), f = cdr(cdr(car(cdr(evalLisp(s))))), b = car(cdr(f));
		if (car(b) === cst.iSym["pass"]) f = evalLisp(car(cdr(b)));
		setSymbolValue(s, f);
		return s;
	},
	"usec": function(c) { return new Number(((new Date()).getTime() - cst.startupMillis) * 1000); },
	"version": function(c) { if (!aTrue(evalLisp(c.car))) _stdPrint(VERSION.join(".") + " JS\n");
		mkNew(); for (var i=0; i<VERSION.length; i++) { link(VERSION[i]); }; return mkResult(); },
	"yoke": function(c) { if (cst.mk.length === 0) throw new Error(newErrMsg(NOT_MAK));
		var tn = (cst.mk[0].t === NIL);
		do { var h = new Cell(evalLisp(c.car), cst.mk[0].h);
			cst.mk[0].h = h; if (tn) { cst.mk[0].t = h; tn = false; }
			c = c.cdr; } while (c !== NIL);
		return cst.mk[0].h.car;
	},
	"zero": function(c) {
		do { setSymbolValue(c.car, ZERO); c = c.cdr; } while (c instanceof Cell); return ZERO;
	},
	// Test: (let (A 3 B 5) ($ f1 (A B) ($ f2 (A B) (* A B))))
	// (de foo (X Y . @) (+ X Y (next) (next))) (trace 'foo) (foo 4 5 6 7)	// not yet
	"$": function(c) { var lst = c.cdr.car;
		cst.trcIndent += " ";
		_stdPrint(cst.trcIndent + c.car.name + " :");	// TODO: Handle methods
		while (lst instanceof Cell) { _stdPrint(" " + lispToStr(lst.car.getVal())); lst = lst.cdr; }
		if (lst === A1) {
			lst = cst.evFrames.car.cdr;
			while (lst instanceof Cell) { _stdPrint(" " + lispToStr(lst.car)); lst = lst.cdr; }
		}
		_stdPrint("\n");
		var res = prog(c.cdr.cdr);
		_stdPrint(cst.trcIndent + c.car.name + " = " + lispToStr(res) + "\n");
		cst.trcIndent = cst.trcIndent.substring(1);
		return res;
	},
	"+": function(c) { var t = 0;
		do { var v = evalLisp(c.car); if (v === NIL) return NIL;
			t += numeric(v); c = c.cdr; } while (c instanceof Cell); return new Number(t);
	},
	"-": function(c) { var t = evalLisp(c.car);
		if (t === NIL) return NIL;
		t = numeric(t); c = c.cdr;
		if (c === NIL) return new Number(-t);
		do { var v = evalLisp(c.car); if (v === NIL) return NIL;
			t -= numeric(v); c = c.cdr; } while (c instanceof Cell); return new Number(t);
	},
	"*": function(c) { var t = 1;
		do { var v = evalLisp(c.car); if (v === NIL) return NIL;
			t *= numeric(v); c = c.cdr; } while (c instanceof Cell); return new Number(t);
	},
	"/": function(c) { return div(c, function(a, b) { return a / b; }); },	// floating point division
	"/t": function(c) { return div(c, function(a, b) { var d = a / b;
		return (d >= 0) ? Math.floor(d) : Math.ceil(d); }); },	// truncated division
	"=": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) { d = d.cdr; dv = evalLisp(d.car); if (!eqVal(cv, dv)) return NIL; }; return T; },
	"==": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) { d = d.cdr; dv = evalLisp(d.car); if (cv !== dv) return NIL; }; return T; },
	"<": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) {
			d = d.cdr; dv = evalLisp(d.car); if (!ltVal(cv, dv)) return NIL;
			cv = dv;
		}; return T;
	},
	"<=": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) {
			d = d.cdr; dv = evalLisp(d.car); if (ltVal(dv, cv)) return NIL;
			cv = dv;
		}; return T;
	},
	">": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) {
			d = d.cdr; dv = evalLisp(d.car); if (!ltVal(dv, cv)) return NIL;
			cv = dv;
		}; return T;
	},
	">=": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) {
			d = d.cdr; dv = evalLisp(d.car); if (ltVal(cv, dv)) return NIL;
			cv = dv;
		}; return T;
	},
	";": function(c) { return getAlg(new Cell(evalLisp(c.car), c.cdr)); }
};

function internalSymbolsInclPrimitives() {
	var symbols = {NIL: NIL, T: T, "@": A1, "@@": A2, "@@@": A3,
		"*OS": new Symbol("*OS", "TODO")};
	var names = Object.keys(coreFunctions);
	for (var i=0; i<names.length; i++) {
		var name = names[i];
		if (name in gEmptyObj) throw new Error(newErrMsg(JS_RESERVED, name));
		symbols[name] = new Symbol(name, coreFunctions[name]);
	}
	return symbols;
}

prepareNewState();

function evalDef(def, inExprLst) {
	//alert("evalDef: " + lispToStr(def.cdr) + ", " + lispToStr(inExprLst));
	var locVars = null, locSym = null, evFrame = null;
	if (def.car instanceof Symbol) {
		if (def.car === A1) {
			evFrame = new Cell(NIL, evalArgs(inExprLst));
			cst.evFrames = new Cell(evFrame, cst.evFrames);	// pushing evFrame onto cst.evFrames
		} else {
			locSym = def.car;
			locSym.pushValue(inExprLst);	// Binding unevaluated list to a single symbol
		}
	} else {
		locVars = def.car;
		var evArgs = evalArgs(inExprLst);
		// Saving old symbol values and binding new values ...
		while (locVars instanceof Cell) {
			//if (!confirm("locVars: " + lispToStr(locVars.car))) throw new Error("evalDef aborted");
			locVars.car.pushValue(evArgs.car);
			locVars = locVars.cdr;
			evArgs = evArgs.cdr;
		}
		locVars = def.car;
	}
	// Executing body ...
	var res = prog(def.cdr);
	// Restoring previous symbol values ...
	if (locSym instanceof Symbol) locSym.popValue();
	if (locVars instanceof Cell) {
		while (locVars instanceof Cell) { locVars.car.popValue(); locVars = locVars.cdr; }
	}
	if (evFrame instanceof Cell) cst.evFrames = cst.evFrames.cdr;		// popping evFrame
	return res;
}

function evalLisp(lst) {
	if (lst instanceof Symbol) return lst.cdr;
	if (lst instanceof Cell) {
		if (typeof lst.car.cdr === "function") {
			return lst.car.cdr(lst.cdr);
		}
		if (lst.car instanceof Symbol) {
			if (lst.car.cdr === NIL) throw new Error(newErrMsg(UNDEF, lst.car));
			return evalDef(lst.car.cdr, lst.cdr);
		}
		if ((lst.car.car === QUOTE) && (lst.car.cdr instanceof Cell)) {
			return evalDef(lst.car.cdr, lst.cdr);
		}
		if (lst.car instanceof Number) return lst;
		throw new Error(newErrMsg(EXEC_OR_NUM_EXP, lst.car));
	}
	return lst;		// a number, or text
}

function evalArgs(lst) {
	if (lst === NIL) return NIL;
	var resLst = new Cell(NIL, NIL);	// to become new list of evaluation results
	var res = resLst;
	do {
		//alert("evalArgs: " + lispToStr(lst.car));
		res.car = evalLisp(lst.car);
		lst = lst.cdr;
		if (lst instanceof Cell) {
			res.cdr = new Cell(NIL, NIL);
			res = res.cdr;
		}
	} while (lst instanceof Cell);
	return resLst;
}

function loadLisp(fileUrl) {
	cst.tSym = {};
	var res = parseList(new Source(getFileSync(fileUrl)), true);
	cst.tSym = {};
	//alert("loadLisp: " + lispToStr(res));
	return res;
}

function loadJavaScript(fileUrl) {
	return newTransSymbol(eval(getFileSync(fileUrl)).toString());
}

function _stdPrint(text) {
	if (typeof stdPrint === "function") stdPrint(text)
	else // when function stdPrint is not available in front end
	//if (!confirm("_stdPrint:\n" + text)) throw new Error("_stdPrint aborted");
	console.log(text);
}

function _warn(msg) {
	if (typeof warn === "function") warn(msg);
}

/*
 * Objects of the Params class are used to deliver evaluated parameter values to
 * JavaScript functions. Some functions take an optional default input value.
 */
function Params(lst) {
	this.lst = lst;
}

Params.prototype.any = function() {
	var val = null;
	if (this.lst !== NIL) {
		val = evalLisp(this.lst.car); this.lst = this.lst.cdr;
	}
	return val;
}

Params.prototype.bool = function(val) {
	if (this.lst !== NIL) {
		val = evalLisp(this.lst.car); this.lst = this.lst.cdr;
	}
	if ((val === NIL) || (val === T)) return val.bool;
	throw new Error(newErrMsg(BOOL_EXP, val));
}

Params.prototype.natObj = function() {
	if (this.lst !== NIL) {
		val = evalLisp(this.lst.car); this.lst = this.lst.cdr;
	}
	if ((val instanceof Symbol) && (val.obj !== undefined)) return val.obj;
	throw new Error(newErrMsg(BOXNAT_EXP, val));
}

Params.prototype.num = function(val) {
	if (this.lst !== NIL) {
		val = evalLisp(this.lst.car); this.lst = this.lst.cdr;
	}
	if (val instanceof Number) return val;
	throw new Error(newErrMsg(NUM_EXP, val));
}

Params.prototype.optNum = function() {
	if (this.lst !== NIL) {
		var val = evalLisp(this.lst.car); this.lst = this.lst.cdr;
		if (val instanceof Number) return val;
		throw new Error(newErrMsg(NUM_EXP, val));
	}
	return null;
}

Params.prototype.str = function(val) {
	if (this.lst !== NIL) {
		val = evalLisp(this.lst.car); this.lst = this.lst.cdr;
	}
	if (val instanceof Symbol) return val.valueOf();
	throw new Error(newErrMsg(SYM_EXP, val));
}

function symbolRefUrl(symbolName) {
	if (symbolName == "NIL") {
		return "ref.html#nilSym";
	} else if (symbolName.match(/^[a-zA-Z_]/)) {
		return "ref" + symbolName.substring(0, 1).toUpperCase() + ".html#" + symbolName;
	} else if (symbolName.match(/^\*[a-zA-Z_]/)) {
		return "ref" + symbolName.substring(1, 2) + ".html#" + symbolName;
	} else {
		return "ref_.html#" + symbolName;
	}
}

var pub = {	
	init: function(optionalState) { prepareNewState(optionalState); },
	
	currentState: function() { return cst; },

	forSymbolWithNameDefineFun: function(name, jsFn) {
		if (name in gEmptyObj) throw new Error(newErrMsg(JS_RESERVED, name));
		var sym = new Symbol(name, jsFn);
		cst.iSym[name] = sym;
	},
	
	forSymbolWithNamePushValue: function(name, value) {
		var sym = getSymbol(name);
		sym.pushValue(value);
		return sym;
	},
	
	forSymbolWithNameSetValue: function(name, value) {
		return getSymbol(name).setVal(value);
	},

	boxNativeObject: function(obj) {
		var ts = newTransSymbol(null);
		ts.obj = obj;
		return ts;
	},
	
	isCell: function(obj) { return (obj instanceof Cell); },
	isSymbol: function(obj) { return (obj instanceof Symbol); },
	
	evalArgs: evalArgs, evalLisp: evalLisp, lispToStr: lispToStr, newErrMsg: newErrMsg,
	newTransSymbol: newTransSymbol, prog: prog, valueToStr: valueToStr, Params: Params,
	NIL: NIL, T: T,
	
	eval: function(code) {
		return prog(parseList(new Source(code))).toString();
	}
}

function testExports() {
	var pubKeys = Object.keys(pub);
	for (var i=0; i<pubKeys.length; i++) {
		console.log("pub.%s: %s", pubKeys[i], typeof pub[pubKeys[i]]);
	}
}
testExports();

return pub;

}());
