
/////////////////////// Object Modeling code figures 1 ///////////////////



//	figure 8.1 - a Puppet class, and tests for it.

Puppet {
	var <>myfreq; // an instance variable with a getter and a setter method

	// a method for creating a new object of this kind
	*new { |myfreq=50| ^super.new.myfreq_(myfreq) }

	// a simple method that uses 'myfreq' for something audible.
	blip { { Blip.ar(myfreq, 11) * XLine.kr(1, 0.01, 0.6, doneAction: 2) }.play; }
}

// tests for the behavior implemented so far:
m = Puppet.new(50);// make an instance of Puppet, pass in myfreq

m.dump;			// test that myfreq is set correctly
m.myfreq;			// test accessing myfreq
m.blip;			// should sound
m.myfreq_(100);	// test setting myfreq
m.blip;		 // should sound differently







// figure  8.2 - a puppet modeled as an event.

m = (); 			// make an empty event
m.myfreq_(50);	// put something in it with a setter method: a pseudo-instance variable
m.myfreq;			// look it up with a getter method
// put a function into it with a setter:
// this becomes a pseudo-method
m.blip_({ |ev| { Blip.ar(ev.myfreq, 11) * XLine.kr(1, 0.01, 0.6, doneAction: 2) }.play; });
m.blip;		// execute the function with a pseudo-method call (same name)





// figure  8.3 - add more instance variables, change the blip method.
(
m.numHarms_(20); 	// a new instvar
m.decay_(0.3); 	// and another
// update the blip method to use them:
m.blip_({ |ev|
	{ Blip.ar(ev.myfreq, ev.numHarms)
		* XLine.kr(1, 0.01, ev.decay, doneAction: 2) }.play;
});
)
m.blip;	// test





//	figure 8.4 - A minimal Shout Window sketch.

z = z ? (); 	// make an empty event as a pseudo-object
z.window = Window("Shout", Rect(0, 0, 1200, 80)).front;
z.textView = TextView(z.window, z.window.bounds.extent);
z.textView.resize_(5);
z.textView.font_(Font("Monaco", 64));
z.textView.string_("Shout this!");

// tune appearances
z.window.alwaysOnTop_(true);	// make sure it is always on top .
z.window.alpha_(0.5);		// make the window semi-transparent

z.window.close;	// close when done


// figure 8.5 - wrap the sketch in a pseudo-method.
(
z.makeWindow = { |z, message="Shout this!"|
	z.window = Window("Shout", Rect(0, 0, 1200, 80)).front;
	z.window.alwaysOnTop_(true);
	z.window.alpha_(0.5);

	z.textView = TextView(z.window, z.window.bounds.extent);
	z.textView.resize_(5);
	z.textView.font_(Font("Monaco", 64));

	z.textView.string_(message);
};
)
z.makeWindow;
z.makeWindow("Try showing that.");



// figure 8.6 - more pseudo-methods.

z.setMessage = { |z, str| z.textView.string_(str) };

z.setMessage("Does this update?");	// test
(
// use z.shout as main interface
z.shout = { |z, str|
	// only make window if not already there
	if (z.window.isNil or: { z.window.isClosed }) {
		z.makeWindow(str);
	};
	z.setMessage(str);
};
)
z.shout("Does this shout the text?"); // test

z.window.close;
z.shout("also when window was closed?");



// figure 8.7 - text color animation

z.textView.stringColor_(Color.red);	// try a single color
(
z.animate = { |z, dt=0.2, n = 6|
	var colors = [Color.red, Color.green, Color.black];
	fork {
		n.do { |i|
			dt.wait;
			defer { z.textView.stringColor_(colors.wrapAt(i)) }
		}
	};
};
)
z.animate;          // test with default values
z.animate(0.1, 24); // and test with arguments given



// Figure 8.8 is a screenshot of the window so far



// figure 8.9 - using codeDump to shout
this.codeDump = { |str, result, func| [str, result, func].printAll };

a = 1 + 2;	// code appears in post window now

z.shoutTag = "//!!";
this.codeDump = { |str|
	if (str.beginsWith(z.shoutTag)) { z.shout(str.drop(z.shoutTag.size)) }
};

//!! a comment with a 'shout tag' now gets shouted!




//	figure 8.10 - updated setMessage to scale font and flash text.
(
z.setMessage = { |z, str|
	var messSize = str.size;
	var fontsize = (1.64 * z.textView.bounds.width) / max(messSize, 32);
	z.textView.font_(Font("Monaco", fontsize));
	z.textView.string_(str);
	z.animate;
};
)
//!! a long comment gets scaled down to a rather smaller font size, minimally fontsize 32!
//!! a short message is big!



