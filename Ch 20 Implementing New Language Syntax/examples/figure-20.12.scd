(
thisProcess.interpreter.preProcessor = { |str|
	var places = str.findAllRegexp("~[0-9\\[]");
	var inStream, outStream, parsed;
	if(places.isEmpty) {
		str  // nothing to do, return original
	} {
		inStream = CollStream(str);
		outStream = CollStream.new;
		try {
			places.do { |index, i|
				outStream << inStream.nextN(index - inStream.pos);
				// .next - parser isn't interested in ~
				inStream.next;
				parsed = SCBookPatternNode.new.parse(inStream);
				parsed.setTime
				.streamCode(outStream);
			};
			// copy tail of string
			outStream << str[inStream.pos ..];
		} { |err|
			// no stack trace for parser errors
			err.errorString.postln;
			outStream = CollStream.new;
		};
		outStream.collection
	};
};
)
