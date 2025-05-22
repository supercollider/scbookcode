
// "Rainy Route 79" ver.1.1.2
// by Takuro Hishikawa a.k.a. umbrella_process

// SynthDefs
(
//// melody
SynthDef("rr79_m", {
	arg note, pan, amp, outBus=0;
	var scale, buffer, freq, signal, env;
	env = Env.adsr(0.01,0.1,0.5,0.1,-4);
	scale=FloatArray[0,2,3,5,7,8,10];
	buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });
	freq = DegreeToKey.kr(
				buffer.bufnum,
				note,		// input
				12,			// 12 notes per octave
				1,			// mul = 1
				37			// offset by 53 notes
			).midicps;
	signal = SinOsc.ar(freq, 0, amp * 0.22);
	Out.ar(outBus,Pan2.ar(EnvGen.ar(env) * signal.abs.trunc(0.008) * (signal.sign), pan));
}).load(s);

//// kick
SynthDef("rr79_kick",{
	arg amp, dur, pan=0, outBus=0;
	var env1, env2, mod, signal;
	env1 = Env.new([0.001,1,0.7,0.6,0], [0.001,0.003,0.03,0.1], -3);
	env2 = Env.perc(0.001, 0.01, 1, -3);
	mod = EnvGen.ar(env2)*300;
	signal = SinOsc.ar(mod+37.midicps, 0, amp);
	Out.ar(outBus,Pan2.ar(EnvGen.ar(env1, doneAction: 2)*signal, pan));
}).load(s);

//// snare
SynthDef("rr79_snare",{
	arg amp, dur, pan=0, outBus=0;
	var env1, env2, x;
	env1 = Env.perc(0.01, 0.2, 1, -3);
	env2 = Env.perc(0, 0.01, 1, -3);
	x = RHPF.ar(
		EnvGen.ar(env2) * SinOsc.ar(250,0,amp)
		+
		WhiteNoise.ar(amp * 0.10),
		150, 0.5
	);
	Out.ar(outBus,
		Pan2.ar(
			EnvGen.ar(env1,doneAction: 2) *
			x.abs.trunc(0.01) * (x.sign),
		pan
		)
	);
}).load(s);

//// hihat
SynthDef("rr79_hh",{
	arg amp, dur, pan, outBus=0;
	var env1, env2;
	env1 = Env.perc(0, 0.1, 1, -6);
	Out.ar(outBus,
		Pan2.ar(
			EnvGen.ar(env1,doneAction: 2)*RHPF.ar(
				LFClipNoise.ar(3000,amp * 0.1),
			3000, 0.8),
			pan
		)
	);
}).load(s);

//// sine pad
SynthDef("rr79_pad",{
	arg note, pan, amp, bpm=108;
	var env,scale,buffer,freq,outBus=0;
	env = Env.perc(bpm/60 - 0.3, 2, 0.25, 3);
	scale=FloatArray[0,2,3,5,7,8,10];
	buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });
	freq = DegreeToKey.kr(
				buffer.bufnum,
				note,		// input
				12,			// 12 notes per octave
				1,			// mul = 1
				61			// offset by 53 notes
			).midicps;
	Out.ar(outBus,
		Pan2.ar(
			EnvGen.ar(env,doneAction: 2)
			* SinOsc.ar(freq, 0, amp)
			* Lag.ar(LFPulse.ar(bpm/15, 0, 0.5, 1),0.02)
		,pan)
	);
}).load(s);

//// drone
SynthDef("rr79_d",{
	arg freq,outBus=0;
	Out.ar([outBus,outBus+1],
		LPF.ar(
			Saw.ar([freq,freq-0.1]) * LFNoise2.ar(0.1,0.02,0.07),
			LFNoise2.kr(0.1,300)+500
		)
	)
}).load(s);
)

// Then do this
(
var bpm,n;
var melody,kick,snare,hihat,pad,drone;

~source = Group.head(s);

bpm=108;
n=7;

m=Synth.tail(~source, "rr79_m", [\amp,0]);
drone=Synth.tail(~source, "rr79_d",[\freq,25.midicps]);

// melody
melody=Task({
	var degreepat,durpat,amppat;
	degreepat = Pseq([
		Pfunc({
			n = n + 3.rand2;
			if (n < 6, { n = 7 });
			if (n > 16, { n = 15 });
			n;
		}) + Pwrand([0,-7], [0.8, 0.2], {exprand(4,40)}),
		Pseq([0,5,6,5,3,7],1)
	], inf).asStream;
	durpat = Pseq([1.2,0.8], inf).asStream;
	amppat = Pseq([
		Pseq([
			Pseq([1,0,0,0.8], 2),
			Pseq([1,0,0.7,0], 2),
			Pseq([0.9,0.9,0.9,0.9], 3),
			Pseq([1,0,0.5,0.7], 1)
		],8),
		Pseq([
			Pseq([1.5,0,0,0], 1),
			Pseq([0,0,0,0], 13),
			Pseq([0,0,1,0.5], 1)
		],1)
	],inf).asStream;

	loop({
		m.set(\note, degreepat.next);
		m.set(\amp, 0.2*amppat.next);
		m.set(\pan, 1.0.bilinrand);
		(durpat.next).wait;
	});
},TempoClock(bpm/15));

// kick
kick=Task({
	var durpat,amppat;
	durpat = Pseq([1.2,0.8], inf).asStream;
	amppat = Pseq([
		Pseq([1,0,0.4,0.4, 0,0,0,0, 0], 1),
		Pwrand([0.3,0], [0.3,0.7], 3),
		Prand([
			Pwrand([0.8,0.5,0], [0.3,0.4,0.3], 4),
			Pwrand([0.6,0], [0.3,0.7], 4)
		], 1)
	], inf).asStream;
	loop({
		Synth.tail(~source, "rr79_kick", [
			\amp, amppat.next
		]);
		(durpat.next).wait;
	});
},TempoClock(bpm/15));

// snare
snare=Task({
	var durpat,amppat;
	durpat = Pseq([1.2,0.8], inf).asStream;
	amppat = Pseq([
		Pseq([0],1),
		Pwrand([
			Pwrand([0.6,0], [0.2, 0.8], 3),
			Pseq([0], 3)
		], [0.8,0.2], 1),
		Pwrand([1,0], [0.92, 0.08], 1),
		Pwrand([
			Pwrand([0.6,0.2,0], [0.4, 0.4, 0.2], 3),
			Pwrand([0.6,0], [0.2, 0.8], 3),
			Pseq([0], 3)
		], [0.2,0.7,0.1], 1)
	], inf).asStream;
	loop({
		Synth.tail(~source, "rr79_snare", [
			\amp, amppat.next
		]);
		(durpat.next).wait;
	});
},TempoClock(bpm/15));

// hihat
hihat=Task({
	var durpat,amppat,panpat;
	durpat = Pseq([1.2,0.8], inf).asStream;
	amppat = Pseq([
		Pseq([0,0,1,0], 2),
		Pseq([0,0,1,0.8],1),
		Pseq([0,0,1,0], 5)
	], inf).asStream;
	panpat = Pseq([Pseq([0.8],4), Pseq([-0.8],4)],inf).asStream;
	loop({
		Synth.tail(~source, "rr79_hh", [
			\amp, amppat.next,
			\pan, panpat.next
		]);
		(durpat.next).wait;
	});
},TempoClock(bpm/15));

// sine pad
pad=Task({
	var i=3;
	loop({
		i.postln;
		16.do({
			i.do({
				Synth.tail(~source, "rr79_pad", [
					\note, 13.rand2 + 5,
					\amp, 0.15,
					\pan, 1.0.rand2
				]);
			});
			1.wait;
		});
		i=i+3;
	});
},TempoClock(bpm/240));

SystemClock.sched((10*240)/bpm,{melody.start});
SystemClock.sched(0,{kick.start});
SystemClock.sched((4*240)/bpm,{snare.start});
SystemClock.sched(0,{hihat.start});
SystemClock.sched((4*240)/bpm,{pad.start});
)

// licensed under a Creative Commons Attribution
// http://creativecommons.org/licenses/by-nc/2.1/jp/