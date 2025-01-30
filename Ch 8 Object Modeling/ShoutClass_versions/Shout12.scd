/* Tests:
Shout.rect;
Shout.codeDumpFunc;
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
}
