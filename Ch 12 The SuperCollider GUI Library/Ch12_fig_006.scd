// figure 12.6

(
w = Window(
	"window with a view",
	Rect(50, 100, 400, 300)
).front;

~slider = Slider(w, Rect(50, 50, 300, 50))
.background_(Color.rand);
)

~slider.background; // get background color

~slider.background_(Color.green); // set background color to green

~slider.bounds_(Rect(50, 200, 300, 50)); // reposition slider

~slider.visible_(false); // make invisible
