// attempt to get all examples working with Wavesets2/Event ...

Quarks.install("WavesetsEvent");


//	figure 16.24 - a Wavesets object

// using WavesetsEvent quark:
// ~wsev is the WavesetsEvent which does the Wavesets event interface,
// w is the Wavesets2 object which contains all the wavesets data.
~wsev = WavesetsEvent.read(Platform.resourceDir +/+ "sounds/a11wlk01.wav",
	onComplete: {
		w = ~wsev.wavesets;
		b = ~wsev.buffer;
});

w.xings;			// all integer indices of the zero crossings found
w.numXings;		// the total number of zero crossings
w.lengths;		// lengths of all wavesets
w.amps;			// peak amplitude of every waveset
w.maxima;			// index of positive maximum value in every waveset
w.minima;			// index of negative minimum value in every waveset

w.fracXings;		// fractional zerocrossing points
w.fracLengths;	// and lengths: allows more precise looping / tuning.

w.lengths.plot;	// show distribution of lengths
w.amps.plot;

// get data for a single waveset: startFrame, length (in frames), duration
w.frameFor(140, 1);

w.maximumAmp(140, 1);	// maximum amplitude of that waveset or group
w.ampFor(140, 1);


// extract a waveset by hand
w.signal.copyRange(w.xings[150], w.xings[151]).plot("waveset 150");
w.plot(140, 1);	// convenience plotting
w.plot(1510, 1);

// plot a group of 5 adjacent wavesets
w.plot(1510, 5);



// figure 16.25 shows screenshots of the two plots above


//	figure 16.26 - wavesets and buffers

// A Synthdef to play a waveset (or group) n times.
(
// Wavesets.prepareSynthDefs loads this synthdef:
SynthDef(\wvst0, { | out = 0, buf = 0, startFrame = 0, numFrames = 441, rate = 1, sustain = 1, amp = 0.1, pan, interpolation = 2 |
	var phasor = Phasor.ar(0, BufRateScale.ir(buf) * rate * sign(numFrames), 0, abs(numFrames)) + startFrame;
	var env = EnvGen.ar(Env([amp, amp, 0], [sustain, 0]), doneAction: 2);
	var snd = BufRd.ar(1, buf, phasor, 1, interpolation) * env;

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}, \ir.dup(9)).add;
)

// make a wavesets play-event with hand-set parameters:
// play from frame 0 to 440, looped for 0.1 secs, so ca 10 repeats.
(instrument: \wvst0, buf: b.bufnum, startFrame: 0, numFrames: 440, amp: 1, sustain: 0.1).play;

// get frame data from wavesets with frameFor:
(
var startFrame, numFrames, sustain, repeats = 20, rate = 1;
#startFrame, numFrames, sustain = w.frameFor(2300, 5);
(
instrument: \wvst0, buf: b.bufnum, amp: 1,
startFrame: startFrame, numFrames: numFrames,
rate: rate,
sustain: sustain * repeats
).postln.play;
)

// or even use eventFor :
~wsev.eventFor(startWs: 2300, numWs: 5, repeats: 20, rate: 1).put(\amp, 0.5).play;

// WavesetsEvent:asEvent prepares a playable event from an inevent,
// which supports specifying many waveset parameters. The basic ones are:
// start: (waveset index),
// num: number of wavesets to use as group
// repeats: number of repeats of that waveset group
~playme = ~wsev.asEvent((start: 2300, num: 5, repeats: 20, amp: 1));
~playme.play;


// figure 16.27 - a pattern to play wavesets

// by default, this pattern reconstructs a soundfile segment.
(
Pbindef(\ws1).clear;
Pbindef(\ws1,
	\instrument, \wvst0,
	\startWs, Pn(Pseries(0, 1, w.size - 1), 1),
	\numWs, 1,
	\rate, 1,
	\buf, b.bufnum,
	\repeats, 1,
	\amp, 1,
	[\startFrame, \numFrames, \sustain], Pfunc({ |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		if (length > 0) {
			[start, length, wsDur * ev[\repeats] / ev[\rate].abs]
		}
	}),
	\dur, Pkey(\sustain)
).play;
)



//	figure 16.28 - some of Wishart's transforms

// waveset transposition: every second waveset, half speed
Pbindef(\ws1, \rate, 0.5, \startWs, Pn(Pseries(0, 2, w.size / 2), 1)).play;

// reverse every single waveset
Pbindef(\ws1, \rate, -1, \startWs, Pn(Pseries(0, 1, w.size), 1)).play;
// reverse every 2 wavesets
Pbindef(\ws1, \numWs, 3, \rate, -1, \startWs, Pn(Pseries(0, 3, w.size / 3), 1)).play;
// reverse every 20 wavesets
Pbindef(\ws1, \numWs, 10, \rate, -1, \startWs, Pn(Pseries(0, 10, w.size / 10), 1)).play;
// reverse every 200 wavesets
Pbindef(\ws1, \numWs, 30, \rate, -1, \startWs, Pn(Pseries(0, 30, w.size / 30), 1)).play;
// reverse every 200 wavesets
Pbindef(\ws1, \numWs, 100, \rate, -1, \startWs, Pn(Pseries(0, 100, w.size / 100), 1)).play;
// restore
Pbindef(\ws1, \numWs, 1, \rate, 1, \startWs, Pn(Pseries(0, 1, w.size), 1)).play;

// time stretching
Pbindef(\ws1, \rate, 1, \repeats, 2).play;
Pbindef(\ws1, \rate, 1, \repeats, 4).play;
Pbindef(\ws1, \rate, 1, \repeats, 6).play;
Pbindef(\ws1, \repeats, 1).play;	// restore

// waveset omission: drop every second waveset
Pbindef(\ws1, \numWs, 1, \freq, Pseq([1, \], inf) ).play;
Pbindef(\ws1, \numWs, 1, \freq, Pseq([1,1, \, \], inf) ).play;
Pbindef(\ws1, \numWs, 1, \freq, Pfunc({ if (0.25.coin, 1, \) }) ).play; // drop randomly
Pbindef(\ws1, \numWs, 1, \freq, 1 ).play; // restore

// waveset shuffling (randomize waveset order +- 5, 25, 125)
Pbindef(\ws1, \startWs, (Pn(Pseries(0, 1, w.size), 1) + Pfunc({ 5.rand2 })).max(0)).play;
Pbindef(\ws1, \startWs, (Pn(Pseries(0, 1, w.size), 1) + Pfunc({ 25.rand2 })).max(0)).play;
Pbindef(\ws1, \startWs, (Pn(Pseries(0, 1, w.size), 1) + Pfunc({ 125.rand2 })).max(0)).play;





//	figure 16.29 - waveset substitution

// the waveform to substitute
c = Buffer.alloc(s, 512); c.loadCollection(Signal.sineFill(512, [1]));
(
Pbindef(\ws1).clear;
Pbindef(\ws1,
	\instrument, \wvst0,
	\startWs, Pn(Pseries(0, 1, w.size), 5),
	\numWs, 1, \rate, 1,
	\buf, c.bufnum, // sine wave
	\repeats, 1,
	\amp, 1,
	[\startFrame, \numFrames, \sustain], Pfunc({ |ev|
		var start, length, wsDur, origRate;
		origRate = ev[\rate];

		// get orig waveset specs
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);

		// adjust rate for different length of substituted wave
		ev[\rate] = origRate * (512 / length);

		// get amplitude from waveset, to scale full volume sine wave
		ev[\amp] = ev[\amp] * w.ampFor(ev[\startWs], ev[\numWs]);

		[0, 512, wsDur * ev[\repeats] / origRate.abs]
	}),
	\dur, Pkey(\sustain)
).play;
)

// clearer sinewave-ish segments
Pbindef(\ws1, \rate, 1, \repeats, 2).play;
Pbindef(\ws1, \rate, 1, \repeats, 6).play;
Pbindef(\ws1).stop;

// different substitution waveforms to try:
c.loadCollection(Signal.sineFill(512, 1/(1..4))); c.plot; // sawish
// fibonacci overtones
c.loadCollection(Signal.sineFill(512, [1, 1, 1, 0, 1, 0, 0, 1])); c.plot;
c.loadCollection(Signal.rand(512, -1.0, 1.0)); c.plot; // white noise
c.loadCollection(Signal.sineFill(512, [1])); c.plot;// sine


//	waveset interpolation - web examples only
(
SynthDef("wsInterp", { arg out = 0,
	buf1 = 0, startFrame1 = 0, numFrames1 = 1000,
	buf2 = 0, startFrame2 = 0, numFrames2 = 500,
	rate = 1, sustain = 1,
	amp=0.2, pan;

	var lenRatio = (numFrames1 / numFrames2);
	var rateLine = Line.ar(rate, rate * lenRatio, sustain);

	var phasor1 = Phasor.ar(0, BufRateScale.ir(buf1) * rateLine, 0, numFrames1);
	var phasor2 = phasor1 / lenRatio;
	var xfade = Line.ar(0, 1, sustain);

	var snd = (BufRd.ar(1, [buf1, buf2],
		[phasor1 + startFrame1, phasor2 + startFrame2],
		interpolation: 4)
	* [1 - xfade, xfade]).sum;

	OffsetOut.ar(out,
		Pan2.ar(
			snd * EnvGen.ar(Env([amp, amp, 0], [sustain, 0]), doneAction: 2),
			pan
		)
	);
}, \ir.dup(12)).add;
)

(
q = q ? ();
q.playInterp = { |q, startFrame1, numFrames1, startFrame2, numFrames2, numWs=200|
	var set1 = w.frameFor(startFrame1, numFrames1).postln;
	var set2 = w.frameFor(startFrame2, numFrames2).postln;
	var sustain = (set2[2] + set1[2] * 0.5 * numWs).postln;

	(instrument: \wsInterp, buf1: b.bufnum, buf2: b.bufnum, amp: 0.5,

		startFrame1: set1[0], numFrames1: set1[1], rate: 1,
		startFrame2: set2[0], numFrames1: set2[1], sustain: sustain
	).play;
};
)
// some interpolations
q.playInterp(200, 1, 500, 1, 400);
q.playInterp(400, 8, 600, 3, 100);
q.playInterp(200, 1, 500, 5, 600);





//	figure 16.30 - wavesets played with Tdef

// very simple first pass, fixed repeat time
(
Tdef(\ws1).set(\startWs, 400);
Tdef(\ws1).set(\numWs, 5);
Tdef(\ws1).set(\repeats, 5);

Tdef(\ws1, { |ev|
	var startFrame, numFrames, wsSustain;

	loop {
		#startFrame, numFrames, wsSustain = w.frameFor(ev.startWs.next, ev.numWs);

		(instrument: \wvst0, buf: b.bufnum, amp: 1,
			start: startFrame, numFrames:  numFrames,
			sustain: wsSustain * ev.repeats;
		).play;

		0.1.wait;
	}
}).play;
)

Tdef(\ws1).set(\startWs, 420);
Tdef(\ws1).set(\repeats, 3);
Tdef(\ws1).set(\numWs, 2);

// drop in a pattern for starting waveset
Tdef(\ws1).set(\startWs, Pn(Pseries(0, 5, 400) + 500, inf).asStream);





// figure 16.31 - waittime from waveset duration, gap added
(
Tdef(\ws1).set(\gap, 3);
Tdef(\ws1, { |ev|
	var startFrame, numFrames, wsSustain, reps;

	loop {
		reps = ev.repeats.next;

		#startFrame, numFrames, wsSustain =
		w.frameFor(ev.startWs.next, ev.numWs.next);

		(instrument: \wvst0, buf: b.bufnum, amp: 1,
			start: startFrame, numFrames:  numFrames,
			sustain: wsSustain * reps,
			pan: 1.0.rand2
		).play;

		// derive waittime from waveset sustain time
		// add gap based on waveset sustain time
		(wsSustain * (reps + ev.gap.next)).wait;
	}
}).play;
)
// experiment with dropping in patterns:
// very irregular gaps
Tdef(\ws1).set(\gap, { exprand(0.1, 20) });
// sometimes continuous, sometimes gaps
Tdef(\ws1).set(\gap, Pbrown(-10.0, 20, 2.0).max(0).asStream);

// random repeats
Tdef(\ws1).set(\repeats, { exprand(1, 20).round });
// randomize number of wavesets per group
Tdef(\ws1).set(\numWs, { exprand(3, 20).round });
Tdef(\ws1).set(\numWs, 3, \repeats, { rrand(2, 5) });

Tdef(\ws1).stop;


// figure 16.32 - add pitch contour and dropout rate
(
Tdef(\ws1).set(\startWs, Pn(Pseries(0, 5, 400) + 500, inf).asStream);

Tdef(\ws1).set(\gap, 0);
Tdef(\ws1).set(\pitchContour, 0);
Tdef(\ws1).set(\keepCoin, 1.0);
Tdef( 'ws1' ).set( 'repeats' , 5 );
Tdef( 'ws1' ).set( 'numWs' , 3 );

Tdef(\ws1, { |ev|
	var startFrame, numFrames, wsSustain, reps, numWs, numFrames2Avg;
	var squeezer, rate;
	loop {
		reps = ev.repeats.next;
		numWs = ev.numWs.next;

		#startFrame, numFrames, wsSustain =
		w.frameFor(ev.startWs.next, numWs);

		numFrames2Avg = numFrames / numWs / w.avgLength;
		squeezer = numFrames2Avg ** ev.pitchContour.next;
		wsSustain = wsSustain / squeezer;
		rate = 1 * squeezer;

		if (ev.keepCoin.next.coin) {
			(instrument: \wvst0, buf: b.bufnum, amp: 1,
				start: startFrame, numFrames:  numFrames,
				sustain: wsSustain * reps,
				rate: rate,
				pan: 1.0.rand2
			).play;
		};

		(wsSustain * (reps + ev.gap.next)).wait;
	}
}).play;
)

// try different pitch Contours:
Tdef(\ws1).set(\pitchContour, 0); 	// original pitch

Tdef(\ws1).set(\pitchContour, 0.5); // flattened contour

// waveset overtone singing - all equal duration
Tdef(\ws1).set(\pitchContour, 1.0);

// inversion of contour
Tdef(\ws1).set(\pitchContour, 1.5);
Tdef(\ws1).set(\pitchContour, 2);
Tdef(\ws1).set(\repeats, 3);

// waveset omission
Tdef(\ws1).set(\keepCoin, 0.75);
Tdef(\ws1).set(\keepCoin, 1);

// fade out by omission over 13 secs, pause 2 secs
Tdef(\ws1).set(\keepCoin, Pn(Penv([1, 0, 0], [13, 2])).asStream).play;

// add a pitch contour envelope
Tdef(\ws1).set(\pitchContour, Pn(Penv([0, 2, 0], [21, 13])).asStream);


