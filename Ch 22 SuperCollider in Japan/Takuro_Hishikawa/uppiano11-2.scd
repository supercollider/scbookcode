
// I love delicate, shimmered sound.
// It is possible to try and err freely and minutely by using SC.

(
SynthDef("up-piano-11-2", {
	arg freq=440, gate=1, amp=1, pan=0, outBus=0;
	var x, lfo, mod1, mod2, mod3, env, burstEnv, burst, atk;
	env = Env.adsr(0.01,0.2,0.5,1,1,-4);
	lfo = LFNoise2.kr(30, amp * freq, amp * freq);
	mod1 = SinOsc.ar( freq * 3.01, 0, freq);
	mod2 = SinOsc.ar( freq * 4, 0, lfo);
	mod3 = SinOsc.ar( freq * 2 + mod1, 0, 200);
	burstEnv = Env.perc(0, 0.01);
	burst = WhiteNoise.ar * EnvGen.kr(burstEnv);
	atk = RLPF.ar(
		CombC.ar(burst, freq.reciprocal, freq.reciprocal, -1, 1),
		6800, 3, amp
	);
	x = SinOsc.ar(freq + mod2 + mod3, 0, amp, atk).softclip;
	x = EnvGen.kr(env,gate,doneAction: 2) * x;
	Out.ar(outBus, Pan2.ar(x,pan));
}).send(s);
)

a=Synth("up-piano-11-2");
a.set(\gate,0.0);

// sound designed by umbrella_process