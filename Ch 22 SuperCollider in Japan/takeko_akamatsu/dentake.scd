
(
// First you need to send SynthDefs below.
// This is a very simple example with TouchOSC
// using template "Simple"

~kamp = 1; ~samp = 1; ~camp = 1; ~mamp = 1; ~bamp = 1;

~kick = Pbind(
	\tempo,2.15,
	\dur, Pseq([1.01,0.99],inf),
	\amp, 0.15 * Pfunc({~kamp}),
	\instrument,\drum_kick
).play;

~snare = Pbind(
	\tempo,2.15,
	\dur, Pseq([Pseq([1],7),Pseq([0.77,0.23],1)],inf),
	\amp,Pseq([0, 0.25,0,0.15,0, 0.25,0,0.2,0.12] * 0.8,inf) * Pfunc({~samp}),
	\releasetime, Pshuf([0.1,0.1,0.4],inf),
	\instrument,\SOSsnare
).play;

~chord = Pbind(
	\dur, Pseq([Pseq([1.52,1.48,1]/2,3),Pseq([1.02,0.98,2]/2,1)],inf),
	\amp, 0.2* Pfunc({~camp}),
	\reverb, 0.2,
	\releaseTime, Pseq([0.4,0.15,0.17] * 0.8,inf),
	\midinote, Pseq([[63,65,68,70]] , inf) - Pseq([Pseq([0,0,12],3), Pseq([0,12,0],1)],inf),
	\instrument,\chord_bass
).play;

~melo = Pbind(
	\dur, Pseq([0.5,0.5,1,1.5,0.5,0.5,0.5,1,1.5,0.5,
	0.5,0.5,1,1.5,0.5,0.5,0.5,1,0.5,1,0.5],inf),
	\amp, 0.1 * Pfunc({~mamp}),
	\filtfreq1, Prand([10000,18000,7000,12000],inf),
	\filtfreq2, Prand([1000, 500],inf),
	\midinote, Pseq([ Prand([68, 70, 77, 77, 75, 68,70,75,75,74],1),
		Prand([68, 70, 77, 77, 75, 68,70,75,75,74,72],1)], inf),
	\instrument,\melody
).play;

~bass = Pbind(
	\dur, Pseq([0.5,0.5,0.5,0.5,0.5,0.5,5],inf),
	\amp, Pseq([0,1,1,1,1,1,1],inf) * 0.2 * Pfunc({~bamp}),
	\filtfreq1, Prand([5000,8000,4000,6000],inf),
	\filtfreq2, Prand([100, 500],inf),
	\releaseTime, Pseq([0.05],inf),
	\midinote, Prand([68,68,77,68,77,68,68]-24, inf),
	\instrument,\bass
).play;
)


/////// OSCresponder --------------------------------------------------

(
OSCdef(
    \toggle1,
	{arg msg, time, addr, port;

		case
		{msg.at(1) == 0}{~kamp = 0;} {msg.at(1) == 1}{~kamp = 1;};
     },
    '/1/toggle1',n,8000
);


OSCdef(
    \toggle2,
	{arg msg, time, addr, port;

		case
		{msg.at(1) == 0}{~bamp = 0;} {msg.at(1) == 1}{~bamp = 1;};
     },
    '/1/toggle2',n,8000
);

OSCdef(
    \toggle3,
	{arg msg, time, addr, port;

		case
		{msg.at(1) == 0}{~mamp = 0;} {msg.at(1) == 1}{~mamp = 1;};
     },
    '/1/toggle3',n,8000
);

OSCdef(
    \toggle4,
	{arg msg, time, addr, port;

		case
		{msg.at(1) == 0}{~camp = 0;} {msg.at(1) == 1}{~camp = 1;};
     },
    '/1/toggle4',n,8000
);

)


/////// SynthDefs --------------------------------------------------

(

SynthDef(\chord_bass,{
	arg amp=0.1, sustain=0.1, freq=400, filtfreq1 = 7000, filtfreq2=1000, releaseTime = 0.11, reverb = 0.1,rq=0.99;
	var env, sound;
	env=EnvGen.ar(Env.perc(releaseTime:releaseTime),doneAction:2);
	sound=FreeVerb.ar(RLPF.ar(LFSaw.ar(freq,0,amp),Line.kr(filtfreq1, filtfreq2,0.1),rq) ,reverb, 0.2,0.5);
	Out.ar(0,Pan2.ar(sound*env, 0.0))
}).store;


SynthDef(\melody,{
	arg amp=0.1, sustain=0.1, freq=400, filtfreq1 = 2000, filtfreq2=1000, releaseTime = 0.11,reverb=0.3;
	var env, sound;
	env=EnvGen.ar(Env([0,1,1,0],[0.01,releaseTime,0.05]),doneAction:2);
	sound=LPF.ar(Pulse.ar([freq,freq*0.5001],0.5,amp),Line.kr(filtfreq1, filtfreq2, 0.2)) ;
	Out.ar(0,Pan2.ar(sound*env, 0.0))
}).store;


SynthDef(\bass,{
	arg amp=0.1, sustain=0.1, freq=400, filtfreq1 = 2000, filtfreq2=1000, releaseTime = 0.11,reverb=0.1;
	var env, sound;
	env=EnvGen.ar(Env([0,1,1,0],[0.01,releaseTime,0.03]),doneAction:2);
	sound=LPF.ar(Pulse.ar(freq,0.4,amp) + SinOsc.ar(freq,0.5,0.05),Line.kr(filtfreq1, filtfreq2, 0.3)) ;
	Out.ar(0,Pan2.ar(sound*env, 0.0))
}).store;


// chineseroom's drum_kick
SynthDef("drum_kick", {
	arg freq=440, gate=1, amp=0.5, source, pan = 0.0 ;
	source =
	Pan2.ar(
	SinOsc.ar(EnvGen.kr(Env.perc(0.0001, 1.5, 1, -200), gate, 1000, 45, doneAction:2), 1, 1) +
	((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)],EnvGen.kr(Env.perc(0.001, 0.3, 1, -200), gate, 6000, 70), 1.5)).distort * Line.kr(0.3,0,0.1))
	*
	EnvGen.kr(Env.perc(0.0001, 0.09, amp, 8)),0);
	Out.ar(0, source);
}).store;


SynthDef(\SOSsnare,
// recipe basically from Gordon Reid
// http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp
// programmed by Renick Bell, renick_at_gmail.com
	{arg out = 0, decay = 0.12, drum_mode_level = 0.25,
	snare_level = 40, snare_tightness = 2000,
	freq = 405, amp = 0.8;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix,
drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4,
snare_reson;
	var snare_env;
	var snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, decay), 1.0, doneAction: 2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
					184,
					0.5/1.3,
					mul: drum_mode_env*5,
					add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2,
drum_mode_pmosc]) * drum_mode_level;

// choose either noise source below
//	snare_noise = Crackle.ar(2.01, 1);
	snare_noise = LFNoise0.ar(20000, 0.1);
	snare_env = EnvGen.ar(Env.perc(0.005, decay, curve:-5), 1.0, doneAction: 2);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
	}
).store;

)