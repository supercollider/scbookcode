////// The complete Shout object model as code,
//// can be used as a single-file loadscript.

/*
Shout Window:
Send visually loud messages in network music setups

//// tests:
// top level:
//!! this line should shout and animate!
z.shout("Space is the place");
// individual tests:
z.makeWindow;
z.setMessage("setMessage test");
z.animate;
z.shoutTag;
*/
(
z = z ? ();
// make the window
z.makeWindow = { |z, message="Shout this!"|
	z.window = Window("Shout", Rect(0, 0, 1200, 80)).front;
	z.window.alwaysOnTop_(true);
	z.window.alpha_(0.5);

	z.textView = TextView(z.window, z.window.bounds.extent);
	z.textView.resize_(5);
	z.textView.font_(Font("Monaco", 64));

	z.textView.string_(message);
};
/*
z.makeWindow(“yo”);
*/
// top level shout method, gets called from codeDump
z.shout = { |z, str|
	// only make win if not already there
	if (z.window.isNil or: { z.window.isClosed }) {
		z.makeWindow(str);
	} {
		z.setMessage(str);
	}
};
/*
z.shout(“yoyo”);
*/
// set the shouted message
z.setMessage = { |z, str|
	var messSize = str.size;
	var fontsize = (1.64 * z.textView.bounds.width) / max(messSize, 32);
	z.textView.font_(Font("Monaco", fontsize));
	z.textView.string_(str);
	z.animate;
};
/*
z.setMessage(“yoyoyoyo”);
*/
z.animate = { |z, dt=0.2, n = 6|
	var colors = [Color.red, Color.green, Color.black];
	fork {
		n.do { |i|
			dt.wait;
			defer { z.textView.stringColor_(colors.wrapAt(i)) }
		}
	};
};
// that tag for comment lines to be shouted
z.shoutTag = "//!!";
// and activate shouting
this.codeDump = { |str|
	if (str.beginsWith(z.shoutTag)) {
		z.shout(str.drop(z.shoutTag.size))
	}
};
z; // return Shout model
/*
//!! this line should shout and animate!
*/
)
