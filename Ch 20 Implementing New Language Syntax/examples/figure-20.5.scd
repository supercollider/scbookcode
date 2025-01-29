(
var convertFStrings = { |code|
	var stream = CollStream(code);
	var out = CollStream.new;
	var ch, closeQuote;
	while {
		ch = stream.next;
		ch.notNil
	} {
		case
		{ ch == $f and: { stream.peek == $" } } {
			stream.next;  // swallow quote
			out << parseFString.(stream);
		}
		{ ch == $" or: { ch == $' } } {
			out << ch << scanNormalString.(stream, ch) << ch;
		}
		{ ch == $$ } {
			// see above: $" is valid and must not trigger string-literal state
			out << ch;
			ch = stream.next;
			out << ch;
			// and... this branch because $\" is a valid character literal too
			if(ch == $\\) {
				out << stream.next;
			};
		}
		{
			out << ch;
		};
	};
	out.collection
};

var scanNormalString = { |stream, delimiter|
	var ch;
	var string = String.new;
	while {
		ch = stream.next;
		ch.notNil and: { ch != delimiter }
	} {
		string = string.add(ch);
		if(ch == $\\) {
			ch = stream.next;
			if(ch.notNil) { string = string.add(ch) };
		}
	};
	string  // return scanned string back to caller
};

var parseFString = { |stream|
	// assumes 'f"' is already scanned; return: code converted to "str".format(...)
	var start = stream.pos;
	var list = List.new;
	var formatStr = String.new;
	var out, ch;
	// Stage 1: Extract expressions
	while {
		ch = stream.next;
		ch.notNil and: { ch != $" }
	} {
		switch(ch)
		{ ${ } {
			parseOneExpression.(stream, list);
			formatStr = formatStr ++ "%";
		}
		{ $\\ } {
			formatStr = formatStr ++ ch ++ stream.next;
		}
		{ formatStr = formatStr ++ ch };
	};
	// reached the end without a closing quote: syntax error
	if(ch.isNil) {
		Error("open-ended f-string: %".format(stream.collection[start .. start + 20])).throw;
	};
	// Stage 2: Code generation
	if(list.size >= 1) {  // .format only if there's something to format
		out = CollStream.new;
		out << $" << formatStr << $" << ".format(";
		list.do { |expr, i|
			if(i > 0) { out << ", " };
			out << expr;
		};
		out << ")";
		out.collection
	} {
		// -1 -- we need the opening quote, and don't include .next char
		stream.collection[start - 1 .. stream.pos - 1]
	}
};

var parseOneExpression = { |stream, list|
	// assumes '{' is already scanned; result: item added to list
	var start = stream.pos;
	var out = CollStream.new;
	var ch;
	while {
		ch = stream.next;
		ch.notNil and: { ch != $} }
	} {
		case
		// check for nested f-string
		{ ch == $f and: { stream.peek == $" } } {
			stream.next;  // swallow quote
			out << parseFString.(stream);
		}
		// check for escape char
		{ ch == $\\ } {
			out << stream.next;  // do not pass \ into expression string
		}
		{ out << ch };  // default case
	};
	if(ch.isNil) {
		Error("open-ended f-string argument: %".format(
			stream.collection[start .. start + 20]
		)).throw;
	};
	list.add(out.collection);
	stream
};

this.preProcessor = convertFStrings;
)

// Usage:
TempoClock.sched(0, { f"Current time is {thisThread.beats}".postln });
// Sample output: Current time is 70.472959011
