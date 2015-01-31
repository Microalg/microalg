/* 15dec14jk
 * (c) Jon Kleiser
 */

var EMULISP_CORE = (function () {

var VERSION = [2, 0, 3, 0],
	MONLEN = [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
	BOXNAT_EXP = "Boxed native object expected",
	BOOL_EXP = "Boolean expected", CELL_EXP = "Cell expected", LIST_EXP = "List expected",
	NUM_EXP = "Number expected", SYM_EXP = "Symbol expected", VAR_EXP = "Variable expected",
	EXEC_OR_NUM_EXP = "Executable or Number expected",
	CHANNEL_NOT_SUPPORTED = "EmuLisp only supports the NIL channel",
	BAD_ARG = "Bad argument", BAD_DOT = "Bad dotted pair", BAD_INPUT = "Bad input",
	BAD_MSG = "Bad message", BAD_SUPER = "Bad super", DIV_0 = "Div/0",
	NOT_MAK = "Not making", PROT_SYM = "Protected symbol", UNDEF = "Undefined",
	JS_CTORNAME_EXP = "Constructor name expected", JS_RESERVED = "Reserved word";

function getFileSync(fileUrl) {
	var req = new XMLHttpRequest();
	var OK = fileUrl.match(/^file:/) ? 0 : 200;
	req.open("GET", fileUrl, false);		// synchronous
	if (req.overrideMimeType) req.overrideMimeType("text/plain; charset=utf-8");
	req.send(null);
	//console.log("getFileSync: %s -> %s", fileUrl, req.status);
	if (req.status == OK) {
		return req.responseText;
	}
	throw new Error("XMLHttpRequest status: " + req.status);
}

var NILTYPE = 0, NUMBERTYPE = 1, SYMBOLTYPE = 2, CELLTYPE = 3, TRUETYPE = 4;

Number.prototype.pow = function(p) { return new Number(Math.pow(this, p)); };
Number.prototype.rem = function(d) { return new Number(this % d); };
Number.prototype.put = function() { throw new Error(newErrMsg(SYM_EXP)); };
Number.prototype.get = Number.prototype.put;
Number.prototype.prop = Number.prototype.put;
Number.prototype.putl = Number.prototype.put;
Number.prototype.getl = Number.prototype.put;
Number.prototype.TYPEVAL = NUMBERTYPE;
Function.prototype.TYPEVAL = NUMBERTYPE;

function logLisp(msg, x) {
	console.log("%s: %s", msg, x.toString());
	return x;
}

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

Cell.prototype.get = function(key) {	// Ersatz-like
	//console.log("Cell.prototype.get: key=%s", lispToStr(key));
	var x, y = this;
	if (key instanceof Number) {
		var n = key;
		if (n > 0) {
			while (--n !== 0) { y = y.cdr; }
			return y.car;
		}
		if (n < 0) {
			while (++n !== 0) { y = y.cdr; }
			return y.cdr;
		}
	} else {
		do {
			if ((x = y.car) instanceof Cell  &&  key === x.car) return x.cdr;
		} while ((y = y.cdr) instanceof Cell);
	}
	return NIL;
}

Cell.prototype.put = function() { throw new Error(newErrMsg(SYM_EXP)); };
Cell.prototype.prop = Cell.prototype.put;
Cell.prototype.putl = Cell.prototype.put;
Cell.prototype.getl = Cell.prototype.put;

Cell.prototype.func = function(ex) {	// Ersatz-like
	//console.log("Cell.prototype.func #1: ex=%s", lispToStr(ex));
	var i, x, y;
	var bnd = new Bind();  bnd.add(A1.car);  bnd.add(A1);
	for (x = this.car; x instanceof Cell; x = x.cdr) {
		bnd.add(evalLisp((ex = ex.cdr).car));	// Save new value
		bnd.add(x.car);	// and symbol
	}
	if (x === NIL || x !== A1) {
		i = bnd.Cnt;
		if (x !== NIL) {
			bnd.add(x.car);	// Save old value
			bnd.add(x);			// and symbol
			x.car = ex.cdr;	// Set new value
		}
		do {
			y = bnd.Data[--i];
			x = y.car;
			y.car = bnd.Data[--i];	// Set new value
			bnd.Data[i] = x;			// Save old value
		} while (i > 0);
		Env.Bind = bnd;
		x = prog(this.cdr);
		//console.log("Cell.prototype.func #2: x=%s", lispToStr(x));
	} else {
		//console.log("Cell.prototype.func #3: x=%s", lispToStr(x));
		var next, argc, j = 0;
		var arg, args, av = null;
		if (ex.cdr !== NIL) {
			av = [];
			do {
				av = append(av, j++, evalLisp((ex = ex.cdr).car));
			} while (ex.cdr !== NIL);
		}
		next = Env.Next;	Env.Next = 0;
		argc = Env.ArgC;	Env.ArgC = j;
		arg = Env.Arg;		Env.Arg = NIL;
		args = Env.Args;	Env.Args = av;
		i = bnd.Cnt;
		do {
			y = bnd.Data[--i];
			x = y.car;
			y.car = bnd.Data[--i];	// Set new value
			bnd.Data[i] = x;			// Save old value
		} while (i > 0);
		Env.Bind = bnd;
		x = prog(this.cdr);
		Env.Args = args;
		Env.Arg = arg;
		Env.ArgC = argc;
		Env.Next = next;
	}
	for (i = bnd.Cnt; (i -= 2) >= 0;) {
		bnd.Data[i+1].car = bnd.Data[i];
	}
	Env.Bind = bnd.Link;
	return x;
	//throw new Error(newErrMsg("Cell.prototype.func not yet fully implemented"));
}

function Symbol(name, val) {
	this.name = name;
	this.trans = false;
	this.car = (val === undefined) ? NIL : val;
	this.props = NIL;
}

function newTransSymbol(name) {
	var ts = new Symbol(name);
	ts.trans = true;
	ts.car = ts;
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
	return this.car;
}

Symbol.prototype.valueOf = function() {
	return this.name;
}

Symbol.prototype.setVal = function(val) {
	if (this.lock) throw new Error(newErrMsg(PROT_SYM, this));
	this.car = val;
}

// Internal symbol names can consist of any printable (non-whitespace) character,
// except for the following meta characters:		" ' ( ) , [ ] ` ~ { }
// It is possible, though, to include these special characters into symbol names
// by escaping them with a backslash '\'.
Symbol.prototype.escName = function() {
	if (this.name instanceof Number) return this.name;
	var eName = this.name.replace(/\\/g, "\\\\");
	eName = eName.replace(/\"/g, "\\\"");
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
	this.stack.push(this.car);
	this.car = val;
}

Symbol.prototype.popValue = function() {
	var pv = this.car;
	this.car = this.stack.pop();
	//if (this.stack.length === 0) delete this.stack;
	return pv;
}

Symbol.prototype.put = function(key, val) {	// not quite Ersatz-like
	if (eqVal(key, ZERO)) {
		this.car = val;
	} else {
		var pre = NIL, pLst = this.props;
		while (pLst !== NIL) {
			var pc = pLst.car;
			if (pc instanceof Cell) {
				if (key === pc.cdr) {
					if (val === NIL) {
						if (pre === NIL) {
							this.props = pLst.cdr;
						} else {
							pre.cdr = pLst.cdr;
						}
					} else if (val === T) {
						pLst.car = key;
					} else {
						pc.car = val;
					}
					return val;
				}
			} else if (key === pc) {
				if (val === NIL) {
					if (pre === NIL) {
						this.props = pLst.cdr;
					} else {
						pre.cdr = pLst.cdr;
					}
				} else if (val !== T) {
					pc = new Cell(val, key);
					var pcTail = new Cell(pc, pLst.cdr);
					if (pre === NIL) {
						this.props = pcTail;
					} else {
						pre.cdr = pcTail;
					}
				}
				return val;
			}
			pre = pLst;
			pLst = pLst.cdr;
		}
		if (val !== NIL) {
			var x = (val !== T) ? new Cell(val, key) : key;
			this.props = new Cell(x, this.props);
		}
	}
	return val;
}

Symbol.prototype.get = function(key) {	// not quite Ersatz-like
	//console.log("Symbol.prototype.get: key=%s", lispToStr(key));
	if (eqVal(key, ZERO)) return this.car;
	var pLst = this.props;
	while (pLst !== NIL) {
		var pc = pLst.car;
		if (pc instanceof Cell) {
			if (key === pc.cdr) return pc.car;
		} else {
			if (key === pc) return T;
		}
		pLst = pLst.cdr;
	}
	return NIL;
}

Symbol.prototype.prop = function(key) {	// not quite Ersatz-like
	//console.log("Symbol.prototype.prop: this=%s, key=%s %s", lispToStr(this), key, lispToStr(key));
	var pLst = this.props;
	while (pLst !== NIL) {
		var pc = pLst.car;
		if (pc instanceof Cell) {
			if (key === pc.cdr) return pc;
		} else {
			if (key === pc) return key;
		}
		pLst = pLst.cdr;
	}
	var c = new Cell(NIL, key);
	this.props = new Cell(c, this.props);
	return c;
}

Symbol.prototype.getl = function() { return this.props; }

Symbol.prototype.func = function(ex) {	// Ersatz-like
	console.log("Symbol.prototype.func: ex=%s", lispToStr(ex));
	return this.car.func(ex);
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

function needVar(ex, x) {
	if (x instanceof Number) throw new Error(newErrMsg(VAR_EXP, x, ex));	// Ersatz-like
}

function indx(x, y) {	// Ersatz-like
	var i = 1, z = y;
	while (y instanceof Cell) {
		if (eqVal(x, y.car)) return i;
		++i;
		if (z === (y = y.cdr)) return 0;
	}
	return 0;
}

function Source(text, chars) {
	this.src = text;
	// character limitation for symbols
	if (chars instanceof Symbol) {
		this.charset = chars.valueOf();
	} else if (typeof chars === "string") {
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

function append(a, i, x) {	// Ersatz-like
	//console.log("append: %s, %s", i, lispToStr(x));
	if (i === a.length) { a.push(x); } else { a[i] = x; }
	return a;
}

function Bind() {	// Ersatz-like
	this.Link = Env.Bind;
	this.Data = [];
	this.Cnt = 0;
	this.Eswp = 0;
}

Bind.prototype.add = function(x) { this.Data = append(this.Data, this.Cnt++, x); }

function Env() {	// Ersatz-like
	this.Next = 0;
	this.ArgC = 0;
	this.Trace = 0;
	this.Bind;
	this.Intern;	// TODO: pico namespace
	this.Arg; this.Args; this.Cls; this.Key; this.Task; this.Make; this.Yoke;
	this.InFrames;
	this.OutFrames;
}

var env = new Env();	// Ersatz-like

var ZERO = new Number(0), ONE = new Number(1);
var NIL = new Symbol("NIL");	NIL.car = NIL;	NIL.cdr = NIL;	NIL.props = NIL;
		NIL.lock = true; NIL.TYPEVAL = NILTYPE; NIL.bool = false;
var T = new Symbol("T");	T.car = T;	T.lock = true; T.TYPEVAL = TRUETYPE; T.bool = true;
var A1 = new Symbol("@", NIL), A2 = new Symbol("@@", NIL), A3 = new Symbol("@@@", NIL);
var Meth = new Symbol("meth");	Meth.car = ONE;	Meth.lock = true;
var This = new Symbol("This");	This.car = NIL;
var Class = new Symbol("*Class");	Class.car = NIL;
var gEmptyObj = {}, TheCls, TheKey;
var cst, QUOTE;

function emuEnv() {
	if (typeof window != "undefined") return "browser";
	if (typeof process != "undefined") return "nodejs";
	return NIL;
}

function prepareNewState(optionalState) {
	cst = optionalState || {
		iSym: internalSymbolsInclPrimitives(),
		tSym: {},	// dictionary/index for transient symbols (strings)
		parseCache: {},
		mk: [],	// 'make' stack
		compExprArr: [],	// sort expression stack
		evFrames: NIL,
		trcIndent: "",
		startupMillis: Date.now()
	};
	QUOTE = getSymbol("quote");
	getSymbol("*EMUENV").setVal(new Symbol(emuEnv()));
}

function mkNew() { cst.mk.unshift({h: NIL, t: NIL}); }
function linkc(c) {
	if (cst.mk.length === 0) throw new Error(newErrMsg(NOT_MAK));
	c = (c !== NIL) ? evalArgs(c) : new Cell(NIL, NIL);
	if (cst.mk[0].h === NIL) { cst.mk[0].h = c; } else { cst.mk[0].t.cdr = c; }
	while (c.cdr !== NIL) { c = c.cdr; }; cst.mk[0].t = c; return c.car;
}
function mkResult() { return cst.mk.shift().h; }

function List() {
	this.list = NIL;
	this.last = NIL;
}

List.prototype.link = function(x) {
	var c = new Cell(x, NIL);
	if (this.list === NIL) { this.list = c; } else { this.last.cdr = c; }
	this.last = c;
}

function getString(str, editMode) {
	var s = (str in gEmptyObj) ? undefined : cst.tSym[str];
	if (s === undefined) {
		s = newTransSymbol(str);
		if (! (editMode || (str in gEmptyObj))) cst.tSym[str] = s;
	}
	return s;
}

function newErrMsg(msg, badValue, ex) {
	getSymbol("*Msg").setVal(newTransSymbol(msg));
	var exStr = "", badValStr = "";
	if (badValue !== undefined) {
		if (ex !== undefined) exStr = "!? " + lispToStr(ex) + "\n";
		badValStr = lispToStr(badValue) + " -- ";
	}
	return exStr + badValStr + msg;
}

function aTrue(val) { if (val !== NIL) { A1.setVal(val); return true; } else return false; }

function car(c) { if (c.car) return c.car; else throw new Error(newErrMsg(LIST_EXP, c)); }
function cdr(c) { if ((c instanceof Cell) || (c === NIL)) return c.cdr;
						else throw new Error(newErrMsg(LIST_EXP, c)); }

function numeric(val) {
	if (val instanceof Number) return val;
	throw new Error(newErrMsg(NUM_EXP, val));
}

function validTime1970(y, m, d) {
	numeric(y); numeric(m); numeric(d);
	if (m<1 || m>12 || d<1 || d>MONLEN[m] && (m!=2 || d!=29 || y%4!=0 || y%100==0 && y%400!=0)) return null;
	var ms1970 = Date.UTC(y, m - 1, d);
	return (y >= 100) ? ms1970 : ms1970 - 59958144000000;
}

function redefMsg(x, y) {
	var yStr = (y !== null) ? (" " + y.valueOf()) : "";
	_warn("# " + x.valueOf() + yStr + " redefined");
}

function putSrc(s, k) {
	//console.log("putSrc: TODO: %s, %s", lispToStr(s), lispToStr(k));	// TODO: whenever needed
}

function nth(lst, n) {
	if (lst instanceof Cell) {
		if (n <= 0) return NIL;
		while ((lst !== NIL) && (--n > 0)) { lst = lst.cdr; }
	}
	return lst;
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
				return {v: v, m: true};
			}
		} else v = evalLisp(cv);
		c = c.cdr;
	}
	return {v: v, m: false};
}

function divs(c, divFn) {
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
	//console.log("eqVal(%s, %s)", a, b);
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

function idxLinkSorted(tree, resList) {
	while (tree !== NIL)
	{ idxLinkSorted(tree.cdr.car, resList); resList.link(tree.car); tree = tree.cdr.cdr; }
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
				while (typeof (ch = src.getNextStringChar()) === "string") s += ch;
				item = (s == "") ? NIL : getString(s, editMode);
				src.traceItemEnd(item);		// in case we would like to know item's position
			} else {
				s = ch;
				while (typeof (ch = src.getNextSymbolChar()) === "string") s += ch;
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
	var a = new List(); while (lst !== NIL) { a.link(box(lst.car)); lst = lst.cdr; }
	return a.list;
}

function applyFn(rawFn, lst, more) {
	if (! (lst instanceof Cell)) lst = NIL;
	if (more !== NIL) {
		var m = new List(); do { m.link(evalLisp(more.car)); more = more.cdr; } while (more !== NIL);
		m.last.cdr = lst; lst = m.list;
	}
	var fn = evalLisp(rawFn); if (! (fn instanceof Symbol)) fn = box(fn);
	//console.log("applyFn: %s, %s", lispToStr(fn), lispToStr(lst));
	return evalLisp(new Cell(fn, unevalArgs(lst)));
}

function printx(c, x) { var arr = [];
	c = evalArgs(c); arr.push(lispToStr(c.car));
	while (c.cdr !== NIL) { c = c.cdr; arr.push(lispToStr(c.car)); }
	_stdPrint(arr.join(" ") + x); return c.car;
}

function rand(c, picoSize) {
	var r = Math.random();	// range 0.0 .. 1.0
	if (c === NIL) {
		if (picoSize) r = Math.floor((2 * r - 1) * picoSize);
		return new Number(r);
	}
	var n = evalLisp(c.car);
	if (n === T) return (r < 0.5) ? NIL : T;
	r = (-numeric(n) + numeric(evalLisp(c.cdr.car)) + (picoSize ? 1 : 0)) * r + n;
	if (picoSize) r = Math.floor(r);
	return new Number(r);
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
	this.arg1Sym.car = a;	// faster than this.arg1Sym.setVal(a);
	this.arg2Sym.car = b;
	return (evalLisp(this.expr) === T);
}

function lispFnOrder(a, b) { return cst.compExprArr[0].evalTrue(a, b) ? -1 : 1; }

var coreFunctions = {
	"and": function(c) { var v = NIL; while (c instanceof Cell) { v = evalLisp(c.car);
			if (!aTrue(v)) return NIL; c = c.cdr; } return v;
	},
	"any": function(c) { var cv = evalLisp(c.car);
		if (cv instanceof Symbol) return cachedTextParse(cv.valueOf()).car;
		throw new Error(newErrMsg(SYM_EXP, cv));
	},
	"append": function(c, ex) {
		for (ex = ex.cdr; (z = ex.Cdr) instanceof Cell; ex = z) {
			if ((x = evalLisp(ex.car)) instanceof Cell) {
				z = y = new Cell(x.car, x.cdr);
				while ((x = y.cdr) instanceof Cell)
					y = y.cdr = new Cell(x.car, x.cdr);
				while ((ex = ex.cdr).cdr instanceof Cell) {
					for (x = evalLisp(ex.car); x instanceof Cell; x = y.cdr)
						y = y.cdr = new cell(x.car, x.cdr);
					y.cdr = x;
				}
				y.cdr = evalLisp(ex.car);
				return z;
			}
		}
		return evalLisp(ex.car);
	},
	"apply": function(c) { return applyFn(c.car, evalLisp(c.cdr.car), c.cdr.cdr); },
	"arg": function(c) { var n = 0, f = cst.evFrames.car;
		if (c !== NIL) {
			n = Math.round(numeric(evalLisp(c.car))); if (n < 1) return NIL;
		}
		while (n-- > 0) f = f.cdr;
		return f.car;
	},
	"args": function(c) { return (cst.evFrames.car.cdr === NIL) ? NIL : T; },
	"atom": function(c) { return (evalLisp(c.car) instanceof Cell) ? NIL : T; },
	"bench": function(c) { var t0 = Date.now(), r = prog(c);
		_stdPrint((Date.now() - t0) / 1000 + " sec\n"); return r;
	},
	"bool": function(c) { return (evalLisp(c.car) === NIL) ? NIL : T; },
	"box": function(c) { return box(evalLisp(c.car)); },
	"bye": function(c) { prog(getSymbol("*Bye").getVal());
		if (emuEnv() == "nodejs") { var prv = evalLisp(c.car);
			process.exit((prv instanceof Number) ? prv : 0); } else {
			throw new Error(newErrMsg("Function 'bye' not supported"));
		}
	},
	"caar": function(c) { return car(car(evalLisp(c.car))); },
	"cadddr": function(c) { return car(cdr(cdr(cdr(evalLisp(c.car))))); },
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
	"conc": function(c, ex) {
		var z = evalLisp((ex = ex.cdr).car);
		var x = z;
		var y;
		while ((ex = ex.cdr) instanceof Cell) {
			if (!(x instanceof Cell)) {
				z = x = evalLisp(ex.car);
			} else {
				while ((y = x.cdr) instanceof Cell)
					x = y;
				x.cdr = evalLisp(ex.car);
			}
		}
		return z;
	},
	"cond": function(c) {
		while (c.car instanceof Cell) {
			if (aTrue(evalLisp(c.car.car))) return prog(c.car.cdr);
			c = c.cdr;
		}
		return NIL;
	},
	"cons": function(c) { var r = new Cell(evalLisp(c.car), evalLisp(c.cdr.car)), t = r;
		c = c.cdr.cdr;
		while (c !== NIL) { var d = new Cell(t.cdr, evalLisp(c.car)); t.cdr = d; t = d; c = c.cdr; }
		return r;
	},
	"date": function(c) { var MSPD = 86400000, D1970 = 719469, a1 = evalLisp(c.car), ms1970;
		if ((c === NIL) || (a1 === T)) {
			ms1970 = Date.now();
			if (c === NIL) ms1970 -= (new Date()).getTimezoneOffset() * 60000;	// local (non-UTC)
			return new Number(Math.floor(ms1970 / MSPD) + D1970);
		}
		if (a1 instanceof Cell) {
			ms1970 = validTime1970(a1.car, a1.cdr.car,  a1.cdr.cdr.car);
			return (ms1970 !== null) ? new Number(ms1970 / MSPD + D1970) : NIL;
		}
		if (a1 instanceof Number) {
			if (c.cdr !== NIL) {
				ms1970 = validTime1970(a1, evalLisp(c.cdr.car),  evalLisp(c.cdr.cdr.car));
				return (ms1970 !== null) ? new Number(ms1970 / MSPD + D1970) : NIL;
			}
			var d = new Date((a1 - D1970) * MSPD);
			return new Cell(new Number(d.getUTCFullYear()), new Cell(new Number(d.getUTCMonth() + 1),
				new Cell(new Number(d.getUTCDate()), NIL)));
		}
		return NIL;
	},
	"de": function(c) { var old = c.car.getVal();
		setSymbolValue(c.car, c.cdr);
		if ((old !== NIL) && !eqVal(c.cdr, old)) redefMsg(c.car, null);
		return c.car;
	},
	"dec": function(c) {
		if (c === NIL) return NIL;
		var ns = evalLisp(c.car);
		if (ns instanceof Number) return new Number(ns - 1);
		var v = new Number(ns.getVal() - ((c.cdr !== NIL) ? numeric(evalLisp(c.cdr.car)) : 1));
		ns.setVal(v); return v;
	},
	"def": function(c) { var s = evalLisp(c.car), x = evalLisp(c.cdr.car);
		if (c.cdr.cdr === NIL) {
			var old = s.getVal();
			setSymbolValue(s, x);
			if ((old !== NIL) && (old !== s) && !eqVal(x, old)) redefMsg(s, null);
		} else {
			throw new Error(newErrMsg("Second form not yet implemented"));	// TODO
		}
		return s;
	},
	"delete": function(c) { var a = evalLisp(c.car), lst = evalLisp(c.cdr.car);
		if (!(lst instanceof Cell)) return lst;
		if (eqVal(a, lst.car)) return lst.cdr;
		var r = new List(); r.link(lst.car); lst = lst.cdr;
		while (lst instanceof Cell) {
			if (eqVal(a, lst.car)) { r.last.cdr = lst.cdr; return r.list; }
			r.link(lst.car); lst = lst.cdr;
		}
		r.last.cdr = lst;	// taking care of dotted tail
		return r.list;
	},
	"dm": function(c) { var x, y, s, t;
		if (! ((x = c).car instanceof Cell)) {
			s = x.car;
			t = Class.car;
			// console.log("dm #1: %s", lispToStr(t));
		} else {
			console.log("dm #2, TODO");	// TODO
		}
		if (s !== T) {
			setSymbolValue(s, Meth.car);
			// console.log("dm #3, %s", lispToStr(s));	// TODO: msg. when redefined
		}
		if (x.cdr instanceof Symbol) {
			console.log("dm #4, TODO: %s", lispToStr(x));	// TODO
		}
		for (y = t.car; (y instanceof Cell) && (y.car instanceof Cell); y = y.cdr) {
			if (y.car.car === s) {
				if (! eqVal(x.cdr, y.car.cdr)) {
					console.log("dm #5, %s, %s", lispToStr(s), lispToStr(t));
					redefMsg(s, t);
				}
				y.car.cdr = x.cdr;
				putSrc(t, s);
				return s;
			}
		}
		t.car = (x.car instanceof Cell) ? new Cell(new Cell(s, x.cdr), t.car) : new Cell(x, t.car);
		putSrc(t, s);
		return s;
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
			while (true) {
				if (s2 != null) s2.setVal(new Number(++i));	// increment before condition
				if (evalLisp(a2) === NIL) break;
				var r = iter(b); v = r.v; if (r.m) break;
				if (p != null) s.setVal(evalLisp(p));
			}
		}
		s.popValue();	if (s2 != null) s2.popValue();
		return v;
	},
	"format": function(c) { var cv = evalLisp(c.car);
		// Decimal and thousands separators not implemented yet:
		// http://www.software-lab.de/doc/refF.html#format
		if (cv instanceof Number) return newTransSymbol(cv.toString());
		if (cv.trans) {
			return isNaN(cv.name)? NIL : new Number(parseFloat(cv.name));
		}
		return NIL;
	},
	"ge0": function(c) { var cv = evalLisp(c.car);
		return ((cv instanceof Number) && (cv >= 0)) ? cv : NIL; },
	"get": function(c) { var x = evalLisp(c.car);
		while ((c = c.cdr) instanceof Cell) { x = x.get(evalLisp(c.car)); }
		return x;
	},
	"getl": function(c) { var x = evalLisp(c.car);
		while ((c = c.cdr) instanceof Cell) { x = x.get(evalLisp(c.car)); }
		return x.getl();	// using Symbol.prototype.getl
	},
	"gt0": function(c) { var cv = evalLisp(c.car);
		return ((cv instanceof Number) && (cv > 0)) ? cv : NIL; },
	"idx": function(c) { var s = evalLisp(c.car);
		if (!(s instanceof Symbol)) return NIL;
		if (c.cdr === NIL) { var r = new List(); idxLinkSorted(s.getVal(), r); return r.list; }
		var a = evalLisp(c.cdr.car);
		if (c.cdr.cdr === NIL) return idxLookup(s, a);
		return (evalLisp(c.cdr.cdr.car) === NIL) ? idxDelete(s, a) : idxInsert(s, a);
	},
	"if": function(c) { return aTrue(evalLisp(c.car)) ? evalLisp(c.cdr.car) : prog(c.cdr.cdr); },
	"ifn": function(c) { return aTrue(evalLisp(c.car)) ? prog(c.cdr.cdr) : evalLisp(c.cdr.car); },
	"in": function(c) { // For now only the NIL channel is supported, just for compat with the use of 'read'.
		var chan = c.car;
		if (chan === NIL) {
			return prog(c.cdr);
		} else {
			throw new Error(newErrMsg(CHANNEL_NOT_SUPPORTED, chan));
		}
	},
	"inc": function(c) {
		if (c === NIL) return NIL;
		var ns = evalLisp(c.car);
		if (ns instanceof Number) return new Number(ns + 1);
		var v = new Number(ns.getVal() + ((c.cdr !== NIL) ? numeric(evalLisp(c.cdr.car)) : 1));
		ns.setVal(v); return v;
	},
	"index": function(c) { var i = indx(evalLisp(c.car), evalLisp(c.cdr.car));
		return (i === 0) ? NIL : new Number(i);
	},
	"last": function(c, ex) {
		if (!((x = evalLisp(ex.cdr.car)) instanceof Cell)) return x;
		while (x.cdr instanceof Cell)
			x = x.cdr;
		return x.car;
	},
	"le0": function(c) { var cv = evalLisp(c.car);
		return ((cv instanceof Number) && (cv <= 0)) ? cv : NIL; },
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
	"lt0": function(c) { var cv = evalLisp(c.car);
		return ((cv instanceof Number) && (cv < 0)) ? cv : NIL; },
	"make": function(c) { mkNew(); prog(c); return mkResult(); },
	"mapc": function(c) { var r = NIL, fn = evalLisp(c.car), ci = evalArgs(c.cdr);
		if (! (fn instanceof Symbol)) fn = box(fn);
		while (ci.car !== NIL) { var cj = ci, a = new List();
			while (cj !== NIL) { a.link(cj.car.car); cj.car = cj.car.cdr; cj = cj.cdr; }
			r = evalLisp(new Cell(fn, unevalArgs(a.list)));
		}
		return r;
	},
	"mapcar": function(c) { var fn = evalLisp(c.car), ci = evalArgs(c.cdr), r = new List();
		if (! (fn instanceof Symbol)) fn = box(fn);
		while (ci.car !== NIL) { var cj = ci, a = new List();
			while (cj !== NIL) { a.link(cj.car.car); cj.car = cj.car.cdr; cj = cj.cdr; }
			r.link(evalLisp(new Cell(fn, unevalArgs(a.list))));
		}
		return r.list;
	},
	"method": function(c) { var m = evalLisp(c.car), t = evalLisp(c.cdr.car); TheKey = m;
		return ((m = method(t)) === null) ? NIL : m;
	},
	"n0": function(c) { return eqVal(evalLisp(c.car), ZERO) ? NIL : T; },
	"new": function(c) { var x, s = box(evalLisp(c.car)); TheKey = T; TheCls = null;
		if ((x = method(s)) !== null) {
			evMethod(s, x, c.cdr);
		} else {
			while ((c = c.cdr) !== NIL) { x = evalLisp(c.car); s.put(x, evalLisp((c = c.cdr).car)); }
		}
		return s;
	},
	"next": function(c) { cst.evFrames.car = cst.evFrames.car.cdr; return cst.evFrames.car.car; },
	"not": function(c) { return (evalLisp(c.car) === NIL) ? T : NIL; },
	"nT": function(c) { return (evalLisp(c.car) === T) ? NIL : T; },
	"nth": function(c) { var lst = evalArgs(c); c = lst.cdr;
		do { lst = nth(lst.car, numeric(c.car)); c = c.cdr; } while(c !== NIL); return lst; },
	"num?": function(c) { var v = evalLisp(c.car); return (v instanceof Number) ? v : NIL; },
	"off": function(c) {
		do { setSymbolValue(c.car, NIL); c = c.cdr; } while (c instanceof Cell); return NIL;
	},
	"on": function(c) {
		do { setSymbolValue(c.car, T); c = c.cdr; } while (c instanceof Cell); return T;
	},
	"one": function(c) {
		do { setSymbolValue(c.car, ONE); c = c.cdr; } while (c instanceof Cell); return ONE;
	},
	"or": function(c) { while (c instanceof Cell) { var v = evalLisp(c.car);
			if (aTrue(v)) return v; c = c.cdr; } return NIL;
	},
	// pack has no support for circular lists, same as in PicoLisp
	"pack": function(c) {
		if (c !== NIL) { var s = valueToStr(evalArgs(c)); if (s !== "") return newTransSymbol(s); }
		return NIL;
	},
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
	"pre?": function(c) {
		var s1 = valueToStr(evalLisp(c.car)), v2 = evalLisp(c.cdr.car), s2 = valueToStr(v2);
		if (s1 !== s2.substring(0, s1.length)) return NIL;
		// Handling Cell and Number like PicoLisp, not like Ersatz ...
		return ((v2 instanceof Cell) || (v2 instanceof Number)) ? newTransSymbol(s2) : v2;
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
	"put": function(c) { var x = evalLisp(c.car);	// using Symbol.prototype.put
		for (;;) {
			var y = evalLisp((c = c.cdr).car);
			if (! (c.cdr.cdr instanceof Cell)) return x.put(y, evalLisp(c.cdr.car));
			x = x.get(y);
		}
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
	"quit": function(c) {
		var value = evalLisp(c.cdr.car);
		if (value == NIL) throw new Error(newErrMsg(evalLisp(c.car)));
		else throw new Error(newErrMsg(evalLisp(c.car), value));
	},
	"rand": function(c) { return rand(c, 2147483648); },
	"randfloat": function(c) { return rand(c); },	// not std. PicoLisp
	"range": function(c) {
		var n = numeric(evalLisp(c.car)), n2 = numeric(evalLisp(c.cdr.car)), s = evalLisp(c.cdr.cdr.car);
		if (s === NIL) { s = 1; } else if (numeric(s) <= 0) throw new Error(newErrMsg(BAD_ARG, s));
		if (n > n2) s = -s;
		var r = new List(); do { r.link(n); n = new Number(n + s); } while ((s > 0) ? (n <= n2) : (n >= n2));
		return r.list;
	},
	"read": function(c) { // No support (yet) for the two parameters (non-split chars and comment char).
		if (emuEnv() == 'nodejs') {
			var readlinesync = require('readline-sync');
			readlinesync.setPrompt("");
			_stdPrompt = readlinesync.prompt;
		} else {
			if (typeof stdPrompt != "undefined") {
				var _stdPrompt = stdPrompt;
			} else {
				var _stdPrompt = window.prompt;
			}
		}
		var user_input = _stdPrompt();
		if (emuEnv() == 'nodejs') {
			readlinesync.setPrompt(": ");
		}
		if (user_input === "") {
			return NIL;
		} else {
			return newTransSymbol(user_input);
		}
	},
	"rest": function(c) { return cst.evFrames.car.cdr; },
	"reverse": function(c) { var lst = evalLisp(c.car), r = NIL;
		if (!(lst instanceof Cell)) return NIL;
		do { r = new Cell(lst.car, r); lst = lst.cdr; } while (lst instanceof Cell);
		return r;
	},
	"round": function(c) {
		var len = evalLisp(c.cdr.car);
		if (len == NIL) len = 3;
		var power_of_ten = Math.pow(10, len);
		var num = evalLisp(c.car);
		return newTransSymbol((Math.round(num * power_of_ten) / power_of_ten).toString());
	},
	"run": function(c) { var cv = evalLisp(c.car);
		return (cv instanceof Cell) ? prog(cv) : cv;	// TODO: binding env. offset cnt
	},
	"seed": function(c) { return rand(NIL, 2147483648); },  // not std. PicoLisp
	"send": function(c) { var m = evalLisp(c.car), t = evalLisp(c.cdr.car);
		TheKey = m; TheCls = null;
		console.log("send #1: %s, %s", lispToStr(t), lispToStr(m));
		if ((m = method(t)) === null) throw new Error(newErrMsg(BAD_MSG, TheKey));
		console.log("send #2: %s, %s", lispToStr(t), lispToStr(m));
		return evMethod(t, m, c.cdr.cdr);
	},
	"set": function(c, ex) {
		//console.log("set: %s, %s", lispToStr(c), lispToStr(ex));
		var x = c, y;
		do {
			y = evalLisp(x.car);
			needVar(ex, y);
			y.car = evalLisp((x = x.cdr).car);
		} while ((x = x.cdr) instanceof Cell);
		return y.car;
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
	"space": function(c) { var n = 1, s;
		if (c.car !== NIL) n = numeric(evalLisp(c.car));
		for (s = ""; s.length < n; s += " ") {}
		if (s > "") _stdPrint(s);
		return new Number(n);
	},
	"split": function(c) {
		var lst = evalLisp(c.car);
		if (lst instanceof Cell) {
			var x = c.cdr, arr = []; while (x !== NIL) { arr.push(evalLisp(x.car)); x = x.cdr; }
			var r1 = new List(), r2 = new List();
			do { var i; for (i=0; i<arr.length && !eqVal(lst.car, arr[i]); i++) {}
				if (i<arr.length) { r1.link(r2.list); r2 = new List(); } else r2.link(lst.car);
				lst = lst.cdr;
			} while (lst instanceof Cell);
			r1.link(r2.list);
			return r1.list;
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
	"str?": function(c) { var v = evalLisp(c.car); return ((v instanceof Symbol) && v.trans) ? v : NIL; },
	"super": function(c, ex) {
		TheKey = Env.Key;
		var x = (Env.Cls == null) ? This.car : Env.Cls.car.car;
		while (x.car instanceof Cell) { x = x.cdr; }
		for (;;) {
			if (!(x instanceof Cell)) throw new Error(newErrMsg(BAD_SUPER, TheKey));
			var y;
			if ((y = method((TheCls = x).car)) != null) {
				var z = Env.Cls;	Env.Cls = TheCls;
				var w = Env.Key;	Env.Key = TheKey;
				x = y.func(ex);
				Env.Key = w;  Env.Cls = z;
				return x;
			}
		}
	},
	"sym": function(c) { return newTransSymbol(evalLisp(c.car).toString()); },
	"sym?": function(c) { return (evalLisp(c.car) instanceof Symbol) ? T : NIL; },
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
	"try": function(c, ex) { var x = evalLisp((ex = ex.cdr).car), y;
		if ((y = evalLisp((ex = ex.cdr).car)) instanceof Symbol) {
			TheKey = x;	TheCls = null;
			if ((x = method(y)) !== null) return evMethod(y, x, ex.cdr);
		}
		return NIL;
	},
	"untrace": function(c) {
		var s = evalLisp(c.car), f = cdr(cdr(car(cdr(evalLisp(s))))), b = car(cdr(f));
		if (car(b) === cst.iSym["pass"]) f = evalLisp(car(cdr(b)));
		setSymbolValue(s, f);
		return s;
	},
	"usec": function(c) { return new Number((Date.now() - cst.startupMillis) * 1000); },
	"val": function(c, ex) { var x = evalLisp(c.car); needVar(ex, x); return x.car; },
	"version": function(c) { if (!aTrue(evalLisp(c.car))) _stdPrint(VERSION.join(".") + " JS\n");
		var v = new List(); for (var i=0; i<VERSION.length; i++) { v.link(VERSION[i]); }; return v.list; },
	"while": function(c) {
		var v = NIL; while (aTrue(evalLisp(c.car))) { v = prog(c.cdr); }; return v;
	},
	"wipe": function(c) { var x = evalLisp(c.car);
		// TODO: highly temporary implementation, doesn't handle list arg.
		if (x instanceof Symbol) {
			x.setVal(NIL);
			x.props = NIL;
		}
		return x;
	},
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
	"%": function(c) { var t = evalLisp(c.car); if (t === NIL) return NIL;
		t = numeric(t);
		while (c.cdr !== NIL) {
			c = c.cdr;
			var v = evalLisp(c.car); if (v === NIL) return NIL;
			if (numeric(v) == 0) throw new Error(newErrMsg(DIV_0));
			t = t.rem(v);
		}
		return t;
	},
	"*": function(c) { var t = 1;
		do { var v = evalLisp(c.car); if (v === NIL) return NIL;
			t *= numeric(v); c = c.cdr; } while (c instanceof Cell); return new Number(t);
	},
	"**": function(c) { var n1 = evalLisp(c.car), n2 = evalLisp(c.cdr.car);
		return (n2 instanceof Number) ? numeric(n1).pow(n2) : ZERO;
	},
	"/": function(c) { return divs(c, function(a, b) { return a / b; }); },	// floating point division
	"/t": function(c) { return divs(c, function(a, b) { var d = a / b;
		return (d >= 0) ? Math.floor(d) : Math.ceil(d); }); },	// truncated division
	"=": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) { d = d.cdr; dv = evalLisp(d.car); if (!eqVal(cv, dv)) return NIL; }; return T; },
	"=0": function(c) { return eqVal(evalLisp(c.car), ZERO) ? ZERO : NIL; },
	"==": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) { d = d.cdr; dv = evalLisp(d.car); if (cv !== dv) return NIL; }; return T; },
	"=T": function(c) { return (evalLisp(c.car) === T) ? T : NIL; },
	"=:": function(c) {
		for (var x = This.car;; c=c.cdr) { var y = c.car;
			if (!(c.cdr.cdr instanceof Cell)) return x.put(y, evalLisp(c.cdr.car));
			x = x.get(y);
		}
	},
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
	"<>": function(c) { var cv = evalLisp(c.car), d = c, dv;
		while (d.cdr !== NIL) { d = d.cdr; dv = evalLisp(d.car); if (!eqVal(cv, dv)) return T; }; return NIL; },
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
	":": function(c, ex) { var x = This.car;
		do { x = x.get((ex = ex.cdr).car); } while (ex.cdr instanceof Cell); return x;
	},
	"::": function(c) { var x = This.car;
		while (c.cdr instanceof Cell) { x = x.get(c.car); c = c.cdr; };
		return x.prop(c.car);
	},
	";": function(c) { var x = evalLisp(c.car);
		while ((c = c.cdr) instanceof Cell) { x = x.get(c.car); }
		return x;
	}
};

function internalSymbolsInclPrimitives() {
	var symbols = {NIL: NIL, T: T, "@": A1, "@@": A2, "@@@": A3, "meth": Meth, "This": This, "*Class": Class};
	var names = Object.keys(coreFunctions);
	for (var i=0; i<names.length; i++) {
		var name = names[i];
		if (name in gEmptyObj) throw new Error(newErrMsg(JS_RESERVED, name));
		symbols[name] = new Symbol(name, coreFunctions[name]);
	}
	return symbols;
}

prepareNewState();

function evalDef(def, lst) {
	var inExprLst = lst.cdr, locVars = null, locSym = null, evFrame = null;
	if (def.car instanceof Symbol) {
		if (def.car === A1) {
			evFrame = new Cell(NIL, evalArgs(inExprLst));
			cst.evFrames = new Cell(evFrame, cst.evFrames);	// pushing evFrame onto cst.evFrames
		} else if (! def.car.lock) {
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
	//console.log("evalDef: %s", lispToStr(def));
	var res = prog(def.cdr);
	// Restoring previous symbol values ...
	if (locSym instanceof Symbol) locSym.popValue();
	if (locVars instanceof Cell) {
		while (locVars instanceof Cell) { locVars.car.popValue(); locVars = locVars.cdr; }
	}
	if (evFrame instanceof Cell) cst.evFrames = cst.evFrames.cdr;		// popping evFrame
	return res;
}

function evMethod(o, ex, x) {	// Ersatz-like
	var i, y = ex.car, cls = TheCls, key = TheKey;
	//console.log("evMethod #1: %s, %s, %s, %s, %s", lispToStr(o), lispToStr(ex), lispToStr(x), cls, lispToStr(key));
	var bnd = new Bind();  bnd.add(A1.car);  bnd.add(A1);
	while (y instanceof Cell) {
		bnd.add(evalLisp(x.car));	// Save new value
		bnd.add(y.car);				// and symbol
		x = x.cdr;
		y = y.cdr;
	}
	if (y === NIL || y !== A1) {
		i = bnd.Cnt;
		if (y !== NIL) {
			bnd.add(y.car);	// Save old value
			bnd.add(y);			// and symbol
			y.car = x;			// Set new value
		}
		do {
			y = bnd.Data[--i];
			x = y.car;
			y.car = bnd.Data[--i];	// Set new value
			bnd.Data[i] = x;			// Save old value
		} while (i > 0);
		bnd.add(This.car);
		bnd.add(This);
		This.car = o;
		Env.Bind = bnd;
		y = cls;  cls = Env.Cls;  Env.Cls = y;
		y = key;  key = Env.Key;  Env.Key = y;
		//console.log("evMethod #2: %s", lispToStr(ex.cdr));
		x = prog(ex.cdr);
	} else {
		var next, argc, j = 0;
		throw new Error(newErrMsg("evMethod not yet fully implemented"));	// TODO
	}
	for (i = bnd.Cnt; (i -= 2) >= 0;) {
		bnd.Data[i+1].car = bnd.Data[i];
	}
	Env.Bind = bnd.Link;
	Env.Cls = cls;  Env.Key = key;
	return x;
}

function method(x) {	// Ersatz-like
	var y, z;
	if ((y = x.car) instanceof Cell) {
		while ((z = y.car) instanceof Cell) {
			if (z.car === TheKey) return z.cdr;
			if (!((y = y.cdr) instanceof Cell)) return null;
		}
		do {
			if ((x = method((TheCls = y).car)) !== null) return x;
		} while ((y = y.cdr) instanceof Cell);
	}
	return null;
}

function evalMeth(m, lst) {
	//console.log("evalMeth: %s, %s", lispToStr(m), lispToStr(lst));
	var t = evalLisp(lst.car);
	TheKey = m; TheCls = null;
	if ((m = method(t)) === null) throw new Error(newErrMsg(BAD_MSG, TheKey));
	return evMethod(t, m, lst.cdr);
}

function evalLisp(lst) {
	if (lst instanceof Symbol) return lst.car;
	if (lst instanceof Cell) {
		if (typeof lst.car.car === "function") {
			return lst.car.car(lst.cdr, lst);	// should have been only lst in the first place
		}
		if (lst.car instanceof Symbol) {
			var s = lst.car;
			if (s.car === NIL) throw new Error(newErrMsg(UNDEF, s));
			return (s.car === Meth.car) ? evalMeth(s, lst.cdr) : evalDef(s.car, lst);
		}
		if ((lst.car.car === QUOTE) && (lst.car.cdr instanceof Cell)) {
			return evalDef(lst.car.cdr, lst);
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

function loadLispStr(srcString) {
	cst.tSym = {};
	var res = parseList(new Source(srcString), true);
	cst.tSym = {};
	//console.log("loadLispStr: res=%s", lispToStr(res));
	return res;
}

function loadLisp(fileUrl) {
	return loadLispStr(getFileSync(fileUrl));
}

function loadJavaScript(fileUrl) {
	var res = eval(getFileSync(fileUrl));
	return (res !== undefined) ? newTransSymbol(res.toString()) : NIL;
}

function _stdPrint(text) {
	if (typeof stdPrint === "function") stdPrint(text, cst)
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

	evalArgs: evalArgs, evalLisp: evalLisp, lispToStr: lispToStr, loadLisp: loadLisp,
	loadLispStr: loadLispStr, newErrMsg: newErrMsg,
	newTransSymbol: newTransSymbol, prog: prog, valueToStr: valueToStr, Params: Params,
	NIL: NIL, T: T,

	getFileSync: getFileSync,
	
	eval: function(code) {
		var result = prog(parseList(new Source(code)));
		A3.setVal(A2.getVal()); A2.setVal(A1.getVal()); A1.setVal(result);
		return result.toString();
	}
}

function testExports() {
	var pubKeys = Object.keys(pub);
	for (var i=0; i<pubKeys.length; i++) {
		console.log("pub.%s: %s", pubKeys[i], typeof pub[pubKeys[i]]);
	}
}
//testExports();

return pub;

}());
