/* 12feb14jk
 * (c) Jon Kleiser
 */

var EMULISP_CV = (function (ec) {
	
	var deFn = ec.forSymbolWithNameDefineFun,
		boxNativeObject = ec.boxNativeObject,
		isCell = ec.isCell,
		//evalArgs = ec.evalArgs,
		evalLisp = ec.evalLisp,
		lispToStr = ec.lispToStr,
		newErrMsg = ec.newErrMsg,
		newTransSymbol = ec.newTransSymbol,
		prog = ec.prog,
		valueToStr = ec.valueToStr,
		Params = ec.Params,
		NIL = ec.NIL, T = ec.T;

	var gCvContext2d = null;
	
	function ensureCtx() {
		if (gCvContext2d) return;
		throw new Error(newErrMsg("No canvas context"));
	}
	
	// (cv:setctx2d "testCanvas")
	deFn("cv:setctx2d", function(c) {
		var cvid = evalLisp(c.car), cv = document.getElementById(valueToStr(cvid));
		if (cv && cv.getContext) {
			gCvContext2d = cv.getContext("2d");
			return cvid;
		}
		return NIL;
	});

// This combines save and restore, use: (cv:saveRestore (...) (...) ... )
deFn("cv:saveRestore", function(c) {
	ensureCtx(); gCvContext2d.save();
	var r = prog(c);
	gCvContext2d.restore(); return r;
});

deFn("cv:addColorStop", function(c) { var p = new Params(c), gradient = p.natObj();
	gradient.addColorStop(p.num(), p.str()); return T;
});
	
	// (cv:arc 150 150 100 0 3.14 T)
	deFn("cv:arc", function(c) { var p = new Params(c);
		ensureCtx();
		gCvContext2d.arc(p.num(), p.num(), p.num(), p.num(), p.num(), p.bool(T)); return T;
	});

deFn("cv:arcTo", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.arcTo(p.num(), p.num(), p.num(), p.num(), p.num()); return T;
	// Resulting graphics seem to be browser dependent.
});
	
	// (cv:beginPath)
	deFn("cv:beginPath", function(c) { ensureCtx(); gCvContext2d.beginPath(); return T; });

deFn("cv:bezierCurveTo", function(c) { var p = new Params(c);
	ensureCtx();
	gCvContext2d.bezierCurveTo(p.num(), p.num(), p.num(), p.num(), p.num(), p.num()); return T;
});
	
	// (cv:clearRect 80 50 200 200)
	deFn("cv:clearRect", function(c) { var p = new Params(c);
		ensureCtx(); gCvContext2d.clearRect(p.num(), p.num(), p.num(), p.num()); return T;
	});

// ('clearShadow' seems to be Safari or WebKit specific.)

// (cv:clip)
deFn("cv:clip", function(c) { ensureCtx(); gCvContext2d.clip(); return T; });
	
	// (cv:closePath)
	deFn("cv:closePath", function(c) { ensureCtx(); gCvContext2d.closePath(); return T; });

// (cv:createImageData 320 240), or (cv:createImageData ImgData), both return ImageData
deFn("cv:createImageData", function(c) { var p = new Params(c), v = p.any();
	ensureCtx();
	if (v instanceof Number) {
		return boxNativeObject(gCvContext2d.createImageData(v, p.num()));		// sw, sh
	} else if ((v instanceof Symbol) && (v.obj !== undefined)) {
		return boxNativeObject(gCvContext2d.createImageData(v.obj));			// ImageData
	}
	throw new Error(newErrMsg(BOXNAT_EXP, v));
});

// (cv:createLinearGradient 0 50 0 95)
deFn("cv:createLinearGradient", function(c) { var p = new Params(c);
	ensureCtx();
	return boxNativeObject(gCvContext2d.createLinearGradient(p.num(), p.num(), p.num(), p.num()));
});

// TODO: createPattern

// (cv:createRadialGradient 45 45 10 52 50 30)
deFn("cv:createRadialGradient", function(c) { var p = new Params(c);
	ensureCtx();
	return boxNativeObject(
		gCvContext2d.createRadialGradient(p.num(), p.num(), p.num(), p.num(), p.num(), p.num()));
});

deFn("cv:drawImage", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.drawImage(p.natObj(), p.num(), p.num()); return T;
	// TODO: more params
});

// TODO: drawImageFromRect

// (cv:fill)
deFn("cv:fill", function(c) { ensureCtx(); gCvContext2d.fill(); return T; });

// (cv:fillRect 80 50 200 200)
deFn("cv:fillRect", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.fillRect(p.num(), p.num(), p.num(), p.num()); return T;
});
	
	// Converts a JavaScript style to Lisp data (by wrapping)
	function stringOrBoxObject(style) {
		return ((typeof style == "string") || (style instanceof Symbol)) ?
			newTransSymbol(style) : boxNativeObject(style);
	}
	
	// Converts Lisp data to a JavaScript style (by unwrapping)
	function stringOrGradient(sym) {
		return (sym.obj === undefined) ? sym.toValueString() : sym.obj;
	}

// (cv:fillStyle "#6060f0")
// If called as getter, (cv:fillStyle), most browsers will return "#000000" or "black".
deFn("cv:fillStyle", function(c) {
	ensureCtx(); if (c === NIL) return stringOrBoxObject(gCvContext2d.fillStyle);
	var v = evalLisp(c.car); gCvContext2d.fillStyle = stringOrGradient(v); return v;
});
	
	// (cv:fillText "Hello Lisper!" 50 40)
	deFn("cv:fillText", function(c) { var p = new Params(c);
		var s = p.str(), n1 = p.num(), n2 = p.num(), n3 = p.optNum(); ensureCtx();
		// Not all browsers (Chrome) accept 'null' as the optional 'maxWidth' parameter at the end.
		if (n3 === null) { gCvContext2d.fillText(s, n1, n2); }
		else { gCvContext2d.fillText(s, n1, n2, n3); }
		return T;
	});
	
	// (cv:font "18px sans-serif")
	deFn("cv:font", function(c) {
		ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.font);
		var v = evalLisp(c.car); gCvContext2d.font = valueToStr(v); return v;
	});

// TODO: getImageData

// (cv:globalAlpha 1)
deFn("cv:globalAlpha", function(c) {
	ensureCtx(); if (c === NIL) return new Number(gCvContext2d.globalAlpha);
	var v = evalLisp(c.car); gCvContext2d.globalAlpha = numeric(v); return v;
});

// (cv:globalCompositeOperation "source-over")
deFn("cv:globalCompositeOperation", function(c) {
	ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.globalCompositeOperation);
	var v = evalLisp(c.car); gCvContext2d.globalCompositeOperation = valueToStr(v); return v;
});

// TODO: isPointInPath

// (cv:lineCap "round")
deFn("cv:lineCap", function(c) {
	ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.lineCap);
	var v = evalLisp(c.car); gCvContext2d.lineCap = valueToStr(v); return v;
});

// (cv:lineJoin "miter")
deFn("cv:lineJoin", function(c) {
	ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.lineJoin);
	var v = evalLisp(c.car); gCvContext2d.lineJoin = valueToStr(v); return v;
});

// (cv:lineTo 50 50)
deFn("cv:lineTo", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.lineTo(p.num(), p.num()); return T;
});

// (cv:lineWidth 4)
deFn("cv:lineWidth", function(c) {
	ensureCtx(); if (c === NIL) return new Number(gCvContext2d.lineWidth);
	var v = evalLisp(c.car); gCvContext2d.lineWidth = numeric(v); return v;
});

// TODO: measureText

// (cv:miterLimit 10)
deFn("cv:miterLimit", function(c) {
	ensureCtx(); if (c === NIL) return new Number(gCvContext2d.miterLimit);
	var v = evalLisp(c.car); gCvContext2d.miterLimit = numeric(v); return v;
});

// (cv:moveTo 50 50)
deFn("cv:moveTo", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.moveTo(p.num(), p.num()); return T;
});

// (cv:putImageData ImgData 0 0), ...
deFn("cv:putImageData", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.putImageData(p.natObj(), p.num(), p.num()); return T;
	// TODO: more params
});

// (cv:quadraticCurveTo 0 0 10 0)
deFn("cv:quadraticCurveTo", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.quadraticCurveTo(p.num(), p.num(), p.num(), p.num()); return T;
});

// (cv:rect 80 50 200 200)
deFn("cv:rect", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.rect(p.num(), p.num(), p.num(), p.num()); return T;
});

// (cv:rotate 3.14)
deFn("cv:rotate", function(c) {
	ensureCtx(); var v = numeric(evalLisp(c.car)); gCvContext2d.rotate(v); return T;
});

// (cv:scale 1 2)
deFn("cv:scale", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.scale(p.num(), p.num()); return T;
});

// TODO: setAlpha
// TODO: setCompositeOperation
// TODO: setFillColor
// TODO: setLineCap
// TODO: setLineJoin
// TODO: setLineWidth
// TODO: setMiterLimit
// TODO: setShadow
// TODO: setStrokeColor
// TODO: setTransform

// (cv:shadowBlur 0)
deFn("cv:shadowBlur", function(c) {
	ensureCtx(); if (c === NIL) return new Number(gCvContext2d.shadowBlur);
	var v = evalLisp(c.car); gCvContext2d.shadowBlur = numeric(v); return v;
});

// (cv:shadowColor "black")
deFn("cv:shadowColor", function(c) {
	ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.shadowColor);
	var v = evalLisp(c.car); gCvContext2d.shadowColor = valueToStr(v); return v;
});

// (cv:shadowOffsetX 0)
deFn("cv:shadowOffsetX", function(c) {
	ensureCtx(); if (c === NIL) return new Number(gCvContext2d.shadowOffsetX);
	var v = evalLisp(c.car); gCvContext2d.shadowOffsetX = numeric(v); return v;
});

// (cv:shadowOffsetY 0)
deFn("cv:shadowOffsetY", function(c) {
	ensureCtx(); if (c === NIL) return new Number(gCvContext2d.shadowOffsetY);
	var v = evalLisp(c.car); gCvContext2d.shadowOffsetY = numeric(v); return v;
});
	
	// (cv:stroke)
	deFn("cv:stroke", function(c) { ensureCtx(); gCvContext2d.stroke(); return T; });

// (cv:strokeRect 80 50 200 200)
deFn("cv:strokeRect", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.strokeRect(p.num(), p.num(), p.num(), p.num()); return T;
});
	
	// (cv:strokeStyle "#6060f0")
	// If called as getter, (cv:strokeStyle), most browsers will return "#000000" or "black".
	deFn("cv:strokeStyle", function(c) {
		ensureCtx(); if (c === NIL) return stringOrBoxObject(gCvContext2d.strokeStyle);
		var v = evalLisp(c.car); gCvContext2d.strokeStyle = stringOrGradient(v); return v;
	});
	
	// (cv:strokeText "Hello Lisper!" 50 40)
	deFn("cv:strokeText", function(c) { var p = new Params(c);
		var s = p.str(), n1 = p.num(), n2 = p.num(), n3 = p.optNum(); ensureCtx();
		// Not all browsers (Chrome) accept 'null' as the optional 'maxWidth' parameter at the end.
		if (n3 === null) { gCvContext2d.strokeText(s, n1, n2); }
		else { gCvContext2d.strokeText(s, n1, n2, n3); }
		return T;
	});

// (cv:textAlign "start")
deFn("cv:textAlign", function(c) {
	ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.textAlign);
	var v = evalLisp(c.car); gCvContext2d.textAlign = valueToStr(v); return v;
});

// (cv:textBaseline "alphabetic")
deFn("cv:textBaseline", function(c) {
	ensureCtx(); if (c === NIL) return newTransSymbol(gCvContext2d.textBaseline);
	var v = evalLisp(c.car); gCvContext2d.textBaseline = valueToStr(v); return v;
});

// TODO: transform

// (cv:translate 50 50)
deFn("cv:translate", function(c) { var p = new Params(c);
	ensureCtx(); gCvContext2d.translate(p.num(), p.num()); return T;
});

	function drawLispRecur(ctx, c) {
		var  segx = 16, dy = 16, c0 = c, h = 0;
		if (isCell(c)) {
			while (isCell(c)) {
				ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(segx, 0); ctx.stroke();
				ctx.save();
				ctx.translate(segx, 0);
				var cy = drawLispRecur(ctx, c.car);
				h += cy;
				ctx.restore();
				c = c.cdr;
				if (c !== NIL) {
					ctx.translate(0, cy);
					ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(0, -h); ctx.stroke();
					if (c === c0) {
						// Indicating circular list ...
						var up = -dy/4;
						ctx.beginPath(); ctx.moveTo(0, up*2); ctx.lineTo(segx/2, up*2); ctx.stroke();
						ctx.beginPath(); ctx.moveTo(0, up); ctx.lineTo(segx/2, up); ctx.stroke();
						h += dy;
						break;
					}
				}
			}
			if ((c !== NIL) && (c !== c0)) {
				ctx.fillText(lispToStr(c), -3, 12);
				h += dy * 1.7;
			}
		} else {
			ctx.fillText(lispToStr(c), 4, 3);
			h = dy;
		}
		return h;
	}

	// (cv:drawLisp "testCanvas" '(a b c))
	deFn("cv:drawLisp", function(c) {
		var cvid = evalLisp(c.car), cv = document.getElementById(valueToStr(cvid));
		if (cv && cv.getContext) {
			var ctx = cv.getContext("2d");
			ctx.save();
			ctx.strokeStyle = "#933";
			ctx.lineWidth = 1;
			ctx.fillStyle = "#000";
			ctx.font = "12px Arial, sans-serif";
			ctx.translate(16.5, 16.5);
			drawLispRecur(ctx, evalLisp(c.cdr.car));
			ctx.restore();
			return cvid;
		}
		throw new Error(newErrMsg("No canvas context"));
		//return NIL;
	});

// A utility function for exporting graphics as a "file" to a separate window:
// (cv:export "monView" "png" 400 320)
deFn("cv:export", function(c) {
	var cvid = evalLisp(c.car), cv = document.getElementById(valueToStr(cvid)),
		fmt = "png", winWidth = "400", winHeight = "320";
	if (c.cdr.car !== NIL) {
		fmt = valueToStr(evalLisp(c.cdr.car));	//	gif, jpeg, png, tiff
		if (c.cdr.cdr.car !== NIL) {
			winWidth = valueToStr(evalLisp(c.cdr.cdr.car));
			if (c.cdr.cdr.cdr.car !== NIL) {
				winHeight = valueToStr(evalLisp(c.cdr.cdr.cdr.car));
			}
		}
	}
	window.open(cv.toDataURL("image/" + fmt), "_blank",
		"width=" + winWidth + ", height=" + winHeight);
	return T;
});	

	var pub = {
		drawLispRecur: drawLispRecur
	};

	return pub;

}(EMULISP_CORE));
