// figure 12.2

(
Window.closeAll; // close any previously opened windows
// make a centered window
w = Window(
	"centered window",
	Rect(
		Window.screenBounds.width/2 - 200,
		Window.screenBounds.height/2 - 150,
		400,
		300
	)
).front;
)