a = CSVFileReader.read("/Users/shellyknotts/sc_ml_chapter/midicsv/girls_melody.sc").flatten.asInteger;
b = CSVFileReader.read("/Users/shellyknotts/sc_ml_chapter/midicsv/girls_rhythm.sc").flatten.asInteger;

~mel = PPMC(3);
~mel.train(a)
~rhy = PPMC(3);
~rhy.train(b)

SynthDef(\a, { |freq = 60, amp = 1, fb=1|
	var snd, env;

	snd = Decay2.ar(SinOscFB.ar(freq.midicps * [1, 1.01], fb, 3).tanh,0.005, 0.004).tanh;
	snd = FreeVerb.ar(snd);
	env = EnvGen.kr(Env.perc, doneAction: Done.freeSelf);

	Out.ar(0, snd * env * amp);
}).add;


(
var lastvals = [[a[0]],[b[0]]];

Tdef(\gen, {

	loop {
		var nextmel = ~mel.generate(lastvals[0].reverse);
		var nextrhy = ~rhy.generate(lastvals[1].reverse);

		Synth(\a, [\freq, nextmel] );
		(nextrhy*0.25).wait;

		lastvals[0] = lastvals[0].addFirst(nextmel);
		lastvals[1] = lastvals[1].addFirst(nextrhy);

		if(lastvals[0].size>4, {lastvals[0].pop; lastvals[1].pop; });
	}
} ).play;
)