//	figure 8.11 - a Shout class

// beginning of file - Shout11.sc
/* Tests:
Shout.tag;
Shout.tag_("//SHOUT");

Shout.window; // nothing here yet
Shout.textView;
*/
Shout {
	classvar <window;
	classvar <textView;
	classvar <>tag="//!!";
}
// end of file - Shout11.sc




// figure 8.12 - more class variables and initClass method.

// begin of file - Shout12.sc
/* tests
Shout.rect;
Shout.codeDumpFunc;
*/
Shout {
	classvar <>tag="//!!";
	classvar <window;
	classvar <rect;
	classvar <textView;
	classvar <codeDumpFunc;

	*initClass {
		rect = Rect(0, 0, Window.screenBounds.width, 80);
		codeDumpFunc = { |str|
			if (str.beginsWith(tag)) {
				Shout(str.drop(tag.size))
			}
		};
	}
}
// end of Shout12.sc


// figure 8.13 - converting makeWin.

z.makeWin = { |message="Shout this!"|
	z.window = Window("Shout", Rect(0, 0, 1200, 80)).front;
	z.window.alwaysOnTop_(true);
	z.window.alpha_(0.5);

	z.textView = TextView(z.window, z.window.bounds.extent);
	z.textView.resize_(5);
	z.textView.font_(Font("Monaco", 64));
	z.setMessage(message);
};

Shout {
	...
	*makeWin { |message="Shout this!"|
		win = Window("Shout", Rect(0, 0, 1200, 80)).front;
		win.alwaysOnTop_(true);
		win.alpha_(0.5);

		textView = TextView(win, win.bounds.extent);
		textView.resize_(5);
		textView.font_(Font("Monaco", 64));
		this.setMessage(message);
	}
	*setMessage { |message|
		textView.string = message;
	}
	...
}

// tests:
Shout.makeWin("Blong");





//	figure 8.14 - converting z.shout to Shout.new.

z.shout = { |z, str|
	if (z.window.isNil or: { z.window.isClosed }) {
		z.makeWin
	} {
		z.setMessage(str)
	}
};

Shout {
	...
	*new { |message = "Shout!"|
		if (win.isNil or: { win.isClosed }) {
			this.makeWin(message);
		} {
			this.setMessage(message)
		}
	}

	*close {
		if (win.notNil and: { win.isClosed.not })
		{ win.close }
	}
	...
}

// tests:
Shout("Test 1, 2");
Shout("Test 1, 2, 3, 4");	// same window
Shout.close;
Shout("Test 1, 2");		// new window




//	figure 8.15 - converting animate to a class method.
z.animate = { |z, dt=0.2, n = 6|
	var colors = [Color.red, Color.green, Color.black];
	fork {
		n.do { |i|
			dt.wait;
			defer { z.textView.stringColor_(colors.wrapAt(i)) }
		}
	};
};


Shout {
	...
	classvar <>colors;
	...
	animate { |dt=0.2, n=6|
		colors = colors ?? { [Color.red, Color.green, Color.black] };
		fork {
			n.do { |i|
				dt.wait;
				defer { textView.stringColor_(colors.wrapAt(i)) }
			}
		};
	}
	...
}

// tests:
Shout("Test 1, 2");
Shout.animate;



// figure 8.16 - converting setMessage

z.setMessage = { |z, str|
	var messSize = str.size;
	var fontsize = (1.64 * z.textView.bounds.width) / max(messSize, 32);
	z.textView.font_(Font("Monaco", fontsize));
	z.textView.string_(str);
	z.animate;
};

Shout {
	...
	*setMessage { |message|
		var messSize, fontSize;
		messSize = message.size;
		fontSize = (1.64 * width) / max(messSize, 32);

		defer {
			textView.font_(Font("Monaco", fontSize))
			.string_(message.asString);
		};
		this.animate;
	}
	...
}

Shout("Test 1, 2");
Shout("Test" + (1..16));


//	figure 8.17 - handling codeDump in the object model and class.

// load object model z first... then
// clear codeDump
this.codeDump = nil;
// declare the func to add/remove
z[\codeDumpFunc] = { |str|
	if (str.beginsWith(z.shoutTag)) {
		z.shout(str.drop(z.shoutTag.size))
	}
};
z.enable = {
	this.codeDump = this.codeDump.addFunc(z[\codeDumpFunc]);
};
z.disable = {
	this.codeDump = this.codeDump.removeFunc(z[\codeDumpFunc]);
};
// tests:
z.enable
//!! should shout
this.codeDump.postcs	// should be there now

z.disable
//!! shhhhh // should be silent
this.codeDump.postcs	// should be gone now


Shout {
	...
	*enable {
		var interp = thisProcess.interpreter;
		interp.codeDump = interp.codeDump
		.removeFunc(codeDumpFunc) // remove it first so it will
		// only be in the list once
		.addFunc(codeDumpFunc);
	}
	*disable {
		var interp = thisProcess.interpreter;
		interp.codeDump = interp.codeDump.removeFunc(codeDumpFunc);
	}
	...
}

// tests
Shout.add;
//!! test whether Shout works now - it should!
Shout.remove;
//!! test whether Shout works now - should be off.

