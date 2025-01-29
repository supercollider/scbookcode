// figure 12.13

(
var active = true;
w = Window("mouse/keyboard interaction", Rect(50, 100, 400, 200))
.acceptsMouseOver_(true) // necessary in order to use mouseOverActions
.layout_(VLayout(
	Slider(), Slider(), Slider(),
	StaticText()
	.string_("spacebar to disable/enable")
	.align_(\center)
))
.front;

// set the actions for the sliders (children 0-2)
w.view.children[0..2].do({ |sl, i|
	sl.action_({ |v| [i, v.value].postln })
	.orientation_(\horizontal)
	.mouseOverAction_({ |v| v.background_(Color(0.7, 0.8, 0.9)) })
	.mouseLeaveAction_({ |v| v.background_(Color.gray(0.75)) });
});

w.view.keyDownAction_({ |v, char|
	if(char == $ ) // space character
	{
		active = not(active);
		w.view.children[0..2].do({ |sl|
			sl.enabled_(active);
			sl.background_(Color.gray( if(active, {0.75}, {0.65}) ))
		});
	}
});
)