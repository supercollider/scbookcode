MKtl.find;

k = MKtl('nk2', "korg-nanokontrol2");

k.gui;

// turn tracing on
k.trace;

// turn it off
k.trace(false);

k.postElements;

k.elAt(\tr, \rew); // the rewind button
k.elAt(\sl, 0); // the first slider
k.elAt(\sl); // a group containing all sliders
k.elAt(\bt, \S, 0); // the first button of the top row of buttons

// assign an action to the third knob
k.elAt(\kn, 2).action_( {|el| [el.name, el.value.round(0.0001)].postcs});
// reset the action of this knob to nothing (nil)
k.elAt(\kn, 2).resetAction;

// add an action to the group of all knobs
(
k.elAt(\kn).action_( {|el|
	"knob % value: %\n"​.­postf(el​.­parent​.­indexOf(el), el.value)
});
);

//With synth

s.boot;

// using a very ­simple SynthDef and Synth:
(
SynthDef(\blippy, {
	var snd = Blip.ar(
		\freq.kr(440).lag(0.1),
		\numHarmonics.kr(100),
		\amp.kr(1.0).lag(0.1)) * 0.5;
	Out.ar(0,
		Pan2.ar(snd, \pan.kr(0).lag(0.1))
	)
}).add
);
// start the synth by hand first
z = Synth(\blippy, [\freq, 440, \numHarmonics, 100, \amp, 0.5, \pan, 0]);

// create 4 control ele­ments for it:
(
// clear all actions first
k.resetActions;
// slider 0 −­> amplitude
k.elAt(\sl, 0).action_({|elem| z!? _.set(\amp, \amp.asSpec
	.map(elem.value))});
// knob 0 −­> pan
k.elAt(\kn, 0).action_({|elem| z!? _.set(\pan, \pan.asSpec
	.map(elem.value))});
// slider 1 −­> freq
k.elAt(\sl, 1).action_({|elem| z!? _.set(\freq, elem.value
	.linlin(0.0, 1.0, 50, 2000))});
// knob 1 −­> number of harmonics
k.elAt(\kn, 1).action_({|elem| z!? _.set(\numHarmonics, elem
	.value.linexp(0.0, 1.0, 1, 50))});
)







// remove all actions
k.resetActions;

// add new names for the ele­ments used in the instrument
(
// control synth ­parameters
k.addNamed(\amp, k.elAt(\sl, 0));
k.addNamed(\pan, k.elAt(\kn, 0));
k.addNamed(\freq, k.elAt(\sl, 1));
k.addNamed(\numHarmonics, k.elAt(\kn, 1));
// use play and stop buttons to create and ­free the synth
k.addNamed(\start, k.elAt(\tr, \play));
k.addNamed(\stop, k.elAt(\tr, \stop));
);

// give them the same actions as before.
(
k.elAt(\amp).action_({|elem| z!? _.set(\amp, \amp.asSpec.map(elem.value))});
k.elAt(\pan).action_({|elem| z!? _.set(\pan, \pan.asSpec.map(elem.value))});
k.elAt(\freq).action_({|elem| z!? _.set(\freq, elem.value.linlin(0.0, 1.0, 50, 2000))});
k.elAt(\numHarmonics).action_({|elem| z!? _.set(\numHarmonics, elem.value.linexp(0.0, 1.0, 1, 50))});

// and new functions for start and stop:
k.elAt(\start).action_({|elem|
	if(elem.value > 0) {// only start on button down
		z!? _.­free;
		z = Synth(\blippy, [\freq, 440, \numHarmonics, 100, \amp, 0.5, \pan, 0])
	}
});
k.elAt(\stop).action_({|elem|
	if(elem.value > 0) {// only stop on button down
		z!? _.­
		free; z = nil;
	}
});
);

// To control the same instrument from a dif­ferent controller evaluate the block of code below,
// followed by the block of code above.
(
k = MKtl(\gp, "*impact-gamepad"); // k is now the new controller
k.gui;
k.addNamed(\amp, k.elAt(\joy, \r, \y));
k.addNamed(\pan, k.elAt(\joy, \r, \x));
k.addNamed(\freq, k.elAt(\joy, \l, \x));
k.addNamed(\numHarmonics, k.elAt(\joy, \l, \y));
k.addNamed(\start, k.elAt(\bt, \5));
k.addNamed(\stop, k.elAt(\bt, \7));
);



(
k = MKtl('nk2');
k.resetActions;
f = {|elem| ("1: "++elem.value).postln};
g = {|elem| ("2: "++elem.value).postln};
k.elAt(\sl, 0).addAction(f);
k.elAt(\sl, 0).addAction(g);
);

k.gui;





//outputs


k = MKtl('bcr', "behringer-bcr2000");
k.gui;
// list ele­ments which can send a value back to the controller
k.outputElements;

k.elAt(\kn,0,0).value_(0.5);