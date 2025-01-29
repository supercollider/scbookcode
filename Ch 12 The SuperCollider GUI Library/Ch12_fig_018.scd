// figure 12.18

(
var t = 0, rad;
w = Window("ripple", Rect(100, 100, 400, 400)).front;
u = UserView(w, w.view.bounds)
.background_(Color.black)
.drawFunc_({
	Pen.fillColor_(Color.gray(0.0, 0.05));
	Pen.fillRect(u.bounds);
	Pen.width_(3);
	t = t + (2pi/200) % 2pi;
	rad = cos(t + [0, pi/10, pi/5]) / 2 + 0.5;
	rad.do({ |n|
		Pen.strokeColor_(Color(0, n, rrand(0.7, 0.9)));
		Pen.addArc(200@200, n * 150 + 10, 0, 2pi);
		Pen.stroke;
	});
})
.clearOnRefresh_(false)
.animate_(true);
)