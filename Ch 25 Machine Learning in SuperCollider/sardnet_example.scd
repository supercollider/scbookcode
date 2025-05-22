f = SCMIRAudioFile("Beyonce_HoldUp.wav".resolveRelative, [[MFCC, 13], [Chromagram, 12]]); //, Loudness, SensoryDissonance, SpecCentroid, SpecPcile] );
// we're just looking at the pitch trajectory in this example but we could include other features

resolveRelative

{f.extractFeatures();}.fork; //wait for me to finish

(
var hopsize = 1024;
var frames_per_sec = s.sampleRate / hopsize;
var siz = frames_per_sec* f.numfeatures;

~num_samples = f.numframes.div(frames_per_sec) //dividing it by 43 gives us 221 entries - there are approximately 43 frames per second so we end up with 1 vector per second of the track.

~reps = Array.fill(f.numframes.div(frames_per_sec), {|i|

var frameindex = frames_per_sec*i;
var index = f.numfeatures * frameindex;

Array.fill(frames_per_sec,{|j| var base = index + (j*f.numfeatures);  f.featuredata.copyRange(base, base + f.numfeatures-1);   });

}) // the feature data is clumped into sets of 43  frames of feature data values.
)

a=SARDNET(f.numfeatures, 100, 300, 0.5, 0.5);

~reps.do{|array|  a.train(array); }; // we're training the model with arrays.

~results = ~reps.collect{|array|  a.test(array).collect{|val|  val[0]}}; // testing each second of the song against the SARDNET map. each input sample produces a sequence of representatives. .test posts the representative which is closest to the input data.
//each result is a sequence of 43 representatives each representing one value (set) in the input vector: e.g. [ 16, 18, 17, 19, 20, 15, 14, 21, 13, 22, 25, 12, 11, 60, 61, 23, 10, 24, 26, 27, 59, 30, 58, 31, 33, 32, 28, 9, 7, 6, 8, 5, 4, 3, 2, 1, 0, 29, 34, 35, 36, 37, 38 ]

~data = Array.fill(~num_samples,{|i|  Array.fill(~num_samples,{|j|  (~results[i] - ~results[j]).abs.sum  }); }) // calculate the manhatten distances between results for each input sample

~data_ordered = ~data.collect{|item|
	var sorted = item.deepCopy.sort;
	sorted.collect{|itm| item.indexOfEqual(itm); };
} // reorder the data to give the order fo similarity from each point in the soundfile.


b = Buffer.read(s, "Beyonce_HoldUp.wav".resolveRelative);

SynthDef(\bufl, {| out = 0, bufnum = 0, sustain = 1, start = 0, amp = 1|
	var env, buf, snd;
	env = EnvGen.kr(Env.linen(0.01, sustain, 0.01), doneAction:2);
	buf =  PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), 1, start * 44100 * BufDur.kr(bufnum), doneAction: Done.freeSelf);
	snd = buf;
	    Out.ar(out, env * snd * amp)
}).add

SkipJack({defer{ ~cursor=QtGUI.cursorPosition; }}, 0.1);
~windowX = Window.screenBounds.extent.x; // calculate the screen width to later scale our mouseX value.
~x_pos = (((~cursor.x/~windowX) * (~num_samples-1))).floor.asInteger.postln;

(
Pbindef(\a,
	\dur, 1,
	\legato, 0.99,
	\start, Pseq(~data_ordered[~x_pos]/(~num_samples-1), inf),
	\bufnum, b, // scrolling through the buffer
    \instrument, \bufl
).play;

Tdef(\x, {
	var old_xpos = 0;
	loop {
		1.wait;
		~x_pos = ((~cursor.x/~windowX) * (~num_samples-1)).floor.asInteger; // extract the current x position of the mouse and scale to 0-221

		if (~x_pos!=old_xpos, {
			("new x position: " ++~x_pos).postln
			Pbindef(\a, \start, Pseq(~data_ordered[~x_pos]/(~num_samples-1), inf));
		});

		old_xpos = ~x_pos;
}}
).play;
)