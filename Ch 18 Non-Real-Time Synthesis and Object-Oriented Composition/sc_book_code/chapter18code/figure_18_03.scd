(
//In this example, we use higher-level server abstraction classes, Group
//and Synth, to handle node IDs. At least as important though, is the use
//of variables. Now that we specify relationships rather than specific
//values, we can change the gesture dramatically by changing just one or
//two variables. To transpose everything, we only need to change the value
//of ~baseNote. To adjust the duration, we only need to change the ~dur
//variable, and we can change duration independently of deltaOn.
var score;
var deltaOn = 0.2;  //time between the start of one note and the next
var dur = 0.4;      //try changing dur to 0.3, 1.4, 3.4, or whatever you like
var baseNote = 75;  //transpose the entire fragment up or down
var firstPitch  = (baseNote + 0).midicps;  //alter the interval between first
var secondPitch = (baseNote - 4).midicps;  //and ssedond independently of
var thirdPitch  = (baseNote + 7).midicps;  //second and third.

score = Score.new([
	[t =  0.0,
		['/d_recv',
			SynthDef(\NRT_beep, {arg freq, dur, amp = 0.1;
				var half;
				half = dur * 0.5;
				Out.ar(0, SinOsc.ar(freq, 0,
					EnvGen.kr(Env.new([0, amp, 0], [half, half], [4, -4]))));
		}).asBytes],
		(g = Group.basicNew(s)).newMsg,
		//we use environment variables (identified by the preceding ~)
		// since we don't know how many variables we'll need.
		(~s01 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, firstPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s01.freeMsg
	],
	[t = t + deltaOn,
		(~s02 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, firstPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s02.freeMsg
	],
	[t = t + deltaOn,
		(~s03 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, firstPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s03.freeMsg
	],
	[t = t + deltaOn,
		(~s04 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, firstPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s04.freeMsg
	],
	[t = t + deltaOn,
		(~s05 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, secondPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s05.freeMsg
	],
	[t = t + deltaOn,
		(~s06 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, secondPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s06.freeMsg
	],
	[t = t + deltaOn,
		(~s07 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, thirdPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s07.freeMsg
	],
	[t = t + deltaOn,
		(~s08 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, thirdPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s08.freeMsg
	],
	[t = t + deltaOn,
		(~s09 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, thirdPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s09.freeMsg
	],
	[t = t + deltaOn,
		(~s10 = Synth.basicNew(\NRT_beep, s))
			.newMsg(g, [\freq, thirdPitch, \dur, dur], \addToHead)
	],
	[t + dur,
		~s10.freeMsg,
		g.freeMsg
	],
]
);

score.sort;
score.recordNRT(
	Platform.defaultTempDir ++ "trashme",
	"~/chptr_1803.aiff".standardizePath,
	options: ServerOptions.new.numOutputBusChannels_(1)
);
)
