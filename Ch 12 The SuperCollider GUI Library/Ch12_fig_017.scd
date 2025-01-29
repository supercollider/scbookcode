// figure 12.17

(
var on = false;

w = Window("custom button with Pen", Rect(50, 100, 300, 200)).front;

u = UserView(w, Rect(100, 50, 100, 100))
.background_(Color.clear)
.drawFunc_({
	Pen.strokeColor_(Color.black);
	Pen.fillColor_(
		Color(0, 0.75, 1, if(on, { 0.8 }, { 0.2 }))
	);
	Pen.width_(3);
	Pen.moveTo(50@4);
	[10@28, 10@72, 50@96, 90@72, 90@28, 50@4].do({ |n| Pen.lineTo(n) });
	Pen.fillStroke;
	Pen.stringCenteredIn(
		if(on, { "ON" }, { "OFF" }),
		Rect(0, 0, 100, 100),
		Font("Arial", 24),
		Color.black
	);
})
.mouseDownAction_({ |view|
	on = not(on);
	if(on, { "on action".postln }, { "off action".postln });
	view.refresh;
})
)