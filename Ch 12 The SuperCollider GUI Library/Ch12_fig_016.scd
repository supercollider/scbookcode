// figure 12.16

(
w = Window("basic Pen usage", Rect(100, 100, 300, 300)).front;

u = UserView(w, w.view.bounds)
.background_(Color.white)
.drawFunc_({
	Pen.width_(5);

	// Line
	Pen.strokeColor_(Color.black);
	Pen.moveTo(105@20);
	Pen.lineTo(30@80);
	Pen.stroke; // <-- draw line

	// Rectangle
	Pen.fillColor_(Color.red(0.8, 0.5));
	Pen.width_(2);
	Pen.addRect(Rect(160, 55, 100, 80));
	Pen.fill; // <-- draw rectangle

	// Wedge
	Pen.strokeColor_(Color(0, 0.5, 1));
	Pen.fillColor_(Color.gray(0.8));
	Pen.addWedge(100@200, 70, 0, 3pi/2);
	Pen.fillStroke; // <-- draw wedge
});
)
