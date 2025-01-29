// figure 12.7

s.boot;

(
~amp = 0.5;
~synth = { |amp| PinkNoise.ar(0.3!2) * amp }.play(args: [\amp, ~amp]);

~slider = Slider()
.orientation_(\horizontal)
.value_(~amp)
.action_({ |v|
	~amp = v.value;
	~synth.set(\amp, ~amp);
});

w = Window(
	"slider sound control",
	Rect(50, 100, 400, 50)
)
.layout_(HLayout(~slider))
.onClose_({ ~synth.set(\gate, 0) })
.front;
)

~slider.valueAction_(rrand(0.0, 1.0)); // manually update view & invoke action

w.close; // also releases the synth because of onClose above