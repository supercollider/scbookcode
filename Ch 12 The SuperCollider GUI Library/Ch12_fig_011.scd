// figure 12.11

s.boot;

(
~freqspec = ControlSpec(60, 500, \exp);
~freq = ~freqspec.map(0.5);

~synth = { |freq|
	Saw.ar(freq.lag(0.1) + [0, 1], 0.03)
}.play(args: [\freq, ~freq]);

~freqslider = EZSlider(
	label: "freq: ",
	controlSpec: ~freqspec,
	initVal: 0.5
)
.setColors(Color.gray(0.4), Color.gray(0.75))
.value_(~freq)
.action_({ |v|
	~freq = v.value;
	~synth.set(\freq, ~freq);
})
.window.onClose_({ ~synth.set(\gate, 0) });
)

w.close;