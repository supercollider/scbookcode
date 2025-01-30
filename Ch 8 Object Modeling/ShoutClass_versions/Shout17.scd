/* tests:
// tests
Shout.enable;
//!! test whether Shout works now - it should!
Shout.disable;
//!! test whether Shout works now - should be off.
*/
Shout {
	classvar <>tag="//!!";
	classvar <rect;
	classvar <window;
	classvar <textView;
	classvar <codeDumpFunc;
	classvar <>colors;

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

	//	figure 8.17 - handling codeDump in object model and class.
	*enable {
		var interp = thisProcess.interpreter;
		// remove it first so it will only be in the list once
		this.disable;
		// then add it
		interp.codeDump = interp.codeDump.addFunc(codeDumpFunc);
	}

	*disable {
		var interp = thisProcess.interpreter;
		interp.codeDump = interp.codeDump.removeFunc(codeDumpFunc);
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
		var messSize, fontSize;
		messSize = message.size;
		fontSize = (1.64 * rect.width) / max(messSize, 32);

		defer {
			textView.font_(Font("Monaco", fontSize))
			.string_(message.asString);
		};
		this.animate;
	}

	*animate { |dt=0.2, n=6|
		colors = colors ?? { [Color.red, Color.green, Color.black] };
		fork {
			n.do { |i|
				dt.wait;
				defer { textView.stringColor_(colors.wrapAt(i)) }
			}
		};
	}
}

