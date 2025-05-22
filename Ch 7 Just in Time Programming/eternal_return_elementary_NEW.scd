

// eternal return.
// nonlinear history for live and experimental just in time programming.
// Julian Rohrhuber 2007 / 2022

/*


This program will give access to any ProxySpace (or subclass of LazyEnvir / EnvironmentRedirect) that is present as current environment. If none is present, it will create a ProxySpace and push it.
You can make changes to the ProxySpace at runtime and jump fore and back.

It creates a document window with some temporal navigations.
This document is a throw away GUI, it can be closed anytime.

- the black stripe is the current time. here the edits become visible.
- the first number box is the current time
- the last number box represents the length of history, after which we return to beginning

Buttons:
_	navigate in time without entering it (toggles)
->	start time / stop time (toggles)
<<	rewind to beginning of time
:<	step back to previous edit
>:	step forward to next edit
<	backward 0.25 sec in time
>	forward 0.25 sec in time
p	post the complete history
rm	remove the current entry
ld	load an appropriate history


*/


(
var w, txt, value = 0, mapVal, valMap, loadFunc, scaledValue = 0, tmax = 4 * 60 + 33, delta = 0.25;
var ff, fne, fla, fba, fne2, fla2, m,  v, vv, mmax, task, changed, updateWindowTitle, running = false;
var drawLine, toggleHistory, dispatch;
var browseBut, browseMode = false;
var nietzsche, windowTitle, temporaryPseudoEnvironment, proxyspace;
var width = 700;
temporaryPseudoEnvironment = EnvironmentRedirect.new;

if(Quarks.isInstalled("JITLibExtensions").not) { "Please install JITLibExtensions Quark first".warn; this.halt };

windowTitle = "eternal return";
w = Window.new(windowTitle, Rect(128, 64, width, 30));
w.view.decorator = FlowLayout( w.view.bounds ).gap_(2 @ 2);


running = { task.isPlaying };
toggleHistory = {
	if(running.value) { task.play(AppClock) } { task.stop };
};

updateWindowTitle = {
	var prefix;
	prefix = if(browseMode) { "browsing" } { "" };
	w.name = "% %".format(prefix, windowTitle);
};

// get the next appropriate point in time,
// either the next delta step, or, if closer, the next timepoint
task = Task {
	var nextDelta, nextIndex;
	loop {
		nextIndex = dispatch.timepoints.indexOfGreaterThan(scaledValue);
		if(nextIndex.isNil) {
			if(dispatch.timepoints.last.notNil
				and: {dispatch.timepoints.last >= (scaledValue + delta)}) {
				nextDelta = tmax - scaledValue;
			} {
				nextDelta = delta
			}
		} {
			nextDelta = min(delta, dispatch.timepoints.at(nextIndex) - scaledValue);
		};
		scaledValue = (scaledValue + nextDelta % tmax);
		valMap.(scaledValue);
		nextDelta.wait;
	}

};
if(currentEnvironment.isKindOf(EnvironmentRedirect).not) {
	proxyspace = p = ProxySpace.push(s.boot);
} {
	proxyspace = currentEnvironment;
};
dispatch = proxyspace.dispatch;
if(dispatch.isNil) {
	proxyspace.dispatch = dispatch = HistoryDispatch.new;
};
dispatch.manual = true;
dispatch.alwaysReplace = false;

changed = { |time|
	var str, envir, changed, pairs;
	envir = dispatch.envir;
	if(browseMode) {
		pairs = dispatch.getPairsForTime(time);
		if(pairs.isNil) { d.text = "" } {
			d.text = pairs.collect { |pair|
				format("\n~% = %;\n\n", pair[0], pair[1].asCompileString)
			}.join;
		};
	} {
		changed = dispatch.setTime(time);
		if(changed) {
			str = dispatch.envir.asCompileString;
			d.text = String.streamContents { arg str;
				envir.storeOn(str, includeSettings: false)
			};
		}
	};
	if(0.07.coin) { nietzsche.choose.postln };
};


loadFunc = { |path|
	var file, str, delim;
	protect {
		file = File(path.standardizePath, "r");
		str = file.readAllString;
	} {
		file.close;
	};
	str = str.stripRTF;
	delim = str.findAll("// -").add(str.size - 1);

	str = str.clumps(delim.differentiate).drop(1).drop(-1);

	proxyspace.awake = false;
	str.do { |substr|
		var time = History.getTimeFromString(substr);
		changed.(time);
		substr.interpret;
	};
	proxyspace.awake = true;
	tmax = max(tmax, History.getTimeFromString(str.last));
	mmax.value = tmax;
	valMap.(0.0);
	d.front;
};

v = UserView(w, Rect(0, 0, 350, 20)).resize_(2);
v.background = Color.black;
v.mouseMoveAction_({|v,x| mapVal.value(x) });
v.mouseUpAction_({|v,x| mapVal.value(x); changed.value(scaledValue) });
v.mouseDownAction_({|v,x| mapVal.value(x); });

mapVal = {|x|
	value = x;
	scaledValue = x / v.bounds.width * tmax;
	m.value = scaledValue;
	w.refresh;
};

valMap = {|x|
	if(x.notNil) {
		x = x.clip(0, tmax);
		scaledValue = x;
		m.value = scaledValue.round(0.01);
		value = x / tmax * v.bounds.width;
		changed.value(scaledValue);
		w.refresh;
	}
};


drawLine = { |x, color|
	Pen.beginPath;
	Pen.moveTo(x @ 0);
	Pen.lineTo(x @ v.bounds.height);
	Pen.strokeColor = color;
	Pen.stroke;
};

v.drawFunc = {
	Pen.use {
		Pen.smoothing = false;
		Pen.width = 1;

		dispatch.timepoints.do {|x=(0)|
			x = x.clip(0, tmax);
			drawLine.(x / tmax * v.bounds.width, Color.new255(230, 123, 155));
		};

		drawLine.(value.max(1), Color.white);


	};
};

m = NumberBox(w, Rect(0, 0, 50, 20)); // todo resize .resize_(1);
m.value = 0;
m.action = { valMap.value(m.value) };

w.view.keyDownAction = { |v, char, mod, x, y, code|
	char.postln;
	if(char == $ , toggleHistory);
	// right arrow
	if(code == 16777236) {
		if(mod.isAlt) {
			fne.action.value;
		} {
			fne2.action.value;
		};
	};

	// left arrow
	if(code == 16777234) {
		if(mod.isAlt) {
			fla.action.value;
		} {
			fla2.action.value;
		};
	};

};

browseBut = Button(w, Rect(0, 0, 20, 20))
.states_([["_", Color.black], ["-", Color.black]])
.action_({|b|
	browseMode = b.value == 1;
	updateWindowTitle.value;
	if(b.value == 0) {
		valMap.(scaledValue);
	};
});


ff = Button(w, Rect(0, 0, 20, 20)).states_([["->", Color.black], ["||", Color.red]]);

fba = Button(w, Rect(0, 0, 20, 20)).states_([["<<", Color.black]]);

fla = Button(w, Rect(0, 0, 20, 20)).states_([[":<", Color.black]]);
fne = Button(w, Rect(0, 0, 20, 20)).states_([[">:", Color.black]]);

fla2 = Button(w, Rect(0, 0, 20, 20)).states_([["<", Color.black]]);
fne2 = Button(w, Rect(0, 0, 20, 20)).states_([[">", Color.black]]);

ff.action = { if(ff.value == 1) { task.play(AppClock);  } { task.stop } };
fba.action = { valMap.(0.0) };
fne.action = {
	i = dispatch.timepoints.indexOfGreaterThan(scaledValue) ? 0;
	valMap.(dispatch.timepoints.at(i))
};
fla.action = {
	i = dispatch.timepoints.indexOfGreaterThan(scaledValue - 0.01);
	i = i ? dispatch.timepoints.lastIndex;
	if(i.notNil) {
		valMap.(dispatch.timepoints.wrapAt(i-1))
	}
};

fne2.action = {
	valMap.(scaledValue + delta % tmax)
};
fla2.action = {
	valMap.(scaledValue - delta  % tmax)
};

mmax = NumberBox(w, Rect(0, 0, 40, 20));
mmax.value = tmax;
mmax.action = { tmax = mmax.value; valMap.(scaledValue); };



Button(w, Rect(0, 0, 20, 20)).states_([["p", Color.black]])
.action_({dispatch.document});


Button(w, Rect(0, 0, 20, 20)).states_([["rm", Color.black]])
.action_({
	dispatch.removeAllAtTime(scaledValue);
	changed.(scaledValue);
	w.refresh;
});

Button(w, Rect(0, 0, 20, 20)).states_([["ld", Color.black]])
.action_({
	Dialog.openPanel({ |paths| paths.do(loadFunc.(_)) }, multipleSelection: true);
});

w.front;

d = Document.allDocuments.detect { |x| x.title == "history document" } ?? { Document.new("history document") };
d.toFrontAction = d.toFrontAction.addFunc {
	if(w.isClosed.not) { ff.valueAction = 0 };
};
d.front;

nietzsche = #["Alles Laufenkoennen muss gelaufen sein", "Der Torweg muss auch gelaufen sein", "Der Augenblick zieht alles nach sich, auch sich selbst", "Alles Laufenkoennen muss noch laufen", "Out of damp and gloomy days, out of solitude, out of loveless words directed at us, conclusions grow in us like fungus: one morning they are there, we do not know how, and they gaze upon us.", "Woe to the thinker who is not the gardener but only the soil of the plants that grow up in him!"];
valMap.value(0);


)
