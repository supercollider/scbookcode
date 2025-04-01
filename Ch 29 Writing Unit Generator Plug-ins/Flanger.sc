Flanger : Filter {
	*ar { |in, rate=0.5, depth=1.0|
		^this.multiNew('audio', in, rate, depth)
	}

	*kr { |in, rate=0.5, depth=1.0|
		^this.multiNew('control', in, rate, depth)
	}
}
