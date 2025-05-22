/*
Code compiled for The SuperCollider Book, 2nd Edn, MIT Press

26 Notations and Score-making

Tom Hall, Newton Armstrong, Richard Hoadley

CODE LISTING

*/

// 26.2 CPWN and graphic notation within SuperCollider

// Class code at https://github.com/ludions

// 26.2.2		Page, frame, view

MITHScreenRatios().ratioToDims(\usLetter)

[sqrt(2): 1]

m = MITHScreenRatios(); m.viewDims_(m.ratioToDims(\usLetter)); MITHRatiosView(m);
m.viewDims_(m.ratioToDims(\iso, landscape: false));

// Figure 26.1: WinBlock used with MITHRatios

// dimensions for an iso ratio landscape Window, width 800px
~dims = MITHScreenRatios().ratioToDims(\iso, 800) // default is m.screenDims


// make a WinBlock, args: win, dims, margins, usrViewBool
b = WinBlock.new(dims: ~dims); b.moveWin(0, 0)

// view is by default an UserView
(
b.marginCol_(Color.white);
b.view.drawFunc = {|self|
	Pen.addRect(Rect(0.5, 0.5, self.bounds.width-1, self.bounds.height-1));
	Pen.stroke;
};
b.view.refresh;
)

b.viewDims // return current block dimensions

// experiment with blockSize / ratio
g = b.gui

// shape view dimensions
d = MITHScreenRatios().ratioToDims(\r5_3, ~dims * (5/6));
b.viewDims_(*d); b.centerView;

// show area revealed in fullscreen mode
b.winCol_(Color.new255(255, 85, 0)); b.resizeWin(*(~dims * 1.2));

// timed fullScreen, also ESC key (MBP) to endFullScreen
r{ b.fullScreen; 3.wait; b.endFullScreen}.play(AppClock)

b.shrinkWin // hide area beyond main margin
g.close; b.close;



// 26.2.3		Unicode and common practice Western notations

"🎹".asCodePoint // U+1F3B9
"U+1F3B9".asGlyph // 🎹

(
w = Window.new.front;
a = StaticText(w, Rect(100, 50, 300, 300));
a.font = Font("Bravura", 72);
a.string = "U+E050".asGlyph
)

a.string = ["U+1F1FA", "U+1F1E6"].scramble.asUnicodeString


// Figure 26.2: MITHNoteViewer dynamic note array presentation with Synth.

(
s.waitForBoot({
	SynthDef(\percSine, {|midi = 69, mul = 0.2, out=0|
		var sig, env = Env.perc(releaseTime:0.4);
		sig = SinOsc.ar(midi.midicps, mul: mul)
		    * EnvGen.kr(env, doneAction: Done.freeSelf);
		Out.ar(out, [sig, sig])
	}).add;

	l = MITHNoteViewer.new(8, 350);
	a = [60, 62, -63, 65, 67, 69, 71, 72, -70, -68, 67, 65, -63, 62, 60];
	r = Routine{
		l.fullScreen;
		1.wait;
		a.size.do{|i|
			Synth(\percSine, [\midi, a[i].abs]);
			l.add(a[i], slot: i.fold(0, 7), color:Color.red);
			if(p.notNil){l.glyphsCol_(Color.black, p)};
			p = i.fold(0, 7);
			(60/94).wait
		};
		l.glyphsCol_(Color.black, p);
		p = nil;
		l.endFullScreen;
		2.wait;
		l.clearAll;
		l.close
	};
	AppClock.play(r)
})
)


// 26.2.4 Model, grid, score

// Figure 26.4: Simple GMITH score creation and galley view display.

(
l = GMITH.new;
// [row, column] -> [number, type, duration]
l.addAll([
	[1, 0],
	[2, 1] -> [3],
	[0, 2] -> [nil, \h],
	[1, 3] -> ["Pz 3", nil, 2],
	[2, 5] -> [[2, 1]],
	[0, 6] -> [nil, \a]

]);
)

// |key, rows, cols, vHeightPct, win|
w = l.makeGalley(\gv1, cols: 8)

// to complete the score, click the bottom right (empty) cell, then evaluate:
l.addMouseCell([nil, \p]); // l.undo if in error

// post sorted score events l.scoreArr
l.postEvents(order: 0) // row order. order: 1 posts column order

// grid line patterns
l.gvGridPatterns(\gv1) // [ [ 1 ], [ 1 ] ]
l.gvGridPatterns_(\gv1, [1, 0, 0], [-1, 0, 0, 0]);

// display adjustments
l.gvColRange_(\gv1, 0, 63);
l.gvGridLineWidth(\gv1)
l.gvShapeLnWidth_(\gv1, 2) // adjust, default is 3
l.gvFontSizeScale_(\gv1, 0.8) // adjust
l.moveAll(12); // move score events to columns to the right
l.moveAll // return to 0 column as first event
l.gvColRange_(\gv1); // default view range is filled cell range



// Code example for image shown in Figure 26.5: Example of GMITH score view using makePage method

// Evaluate initial code in previous example first
l.class == GMITH // checking: needs to be true

// arg key, numSystems, dims, titleBool = false, win;
l.makePage(\title, 1, MITHScreenRatios().ratioToDims(\iso, 1000), true)

// initial placement, will be adjusted
// arg key, system, startCol, endCol, numRows = 3;
l.pageDrawSystem(\title, 0, 0, 7, 3);

// Adjust margins
g = l.pageMarginsGui(\title); // g.close if needed
l.pageViewDims(\title) // as pixels
// finalise as
l.pageViewDimsPct_(\title, 0.75, 0.8); // %s

// Enter page text
(
m = l.pageViewModel(\title); // access model
m.title.string_("a composition"); // bold by default
m.subtitle.string_("a subtitle");
m.composer.string_("a composer");
[m.title, m.subtitle, m.composer].do{|i| i.font_(Font.defaultSansFace, 16)};
m.midGutter.string_("Copyright 2022 some body");
m.midGutter.font_(Font.defaultSansFace, 12);
m.systemTopText(0).string = "a performance instruction";
m.systemTopText(0).font_(Font.defaultSansFace, 14, true);
// system text access can also be via a function see NotnFlow method sysTxtFnEval
m.systemInstrs_("instr", font:Font(Font.defaultSansFace, 14));
)

(
// finalise page elements layout
m.setSystemWidths(675);
m.setSystemNotnsHeight(254);
m.setSystemTopsHeight(50);
m.setGuttersHeight(125);// maxHeight
l.pageSysSqSize_(\title, 84.2); // Adjust notation size to fit
)

(
// Adjust notation defaults
l.pageGridPatterns_(\title, [1, 0, 0], [-1, 0]);
l.pageGridLnWdth_(\title, 1.5);
l.pageShapeLnWidth_(\title, 2.5);
l.pageFontSizeScale_(\title, 0.75);
)
// colors
// inner block background color
l.pageViewCol_(\title, Color.yellow)
// inner margins incl. between Layout Spacing
l.pageMarginCol_(\title, Color.rand)
// changes ALL backgrounds
l.pageColor_(\title, Color.white);
l.pageWinCol_(\title, Color.gray); // access outer margin color
l.pagefullScreen(\title); // ESC key to undo or use pageEndFullScreen


/////////////////////////////////////////////////////////////////////////////////

// 26.3 INScore

// Class code at https://github.com/richardhoadley/inscoremit

// **26.3.2 INScore and SuperCollider**

// depending on installation path location
"Applications/INScoreViewer.app".openOS

// example INScore text file contents
/ITL/scene/score0 set gmn "[ c ]"; // not SuperCollider code

// assumes INScoreViewer listening for OSC on port 7000
~addr = NetAddr.new("localhost", 7000);
~addr.sendMsg("/ITL/scene/score0", \set, \gmn, "[ d ]");

// assumes INScoreViewer listening for OSC on hostname "127.0.0.1", port 7000
~scene= INScoreSceneMIT.new;
~scene.note(pitch: \c);

// synchronize with a remote machine
~scene.addINScoreView(NetAddr.new("192.168.178.64", 7000)) // needs correct remote IP address

// FOLLOWING INScoreManagerMIT EXAMPLE OMITTED FROM CHAPTER DUE TO SPACE CONSTRINTS
~helper = INScoreManagerMIT.new(~addr); // use ~addr from example above
~helper.showLog // display INScore log window
~helper.makeScene(\joni, foreground: true);
~helper.allScenes // list all scenes by name
~helper.deleteScene(\joni);
~helper.free // frees the class instance OSCdefs

// using INScoreSceneMIT
j = INScoreSceneMIT.new("localhost", \joni).window
j.foreground;
j.note(pitch: "b&1/2 a", componentNum: 0);
j.close; // close window


// make chords manually (_ for rest), two staves
~scene= INScoreSceneMIT.new; // new class instance as needed
~scene.staves("[{a/4, b, c} {b3,e2, g&} _/8 {c#2/4., e0}], [{g/1, f}]" );

// helper string Guido string manipulation class
g = ~scene.guido; // otherwise: g = SimpleGuidoMIT.new;
~scene.note(pitch: g.clef(\f) + g.meter(3, 8) +g.key(-2) + "c0/8. b-1");



// Figure 26.6: Dynamic CPWN using a function to generate an algorithmic chord sequence.

~scene= INScoreSceneMIT.new; // new class instance as needed
(
~randomChordsFn = {
	var chordArr, chord3, noteFN, chosenDur, melodicArr;
	var guidoOutput = "", guidoChord = [], g = ~scene.guido;
	noteFN = {rrand(30, 90)};
	chordArr = [[50, 54, 57, 59], [34, 56, 78], 3.collect({noteFN.value})];
	chord3 = [chordArr[1], chordArr[1]].choose;
	melodicArr = [chordArr[0], chordArr[0]+[2, -2].choose, chord3, chordArr[2]];
	melodicArr.do({|chord|
		chosenDur = ["/16", "/4", "/2."].choose;
		chord = chord.collect({|note| g.midiNoteMap(note, "mixed") ++ chosenDur});
		chord = [g.makeChord(chord), "_"++chosenDur].wchoose([0.8, 0.2]);
		guidoOutput = guidoOutput + chord
	});
	guidoOutput;
};

~scene.osaActivate;
~scene.verbose_(false);
Routine.new({
	6.do({|i|
		~scene.note(pitch: ~randomChordsFn.value);
		~scene.htmlFull(fontsize: "40pt", text: (i+1) + "/ 6");
		~scene.move(-0.4, -0.6, component:"html");
		2.5.wait
	});
	~scene.clear; // clear exising scene
}).play;
)


// Figure 26.7: Dynamic score with audio.
~scene= INScoreSceneMIT.new // new class instance as needed
(
var acc, glyph, glyphRed, string, oldString;
s.waitForBoot({
	SynthDef(\percSine, {|midi = 69, mul = 0.2, out=0|
		var sig, env = Env.perc(releaseTime:0.4);
		sig = SinOsc.ar(midi.midicps, mul: mul)
		* EnvGen.kr(env, doneAction: Done.freeSelf);
		Out.ar(out, [sig, sig])
	}).add;
	m = [60, 62, -63, 65, 67, 69, 71, 72, -70, -68, 67, 65, -63, 62, 60];
	g = ~scene.guido;
	string = g.stemsOff;
	oldString = string.copy;
	~scene.osaActivate;
	r = Routine.new({
		1.wait;
		m.do({|i, j|
			Synth(\percSine, [\midi, i.abs]);
			acc = if(i.isNegative){"flats"}{""};
			glyph = g.midiNoteMap(i.abs, acc);
			glyphRed = g.noteFormat(color: \red) + glyph;
			// start a new string of pitches
			if(j==8){
				string = g.stemsOff + g.midiNoteMap(m[j-1].abs, acc);
				oldString = string.copy;
			};
			string = (oldString + glyphRed).postln;
			oldString = oldString + glyph;
			~scene.note(pitch: string);
			(60/94).wait
		});
		0.5.wait;
		~scene.note(pitch: oldString);
		1.wait;
		~scene.note(pitch: g.emptyStaff);
	}).play;
})
)


// scale, move or delete the existing GUIDO score0 scene object
~scene= INScoreSceneMIT.new // new class instance as needed
~scene.note(~scene.guido.emptyStaff); // from previous example
~scene.move(y: -0.8).scale(0.5);
~scene.deleteComponent(component: "score", componentNum: 0);

// create a polygon
// ITL/scene/polygon0 set poly [0.7, 0.05, 0.1, 0.1, 0.1, 0.0];
~scene.poly([0.7, 0.05, 0.1, 0.1, 0.1, 0.0]);
~scene.color(\orange, component: "poly"); // https://en.wikipedia.org/wiki/Web_colors

// place the centre of the polygon at the center
// or either horizontal edge of the scene window:
~scene.move(x: [-1, 0, 1].choose, component: "poly");

// FOLLOWING EXAMPLE OMITTED FROM CHAPTER DUE TO SPACE CONSTRINTS
// change the screen ratio, then fullscreen
// move poly across screen, fading in/out alpha
// uses absolute position (relative possible with dx or dalpha)

~scene= INScoreSceneMIT.new; // new class instance as needed
(
var screenRatio = 1.78, dur = 5, fRate=60, iter;
var pos, wait, posSpec, alpha, alphaSpec;
posSpec =[screenRatio.neg, screenRatio].asSpec;
alphaSpec = [0, 255].asSpec;
iter = dur * fRate;
~scene.osaActivate;
~scene.poly([0.7, 0.05, 0.1, 0.1, 0.1, 0.0]);
Routine.new({
	~scene.windowHeight("scene", 1.0);
	0.25.wait;
	~scene.windowWidth("scene", screenRatio);
	~scene.fullScreen(true);
	1.25.wait;
	iter.reverseDo{|i|
		alpha = alphaSpec.map(i/iter);
		alpha = (alpha*2).round.asInteger.fold(0, 255);
		~scene.scale((i/iter*2).fold(0, 1), component: "poly");
		~scene.alpha(alpha, component: "poly");
		pos = posSpec.map(i/(iter-1));
		~scene.move(x: pos, component: "poly");
		wait = fRate.reciprocal;
		wait.wait;
	};
	1.wait;
	~scene.endFullScreen;
	~scene.alpha(255, component: "poly");
}).play
)


// Code for image in Figure 26.8: INScore scene scaling, object and dynamic CPWN animation


~scene= INScoreSceneMIT.new; // assumes INScoreViewer listening for OSC on port 7000
~scene.verbose_(false);

(
var scorePos, scoreMovt, screenRatio = 1.78, guido = ~scene.guido;
~scene.osaActivate;
~scene.clear; // clear exising scene
Routine.new({
	~scene.windowHeight(1.0);
	0.25.wait;
	~scene.windowWidth("scene", screenRatio);
	~scene.fullScreen;
	1.25.wait;
	6.do({|i|
		var waitTime = rrand(3, 5), randIter = rrand(4, 7), numScores = randIter + 2;
		var newMel, melodyHeader = Array.newClear(numScores, {""}), melodyRH = melodyHeader.copy;
		var starPos = [rrand(0.6, 0.8)* screenRatio.neg, rrand(-0.5, -0.7)]; // star lines pos
		~scene.htmlFull(text: (i+1) + "/ 6", fontsize: "48pt");
		~scene.move(-1.4, -0.85, component: "html"); // counter
		scorePos = Array.fill(numScores, {[rand2(screenRatio), rand2(1.0)]});
		scoreMovt = Array.fill(numScores, {|i| {rrand(0.075, 4.0)}.dup * 0.001 * scorePos[i].sign.neg});
		numScores.do({|i|
			melodyHeader[i] = guido.meter(rrand(2, 5), [2, 4, 8].choose) + guido.key(rrand(-4, 4));
			melodyRH[i] = "";
			~scene.note(pitch: melodyHeader[i] ++ melodyRH[i], componentNum: i);
			~scene.origin(x: -1.0, y: 1.0, componentNum: i); // scores expand to the right
			~scene.move(x: scorePos[i][0], y: scorePos[i][1], componentNum: i);
			~scene.scale(scale: rrand(0.2, 1.0), componentNum: i);
			~scene.color(color: 255.rand!3++[255], componentNum: i);
			Routine.new({
				4.do({
					newMel = guido.note(*[["b&", "a", "c", "b"], ["", "1"], [2, 4, 8]].collect{|i| i.choose});
					melodyRH[i] = melodyRH[i] ++ newMel;
					~scene.note(pitch: melodyHeader[i] ++ melodyRH[i], componentNum: i);
					[0.25, 0.33, 0.5, 0.6].choose.wait
				})
			}).play;
			Routine.new({
				((waitTime/0.01).floor).do({
					~scene.pos(dx: scoreMovt[i][0], dy: scoreMovt[i][1], componentNum: i);
					0.01.wait
				})
			}).play
		});
		(randIter*4).do({|i|
			~scene.rect(xSize: rrand(0.01, 0.3), ySize: rrand(0.01, 0.1), angle: 0, componentNum: i); // rect
			~scene.move(x: rand2(screenRatio), y: rand2(1.0), componentNum: i, component: "rect");
			~scene.color(color: [200, 200, rrand(200, 255), 255.rand], componentNum: i, component: "rect");
			Routine.new({200.do({~scene.drotate(8.rand, componentNum: i, component: "rect"); 0.04.wait})}).play;
			~scene.line(x: rand2(0.4), y: rand2(0.4), angle: 360.rand, widthVal: 0.5, componentNum: i); // line
			~scene.move(x: starPos[0], y: starPos[1], componentNum: i, component: "line");
			~scene.color(color: [0, 0, 0, 100], componentNum: i, component: "line");
			Routine.new({200.do({
				~scene.drotate(dx: rrand(1, 6), dy: rrand(1, 6), dz: rrand(1, 6), componentNum: i, component: "line");
				0.04.wait
			});
			}).play;
			~scene.ellipse(width: rrand(0.01, 0.08), angle: 360.rand, componentNum: i); // ellipse
			~scene.move(x: rand2(screenRatio), y: rand2(1.0), componentNum: i, component: "ellipse");
			~scene.color(color: [rrand(200, 255), 0, 0, 255 ], componentNum: i, component: "ellipse");
			Routine.new({10.rand.do({
				~scene.move(x: rand2(1.0), y: rand2(1.0), componentNum: i, component: "ellipse");
				~scene.scale(scale: rrand(0.3, 0.8), componentNum: i, component: "ellipse");
				[0.15, 0.25, 0.3].choose.wait});
			}).play
		});
		waitTime.wait;
		numScores.do({|i| ~scene.deleteComponent(component: "score", componentNum: i)});
	});
	~scene.endFullScreen;
	~scene.windowWidth(1);
}).play;
)


/////////////////////////////////////////////////////////////////////////////////

// 26.4 Fosc

// Majority of Class code at https://github.com/n-armstrong/fosc

// 26.4.2 Low-level interface

// Figure 26.12: Display notes on a staff.
(
a = [FoscNote(60, 1/4), FoscNote(62, 1/8), FoscNote(63, 1/8), FoscNote(65, 1/2)];
FoscStaff(a).show;
)


// Figure 26.14: Attach articulation and dynamics marks to a note.
(
a = FoscNote(60, 1/4);
a.attach(FoscArticulation('>'));
a.attach(FoscDynamic('f'));
a.show;
)

// Figure 26.16: Attach slur and dynamic hairpin spanners to a selection of notes.
(
a = [FoscNote(60, 1/4), FoscNote(62, 1/8), FoscNote(63, 1/8), FoscNote(65, 1/2)];
b = FoscStaff(a);
b.selectLeaves.slur.hairpin('p < f');
b.show;
)

// Figure 26.18: Attach a LilyPond literal string to the first note in a selection.
(
a = [FoscNote(60, 1/4), FoscNote(62, 1/8), FoscNote(63, 1/8), FoscNote(65, 1/2)];
b = FoscStaff(a);
b[0].attach(FoscLilyPondLiteral("\\tweak NoteHead.style #'harmonic"));
b.show;
)

// Figure 26.20: The transpose and scale mutation methods.
// a) Make a copy of a staff. Transpose the contents of the copied staff up two semitones.
(
a = [FoscNote(60, 1/4), FoscNote(62, 1/8), FoscNote(63, 1/8), FoscNote(65, 1/2)];
b = FoscStaff(a);
b.selectLeaves.slur.hairpin('p < f');
c = b.deepCopy;
mutate(c.selectLeaves).transpose(2);
FoscScore([b, c]).show;
)

// b) Make a copy of a staff. Scale the contents of the copied staff by a factor of 2.
(
a = [FoscNote(60, 1/4), FoscNote(62, 1/8), FoscNote(63, 1/8), FoscNote(65, 1/2)];
b = FoscStaff(a);
b.selectLeaves.slur.hairpin('p < f');
c = b.deepCopy;
mutate(c.selectLeaves).scale(2);
FoscScore([b, c]).show;
)

// 26.4.3 Making sound

s.waitForBoot { FoscChord(#[60,64,67], 1/2).play };

(
a = FoscStaff((60..72).collect { |pitch| FoscNote(pitch, 1/16) });
a.selectLeaves.hairpin('ppp < fff');
a.play;
)

// Figure 26.22: Provide a custom SynthDef for playing a FoscStaff.
(
SynthDef('ping', { |midinote=60, amp=1|
    var envgen, src;
    envgen = EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);
    src = Pan2.ar(SinOsc.ar(midinote.midicps, 0, amp), 0);
    OffsetOut.ar(0, src * envgen);
}).add;
)

(
a = FoscStaff((60..72).collect { |pitch| FoscNote(pitch, 1/16) });
a.selectLeaves.hairpin('ppp < fff');
Pbindf(Pseq(a.eventList), \instrument, 'ping').play;
)


// 26.4.4 High-level interface: FoscMusicMaker

// Figure 26.23: Simple usage of FoscMusicMaker.
(
a = FoscMusicMaker();
b = a.(durations: [1/4, 1/8, 1/8, 1/2], pitches: #[60,62]);
b.show;
)

// Figure 26.25: FoscMusicMaker used to create complex divisive rhythmic structures.

// a) Embed divisions into durations. Negative divisions are interpreted as rests.
(
a = FoscMusicMaker();
b = a.(durations: [1/2, 1/8, 3/8], divisions: #[[-1,3],[3,2],[2,2,-3]], pitches: #[60,62]);
b.show;
)

// b) Divisions can be nested using a variant of rhythm-tree syntax.
(
a = FoscMusicMaker();
b = a.(durations: [1/2, 1/8, 3/8], divisions: #[[-1,3],[3,2],[2,[2,[3,2]],-3]], pitches: #[60,62]);
b.show;
)

// Figure 26.27: Melodic sequences demonstrating the use of a mask

// a) An unmasked periodic sequence. The sequence of divisions repeats cyclically to match the length of the sequence of durations.
(
a = FoscMusicMaker();
b = a.(durations: 1/4 ! 4, divisions: #[[1,1,1,1]], pitches: #[60,62]);
b.show;
)

// b) The same sequence with a [2, 1] mask applied. The mask pattern repeats cyclically. Pitches are added after the mask is applied.
(
a = FoscMusicMaker();
b = a.(durations: 1/4 ! 4, divisions: #[[1,1,1,1]], mask: #[2,1], pitches: #[60,62]);
b.show;
)

// c) The same sequence with a [2, -1] mask applied. Negative mask values are interpreted as rests.
(
a = FoscMusicMaker();
b = a.(durations: 1/4 ! 4, divisions: #[[1,1,1,1]], mask: #[2,-1], pitches: #[60,62]);
b.show;
)

// Figure 26.29: A customized extension of FoscMusicMaker: InconjunctionsMaker.
(
~maker = InconjunctionsMaker();

~selections = ~maker.(
    durations: #[[4,8]],
    // divisions: the rhythmic ratio/s that embed/s into durations
    divisions: #[3,2,1,2].wrapExtend(24),
    // groupSizes: per voice segmentations
    groupSizes: #[
        [5,5,5,5,4],
        [6,6,6,6],
        [5,6,7,6],
        [3,4,5,6,6]
    ],
    // pitches: per voice ordered pitch sequences that repeat cyclically at each segment
    pitches: #[
        "gqf'' bf'' cqf''' d''' ef'''",
        "d' g' bqs' aqf'' bf'' bqf''",
        "aqf d' af' bqs' gqf'' af'' bqf''",
        "gqs aqf d' g' af' bqs'"
    ],
    // hairpins: per voice, repeating cyclically at each segment
    hairpins: #['fff > f'],
    // articulations: per voice, applied cyclically to the first event in each segment
    articulations: #['>'],
    // finalize: ad hoc per voice modifications
    finalize: { |sel, i|
        // override default spelling of tuplet ratio
        sel.selectComponents(FoscTuplet).do { |tuplet|
            tuplet.denominator = 4;
            tuplet.forceFraction = true;
        };
    };
);

// collect selections of music into a score and add final details
~score = FoscScore(~selections.collect { |sel| FoscStaff([FoscVoice(sel)]) });
~score.selectComponents(FoscStaff).do { |staff, i| set(staff).instrumentName = "Vln. %".format(i + 1) };
~score.leafAt(0).attach(FoscTimeSignature(#[4,8]));
~score.show(staffSize: 14);
)

//// CHAPTER 26 CODE LISTING END
