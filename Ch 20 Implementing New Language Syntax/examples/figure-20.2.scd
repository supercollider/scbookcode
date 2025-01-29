(
this.preProcessor = { |str|
	str.findRegexp("\\$[a-z][a-zA-Z0-9]+").reverseDo { |match|
		var pos = match[0];
		str = str[0 .. pos - 1] ++ "thisThread." ++ str[pos + 1 ..];
	};
	str
};
)


// Usage:
"On %, current time is %\n".postf($clock, $beats);
