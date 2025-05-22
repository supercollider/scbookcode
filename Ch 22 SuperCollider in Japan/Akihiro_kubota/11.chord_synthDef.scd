
(
Server.default = Server.internal;
Server.default.options.numWireBufs = 128;
s = Server.default;
if(not(s.serverRunning), {s.boot});
p = ProxySpace.push(s);
p.fadeTime = 3;
p.clock = TempoClock.default;
p.clock.tempo = 1.0;
)

(
~out.ar(2);
~out.play;
~out.vol = 1.0;
)



(
SynthDef(\points, {arg amp=0.5, freq=1, pan=0, sustain=10;
	var env;
	env = Env.linen(0, sustain, 0, amp, 0);
	Out.ar(0,
		Pan2.ar(
		Impulse.ar(freq) * EnvGen.ar(env, doneAction:2),
		pan))
	}).store;

SynthDef(\line, {arg amp=0.5, freq=441, pan=0, sustain=10;
	var env;
	env = Env.linen(0, sustain, 0, amp, 0);
	Out.ar(0,
		Pan2.ar(
		SinOsc.ar(freq) * EnvGen.ar(env, doneAction:2),
		pan))
	}).store;

SynthDef(\plane, {arg amp=0.5, pan=0, sustain=10;
	var env;
	env = Env.linen(0, sustain, 0, amp, 0);
	Out.ar(0,
		Pan2.ar(
		WhiteNoise.ar * EnvGen.ar(env, doneAction:2),
		pan))
	}).store;

SynthDef(\points2, {arg amp1=0.2, amp2=0.7, freq1=2, freq2=0.5, pan1= -1, pan2=1, sustain=10;
	var env;
	env = Env.new([amp1, amp2], [sustain]);
	Out.ar(0,
		Pan2.ar(
		Impulse.ar(Line.kr(freq1, freq2, sustain)) * EnvGen.ar(env, doneAction:2),
		Line.kr(pan1, pan2, sustain)))
	}).store;

SynthDef(\line2, {arg amp1=0.7, amp2=0.2, freq1=4410, freq2=441, pan1= -1, pan2=1, sustain=10;
	var env;
	env = Env.new([amp1, amp2], [sustain]);
	Out.ar(0,
		Pan2.ar(
		SinOsc.ar(Line.kr(freq1, freq2, sustain)) * EnvGen.ar(env, doneAction:2),
		Line.kr(pan1, pan2, sustain)))
	}).store;

SynthDef(\plane2, {arg amp1=0.7, amp2=0.2, pan1= -1, pan2=1, sustain=10;
	var env;
	env = Env.new([amp1, amp2], [sustain]);
	Out.ar(0,
		Pan2.ar(
		WhiteNoise.ar * EnvGen.ar(env, doneAction:2),
		Line.kr(pan1, pan2, sustain)))
	}).store;
)
