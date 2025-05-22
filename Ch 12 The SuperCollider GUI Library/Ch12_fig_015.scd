// figure 12.15

(
var button, knob, sched, i = 0;

knob = Knob()
.canFocus_(false).acceptsMouse_(false); // user can't control it directly

button = Button()
.states_([
	["automate", Color.black, Color.gray(0.75)],
	["automate", Color.white, Color(0, 0.5, 1)]
])
.action_({ |v|
	if(v.value == 1) {
		sched = Routine({
			loop{
				i = i + 0.02;
				{ knob.valueAction_(i.fold(0, 1)) }.defer;
				wait(1/30);
			}
		}).play;
	}
	{ sched.stop };
});

w = Window.new("GUI automation", Rect(100, 100, 200, 300))
.onClose_({ sched.stop })
.layout_(VLayout(button, knob))
.front;
)