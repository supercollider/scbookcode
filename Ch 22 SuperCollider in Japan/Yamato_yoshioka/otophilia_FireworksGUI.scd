( // Fireworks by_otophilia

~frameRate = 30;

s = Server.default;
s.latency = 0.5;


// @@@@ GUIs @@@@
(

~window = Window("Fireworks", Rect(128, 128, 582, 360), false, true).front;
~window.view.background_(Color.black);
~window.onClose_{
	SystemClock.clear;
	~guiClock.clear;
};

~window.drawHook_{
	~particles.do{|pr|
		Pen.color = pr[2].alpha_(pr[3].min(1.0));
		Pen.line(pr[0], pr[0] + (pr[1]/~frameRate));
		Pen.stroke;
	};
};

~particles = List[];

~grav = 4;
~res = 0.5;

~guiClock =  AppClock.sched(0.0, {
	~window.refresh;

	~particles.do{|pr|
		pr[1] = pr[1] * (~res ** ~frameRate.reciprocal);
		pr[1].y = pr[1].y + ~grav;
		pr[0] = pr[0] + (pr[1]/~frameRate);
		pr[3] = pr[3] - ~frameRate.reciprocal;
	};

	~particles.removeAllSuchThat({|pr|
		pr[3] <= 0;
	});

	~frameRate.reciprocal;
});

~newWorks = {|size, pan|
	var x, y, pw, col, colP;

	x = pan*0.5+0.5 * ~window.view.bounds.width;
	y = 1-(size)+rand2(0.2) * ~window.view.bounds.height;
	pw = [40, 200].blendAt(size);
	col = [rand(1.0), rand(1.0), 1];

	[12, 48].blendAt(size).floor.do{
	colP = col;
	colP[0] = colP[0] + rand2(0.01) % 1.0;
	colP = Color.hsv(colP[0],colP[1],colP[2]);

	~particles.add(
		[x@y, rand2(pw)@rand2(pw), colP, size + 0.5 * rrand(0.6, 1.3)]
	);
	}
};

);
// @@@@ End GUIs @@@@



Routine.run {var c;

c = Condition.new;
s.bootSync(c);



( // @@@@ SynthDef @@@@

SynthDef(\fireworksBom,{|pan, n1HPF = 40, n4BPF = 1, susti = 0.4, amp = 1|
var out, env1, noise1, reson, noise2, noise3, noise4, rev;

noise1 = LFPar.ar(
	EnvGen.kr(Env.new([120, 30], [0.2], [-16])),
	0,
	EnvGen.kr(Env.new([1, 1, 0], [0.02, 0.03], [0, -4]))
	);
noise1 = HPF.ar(BPF.ar(noise1, ExpRand(40, 60), 0.3, 5, noise1), n1HPF);

noise2 = GrayNoise.ar * EnvGen.kr(Env.new([0, 1, 0], [0.001, 0.4], [20, -10])) + noise1;
reson = AllpassN.ar(noise2, 0.001, ExpRand(300, 500).reciprocal, 0.02) + noise2 * 0.4;

noise3 = LFNoise0.ar( ExpRand(700, 900), Decay.kr(Dust2.kr(130, 1), 0.004) );
noise3 = (BPF.ar(noise3, ExpRand(2200, 3300), 1, 16)).clip2 * 0.3;

noise4 = LFNoise0.ar( ExpRand(150, 230), Decay.kr(Dust2.kr(300, 1), 0.004) );
noise4 = (BPF.ar(noise4, ExpRand(100, 130) * n4BPF, 1, 16)).clip2 * 0.5;

out = noise1 + reson + noise3 + noise4;
out = AllpassN.ar(out, 0.1, ExpRand(0.01, 0.02), 0, 0.1, out);
out = HPF.ar(out, 40, EnvGen.kr(Env.new([12, susti, 0], [0.02, 1.5], [-4, -7]), doneAction:2)).clip2;

out = Splay.ar(out, Rand(0.8, 1.0), amp, pan);

Out.ar(0, out);
}).send(s);


SynthDef(\fireworksWhi,{| pitchHi, pitchLo, atk, hld, dcy, pan |
var out, freq, noise, tone;

freq = EnvGen.kr(Env.new([pitchHi, pitchLo], [10], [-4])) + LFNoise2.kr(ExpRand(110,140), 1);
freq = freq + LFPar.kr( LFNoise2.kr(6, 4, 0).midicps, 0, LFNoise2.kr(3, 0.8, 0.8));
freq = freq.midicps;

noise = WhiteNoise.ar(2);

tone = Line.kr(0.0, 0.2, 5);
noise = BPF.ar(noise, freq, 0.002) + BPF.ar(noise, freq*2, 0.01, tone) + BPF.ar(noise, freq*3, 0.01, tone);
out = noise * EnvGen.kr(Env.new([0, 1, 1, 0], [atk, hld, dcy], [0, 0, 2]), doneAction:2);
out = Pan2.ar(out * ExpRand(0.2, 0.4), pan);
Out.ar(0, out);
}).send(s);


SynthDef(\fireworksParticle,{| pan = 0, atk = 0.3, dcy = 1.0, densLo = 10, densHi = 40|
var out, dust, noise1, noise2, noise3;

dust = Dust2.kr(
	EnvGen.kr(Env.new([densLo, densHi, densLo], [atk, dcy], [-3, -8]), doneAction:2).midicps,
	EnvGen.kr(Env.new([0, 1, 0], [atk, dcy], [-3, -6]));
	);

noise1 = LFNoise0.ar( ExpRand(700, 900), Decay.kr(dust, 0.004));
noise1 = (BPF.ar(noise1, ExpRand(2000, 4300), 1, 8)).clip2;
noise1 = AllpassN.ar(noise1, 0.001, ExpRand(300, 600).reciprocal, 0.008, 0.1, noise1);

noise2 = GrayNoise.ar(Decay.kr(dust, 0.009));
noise2 = (BPF.ar(noise2, ExpRand(9000, 18000), 0.8, 8)).clip2 * 0.5;

noise3 = GrayNoise.ar(Decay.kr(dust, 0.01));
noise3 = (BPF.ar(noise2, ExpRand(300, 500), 0.8, 8)).clip2 * 0.2;

out = noise1 + noise2 + noise3;
out = AllpassN.ar(out, 0.1, ExpRand(0.01, 0.02), 0, 0.1, out);
out = HPF.ar(out, 200).clip2;

out = Splay.ar(out, Rand(0.8, 1.0), 1, pan);
out = Pan2.ar(out * ExpRand(0.01, 0.1), pan);

Out.ar(0, out);
}).send(s);

); s.sync(c);

// @@@@ End SynthDef @@@@



// @@@@ Functions @@@@
(

~shot = {|size, pan|
	size ?? {size = rrand(0.0, 1.0).squared};
	pan ?? {pan = rand2(1.0)};

	s.makeBundle(s.latency, {
		Synth(\fireworksBom,
			[\n1HPF, ( [30.cpsmidi, 300.cpsmidi].blendAt((1-size).squared) + rand2(2) ).midicps,
			\n4BPF, (8 ** ((1-size).squared)) + rand2(0.4), \susti, [0.5, 0.2].blendAt((1-size).squared),
			\amp, size * 0.5 + 0.5, \pan, pan*0.4],
			~bomGroup, \addToTail);
	});

	if(0.3.coin, {
		SystemClock.sched(exprand(0.1, 1.5), { ~particle.value(pan) });
	});

	{~newWorks.value(size, pan);}.defer(s.latency);
};


~shotWhi = {|size|
	var atk, hld, dcy, pan, pitchHi, pitchDown;

	size ?? {size = rrand(0.0, 1.0).squared};
	pan ?? {pan = rand2(0.5)};

	pitchHi = size * 5 + rand2(2) + 104;
	pitchDown = size * 3 + rand2(2) + 14;

	atk = size * 0.3 + rand2(0.1) + 0.5;
	hld = size * 1.8 + rand2(0.1) + 0.5;
	dcy = size * 0.3 + rand2(0.1) + 1.0;

	s.makeBundle(s.latency, {
		Synth(\fireworksWhi,
			[\pitchHi, pitchHi, \pitchLo, pitchHi - pitchDown,
			\atk, atk, \hld, hld, \dcy, dcy, \pan, pan*0.4],
			~bomGroup, \addToTail);
	});

	SystemClock.sched(atk+hld+dcy, { ~shot.value(size) });
};


~particle = {|pan|
	pan ?? {pan = rand2(0.8)};

	s.makeBundle(s.latency, {
		Synth(\fireworksParticle, [\atk, exprand(0.3,0.8), \dcy, exprand(3.0,8.0),
			\densLo, exprand(30.0,50.0), \densHi,  exprand(70.0,90.0), \pan, pan*0.4], ~bomGroup, \addToTail);
	});
};



);
// @@@@ End Functions @@@@


( // @@@@ Scheduling @@@@

~loop = true;
~densty = 0.6;

~bomGroup = Group.new;

SystemClock.sched(0, {
	~shot.value;
	if(~loop, {rrand(0.01, 1.5) / ~densty}, {nil});
});

SystemClock.sched(0, {
	~shotWhi.value;
	if(~loop, {rrand(1.0, 4.0) / ~densty}, {nil});
});

SystemClock.sched(0, {
	~densty = exprand(1.0, 5.0);
	if(~loop, {8.0}, {nil});
});

);
// @@@@ End Scheduling @@@@


};
);