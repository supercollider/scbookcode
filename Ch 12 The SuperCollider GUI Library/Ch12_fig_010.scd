// figure 12.10

s.boot;

(
~freqspec = ControlSpec(60, 500, \exp);
~freq = ~freqspec.map(0.5);
~synth = { |freq| Saw.ar(freq.lag(0.1) + [0, 1], 0.03)}.play(args: [\freq, ~freq]);

~freqslider = Slider()
.orientation_(\horizontal)
.value_(0.5)
.action_({ |v|
	~freq = ~freqspec.map(v.value);
	~synth.set(\freq, ~freq);
});

w = Window(
	"ControlSpec frequency mapping",
	Rect(50, 100, 400, 100)
)
.layout_(HLayout(~freqslider))
.onClose_({ ~synth.set(\gate, 0) })
.front;
)

w.close;