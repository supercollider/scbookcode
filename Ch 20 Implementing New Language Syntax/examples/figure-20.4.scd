(
var scanCodeBlock = { |string|
	var stream = CollStream(string);
	var ch;
	var output = CollStream.new;

	while {
		ch = stream.next;
		ch.notNil
	} {
		switch(ch)
		{ $$ } {
			if(string[stream.pos .. stream.pos + 4] == "clock") {
				stream.nextN(5);  // consume "clock"
				output << "thisThread.clock"
			} {
				output << ch;  // don't drop $ for char literals!
				// but, char literals also need to swallow the char
				ch = stream.next;
				if(ch.notNil) {
					output << ch
				}
			}
		}
		{ $" } {
			output << ch << scanString.value(stream, $") << ch;
		}
		{ $' } {
			output << ch << scanString.value(stream, $') << ch;
		}
		// default case
		{ output << ch };
	};
	output.collection;
};

var scanString = { |stream, delimiter|
	var ch;
	var string = String.new;
	while {
		ch = stream.next;
		ch.notNil and: { ch != delimiter }
	} {
		string = string.add(ch);
		// handle escaped characters
		if(ch == $\\) {
			ch = stream.next;  // process next char, without delimiter check
			if(ch.notNil) { string = string.add(ch) };
		}
	};
	string  // return scanned string back to caller
};

this.preProcessor = scanCodeBlock;
)


TempoClock.sched(0, { ("$clock is " ++ $clock).postln });
// Sample output: $clock is a TempoClock
