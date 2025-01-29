// figure 12.8

s.boot;

(
~amp = 0;
~synth = { |amp| PinkNoise.ar(0.3!2) * amp }.play(args: [\amp, ~amp]);

~button = Button()
.font_(Font("Courier", 24))
.states_([ // an Array with [text, text color, background color] for each state
	["OFF", Color.gray(0.3), Color.gray(0.75)], // state 0
	["ON", Color.white, Color(0, 0.5, 1)] // state 1
])
.action_({ |v|
	~amp = v.value;
	~synth.set(\amp, ~amp)
}); // button state used as amplitude value

w = Window(
	"button sound control",
	Rect(50, 50, 250, 100)
)
.layout_(HLayout(~button))
.onClose_({ ~synth.set(\gate, 0) })
.front;
)

~button.valueAction_(1 - ~button.value); // manually toggle button state & invoke action

w.close; // also releases the synth because of onClose above