// Stochastic and Deterministic Algorithms for Sound Synthesis and Composition

// Sergio Luque and Daniel Mayer


// Figure 19.1 Code for a 500-step symmetric random walk.

(
var walk = [ 0 ]; // initial position

// 500 new positions are calculated by adding steps of -1 or 1 to the previous position
500.do({ walk = walk.add(walk.last + [ -1, 1 ].choose) });
walk.plot(discrete: true)
)


// Figure 19.3 Code for one hundred 500-step symmetric random walks.

(
({
    var walk = [ 0 ];

    500.do({ walk = walk.add(walk.last + [ -1, 1 ].choose) });
    walk
} ! 100).plot(discrete: true).plotColor_(({ Color.rand } ! 100)).superpose_(true)
)


// Figure 19.5 An asymmetric random walk with a pair of elastic barriers.

(
SynthDef(\sine, {| freq = 440, amp = 0.1, sustain = 0.25, pan = 0 |
	var signal, env;

	signal	= SinOsc.ar(freq);
	env = EnvGen.ar(Env.sine(sustain, amp), doneAction: 2);
	signal = Pan2.ar(signal * env, pan);
	OffsetOut.ar(0, signal)
}).add
)

(
var walk = [ 60 ]; // middle C

500.do({
    walk = walk.add((walk.last + [ -1, 1 ].wchoose([ 0.45, 0.55 ])).fold(21, 108))
});
walk.plot(discrete: true);
Pbind(\midinote, Pseq(walk), \dur, 1/50, \legato, 3, \instrument, \sine).play
)


// Figure 19.6 Pbrown.

(
Ppar(
    ({
        Pbind(
            // a Pbrown with steps with a max step size of ± an eighth tone (0.25)
            \midinote, Pbrown(84.0, 108.0, 0.25, inf),
            \dur, 1/25, \legato, Pbrown(0.1, 3.0, 0.3),
            \db, Pbrown(-57.0, -21.0, 6.0),
            \pan, Pbrown(-1, 1, 0.1),
            \instrument, \sine
        )
    } ! 2) // change the 2 to try different numbers of Pbinds
).play
)


// Figure 19.7 Random walks over the pitch sieve of Jonchaies.

(
SynthDef(\percSine, {| freq = 440, amp = 0.1, release = 0.25, pan = 0 |
	var signal, env;

	signal	= SinOsc.ar(freq);
	env = EnvGen.ar(Env.perc(0.01, release, amp), doneAction: 2);
	signal = Pan2.ar(signal * env, pan);
	OffsetOut.ar(0, signal)
}).add
)

(
p = Pbind(
    // a pitch sieve from A2 to E7
    \sieve, ([ 45 ] ++ [ 1, 3, 1, 2, 4, 1, 4, 1].wrapExtend(26)).integrate,
    // a random walk that returns integers within the range of indices of the pitch sieve
    \walk,  Pbrown(0, 26, 1),
    // the position of the random walk used as an index into the sieve for \midinote
    \midinote, Pfunc({| event | event[\sieve][event[\walk]] }),
    \dur, 1/8,  \release, 0.5, \db, -24,
    // the values of \midinote mapped to \pan
    \pan, Pkey(\midinote).linlin(45, 100, -1, 1),
    \instrument, \percSine,
);
// three Pbinds in parallel starting after 0, 8 and 15 seconds
Ptpar([ 0, p, 8, p, 15, p ]).play
)


Pbind(\dur, 0.25 * Pbrown(0.5, 2, 0.1125), \instrument, \percSine).play


// Figure 19.8 The melody of Steve Reich’s Piano Phase (1967) shifting out of phase.

(
Ppar([
	Pbind(\dur, 0.14 * Pbrown(0.975, 1.025, 0.01), \midinote, Pseq([ 76, 78, 83, 85, 78, 76, 85, 83, 78, 86, 85 ], inf), \pan, -1, \instrument, \percSine),
	Pbind(\dur, 0.14 * Pbrown(0.975, 1.025, 0.01), \midinote, Pseq([ 76, 78, 83, 85, 78, 76, 85, 83, 78, 86, 85 ], inf), \pan, 1, \instrument, \percSine)
]).play
)

// Figure 19.9 Sequences of random walks.

(
// try different numbers of random walks, maximum step sizes, probabilities and durations
var numRWalks = 16;

Pbind(
    // a "just octatonic" scale: the pitch classes of the first eight prime-numbered harmonics of C1 (from James Tenney)
    \scale, ((12.midicps * [ 2, 3, 5, 7, 11, 13, 17, 19 ]).cpsmidi % 12).sort,
    \degree, Pswitch1(
        ({ Pbrown(0, 56, Pwrand([ 7, 0 ], [ 0.1, 0.9 ], inf)) } ! numRWalks),
        Pseq(Array.series(numRWalks, 0, 1), inf)
    ),
    \octave, 2,
    \dur, 1/20, \db, -24,
    //the random walks are spread across the stereo field
    \pan, Pseq(Array.series(numRWalks, -1, 2/(numRWalks-1)), inf),
    \instrument, \percSine
).play
)

(
var numRWalks = 17;

Pbind(
    \midinote, Pswitch1(
        // floating-point numbers within the range of the piano (from A0 to C8)
        ({ Pbrown(21.0, 108.0, Pwrand([ 0.25, 0.0 ], [ 0.01, 0.99 ], inf)) } ! numRWalks),
        Pseq(Array.series(numRWalks, 0, 1), inf)
    ),
    \dur, (1/200) * Pbrown(0.5, 2, 0.02), \db, -27,
    \pan, Pseq(Array.series(numRWalks, -1, 2/(numRWalks-1)), inf),
    \instrument, \percSine
).play
)


// Figure 19.11 DemandEnvGen.

(
{
    // a sawtooth oscillator with DemandEnvGen
    var amps, durs;

    amps = [ 0, 0.025, -0.025 ];
    // the number of samples that each breakpoint lasts is multiplied by the duration of one sample in seconds
    durs = [ 50, 0, 50 ] * SampleDur.ir;
    Pan2.ar(DemandEnvGen.ar(Dseq(amps, inf), Dseq(durs, inf)))
}.play
)

(
{
    // a waveform with 36 breakpoints
    var amps, durs, numBps;

    numBps = 36; // try different numbers of breakpoints
    // amplitudes are generated with a uniform random distribution (from -0.1 to 0.1)
    amps = ({ rrand(-0.1, 0.1) } ! numBps);
    // durations are generated with an exponential distribution (from 1 to 128 samples) and truncated to multiples of 1
    durs = ({ exprand(1, 128).trunc } ! numBps) * SampleDur.ir;
    Pan2.ar(DemandEnvGen.ar(Dseq(amps, inf), Dseq(durs, inf)))
}.play
)


// Figure 19.12 Dynamic Stochastic Synthesis.

(
{
    var numBps, minFreq, maxFreq, maxDur, minDur, maxDurStep, maxAmp, maxAmpStep;

    // number of breakpoints
    numBps = 17;
    // min and max frequencies
    minFreq	 = 27.5;
    maxFreq = 2500;
    // convert the min and max frequencies to number of samples
    maxDur = SampleRate.ir / minFreq;
    minDur = SampleRate.ir / maxFreq;
    // divide the min and max number of samples by the number of breakpoints:
    // these values are the barriers for the duration random walk of each breakpoint
    maxDur = maxDur/numBps;
    minDur = minDur/numBps;
    // ± maximum size for the steps of the duration random walks
    maxDurStep = 8;
    // maximum amplitude: the ± barrier for the amplitude random walks
    maxAmp = 0.1;
    // ± maximum size for the steps of the amplitude random walks
    maxAmpStep = 0.05;
    Pan2.ar(
        DemandEnvGen.ar(
            // amplitude values
            Dswitch1(
                ({ Dbrown(maxAmp.neg, maxAmp, maxAmpStep) } ! numBps),
                Dseq(Array.series(numBps, 0, 1), inf)
            ),
            // duration values
            Dswitch1(
                ({ Dbrown(minDur, maxDur, maxDurStep) } ! numBps),
                Dseq(Array.series(numBps, 0, 1), inf)
            ) * SampleDur.ir
    ) )
}.play
)


// Figure 19.13 Code for a graphical user interface for Dynamic Stochastic Synthesis.

(
// two DemandEnvGens (left channel and right channel)
Ndef(\Dynamic_Stochastic_Synthesis,
    {| bpRatio = 0.5, freqA = 27.5, freqB = 2093, maxDurSt = 0.1, maxAmp = 0.1, maxAmSt = 0.1 |
        var numBps, maxNumBps = 1603, freqs, maxDur, minDur, maxDurStep, maxAmpStep;

        freqs = [ min(freqA, freqB), max(freqA, freqB) ];
        maxDur = SampleRate.ir / freqs[0];
        minDur = SampleRate.ir / freqs[1];
        numBps = (minDur * bpRatio).trunc.clip(1, maxNumBps);
        maxDur = maxDur / numBps;
        minDur = minDur / numBps;
        maxDurStep = (maxDur - minDur) * maxDurSt;
        maxAmpStep = (maxAmp * 2) * maxAmSt;
        ({
            DemandEnvGen.ar(
                Dswitch1(
                    { Dbrown(maxAmp.neg, maxAmp, maxAmpStep) } ! maxNumBps,
                    Dseries(0, 1) % numBps
                ),
                Dswitch1(
                    { Dbrown(minDur, maxDur, maxDurStep) } ! maxNumBps,
                    Dseries(0, 1) % numBps
                ) * SampleDur.ir
        ) } ! 2)
}).play;

// specifications for the GUI
Spec.add(\bpRatio, [ 0, 1, \lin, 0, 0.5 ]);
Spec.add(\freqA, [ 27.5, 2093, \exp, 0, 27.5 ]);
Spec.add(\freqB, [ 27.5, 2093, \exp, 0, 2093 ]);
Spec.add(\maxDurSt, [ 0, 1, \lin, 0, 0.1]);
Spec.add(\maxAmp, [ 0.001, 1, \exp, 0, 0.1 ]);
Spec.add(\maxAmSt, [ 0, 1, \lin, 0, 0.1]);
Ndef(\Dynamic_Stochastic_Synthesis).gui
)


// Figure 19.15 Pseg.

(
Pbind(
    // from C4 to G4 in 5 seconds and back to C4 in 1 second
    \midinote, Pseg(Pseq([ 60, 67 ],inf), Pseq([ 5, 1 ],inf)).trace,
    \dur, Pexprand(0.1, 0.5),
    \instrument, \percSine
).play
)


// Figure 19.16 Tendency masks for pitch, panning, and duration.

(
SynthDef(\saw, {| freq = 440, amp = 0.1, sustain = 0.25, pan = 0 |
    var signal, env;

    signal = Saw.ar(freq);
    env = EnvGen.ar(Env.sine(sustain, amp), doneAction:2);
    signal = Pan2.ar(signal * env, pan);
    OffsetOut.ar(0, signal)
}).add
)

(
// tendency masks for pitch and panning (2100 notes)
~allMidinotes = [];
Pbind(
    \midinote, Pwhite(
        // from B5 to C8 to C#8 to C#1 in 12, 2 and 3 seconds
        Pseg(Pseq([ 83, 108, 109, 25, 25 ]), Pseq([ 12, 2, 3, 4 ])),
        // from F#6 to C8  to C#8 to F#2 in 12, 2 and 7 seconds
        Pseg(Pseq([ 90, 108, 109, 42 ]), Pseq([ 12, 2, 7 ]))
    ),
    \pan, Pwhite(
        // from left to right to left in 14 and 3 seconds
        Pseg(Pseq([ -1, 1, -1, -1 ]), Pseq([ 14, 3, 4 ])),
        // from center to right in 14 seconds
        Pseg(Pseq([  0, 1, 1 ]), Pseq([ 14, 7 ]))
    ),
    \dur, 1/100, \legato, 25, \db, -27,
    \instrument, \saw,
    \addToList, Pfunc({| event |  ~allMidinotes = ~allMidinotes.add(event[\midinote]) })
).play
)
// plot the values generated by the tendency mask for the \midinote key
~allMidinotes.plot(discrete: true).resolution_(0)

(
// a tendency mask for pitch
// based on James Tenney's "Form 4 - in memoriam Morton Feldman" for chamber ensemble (five times faster: this example lasts 3'15" )
~allMidinotes = [];
Pbind(
    // seven notes from the octatonic scale (pitch class set 7-31)
    \scale, [ 0, 1, 3, 4, 6, 7, 10 ],
    \degree, Pwhite(
        Pseg(Pseq([ 1, 33, 33 ]), Pseq([ 810, 165 ]/5)),
        Pseg(Pseq([ 0, 0, 32, 32 ]), Pseq([ 330, 615, 30 ]/5))
    ).round,
    \root, 4, \octave, 3,
    \dur, Pwhite(0.1875, 0.375), \legato, 16, \db, -36,
    \pan, Pseq([ -1, -0.33, 0.33, 1 ], inf),
    \instrument, \sine,
    \addToArray, Pfunc({| event |  ~allMidinotes =~allMidinotes.add(event.use({ ~midinote.value }))})
).play
)
// plot the values generated by the tendency mask as MIDI note numbers
~allMidinotes.plot(discrete: true).resolution_(0)

(
// a tendency mask for duration
// loosely based on the final part of Elliott Carter's 90+ for solo piano
Pbind(
    //  durations go from disorder to order and back to disorder
    \dur, Pwhite(
        Pseg(Pseq([ 0.016, 0.125, 0.125, 0.016 ]), Pseq([ 15, 3, 15 ])),
        Pseg(Pseq([ 3, 0.125, 0.125, 3 ]), Pseq([ 15, 3, 15 ]))
    ),
    // hexachord 6-Z17 (inverted) is permutated randomly and transposed cyclically (+3 and +8 semitones) at each repetition
    \note, Pn(Pshuf([ 0, 1, 4, 6, 7, 8 ], 1), inf) + Pseq([ Pn(3, 6), Pn(8, 6) ], inf),
    \instrument, \percSine
).play
)


// Figure 19.18 Tendency masks for the concatenation of waveforms.

(
// a function that creates arrays with random amplitude and duration values
// DemandEnvGen will create waveforms with these values
~waveformMaker = { arg numWaveforms= 12, loPitch = 21.0, hiPitch = 96.0;
    ~waveforms= ({
        var numBps, amps, totalDur, durs;

        totalDur = rrand(loPitch, hiPitch).min(96).midicps.reciprocal * s.sampleRate;
        numBps = (totalDur * exprand(0.1, 0.25)).asInteger;
        amps =  [ 0 ] ++ ({ rrand(-1.0, 1.0) }   ! (numBps - 1));
        durs = totalDur.round.partition(numBps);
        [ amps, durs, numBps ]
    } ! numWaveforms)
}
)

({
    // one  waveform
    var amps, durs;

    ~waveformMaker.value(1); // the function creates the parameters of one waveform
    #amps, durs = ~waveforms.flop;
    Pan2.ar(DemandEnvGen.ar(Dseq(amps[0], inf), Dseq(durs[0] * SampleDur.ir, inf)), 0, 0.1)
}.play
)

({
    // 4 waveforms concatenated randomly with a Drand
    var amps, durs, numBps, index, selection;

    ~waveformMaker.value(4); // change the number of waveforms
    #amps, durs, numBps = ~waveforms.flop;
    amps = amps.collect({| waveformAmps | Dseq(waveformAmps, inf) });
    durs = durs.collect({| waveformDurs | Dseq(waveformDurs, inf) });
    selection = Ddup(2, Drand(Array.series(~waveforms.size, 0, 1), inf));
    index = Ddup(Dswitch1(numBps, selection) * 2, selection);
    Pan2.ar(DemandEnvGen.ar(Dswitch1(amps, index), Dswitch1(durs * SampleDur.ir, index)), 0, 0.125)
}.play
)

({
    // a narrow tendency mask: 2 waveforms
    var amps, durs, numBps, index, tendency;

    ~waveformMaker.value(2);
    #amps, durs, numBps = ~waveforms.flop;
    amps = amps.collect({| waveformAmps | Dseq(waveformAmps, inf) });
    durs = durs.collect({| waveformDurs | Dseq(waveformDurs, inf) });
    tendency = Ddup(2,
        Dwhite(
            DemandEnvGen.ar(Dwhite(0.5, 1.0, inf), 4),
            DemandEnvGen.ar(Dwhite(1.0, 1.5, inf), 4),
        ).trunc
    );
    index = Ddup(Dswitch1(numBps, tendency) * 2, tendency);
    Pan2.ar(DemandEnvGen.ar(Dswitch1(amps, index), Dswitch1(durs * SampleDur.ir, index)), 0, 0.125)
}.play
)

({
    // a tendency mask that goes from narrow to wide and back to narrow
    var amps, durs, numBps, index, tendency;

    ~waveformMaker.value(6, 60.0, 96.0);
    #amps, durs, numBps = ~waveforms.flop;
    amps = amps.collect({| waveformAmps | Dseq(waveformAmps, inf) });
    durs = durs.collect({| waveformDurs | Dseq(waveformDurs, inf) });
    tendency = Ddup(2,
        Dwhite(
            DemandEnvGen.ar(
                Dseq([ 0, 0, 0, ~waveforms.lastIndex + 0.99 ]),
                Dseq([ 2, 3, 3 ])
            ),
            DemandEnvGen.ar(
                Dseq([ 0, 0, ~waveforms.lastIndex + 0.99, ~waveforms.lastIndex + 0.99 ]),
                Dseq([ 2, 3, 3 ])
            )
        ).trunc
    );
    index = Ddup(Dswitch1(numBps, tendency) * 2, tendency);
    Pan2.ar(DemandEnvGen.ar(Dswitch1(amps, index), Dswitch1(durs * SampleDur.ir, index)), 0, 0.125)
}.play
)

({
    // a  tendency mask with breakpoints with random levels
    var size, amps, durs, numBps, index, tendency;

    size = rrand(3, 12);
    postf("% waveforms\n", size);
    ~waveformMaker.value(size);
    #amps, durs, numBps = ~waveforms.flop;
    amps = amps.collect({| waveformAmps | Dseq(waveformAmps, inf) });
    durs = durs.collect({| waveformDurs | Dseq(waveformDurs, inf) });
    tendency = Ddup(2,
        Dwhite(
            DemandEnvGen.ar(Dwhite(0, ~waveforms.lastIndex + 0.99), 4),
            DemandEnvGen.ar(Dwhite(0, ~waveforms.lastIndex + 0.99), 4)
        ).trunc
    );
    index = Ddup(Dswitch1(numBps, tendency) * 2, tendency);
    Pan2.ar(DemandEnvGen.ar(Dswitch1(amps, index), Dswitch1(durs * SampleDur.ir, index)), 0, 0.125)
}.play
)




// Figure 19.19 Example by Ville-Matias Heikkilä (Viznut).

// first example from https://www.youtube.com/watch?v=tCRPUv8V22o
// the posted input doesn't work in SC because of LR-precedence !
// (t * 5 & t >> 7) | (t * 3 & t >> 10)

(
x = {
	var t = PulseCount.ar(Impulse.ar(8000)); // assuming server running 48 kHz !
	var sig = ((t*5) & (t>>7)) | ((t*3) & (t>>10));
	(sig % 256).linlin(0, 255, 0, 0.2) ! 2 // reduce to 8 bit and limit
}.play
)

x.release




// Figure 19.20 Function that makes a UGen graph Function.

(
~bytebeats = { |func, rate = 8000, mod = 256, amp = 0.3, cutoff, leakDC = false|
	{
		|att = 0.1, rel = 1, gate = 1|
		var t = PulseCount.ar(Impulse.ar(rate.value));
		var sig = func.(t) % mod.value;
		var env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);

		// NamedControl allows using default arguments passed to the maker function
		var amplitude = \amp.kr(amp.value);
		var maxAmp = 0.5;

		// map to [0, amp], amp is kept below maxAmp
		sig = sig.linlin(0, mod, 0, amplitude.clip(0, maxAmp));

		// LPF, LeakDC
		sig = cutoff.notNil.if { LPF.ar(sig, cutoff.value) }{ sig };
		sig = leakDC.if { LeakDC.ar(sig) }{ sig };

		// allow multichannel handling, expand mono to stereo
		(sig.size > 1).if { sig }{ sig ! 2 } * env
	}
};

s.scope;
)

// define bytebeat as Function and use it as input to the maker Function

f = { |t| ((t*5) & (t>>7)) | ((t*3) & (t>>10)) };

// assume 48 kHz

u = ~bytebeats.(f, 8000);

x = u.play;

x.set(\amp, 0.3);

x.release;


// use the UGen graph Function with Ndef

Ndef(\b, u).play;

Ndef(\b).release;




// Figure 19.21 Variants of the "42 melody", cited by Ville-Matias Heikkilä.

f = { |t| t * (42 & (t>>10)) };

x = ~bytebeats.(f, amp: 0.3).play;

x.release


// stereo variant with oscillating rate
// the maker function args can be passed ugen aggregates, wrapped in a function


(
x = ~bytebeats.(f,
	rate: { SinOsc.ar(SinOsc.ar(0.2).range(5, 20), [0, pi]).range(7500, 8500) }
).play
)

x.release


// modulated bit(crushing) param, stereo

(
x = ~bytebeats.(f,
	mod: { 2 ** (SinOsc.ar(LFSaw.ar([0.2, 0.21]).range(0.2, 200)).range(4, 8).round) }
).play
)

x.release



// Figure 19.22 Alternatives to an integer counter.


// linear UGens can chime in instead of a counter:
// Sweep, Phasor, Saw, VarSaw, LFDNoise1 etc.

(
x = {
	var sig = LFDNoise1.ar(5 ! 2).range(1000, 15000).round;
	sig = sig & (sig << 7);
	LeakDC.ar(sig.linlin(0, 1024, 0, 0.2)) // linear mapping clips values over 1024
}.play
)

x.release



// varying the width of a VarSaw

(
x = {
	var sig = VarSaw.ar(2, width: SinOsc.ar([5.49, 5.51], [0, pi]).range(0, 1)).range(500, 1500).round;
	sig = sig & (sig << 7);
	LeakDC.ar(sig.linlin(0, 1024, 0, 0.2)) // linear mapping clips values over 1024
}.play
)

x.release



// Figure 19.23 Examples with greatest common divisor and least common multiple.


// These operations are related:
// gcd(a, b) = a * b / lcm(a, b)

// NOTE: 'gcd'/'lcm' apply 'floor',
// so there might occur differences when applying 'round' to a continuous signal !


// gcd used for synthesis on different counters
// it can perform multichannel expansion which opens nice opportunities

(
x = {
	var t = PulseCount.ar(Impulse.ar(3000)) % 100;
	var u = PulseCount.ar(Impulse.ar(2995)) % 100;
	var sig = gcd(t, u + [30, 25]);
	Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3)
}.play
)

x.release



// triggering can be done with demand rate ugens to get finer control
// iterated gcd on 3 counters

(
x = {
	var a = TDuty.ar(Dseq((1..10), inf) + 102 * SampleDur.ir);
	var b = TDuty.ar(Dseq((1..10), inf) + 101 * SampleDur.ir);
	var c = TDuty.ar(Dseq((1..10), inf) + 100 * SampleDur.ir);
	var t = PulseCount.ar(a) % 100;
	var u = PulseCount.ar(b) % 101;
	var v = PulseCount.ar(c) % 102;
	var sig = gcd(gcd(t + [0, 0], u + [0, 10]), v + [0, 20]);

	// or, better, especially with more iterations:
	// var sig = [t + [0, 0], u + [0, 10], v + [0, 20]].reduce(\gcd);
	Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3)
}.play
)

x.release



// Figure 19.24 Basic bit scrambling by passing permutation arrays.


~bus = Bus.audio(s, 2);


(
// start fx before source
// use LPF as scrambling can cause much energy in higher parts of spectrum

y = { |amp = 0.05, cutoff = 10000|

	// more comfortable to write array arg with NamedControl
	var scramble = NamedControl.ar(\scramble, (0..7));
	var sig = In.ar(~bus, 2);
	var bits, mod_bits, sound;

	sig = sig.round;

	// we want the bits in an array
	mod_bits = 8.collect { |i|
		// scramble[i] indicates the bit value at *mapped* position
		// >> here means division by power of 2
		sig & (2 ** scramble[i]) >> scramble[i]
	};

	// "re-synthesis" from bit representation
	sound = mod_bits.sum { |val, i| 2 ** i * val } / 256;

	Limiter.ar(LPF.ar(LeakDC.ar(sound), cutoff), amp)
}.play
)

// start source

x = { Out.ar(~bus, SinOsc.ar([50, 50.1], 0, 0.2, 1) * 128) }.play;

// define permutation of bits

y.set(\scramble, (0..7).swap(0, 3));


// evaluate several times

y.set(\scramble, (0..7).scramble.postln);


// non-permutation is also ok

y.set(\scramble, [1, 0, 3, 3, 4, 6, 1, 4]);

y.release;

x.free;



// Figure 19.25 Dynamic bit mapping.

// index mapping can also be controlled by arbitrary LFOs

(
x = {
	// source with decorrelated amp LFOs in range [0, 256]
	var sig = LFSaw.ar([60, 60.1], 0, LFDNoise3.ar(0.1 ! 2).range(0.2, 0.7), 1) * 128;
	var bits, mod_bits, sound;

	sig = sig.round;

	mod_bits = 8.collect { |i|
		// bit mapping LFOs with different speed
		var mod_bitIndex = SinOsc.ar(0.2 * (i + 1)).range(0, 7);
		sig & (2 ** mod_bitIndex) >> mod_bitIndex
	};

	sound = mod_bits.sum { |val, i| 2 ** i * val } / 256;
	Limiter.ar(LeakDC.ar(sound), 0.1)
}.play
)

x.release






// Figure 19.26 Equivalence of buffer modulation with BufRd and PlayBuf.

// SC standard soundfile #1

(
~path = Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff";
~buf = Buffer.read(s, ~path);
)

// scratching between buffer indices 2000 and 4000

{ BufRd.ar(1, ~buf, SinOsc.ar(3, 0, 1000, 3000)) }.plot(0.1);

// equivalent: PlayBuf, needs slope/rate (deviation of index change)
// rate in seconds, thus divide by sample rate

{ PlayBuf.ar(1, ~buf, Slope.ar(SinOsc.ar(3, 0, 1000)) / SampleRate.ir, 1, 3000, 1) }.plot(0.1)


// vice versa: rate oscillation given

{ PlayBuf.ar(1, ~buf, SinOsc.ar(10, 0, 0.2), 1, 1000, 1) }.plot(0.1)


// equivalent: Integrator sums up all samples, no need to regard sample rate

{ BufRd.ar(1, ~buf, Integrator.ar(SinOsc.ar(10, 0, 0.2)) + 1000) }.plot(0.1);




// Figure 19.27 Global and local movement.


// decorrelated local movement

(
x = {
	var sig = BufRd.ar(1, ~buf,
		phase: (
			LFDNoise3.ar(0.3).range(0.1, 0.9) + // global movement
			SinOsc.ar(100).range(0, [0.003, 0.0032]) // local movement
		) * BufFrames.ir(~buf),
		interpolation: 4
    ) * 0.2;
    LeakDC.ar(sig)
}.play
)

x.release




// Figure 19.28 Variants of global and local movement.

// use Sweep (linear raise) and Fold to generate zig-zag

(
x = {
	var sig = BufRd.ar(1, ~buf,
		phase: (
			// global movement
	 		LFDNoise3.ar(0.3) * [1, 1.01] +
			// local movement
			Fold.ar(Sweep.ar(0, LFDNoise3.ar(1).range(0.5, 1)), hi: 0.12)
		) * BufFrames.ir(~buf),
		interpolation: 4
    ) * 0.2;
    LeakDC.ar(sig)
}.play
)

x.release


// more extreme zig-zag changes by LFDNoise0 (step noise) for arbitrary rates
// frequency of step noise is also changing

(
x = {
	var sig = BufRd.ar(1, ~buf,
		phase: (
			// global movement
	 		LFDNoise3.ar(0.3) * [1, 1.01] +
			// local movement
			Fold.ar(
				Sweep.ar(
					0,
					LFDNoise0.ar(
						LFDNoise3.ar(0.3).exprange(0.3, 35)
					).exprange(0.1, 5)
				),
				hi: 0.02
			)
		) * BufFrames.ir(~buf),
		interpolation: 4
    ) * 0.2;
	LPF.ar(LeakDC.ar(sig), 10000)
}.play
)

x.release



// Figure 19.29 Model of main modulation and disturbance.

(
x = {
	var mainPhase = LFTri.ar(
		LFDNoise0.ar(LFDNoise1.ar(1).range(0.2, 1)).range(0.2, 0.3)
	).range(0, BufFrames.ir(~buf));

	var disturbance = LFPulse.ar(
		LFDNoise1.ar([2, 2.01]).range(3, 12),
		mul: 10000
	).lag(LFDNoise3.ar(1).exprange(0.0001, 0.05));

	var sig = BufRd.ar(1, ~buf, phase: mainPhase + disturbance, interpolation: 4) * 0.5;
	LPF.ar(LeakDC.ar(sig), 12000)
}.play
)

x.release



// Figure 19.30 Modulation with DemandEnvGen.

// with the first parameters for dur and range, this example is close to vinyl scratching
// the commented out preset results in totally different characteristics

(
x = {
	var dur = 0.2, range = 10000;
	// var dur = 0.02, range = 1000;

	// LR decorrelation
	var phases = {
		 DemandEnvGen.ar(
			Dseq([1, 2, 1, Drand([2, 3], 1)] * range, inf),
			dur,
			shape: Drand([1, 2, 3, 4], inf) // sequence of curvatures
		)
	} ! 2;
	BufRd.ar(1, ~buf, phase: phases, interpolation: 4) * 0.5
}.play
)

x.release





// Figure 19.31 Basic changes of writing and reading rates.

// distorting a sine wave

(
~buf = Buffer.alloc(s, 1000, 1);
~bus = Bus.audio(s, 1);
s.scope;
s.freqscope;
)

// start fx

(
x = { |readRate = 1, writeRate = 1|
	var inSig = In.ar(~bus, 1);
	var writeOffset = 500; // offset above blockSize
	var read, write;

	write = BufWr.ar(inSig, ~buf, Phasor.ar(0, writeRate, 0, BufFrames.ir(~buf)) + writeOffset);
	read = BufRd.ar(1, ~buf, Phasor.ar(0, readRate, 0, BufFrames.ir(~buf)));

	Limiter.ar(read, 0.2) ! 2
}.play
)


// start source, no change as rates equal 1

y = { Out.ar(~bus, SinOsc.ar(200, 0, 0.1)) }.play


// distortion with different rates

x.set(\readRate, 1.2)

x.set(\writeRate, 0.93)

x.set(\readRate, 0.75)

x.set(\writeRate, 2.17)

x.set(\readRate, 0.49)


s.freeAll


// control of write and read rates with MouseX and MouseY
// clear buffer from old data first

~buf.zero


// start fx

(
x = {
	var inSig = In.ar(~bus, 1);
	var read, write;

	write = BufWr.ar(inSig, ~buf, Phasor.ar(0, MouseX.kr(0.2, 2), 0, BufFrames.ir(~buf)));
	// stereo by slightly different reading rates
	read = BufRd.ar(1, ~buf, Phasor.ar(0, MouseY.kr(0.2, 2) * [1, 1.01], 0, BufFrames.ir(~buf)));

	Limiter.ar(read, 0.2)
}.play
)

// start source

y = { Out.ar(~bus, SinOsc.ar(50, 0, 0.1)) }.play

y.free


// source with moving frequency

y = { Out.ar(~bus, SinOsc.ar(LFDNoise1.ar(3).exprange(50, 100), 0, 0.1)) }.play



// cleanup

s.freeAll

(
~buf.free;
~bus.free;
)



// Figure 19.32 Rewriting with variable buffer length and GUI control.


(
~buf = Buffer.alloc(s, 5000);
~bus = Bus.audio(s, 1);
)

// the length argument determines the relative length of used buffer section

(
SynthDef(\rewrite_var_length, { |out, readRate = 1, writeRate = 1,
	length = 1, cutoff = 5000, amp = 0.5|
	var inSig = In.ar(~bus, 1);
	var read, write;
	write = BufWr.ar(inSig, ~buf, Phasor.ar(0, writeRate, 0, BufFrames.ir(~buf) * length));
	read = BufRd.ar(1, ~buf, Phasor.ar(0, readRate * [1, 1.01], 0, BufFrames.ir(~buf) * length));
	Out.ar(out, Limiter.ar(LPF.ar(read, cutoff), amp))
}, metadata: (
	specs: (
		readRate: [0.2, 2, \lin, 0, 1],
		writeRate: [0.2, 2, \lin, 0, 1],
		length: [0.1, 1, 5, 0, 1],
		cutoff: [50, 16000, \exp, 0, 5000],
		amp: [0, 0.5, \db, 0, 0.5]
	)
)
).add
)

// start fx with GUI before source
// distortion with read/write rate values unequal to 1

SynthDescLib.global[\rewrite_var_length].makeGui

y = { Out.ar(~bus, Saw.ar(50, 0.1)) }.play

y.free


// different source

y = { Out.ar(~bus, SinOsc.ar(50, 0, 0.1)) }.play

s.freeAll

(
~buf.free;
~bus.free;
)




// Figure 19.33 Buffer modulation and rewriting combined.

// reading and writing with UGens other than Phasor

(
~buf = Buffer.alloc(s, 1000);
~bus = Bus.audio(s, 1);
)


// control of write and read ugen frequencies with MouseX and MouseY
// start fx

(
x = {
	var inSig = In.ar(~bus, 1);
	var read, write;

	write = BufWr.ar(inSig, ~buf, SinOsc.ar(MouseX.kr(3, 20), 0, BufFrames.ir(~buf)));
	read = BufRd.ar(1, ~buf, SinOsc.ar(MouseY.kr(3, 20) * [1, 1.01]).range(0, BufFrames.ir(~buf)));

	Limiter.ar(LPF.ar(read, 5000), 0.2)
}.play
)


y = { Out.ar(~bus, SinOsc.ar(100, 0, 0.1)) }.play

s.freeAll

(
~buf.free;
~bus.free;
)




// Figure 19.34 Buffer rewriting with feedback.

// Feedback of reading into writing


(
~buf = Buffer.alloc(s, 5000);
~bus = Bus.audio(s, 1);
)


// control of read rate with MouseX
// start fx silently

(
x = {
	var inSig = In.ar(~bus, 1);
	var sig, read, write;

	// this setup works nice with fixed feedback amplitude of 0.99 ...
	sig = (LocalIn.ar(1) * 0.99) + inSig;

	// ... and with write rate around 1
	write = BufWr.ar(sig, ~buf, Phasor.ar(0, MouseX.kr(0.99, 1.01), 0, BufFrames.ir(~buf)));
	read = BufRd.ar(1, ~buf, Phasor.ar(0, [1, 1.001], 0, BufFrames.ir(~buf)));
	LocalOut.ar(read[0]);
	// LocalOut.ar(read[0].tanh);  // check this

	Limiter.ar(LPF.ar(read, 5000), 0.2)
}.play
)

// start source

y = { Out.ar(~bus, SinOsc.ar(MouseY.kr(50, 500), 0, 0.1)) }.play

// feedback continues for a long time after freeing the source

y.free

x.free;

(
~buf.free;
~bus.free;
)



// Figure 19.35 Buffer rewriting with overdubbing.

// overdub, GUI control
// instead of plain rewriting, a mix of the current buffer content and the in signal is written

(
~buf = Buffer.alloc(s, 5000);
~bus = Bus.audio(s, 1);
)


(
SynthDef(\rewrite_overdub, { |out, readRate = 0.8, writeRate = 1.4, odubMix = 0.85, odubMode = 0,
	length = 0.2, cutoff = 5000, amp = 1|
	var inSig = In.ar(~bus, 1);
	var read_1, read_2, write, writePhase, odub;

	writePhase = Phasor.ar(0, writeRate, 0, BufFrames.ir(~buf) * length);

	// need to read the current buffer content before mixing:
	// strict overdubbing would have to take the floor of the phase as BufWr doesn't round
	// make a distinction between floor and non-floor by argument odubMode

	read_1 = BufRd.ar(1, ~buf, [writePhase, writePhase.floor]);
	read_1 = Select.ar(odubMode, read_1);
	odub = inSig * (1 - odubMix) + (read_1 * odubMix);

	write = BufWr.ar(odub, ~buf, writePhase);
	read_2 = BufRd.ar(1, ~buf, Phasor.ar(0, readRate * [1, 1.01], 0, BufFrames.ir(~buf) * length));

	Out.ar(out, Limiter.ar(LPF.ar(read_2, cutoff), amp))
}, metadata: (
	specs: (
		readRate: [0.2, 2, \lin, 0, 0.8],
		writeRate: [0.2, 2, \lin, 0, 1.4],
		odubMix: [0, 1, \lin, 0, 0.85],
		odubMode: [0, 1, \lin, 1, 0],
		length: [0.01, 1, 5, 0, 0.2],
		cutoff: [50, 16000, \exp, 0, 5000],
		amp: [0, 0.5, \db, 0, 0.5]
	)
)
).add
)

// start fx with GUI before source

SynthDescLib.global[\rewrite_overdub].makeGui


// nice resonance and echo effects can occur with decaying impulses

y = { Out.ar(~bus, Decay.ar(Impulse.ar(2), 0.1)) }.play

s.freeAll

(
~buf.free;
~bus.free;
)



// check examples with different blockSizes

(
s.options.blockSize = 1;
s.reboot;
)