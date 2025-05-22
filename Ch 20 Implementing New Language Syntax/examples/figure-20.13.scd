(
SynthDef(\sn, { |out, ffreq = 172, rq = 0.15, amp = 0.1|
	var feg = EnvGen.kr(Env([4, 1], [0.32], \exp));
	var eg = EnvGen.kr(Env.perc(0.01, 0.9), doneAction: 2);
	var src = Array.fill(2, { PinkNoise.ar });
	var sig = BPF.ar(src, (ffreq * feg).clip(20, 20000), rq) * (eg * amp / rq);
	Out.ar(out, sig);
}).add;

SynthDef(\k, { |out, basefreq = 55, bendAmt = 4, bendTime = 0.07, decay = 0.3, amp = 0.1|
	var feg = EnvGen.kr(Env([bendAmt, 1], [bendTime], \exp));
	var eg = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
	var osc = (SinOsc.ar(basefreq * feg) * 3).tanh;
	Out.ar(out, (osc * eg * amp).dup);
}).add;

f = Pbind(\instrument, Pkey(\id));
)

TempoClock.tempo = 136/60;

Pdef(\d).quant = -1; Pdef(\dplay).quant = -1;

Pdef(\d, Pn(~4[k sn [. k] sn], inf));

// to simplify live coding, we factor the id-translation
// into a separate Pdef
Pdef(\dplay, Pchain(f, Pdef(\d))).play;

Pdef(\d, Pn(~4[k [sn . . sn] [. k] sn], inf));

Pdef(\d, Pn(~4[k [sn . . sn] [. sn k .] sn], inf));

Pdef(\dplay).stop;
