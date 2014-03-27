/* 11feb14jk
 * (c) Jon Kleiser
 */

var EMULISP_JS = (function (ec) {
	
	var deFn = ec.forSymbolWithNameDefineFun,
		forSymbolWithNamePushValue = ec.forSymbolWithNamePushValue,
		forSymbolWithNameSetValue = ec.forSymbolWithNameSetValue,
		boxNativeObject = ec.boxNativeObject,
		isCell = ec.isCell,
		isSymbol = ec.isSymbol,
		evalArgs = ec.evalArgs,
		evalLisp = ec.evalLisp,
		newTransSymbol = ec.newTransSymbol,
		prog = ec.prog,
		valueToStr = ec.valueToStr,
		NIL = ec.NIL, T = ec.T;
	
	forSymbolWithNameSetValue("js:E", new Number(Math.E));
	forSymbolWithNameSetValue("js:PI", new Number(Math.PI));
	forSymbolWithNameSetValue("js:Doc", boxNativeObject(document));
	forSymbolWithNameSetValue("js:Win", boxNativeObject(window));

	deFn("js:alert", function(c) { var arr = [], v = NIL;
		c = evalArgs(c); while (c !== NIL) { v = c.car; arr.push(valueToStr(v)); c = c.cdr; }
		alert(arr.join("\n")); return v;
	});

	deFn("js:confirm", function(c) { var arr = [];
		c = evalArgs(c); while (c !== NIL) { arr.push(valueToStr(c.car)); c = c.cdr; }
		return confirm(arr.join("\n")) ? T : NIL;
	});

	// (js:prompt "What's your age?" "sixtysomething")
	deFn("js:prompt", function(c) {
		var r = prompt(valueToStr(evalLisp(c.car)), valueToStr(evalLisp(c.cdr.car)));
		return (r !== null) ? newTransSymbol(r) : NIL;
	});

	deFn("js:getElementById", function(c) {
		var doc = document, elem = doc.getElementById(evalLisp(c.car).valueOf());
		return (elem != null) ? boxNativeObject(elem) : NIL;
	});

	// (js:onEventLisp (js:getElementById "dummy") "click" (prinl "A click on " js:Target))
	deFn("js:onEventLisp", function(c) {
		var objBox = evalLisp(c.car), obj = objBox.obj, evtType = evalLisp(c.cdr.car).valueOf();
		obj[evtType + "Lisp"] = c.cdr.cdr;	// Lisp code to execute on event
		if (c.cdr.cdr != NIL) {
			// Installing event handler
			obj["on" + evtType] = function(evt) {
				try {
					var ts = forSymbolWithNamePushValue("js:Target", objBox);
					var es = forSymbolWithNamePushValue("js:Event",
									boxNativeObject(evt ? evt : window.event));
					prog(obj[evtType + "Lisp"]);
					ts.popValue();
					es.popValue();
				} catch (e) { alert(evtType + "Lisp: " + e); }
			};
		} else {
			// Removing event handler (no Lisp code given after event type)
			obj["on" + evtType] = null;
		}
		return objBox;
	});

	// (js:clearInterval intervalId)
	deFn("js:clearInterval", function(c) { return clearInterval(evalLisp(c.car)) ? T : NIL; });

	// (js:clearTimeout timeoutId)
	deFn("js:clearTimeout", function(c) { return clearTimeout(evalLisp(c.car)) ? T : NIL; });

	/* Most browsers seem to support the form of setInterval(f,t,p) and setTimeout(f,t,p) where
		the first parameter is of type function, and the parameters after the second are parameters
		to that function. If your browser requires the first parameter to be of type string, then
		you can use the two slightly longer alternatives.
	*/
	// (js:setIntervalLisp (prinl "ping") 5000)
	deFn("js:setIntervalLisp", function(c) {
		var id = setInterval(evalLisp, evalLisp(c.cdr.car), c.car);
		return new Number(id);
	});
	/*
	deFn("js:setIntervalLisp", function(c) {
		var str = lispToStr(c.car);
		gParseCache[str] = c.car;
		var jsStr = "evalLisp(gParseCache[\"" + str.replace(/"/g, "\\\"") + "\"])";
		var id = setInterval(jsStr, evalLisp(c.cdr.car));
		return new Number(id);
	});
	*/
	// (js:setTimeoutLisp (prinl "ping") 3000)
	deFn("js:setTimeoutLisp", function(c) {
		var id = setTimeout(evalLisp, evalLisp(c.cdr.car), c.car);
		return new Number(id);
	});
	/*
	deFn("js:setTimeoutLisp", function(c) {
		var str = lispToStr(c.car);
		gParseCache[str] = c.car;
		var jsStr = "evalLisp(gParseCache[\"" + str.replace(/"/g, "\\\"") + "\"])";
		var id = setTimeout(jsStr, evalLisp(c.cdr.car));
		return new Number(id);
	});
	*/


	// Some reflection stuff similar to the 'java' and 'public' functions in ErsatzLisp

	function applyConstructor(ctor, args) {
		switch (args.length) {
			case 0: return new ctor();
			case 1: return new ctor(args[0]);
			case 2: return new ctor(args[0], args[1]);
			case 3: return new ctor(args[0], args[1], args[2]);
			// add more cases if you like
		}
		var jsStr = "new ctor(args[0]";
		for (var i=1; i<args.length; i++) jsStr += ",args[" + i + "]";
		jsStr += ")";
		return eval(jsStr);
	}

	// First a couple of conversion functions ...
	function lispToNativeData(vl) {
		if (vl instanceof Number) return vl.valueOf();	// primitive value required some places
		if (isSymbol(vl)) {
			if (vl.obj !== undefined) return vl.obj;
			return vl.toValueString();
		}
		if ((vl === NIL) || (vl === T)) return vl.bool;
		return undefined;
	}
	
	function nativeToLispData(vn) {
		if ((typeof vn == "number") || (vn instanceof Number)) return new Number(vn);
		if (vn instanceof String) vn = vn.valueOf();
		if (typeof vn == "string") return (vn == "") ? NIL : newTransSymbol(vn);
		if (vn instanceof Boolean) vn = vn.valueOf();
		if ((vn === false) || (vn === null)) return NIL;
		if (vn === true) return T;
		return boxNativeObject(vn);
	}
	
	function lispParamsToArray(c) {
		var arr = [];
		while (c !== NIL) {
			arr.push(lispToNativeData(evalLisp(c.car))); c = c.cdr;
		}
		return arr;
	}
	
	// (js:eval "2+3")
	deFn("js:eval", function(c) {
		return nativeToLispData(eval(valueToStr(evalLisp(c.car))));
	});

	// (setq *MyArr (js:obj "Array" T)) (js:put *MyArr "2" "X") (list (js:get *MyArr 2) (js:get *MyArr "length"))
	// (js:obj (js:obj "Date" T) "getMinutes")
	// (js:obj (js:obj "Date" T 2014 01 10 21 15) "toString")
	// (let D (js:obj "Date" T) (js:obj D "setHours" 16 30) (js:obj D "toString"))
	deFn("js:obj", function(c) {
		var obj = evalLisp(c.car), msg = evalLisp(c.cdr.car);
		if (msg === T) {
			if (isSymbol(obj)) {
				var ctor = eval(obj.valueOf());
				//if (typeof ctor != "function") throw new Error(newErrMsg(JS_CTORNAME_EXP, obj.valueOf()));
				// typeof Date == "function", but typeof Image == "object" !
				return nativeToLispData(applyConstructor(ctor, lispParamsToArray(c.cdr.cdr)));
			}
			throw new Error(newErrMsg(SYM_EXP, obj));
		}
		if (isSymbol(obj) && (obj.obj instanceof Object)) {
			var fn = obj.obj[lispToNativeData(msg)];
			return nativeToLispData(fn.apply(obj.obj, lispParamsToArray(c.cdr.cdr)));
		}
		throw new Error(newErrMsg(BOXNAT_EXP, obj));
	});

	function jsGetPutAlg(c, put) {
		var obj = evalLisp(c.car), k;
		if (isSymbol(obj) && (obj.obj !== undefined)) {
			obj = obj.obj; c = c.cdr;
			do {
				k = lispToNativeData(evalLisp(c.car));
				c = c.cdr;
				if (put && ! isCell(c.cdr)) {
					var vl = evalLisp(c.car), vn = lispToNativeData(vl);
					obj[k] = vn;	// handles both maps/keys and arrays/indices
					return vl;
				}
				obj = obj[k];	// handles both maps/keys and arrays/indices
			} while (isCell(c));
			return nativeToLispData(obj);
		}
		throw new Error(newErrMsg(BOXNAT_EXP, obj));
	}

	// (js:get js:Doc "body" "nodeName")
	deFn("js:get", function(c) { return jsGetPutAlg(c, false); });

	// (js:put js:Doc "body" "contentEditable" "true")
	deFn("js:put", function(c) { return jsGetPutAlg(c, true); });

	var pub = {	
	};

	return pub;

}(EMULISP_CORE));
