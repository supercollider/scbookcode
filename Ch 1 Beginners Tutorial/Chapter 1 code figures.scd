// Listen for at least 30 seconds
(
play({
	var sines = 5, speed = 6;
	Mix.fill(sines,
		{arg x;
			Pan2.ar(
				SinOsc.ar(x+1*100,
					mul: max(0,
						LFNoise1.kr(speed) +
						Line.kr(1, -1, 30)
					)
), rand2(1.0))})/sines})
)
/*Figure 1.1
Example of additive synthesis*/

(
play(
	{
		CombN.ar(
			SinOsc.ar(
				midicps(
					LFNoise1.ar(3, 24,
						LFSaw.ar([5, 5.123], 0, 3, 80)
					)
				),
				0, 0.4),
			1, 0.3, 2)
	}
)
)
/*Figure 1.3
Futuristic (circa 1956) nested music*/

(
{
Blip.ar(
		TRand.kr( // frequency or VCO
			100, 1000, // range
			Impulse.kr(Line.kr(1, 20, 60))), // trigger
		TRand.kr( // number of harmonics or VCF
			1, 10, // range
			Impulse.kr(Line.kr(1, 20, 60))), // trigger
		Linen.kr( // mul, or amplitude, VCA
			Impulse.kr(Line.kr(1, 20, 60)), // trigger
			0, // attack
			0.5, // sustain level
			1/Line.kr(1, 20, 60)) // trigger
		)
}.play
)
/*Figure 1.4
VCO, VCF, VCA*/

(
// run this first
p = { // make p equal to this function
	r = Line.kr(1, 20, 60); // rate
	// r = LFTri.kr(1/10) * 3 + 7;
	t = Impulse.kr(r); // trigger
	// t = Dust.kr(r);
	e = Linen.kr(t, 0, 0.5, 1/r); // envelope uses r and t
	f = TRand.kr(1, 10, t); // triggered random also uses t
	// f = e + 1 * 4;
	Blip.ar(f*100, f, e) // f, and e used in Blip
}.play
)

p.free // run this to stop it
/*Figure 1.5
Synthesis example with variables and statements*/

(
{ // carrier and modulator not linked
	r = Impulse.kr(10);
		c = TRand.kr(100, 5000, r);
		m = TRand.kr(100, 500, r);
		PMOsc.ar(c, m, 12)*0.3
	}.play
)

(
{
	var rate = 4, carrier, modRatio; // declare variables
	carrier = LFNoise0.kr(rate) * 500 + 700;
	modRatio = MouseX.kr(1, 2.0);
	// modulator expressed as ratio, therefore timbre
	PMOsc.ar(carrier, carrier*modRatio, 12)*0.3
}.play
)
/*Figure 1.6
Phase modulation with modulator as ratio*/

(
// run this first
SynthDef("PMCrotale", {
	arg midi = 60, tone = 3, art = 1, amp = 0.8, pan = 0;
	var env, out, mod, freq;

	freq = midi.midicps;
	env = Env.perc(0, art);
	mod = 5 + (1/IRand(2, 6));

	out = PMOsc.ar(freq, mod*freq,
		pmindex: EnvGen.kr(env, timeScale: art, levelScale: tone),
		mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3));

	out = Pan2.ar(out, pan);

	out = out * EnvGen.kr(env, timeScale: 1.3*art,
		levelScale: Rand(0.1, 0.5), doneAction:2);
	Out.ar(0, out); // Out.ar(bus, out);
}).add;
)

// Then run this a bunch of times:

Synth("PMCrotale", ["midi", rrand(48, 72).round(1), "tone", rrand(1, 6)])
/*Figure 1.7
Synth definition*/

~b1 = Buffer.loadDialog(s); // rerun this if you need to
( // phase shift
{
	var rate, trigger, frames;
	frames = ~b1.numFrames;
	rate = [1, 1.01];
	trigger = Impulse.kr(rate);
	PlayBuf.ar(1, ~b1, 1, trigger, frames * Line.kr(0, 1, 60)) *
	EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;
}.play;
)

( // speed and direction change
{
	var speed, direction;
	speed = LFNoise0.kr(12!2) * 0.2 + 1;
	direction = LFClipNoise.kr(1/3);
	PlayBuf.ar(1, ~b1, (speed*direction), loop: 1);
}.play;
)
/*Figure 1.8
Playback buffers*/

~b1 = Buffer.loadDialog(s); // rerun this if you need to
~b2 = Buffer.loadDialog(s); // rerun this if you need to
( // you won't hear any sound yet
~kbus1 = Bus.control; // a control bus
~kbus2 = Bus.control; // a control bus
{
	var speed, direction;
	speed = In.kr(~kbus1, 1) * 0.2 + 1;
	direction = In.kr(~kbus2);
	PlayBuf.ar(1, ~b1, (speed * direction), loop: 1);
}.play;
)

(
// now start the controls
{Out.kr(~kbus1, LFNoise0.kr(12))}.play;
{Out.kr(~kbus2, LFClipNoise.kr(1/4))}.play;
)

// Now start the second buffer with the same control input busses,
// but send it to the right channel using Out.ar(1 etc.

(
{
	var speed, direction;
	speed = In.kr(~kbus1, 1) * 0.2 + 1;
	direction = In.kr(~kbus2);
	Out.ar(1, PlayBuf.ar(1, ~b2, (speed * direction), loop: 1));
}.play;
)
/*Figure 1.9
Connecting controls with a bus*/

~b1 = Buffer.loadDialog(s); // rerun this if you need to
~b2 = Buffer.loadDialog(s); // rerun this if you need to
(
{
	Out.ar(0,
		Pan2.ar(PlayBuf.ar(1, ~b1, loop: 1) *
			SinOsc.ar(LFNoise1.kr(12, mul: 500, add: 600)),
			0.5)
	)
}.play
)

(
{var source, delay;
	source = PlayBuf.ar(1, ~b2, loop: 1);
	delay = AllpassC.ar(source, 2, [0.65, 1.15], 10);
	Out.ar(0,
		Pan2.ar(source) + delay
	)
}.play
)
/*Figure 1.10
Buffer modulation*/

( // This will not make sound, only print to the screen
Task({
	a = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"];
	"count, midi, pitch, octave".postln; // Print a table header first
	do(50, {arg count;
		p = rrand(36, 72);
		[count, p, a.wrapAt(p), (p/12).round(1) -1].postln;
		1.wait;
	})
}).play
)
/*Figure 1.12
Random MIDI walk*/

// This patch uses the PMCrotale synth definition from figure 1.7.
// Be sure it has been added (run).
(
a = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"];
"event, midi, pitch, octave".postln;
r = Task({
	inf.do({ arg count;
		var midi, oct, density;
		// Density at 0.7 creates events 70% of the time.
		density = 0.7;
		// [0, 2, 4, 7, 9] is a Pentatonic scale. Try [0, 2, 4, 5, 7, 9, 11],
		// [0, 2, 3, 5, 7, 9, 11], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
		midi = [0, 2, 4, 7, 9].choose;
		oct = [48, 60, 72].choose;
		if(density.coin,
		{ // true action -- a note
			"".postln;
			[midi + oct, a.wrapAt(midi), (oct/12).round(1)].post;
			Synth("PMCrotale",
				["midi", midi + oct, "tone", rrand(1, 7),
				"art", rrand(0.3, 2.0), "amp", rrand(0.3, 0.6),
				"pan", 1.0.rand2]);
		},
			{["rest"]} // false action -- a rest
		);
		0.2.wait;
	});
}).start
)
/*Figure 1.13
Random Crotale Walk*/

(
var row, inversion, pitchClass;
row = Array.series(11, 1).scramble.insert(0, 0);
// or enter your own row, e.g., Webern's Op 27
// row = [0, 11, 8, 2, 1, 7, 9, 10, 4, 3, 5, 6];
row.postln;
inversion = 12 - row;
// Add spaces to the pitch class strings for a tidy row
pitchClass = ["C  ", "C# ", "D  ", "Eb ",
	"E  ", "F  ", "F# ", "G  ", "Ab ", "A  ", "Bb ", "B  "];
inversion.do({arg eachInv;
	var trans;
	trans = (row + eachInv);
	// prints pitch class
	trans.do({arg scaleDegree; pitchClass.wrapAt(scaleDegree).post});
	//"".postln;
	//trans.do({arg scaleDegree; (scaleDegree%12).post; " ".post});
	"".postln;
});
"".postln;
)

// More elegant with syntax shortcuts
r = ((1, 2..11).scramble.insert(0, 0).neg); r.neg.do({|i| postln((r + i)%12) });
( // or
p = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "T", "E"];
c = ["C ", "C#", "D ", "Eb", "E ", "F ", "F#", "G ", "Ab", "A ", "Bb", "B "];
r = Array.series(11, 1).scramble.insert(0, 0);
(r.neg).do({|i| postln(p@((r + i)%12)) });
(r.neg).do({|i| postln(c@((r + i)%12)) });
)
/*Figure 1.14
Nested do to generate a 12-tone matrix*/

(
{
	var fund = 220;
	Mix.ar(
		[
			SinOsc.ar(220, mul: max(0, LFNoise1.kr(12))),
			SinOsc.ar(440, mul: max(0, LFNoise1.kr(12)))*1/2,
			SinOsc.ar(660, mul: max(0, LFNoise1.kr(12)))*1/3,
			SinOsc.ar(880, mul: max(0, LFNoise1.kr(12)))*1/4,
			SinOsc.ar(1110, mul: max(0, LFNoise1.kr(12)))*1/5,
			SinOsc.ar(1320, mul: max(0, LFNoise1.kr(12)))*1/6
		]
	)*0.3!2
}.play
)
/*Figure 1.15
Additive synthesis*/

(
{
	var nharm = 12;
	Mix.fill(nharm,
		{arg count;
			var harm;
			harm = count + 1 * 110; // remember precedence; count + 1, then * 110
			Pan2.ar(
				SinOsc.ar(harm,
				mul: max(0, SinOsc.kr(count+1/4)))*1/(count+1),
				(count/((nharm-1)/2) - 1).postln)
	}
)*0.4}.play
)

/*Figure 1.16
Example of additive synthesis*/

// Try this first, to illutrate the array of arrays
Array.fill(3, {Array.fill(5, {rand(100)})})
// Then this patch
(
{
	var scale, specs, freqs, amps, rings,
	numRes = 5, bells = 10, pan;
	scale = [60, 62, 64, 67, 69].midicps;
	Mix.fill(bells, {
		arg count;
		freqs = {rrand(1, 15)*(scale.choose)}!numRes; // frequencies
		amps = {rrand(0.3, 0.9)}!numRes; // amplitudes of those freqs
		rings = {rrand(1.0, 4.0)}!numRes; // decay times
		specs = [freqs, amps, rings].round(0.01); // array of arrays
		// specs.postln; // uncomment to see the specs array
		pan = (count/((bells-1)/2) - 1); // pan positin of each bell
		// pan = (LFNoise1.kr(rrand(3, 6))*2).softclip; // random pan
		Pan2.ar(
			Klank.ar(`specs,
				Dust.ar(1/6, 0.03)), // excitation of model
			pan)
	})
}.play
)

(
{
	var nharm = 12;
	Mix.fill(nharm,
		{arg count;
			var harm;
			harm = count + 1 * 110; // remember precedence; count + 1, then * 110
			Pan2.ar(
				SinOsc.ar(harm,
				mul: max(0, SinOsc.kr(count+1/4)))*1/(count+1),
				(count/((nharm-1)/2) - 1).postln)
	}
)*0.4}.play
)

/*Figure 1.18
Physically modeled bells*/

( // first define the synth with arguments
SynthDef.new("SimpleBlip", {
	arg midi = 60, tone = 10, art = 0.125, amp = 0.2, pan = -1;
	var out;
	out = Pan2.ar(
		Blip.ar(midi.midicps, tone) * EnvGen.kr(Env.perc(0.01, art)),
		pan // pan position
	);
	DetectSilence.ar(out, doneAction:2); // turn off silent notes
	// adjust volume based on midi pitch
	amp = amp - ((midi - 60) * 0.02);
	Out.ar(0, out*amp)
}).add;
)

(
// Simple version; pitch, tone, articulation, amp sequence
Task({
	inf.do({arg counter; // counter to advance note
		Synth("SimpleBlip", [
			\midi, [60, 61, 62, 63].wrapAt(counter),
			\tone, [1, 2, 3, 4, 5].wrapAt(counter),
			\art, [0.1, 0.2, 0.3, 0.4].wrapAt(counter),
			\amp, [0.3, 0.5, 0.6, 0.6].wrapAt(counter)*0.5,
			\pan, 0
		]);
		0.125.wait; // tempo
	});
}).start
)

(
// More complex, using if statements to swap, replace, add, and reset
~allThree = [0, 0, 0]; // Three containers for Blip instruments
~pSeq = [0, 0, 0]; // Three containers for sequences
~scaleAdd = [4, 5, 11, 10, 3, 6]; // Scale steps to add
~scale = [0, 2, 7, 9]; // Starting scale steps
~pitchClasses = // for converting midi numbers into pitch class
[" C", " C#", " D", " Eb", " E", " F",
	" F#", " G", " Ab", " A", " Bb", " B"];
Task({
	inf.do({
		arg thisIteration;
		var steps, durSeq, harmSeq;
		"Iteration: ".post; thisIteration.asInteger.postln;
		steps = rrand(6, 12); // Choose length of sequence
		// every fourth iteration, add a scale degree to ~scale
		// and remove that scale degree from ~scaleAdd
		if(thisIteration%4 == 3, {
				~scale = ~scale.add(~scaleAdd.at(0));
				~scaleAdd.remove(~scaleAdd.at(0));
		});
		if(thisIteration%24 == 0, // every 24th iteration, reset scales
			{~scale = [0, 2, 7, 9]; ~scaleAdd = [4, 5, 11, 10, 3, 6];});
		"Current scale: ".post; ~scale.postln;
		// Load each pitch sequence array with choices from scale
		3.do({arg counter2; ~pSeq.wrapPut(counter2,
			Array.fill(rrand(4, 12), {
				~scale.choose + [48, 60].choose}))
		});
		// Print sequences
		"Each sequence in pitch class, MIDI, scale degree".postln;
		~pSeq.do( // for each sequence
			{arg thisSequence, seqNumber;
				"Seq ".post; (seqNumber+1).post; ": ".post;
				thisSequence.do({ // print the pitch classes and octave
					arg thisNote; ~pitchClasses.at(thisNote%12).post; thisNote.div(12).post;
				}); // Print midi values and pitch class numbers
				", ".post; thisSequence.post; ", ".post; (thisSequence%12).postln;
		});
		"\n****".postln; // print return
		// fill harmonic and duration arrays with new values
		harmSeq = Array.fill(steps, {rrand(1.0, 7.0)});
		durSeq = Array.fill(steps -1, {rrand(0.01, 0.9)});
		// Stop the previous iteration of this instrument
		~allThree.wrapAt(thisIteration).stop;
		// And start new ones
		~allThree.wrapPut(thisIteration,
			Task({
				inf.do({arg cnt3; // cnt2 is each iteration
					Synth("SimpleBlip", [
						\midi, ~pSeq.wrapAt(thisIteration).wrapAt(cnt3),
						\tone, harmSeq.wrapAt(cnt3),
						\art, durSeq.wrapAt(cnt3),
						\amp, rrand(0.1, 0.3),
						\pan, thisIteration.wrap(-1, 2)
					]);
					0.125.wait; // tempo of each note
			})}).start;
		);
		4.wait}) // time between each sequence
}).start;
)

/*Figure 1.19
Generative sequences using arrays*/

(
{
	var trigger, control, scale, offset;
	scale = 300; // try other values, but not greater than offset
	offset = 600; // try other values
	trigger = Impulse.kr(10);
	control = SinOsc.ar(1/4).scope("control"); // LFO
	control = control * scale + offset;
	SinOsc.ar(freq: abs(control).poll).scope("audio")
}.play
)
/*Figure 1.21
SinOsc offset and scaled for control*/


(
// run this first
a = SynthDef("Latch_demo",
	{
		arg rate = 9;
		var freq, latchrate, index, ratio, env, out;
		latchrate = rate*LFNoise0.kr(1/10).range(1.3, 1.9);
		index = Latch.kr(
			LFSaw.kr(latchrate).range(4, 5),
			Impulse.kr(rate)
		);
		freq = Latch.kr(
			LFSaw.kr(latchrate,
				mul: max(0, LFNoise1.kr(1/5).range(-14, 34)),
				add: LFNoise0.kr(1/7).range(48, 72)),
			Impulse.kr(rate)
		).round(1).midicps;
		ratio = LFNoise1.kr(1/10).range(3.0, 7.0);

		env = EnvGen.kr(
			Env.perc(0, LFNoise0.kr(rate).range(0.5, 2.5)/rate),
			Impulse.kr(rate),
			LFNoise1.kr([5, 5], 2, 1).max(0).min(0.8));
		out = PMOsc.ar(
			[freq, freq * 1.5],
			freq*ratio,
			index,
			mul: env
		);
		Out.ar(0, out);
	}
).play
)
/*Figure 1.22
PMOsc with sample and hold (latch)*/


(
{ // it's just a bell
	var burst, burstEnv, bell, delay, dry,
	burstFreq = 500, freqs, amps, rings;
	burstEnv = EnvGen.kr(Env.perc(0, 0.05),
		Dust.kr(1/5), 0.1);
	// burstEnv.poll(100, "env");
	burst = SinOsc.ar(freq: burstFreq,
		mul: burstEnv);
	// burst.poll(100, "burst");
	freqs = Array.fill(10, {exprand(100, 10000)});
	amps = Array.fill(10, {rrand(0.01, 0.1)});
	rings = Array.fill(10, {rrand(1.0, 6.0)});
	// [freqs, amps, rings].round(0.01).postln;
	// "safe" values
	// freqs = [100, 200, 300, 400];
	// amps = [1, 1, 1, 1];
	// rings = [1, 1, 1, 1];
	bell = Pan2.ar(
		Klank.ar(`[freqs, amps, rings], burst),
		rrand(-1.0, 1.0)
	);
	delay = AllpassN.ar(bell, 2.5,
		[LFNoise1.kr(7, 1.5, 1.6), LFNoise1.kr(7, 1.5, 1.6)],
		1, mul: 0.8);
	bell
	+ delay
	// + SinOsc.ar(mul: LFPulse.kr(1) * 0.05);
}.play
)
/*Figure 1.23
It’s just a bell*/

