/* tests:
Shout.makeWin("Blong");
*/
Shout {
	classvar <>tag="//!!";
	classvar <rect;
	classvar <window;
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

	*makeWin { |message="Shout this!"|
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

