(
this.preProcessor = { |str|
	str.replace("$clock", "thisThread.clock");
};
)

// Usage:
TempoClock.sched(0, { ("tempo is " ++ $clock.tempo).postln; $c.postln; });
