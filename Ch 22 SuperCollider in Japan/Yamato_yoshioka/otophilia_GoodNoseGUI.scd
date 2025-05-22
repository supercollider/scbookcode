// GoodNose by_otophilia //
// Load "GoodNoseDemoSong.txt"
// and Push the [Play] button;
// Please check "GoodNose_instruction.pdf" to play

(
s = Server.default;
s.latency = 0.05;


(
	~strokePat = Array.fill(8, {
		Array.fill(16, {|i| [0, i%2, 0, 5, 0]});
		});

	~chordMemory = [
		[0, 7, 10, 15, 19, 24],
		[0, 7, 12, 16, 19, 24],
		[0, 7, 12, 17, 19, 24],
		[0, 7, 10, 16, 19, 24],
		[120, 12, 16, 22, 26, 31],
		[120, 12, 16, 22, 26, 33],
		[0, 5, 10, 15, 19, 24],
		[0, 5, 10, 15, 19, 24]];

	~songSeq = [
			[16, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]];

	~bpm = 130;

	~songNow = 0;
	~songStep = 0;

	~playingPat = 0;
	~songKey = 40;
);



// @@@@ GUI @@@@
(
	~editedPat = 0;
	~editedChord = 0;

	~window !? {~window.close};
	~window = GUI.window.new("Everything is GoodNose...", Rect(128, 128, 422, 418), false, true).front;
	~window.onClose_{~stop.()};

	~window.view.background = Color.gray(0.8);
	~window.view.decorator = FlowLayout(~window.view.bounds, 8@0, 0@4);
	~window.view.decorator.nextLine;


	~titleView = GUI.compositeView.new(~window, Rect(0,0, 406, 24))
		.background_(Color.gray(0.7));
	~titleView.decorator = FlowLayout(~titleView.bounds, 2@2, 0@0);

	GUI.staticText.new(~titleView, Rect(0,0, 160, 20))
		.string_("GoodNose by.otophilia")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 12))
		.align_(\center);


	GUI.button.new(~titleView, Rect(0,0, 36, 20))
			.states_([["Save", Color.white, Color.new(0.2, 0.2, 0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~fileSave.();
				};
	GUI.button.new(~titleView, Rect(0,0, 36, 20))
			.states_([["Load", Color.white, Color.new(0.2, 0.2, 0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~fileOpen.();
				};

	~window.view.decorator.nextLine;



	~strokePatView = GUI.compositeView.new(~window, Rect(0,0, 406, 240))
		.background_(Color.gray(0.7)); //.relativeOrigin_(false);
	~strokePatView.decorator = FlowLayout(~strokePatView.bounds, 8@8, 0@0);

	GUI.staticText.new(~strokePatView, Rect(0,0, 48, 20))
		.string_("Pattern")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);


	~editPatSelButtons = Array.fill(~strokePat.size, {|i|
		GUI.button.new(~strokePatView, Rect(0,0, 20, 20))
			.states_([
			[(i+1).asString, Color.white, Color.gray(0.5)],
			[(i+1).asString, Color.white, Color.gray(0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.value_(if(~editedPat == i ){1}{0})
			.action_{|but| ~editedPat = i; ~refreshPatEditor.()}
	});
	~strokePatView.decorator.shift(12, 0);

	~patClipBoard = ~strokePat[~editedPat].deepCopy;

	GUI.button.new(~strokePatView, Rect(0,0, 36, 20))
			.states_([["Copy", Color.white, Color.new(0.3, 0.2, 0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~patClipBoard = ~strokePat[~editedPat].deepCopy
				};

	GUI.button.new(~strokePatView, Rect(0,0, 36, 20))
			.states_([["Paste", Color.white, Color.new(0.2, 0.2, 0.3)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~strokePat[~editedPat] = ~patClipBoard.deepCopy;
				~refreshPatEditor.()
				};

	~strokePatView.decorator.shift(0, 8);
	~strokePatView.decorator.nextLine;


	GUI.staticText.new(~strokePatView, Rect(0,0, 360, 16))
		.string_("Stroke Trigger / Direction / Range / Mute")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9));

	~strokePatView.decorator.nextLine;

	~posLamps = Array.fill(16, {|i|
		~strokePatView.decorator.gap = if(i%4 == 3){2@0}{0@0};

		GUI.staticText.new(~strokePatView, Rect(0,0, 24, 10))
			.background_(Color.gray(0.6))
			.stringColor_(Color.gray(0.2))
			.font_(GUI.font.new("Monaco", 9))
			.align_(\center);
	});

	~strokePatView.decorator.nextLine;


	~trigButtons = Array.fill(16, {|i|
		~strokePatView.decorator.gap = if(i%4 == 3){2@0}{0@0};

		GUI.button.new(~strokePatView, Rect(0,0, 24, 24))
			.states_([
			[" ", Color.white, Color.gray(0.7)],
			["X", Color.white, Color.gray(0.7)]])
			.font_(GUI.font.new("Monaco", 16))
			.canFocus_(false)
			.action_{|but|
				~strokePat[~editedPat][i][0] = but.value;
				};
	});

	~strokePatView.decorator.nextLine;

	~dirButtons = Array.fill(16, {|i|
		~strokePatView.decorator.gap = if(i%4 == 3){2@0}{0@0};

		GUI.button.new(~strokePatView, Rect(0,0, 24, 16))
			.states_([
			["v", Color.white, Color.new(0.4, 0.4, 0.5)],
			["^", Color.white, Color.new(0.4, 0.5, 0.4)]])
			.font_(GUI.font.new("Monaco", 10))
			.canFocus_(false)
			.value_(~strokePat[~editedPat][i][1])
			.action_{|but|
				~strokePat[~editedPat][i][1] = but.value;
				~changeTrigColor.(~trigButtons[i], i)
				};
	});

	~strokePatView.decorator.shift(0, 4);
	~strokePatView.decorator.nextLine;

	~rangeSpec = ControlSpec(0, 5, 0, 1, 0);
	~rangeSliders = Array.fill(16, {|i|
		var tMode, tBegin, begLo, begHi;
		~strokePatView.decorator.gap = if(i%4 == 3){2@0}{0@0};

		GUI.userView.new(~strokePatView, Rect(0,0, 24, 60))
			.canFocus_(false)
			.drawFunc_{|view|
				var lo, hi;

				lo = ~strokePat[~editedPat][i][2];
				hi = ~strokePat[~editedPat][i][3];

				GUI.pen.use{
				//GUI.pen.translate(view.bounds.left, view.bounds.top); //top

				GUI.pen.color = Color.gray(0.3);
				GUI.pen.fillRect(Rect(0,0, view.bounds.width-2, view.bounds.height));

				GUI.pen.color = Color.new(0.8, 0.8, 0.5, 1.0);
				GUI.pen.fillRect(Rect(0, (view.bounds.height*lo/6).round(1),
					view.bounds.width-2, (view.bounds.height*(hi+1-lo/6)).round(1) ));

				GUI.pen.color = Color.gray(1.0, 0.2);
				GUI.pen.fillRect(Rect(0, (view.bounds.height*lo/6).round(1),
					view.bounds.width-2/2, (view.bounds.height*(hi+1-lo/6)).round(1) ));

				//GUI.pen.translate(0.5, 0.5);

				GUI.pen.color = Color.gray(0.0);
				GUI.pen.strokeRect(Rect(0,0, view.bounds.width-2, view.bounds.height));
				}
			}
			.mouseDownAction_{|view, x, y, mod|
				var lo, hi, mouse;
				lo = ~strokePat[~editedPat][i][2];
				hi = ~strokePat[~editedPat][i][3];
				begLo = lo;
				begHi = hi;

				//[y,view.bounds.top,view.bounds.height].postln;
				//mouse = y - view.bounds.top / view.bounds.height * 6;
				mouse = y/ view.bounds.height * 6;

				tBegin = mouse;
				tMode = if(mouse < lo){0}{if(mouse < (hi+1)){1}{2}};
				}
			.mouseMoveAction_{|view, x, y, mod|
				var lo, hi, mouse, plus;
				//mouse = y - view.bounds.top / view.bounds.height * 6;

				//[y,view.bounds.top,view.bounds.height,mouse].postln;
				mouse = y/ view.bounds.height * 6;

				plus = mouse - tBegin;

				switch(tMode,
					0,{
						~strokePat[~editedPat][i][2] =
							~rangeSpec.constrain(begLo + plus).min(~strokePat[~editedPat][i][3]);
					},
					1,{
						~strokePat[~editedPat][i][2] = ~rangeSpec.constrain(begLo + plus);
						~strokePat[~editedPat][i][3] = ~rangeSpec.constrain(begHi + plus);
					},
					2,{
						~strokePat[~editedPat][i][3] =
							~rangeSpec.constrain(begHi + plus).max(~strokePat[~editedPat][i][2]);
					}
				);

				view.refresh;
				}
			.refresh;
	});



	~strokePatView.decorator.shift(0, 4);
	~strokePatView.decorator.nextLine;

	~muteSpec = ControlSpec(0, 1, 0, 0.01, 0);
	~muteSliders = Array.fill(16, {|i|
		var tBegin, begVal;
		~strokePatView.decorator.gap = if(i%4 == 3){2@0}{0@0};

		//.relativeOrigin_(false)
		GUI.userView.new(~strokePatView, Rect(0,0, 24, 60))
			.canFocus_(false)
			.drawFunc_{|view|
				var val;

				val = ~strokePat[~editedPat][i][4];

				GUI.pen.use{
				//GUI.pen.translate(view.bounds.left, view.bounds.top);

				GUI.pen.color = Color.gray(0.3);
				GUI.pen.fillRect(Rect(0,0, view.bounds.width-2, view.bounds.height));

				GUI.pen.color = Color.new(0.8, 0.5, 0.5, 1.0);
				GUI.pen.fillRect(Rect(0, 1-val * view.bounds.height,
					view.bounds.width-2, val * view.bounds.height));

				GUI.pen.color = Color.gray(1.0, 0.2);
				GUI.pen.fillRect(Rect(0, 1-val * view.bounds.height,
					view.bounds.width-2/2, val * view.bounds.height));

				//GUI.pen.translate(0.5, 0.5);

				GUI.pen.color = Color.gray(0.0);
				GUI.pen.strokeRect(Rect(0,0, view.bounds.width-2, view.bounds.height));
				}
			}
			.mouseDownAction_{|view, x, y, mod|
				begVal = ~strokePat[~editedPat][i][4];
				tBegin = y - view.bounds.top / view.bounds.height;
				}
			.mouseMoveAction_{|view, x, y, mod|
				var mouse;
				mouse = y - view.bounds.top / view.bounds.height;
				~strokePat[~editedPat][i][4] = ~muteSpec.constrain(tBegin - mouse + begVal);
				view.refresh;
				}
			.refresh;
	});
	~window.view.decorator.nextLine;



	~chordView = GUI.compositeView.new(~window, Rect(0,0, 406, 28))
		.background_(Color.gray(0.7));
	~chordView.decorator = FlowLayout(~chordView.bounds, 8@4, 0@0);

	GUI.staticText.new(~chordView, Rect(0,0, 32, 20))
		.string_("Chord")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);


	~editChoSelButtons = Array.fill(~chordMemory.size, {|i|
		GUI.button.new(~chordView, Rect(0,0, 20, 20))
			.states_([
			[(i+1).asString, Color.white, Color.gray(0.5)],
			[(i+1).asString, Color.white, Color.gray(0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.value_((~editedChord == i).binaryValue)
			.action_{|but| ~editedChord = i; ~refreshChdEditor.()};
	});
	~chordView.decorator.shift(12, 0);

	~chordNSpec = ControlSpec(-99, 99, 0, 1, 1);
	~chordNumBox = Array.fill(6, {|i|
		GUI.numberBox.new(~chordView, Rect(0,0, 24, 20))
			.font_(GUI.font.new("Monaco", 9))
			.value_( ~chordMemory[~editedChord][i] )
			.action_{|box| ~chordMemory[~editedChord][i] = ~chordNSpec.constrain(box.value);
				box.value = ~chordMemory[~editedChord][i]};
	});

	~chordView.decorator.shift(4, 0);


	~chdClipBoard = ~chordMemory[~editedChord].deepCopy;

	GUI.button.new(~chordView, Rect(0,0, 16, 20))
			.states_([["C", Color.white, Color.new(0.3, 0.2, 0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~chdClipBoard = ~chordMemory[~editedChord].deepCopy
				};

	GUI.button.new(~chordView, Rect(0,0, 16, 20))
			.states_([["P", Color.white, Color.new(0.2, 0.2, 0.3)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~chordMemory[~editedChord] = ~chdClipBoard.deepCopy;
				~refreshChdEditor.()
				};



	~songView = GUI.compositeView.new(~window, Rect(0,0, 406, 106))
		.background_(Color.gray(0.7));
	~songView.decorator = FlowLayout(~songView.bounds, 4@4, 0@4);


	~songView.decorator.shift(34, 0);

	GUI.button.new(~songView, Rect(0,0, 36, 16))
			.states_([["Play", Color.white, Color.new(0.2, 0.4, 0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~setting.(~play);
				};

	GUI.button.new(~songView, Rect(0,0, 36, 16))
			.states_([["Stop", Color.white, Color.new(0.2, 0.4, 0.2)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.action_{
				~stop.();
				};

	~songView.decorator.shift(16, 0);


	GUI.staticText.new(~songView, Rect(0,0, 20, 16))
		.string_("BPM")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9));

	~bpmSpec = ControlSpec(20, 400, 0, 0.1, 0);
	~bpmBox = GUI.numberBox.new(~songView, Rect(0,0, 32, 16))
			.font_(GUI.font.new("Monaco", 9))
			.value_( ~bpm )
			.action_{|box|
				box.value = ~bpm = ~bpmSpec.constrain(box.value);
				~clock !? {~clock.tempo = ~bpm/60};
				};



	GUI.staticText.new(~songView, Rect(0,0, 32, 16))
		.string_("Key")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);

	~songKeyBox = GUI.numberBox.new(~songView, Rect(0,0, 32, 16))
		.font_(GUI.font.new("Monaco", 9))
		.value_( ~songKey )
		.action_{|box| ~songKey = box.value };
	~songView.decorator.nextLine;


	~songView.decorator.shift(34, 0);

	~songLamps = Array.fill(~songSeq.size, {|i|
		~songView.decorator.gap = if(i%4 == 3){2@2}{0@2};
		GUI.button.new(~songView, Rect(0,0, 22, 14))
			.states_([
			[(i+1).asString, Color.gray(0.3), Color.gray(0.5)],
			[(i+1).asString, Color.white, Color.new(0.3, 0.3, 0.5)]])
			.font_(GUI.font.new("Monaco", 9))
			.canFocus_(false)
			.value_((~songNow == i).binaryValue)
			.action_{
				~songNow = i;
				~songStep = 0;
				~step = ~songSeq.collect{|item| item[0]}.addFirst(0).integrate[i] % 16;
				~songLamp.(~songNow);
			};
		});

	~songView.decorator.nextLine;

	~songLabelView = GUI.compositeView.new(~songView, Rect(0,0, 32, 63));
	~songLabelView.decorator = FlowLayout(~songLabelView.bounds, 0@0, 0@2);

	GUI.staticText.new(~songLabelView, Rect(0,0, 32, 14))
		.string_("Dura")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);
	~songLabelView.decorator.nextLine;

	GUI.staticText.new(~songLabelView, Rect(0,0, 32, 14))
		.string_("Ptrn")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);
	~songLabelView.decorator.nextLine;

	GUI.staticText.new(~songLabelView, Rect(0,0, 32, 14))
		.string_("Trsp")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);
	~songLabelView.decorator.nextLine;

	GUI.staticText.new(~songLabelView, Rect(0,0, 32, 14))
		.string_("Chrd")
		.stringColor_(Color.black)
		.font_(GUI.font.new("Monaco", 9))
		.align_(\center);
	~songLabelView.decorator.nextLine;


	~durSpec = ControlSpec(0, 99, 0, 1, 1);
	~patSpec = ControlSpec(1, ~strokePat.size, 0, 1, 1);
	~trsSpec = ControlSpec(-99, 99, 0, 1, 1);
	~chdSpec = ControlSpec(1, ~chordMemory.size, 0, 1, 1);

	~songSeqScenes = Array.fill(~songSeq.size, {|i|
		var view, dur, pat, trs, chd;
		~songView.decorator.gap = if(i%4 == 3){2@0}{0@0};

		view = GUI.compositeView.new(~songView, Rect(0,0, 22, 80));
		view.decorator = FlowLayout(view.bounds, 0@0, 0@2);

		dur = GUI.numberBox.new(view, Rect(0,0, 22, 14))
			.font_(GUI.font.new("Monaco", 9))
			.value_( ~songSeq[i][0] )
			.action_{|box| ~songSeq[i][0] = ~durSpec.constrain(box.value);
				box.value = ~songSeq[i][0]};
		view.decorator.nextLine;

		pat = GUI.numberBox.new(view, Rect(0,0, 22, 14))
			.font_(GUI.font.new("Monaco", 9))
			.value_( ~songSeq[i][1]+1 )
			.action_{|box| ~songSeq[i][1] = ~patSpec.constrain(box.value)-1;
				box.value = ~songSeq[i][1]+1 };
		view.decorator.nextLine;

		trs = GUI.numberBox.new(view, Rect(0,0, 22, 14))
			.font_(GUI.font.new("Monaco", 9))
			.value_( ~songSeq[i][2] )
			.action_{|box| ~songSeq[i][2] = ~trsSpec.constrain(box.value);
				 box.value = ~songSeq[i][2]};
		view.decorator.nextLine;

		chd = GUI.numberBox.new(view, Rect(0,0, 22, 14))
			.font_(GUI.font.new("Monaco", 9))
			.value_( ~songSeq[i][3]+1 )
			.action_{|box| ~songSeq[i][3] = ~chdSpec.constrain(box.value)-1;
				box.value = ~songSeq[i][3]+1 };

		[view, dur, pat, trs, chd]
	});


	~refreshPatEditor = {
		~editPatSelButtons.do{|but, i| but.value = if(~editedPat == i ){1}{0}};
		~trigButtons.do{|but, i| ~changeTrigColor.(but, i); but.value = ~strokePat[~editedPat][i][0];};
		~dirButtons.do{|but, i| but.value = ~strokePat[~editedPat][i][1]};
		~rangeSliders.do{|slid| slid.refresh};
		~muteSliders.do{|slid| slid.refresh};
		};

	~refreshChdEditor = {
		~editChoSelButtons.do{|but, i| but.value = if(~editedChord == i ){1}{0}};
		~chordNumBox.do{|box, i| box.value = ~chordMemory[~editedChord][i] };
		};

	~refreshSongEditor = {
		~songSeqScenes.do{|item, i|
		item[1].value = ~songSeq[i][0];
		item[2].value = ~songSeq[i][1] + 1;
		item[3].value = ~songSeq[i][2];
		item[4].value = ~songSeq[i][3] + 1;
		}
		};

	~changeTrigColor = {|but, i|
		but.states = (
			but.states[1][1] = if(~strokePat[~editedPat][i][1] == 0){Color.new(0.1, 0.1, 0.3)}{Color.new(0.1, 0.3, 0.1)};
			but.states);
			but.refresh
		};

	~trigButtons.do{|but, i| ~changeTrigColor.(but, i) };


	~positionLamp = {|step|
		~posLamps.do{|lamp, i| lamp.string = if(i==step){"="}{" "} }
		};
	~positionLamp.(0);

	~songLamp = {|step|
		~songLamps.do{|lamp, i| lamp.value = (~songNow == i).binaryValue }
		};
	~songLamp.(0);

	~guiRefreshFromClock = {|step, songNow|
		{
		~positionLamp.(step);
		~songLamp.(songNow);
		}.defer(s.latency);
		};
);


// @@@@ File @@@@
(
	~fileSave = {
		var file;
		GUI.dialog.savePanel({|path|
			file = File(path, "w");
			file.write(
				"GoodNoseFile\n"
				++ ~bpm.asCompileString
				++ $\n ++ ~songKey.asCompileString
				++ $\n ++ ~strokePat.asCompileString
				++ $\n ++ ~chordMemory.asCompileString
				++ $\n ++ ~songSeq.asCompileString);
			file.close;
		});
	};

	~fileOpen = {
		var file, text;
		//GUI.dialog.getPaths({|path| // このメソッドが非推奨
		Dialog.openPanel({|path|

			//path = path[0];
			if(File.exists(path)){

				file = File(path, "r");
				text = file.readAllString;
				file.close;

				text = text.split($\n);

				if(text[0] == "GoodNoseFile"){
					~stop.();
					~bpmBox.valueAction = text[1].interpret;
					~songKeyBox.valueAction = text[2].interpret;
					~strokePat = text[3].interpret;
					~chordMemory = text[4].interpret;
					~songSeq = text[5].interpret;
					~refreshPatEditor.();
					~refreshChdEditor.();
					~refreshSongEditor.();
				}
			}

		});



	};

);


// @@@@ Sound @@@@
(
	~setting = {|completeFunc|
		Routine.run {var c, msg;

		c = Condition.new;
		s.bootSync(c);
		s.freeAll;


		SynthDef(\string, {
			arg outBus=0, amp=1.0,
			trig=0, pitch=60, damp=8, decay=2.0, eAtk=0.01, eDec=0.02;
			var output, string, excite;

			excite = GrayNoise.ar(
			EnvGen.ar( Env.perc(eAtk, eDec / pitch.midicps, 1, -4), trig)
			);

			string = CombC.ar(excite, 0.1, pitch.midicps.reciprocal, decay);
			string = string.clip2(1);

			output = string;
			output = LPF.ar(output, EnvGen.ar( Env.perc(0, decay, 1, -6), trig, 60, pitch + damp).midicps.min(SampleRate.ir/2));
			output = output.softclip * amp;

			Out.ar(outBus, output);
		}, [nil, nil, \tr]).send(s);

		SynthDef(\ampSimulator, {
			arg inBus=0, outBus=0, amp=1.0;
			var output, hpf;
			output = In.ar(inBus, 1);
			output = Compander.ar(output, output, 0.5, 1, 0.2, 0.01, 0.01);
			output = HPF.ar(output, 100, 1) + RHPF.ar(output, 7140, 0.3, 0.1);
			output = RLPF.ar(output, 2650, 0.3, 12.0);
			output = output.softclip;
			output = RLPF.ar(output, 4720, 0.3, 0.6);
			output = BPF.ar(output, 3800, 0.3, 0.6, output);
			5.do{|i|
			thisThread.randSeed = 1220;
			output = output + AllpassL.ar(output, 0.03, [exprand(0.01, 0.02),exprand(0.01, 0.02),], 0.02, 0.05)
			};

			output = HPF.ar(output, 100, 1.0);
			output = HPF.ar(output, 7000, 0.5, output);

			output = Limiter.ar(output, 1, 0.002);

			Out.ar(outBus, output);
		}).send(s);

		s.sync(c);

		msg = List.new;

		~guitarGroup = Group.basicNew;
		msg.add( ~guitarGroup.newMsg );

		~amp = Synth.basicNew(\ampSimulator);
		msg.add( ~amp.newMsg(~guitarGroup, [\inBus, 16, \outBus, 0], \addAfter) );

		~strings = Array.fill(6, {
			var synth;

			synth = Synth.basicNew(\string);
			msg.add( synth.newMsg(~guitarGroup, [\outBus, 16, \amp, 0.5]), \addToTail);
			synth
			});

		s.listSendBundle(nil, msg);

		s.sync(c);
		completeFunc.();
		}};

	~play = {

		~step = 0;
		~songNow = 0;
		~songStep = 0;

		~task !? {~task.stop};
		~clock !? {~clock.stop};
		~clock = TempoClock(~bpm/60);

		~task = Task({inf.do{

		~playingPat = ~songSeq[~songNow][1];
		~playingChordRoot = ~songSeq[~songNow][2] + ~songKey;
		~playingChordType = ~songSeq[~songNow][3];

		~strings.do{|synth, strN|
		var msg, sStep, lo, hi, trig, pitch, delay, mute, damp, decay;
		sStep = ~strokePat[~playingPat][~step];
		lo = sStep[2];
		hi = sStep[3];

		trig = ((lo <= strN) && (strN <= hi)).binaryValue * sStep[0];
		pitch = (~chordMemory[~playingChordType][strN] + ~playingChordRoot);
		delay = if(trig==1){
				if(sStep[1]==0)
					{(strN- lo/(hi-lo).max(1)).max(0)}
					{(hi - strN/(hi-lo).max(1)).max(0)} * 0.01
				}{0} + rand(0.003);
		mute = sStep[4];
		if(~chordMemory[~playingChordType][strN] >= 99){mute = 1};
		decay = (1-mute)**2.2 * 4;

		msg = synth.setMsg(\trig, trig, \pitch, pitch, \decay, decay);
		s.sendBundle(s.latency + delay, msg);
		};

		~guiRefreshFromClock.(~step);

		~step = ~step+1 % 16;
		~songStep = ~songStep+1;

		if(~songStep >= ~songSeq[~songNow][0]){~songStep = 0; ~songNow = ~songNow+1};
		if(~songNow >= ~songSeq.size){~songNow = 0; ~step = 0; ~songStep = 0;};
		if(~songSeq[~songNow][0] == 0){~songNow = 0; ~step = 0; ~songStep = 0;};

		(1/4).wait;
		}}, ~clock).start;

	};

	~stop = {
		~task !? {~task.stop};
		};
);

);