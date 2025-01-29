// figure 12.4

(
Window(
	"horizontal/vertical layout",
	Rect(100, 100, 250, 300)
).layout_(VLayout(
	Button(),
	HLayout(Slider(), Slider(), Slider(), Slider())
)
).front;
Window(
	"grid layout",
	Rect(400, 100, 200, 100)
).layout_(GridLayout.rows(
	[ Button(), Button(), Button(), Button() ],
	[ Knob(), Knob(), Knob(), Knob() ],
)).front;
)

// try resizing windows with the mouse to see dynamic adjustments