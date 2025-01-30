Flanger : Filter {	
	*ar { 
	    arg in, rate=0.5, depth=1.0;
		^this.multiNew('audio', in, rate, depth)
	}
	*kr {
	    arg in, rate=0.5, depth=1.0;
		^this.multiNew('control', in, rate, depth)
	}
}
