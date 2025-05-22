// figure 12.9

s.boot;

(
~amp = 0.5.lincurve(0, 1, 0, 1, 3); // 3 represents the curvature of the mapping
~synth = { |amp| PinkNoise.ar(0.3!2) * amp  }.play(args: [\amp, ~amp]);

~slider = Slider()
.orientation_(\horizontal)
.value_(0.5)
.action_({ |v|
	~amp = v.value.lincurve(0, 1, 0, 1, 3);
	~synth.set(\amp, ~amp)
});

w = Window(
	"lincurve amplitude mapping",
	Rect(50, 100, 400, 50)
)
.layout_(HLayout(~slider))
.onClose_({ ~synth.set(\gate, 0) })
.front;
)

w.close;