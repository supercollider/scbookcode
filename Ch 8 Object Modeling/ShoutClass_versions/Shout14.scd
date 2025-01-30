/* tests:
Shout("Test 1, 2");
Shout("Test 1, 2, 3, 4");	// same window
Shout.close;
Shout("Test 1, 2");		// new window
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

	*new { |message = "Shout!"|
		if (window.isNil or: { window.isClosed }) {
			this.makeWindow(message);
		} {
			this.setMessage(message)
		}
	}

	*close {
		if (window.notNil and: { window.isClosed.not })
		{ window.close }
	}

	*makeWindow { |message="Shout this!"|
		window = Window("Shout", rect).front;
		window.alwaysOnTop_(true);
		window.alpha_(0.5);

		textView = TextView(window, rect.extent);
		textView.resize_(5);
		textView.font_(Font("Monaco", 64));
		this.setMessage(message);
	}

	*setMessage { |message|
		textView.string = message;
	}
}

