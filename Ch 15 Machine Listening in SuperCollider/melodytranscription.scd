//Example uses internal server to demonstrate shared busses

(
s.doWhenBooted({

b = Buffer.alloc(s, 512);

//this SynthDef will make no sound, just analyses input
SynthDef(\pitchandonsets,
{
	var in, amp, freqdata, chain, onsets, trigger;

	in = SoundIn.ar(0);
	amp = RunningSum.rms(in, 64); //get rms amplitude value per control block
	freqdata = Pitch.kr(in);

	//can synchronously poll if s.hasShmInterface true
	Out.kr(0,freqdata);
	Out.kr(2,amp);

	chain = FFT(b, in);

	// - move the mouse left/right to change the threshold:
	onsets = Onsets.kr(chain, MouseX.kr(0,1), \complex);

	trigger = SendTrig.kr(onsets);

}).add;
});

)



(
var freqlist=List(), amplist=List();
var notelist= List(), numnotes=10; //will hold the last 10 notes
var lasttime, started=false;
var maxlength=0.5, maxkperiods, waittime;
var freqbus = Bus('control',0,1);
var hasfreqbus = Bus('control',1,1);
var rmsampbus = Bus('control',2,1);

maxkperiods = ((maxlength*(s.sampleRate))/(s.options.blockSize)).asInteger;
waittime = (s.options.blockSize)/(s.sampleRate);


// register to receive message
a = OSCFunc({ arg msg, time, addr, recvPort;
	var newnote;

	if(started,{

	//finalise previous note as [starttime, ioi= inter onset interval, dur, medianpitch, maxamp]
	newnote = 	[lasttime, time-lasttime, (time-lasttime).min(maxlength), if(freqlist.notEmpty, {freqlist.median.cpsmidi},{nil}),amplist.maxItem.ampdb];

	newnote.postln;

	notelist.addFirst(newnote);

	//remove oldest note if over size
	if(notelist.size>numnotes,{notelist.pop});

	},{started = true;});

	//reset lists for collection
	freqlist = List();
	amplist = List();
	lasttime = time;

},'/tr',s.addr).add;

x = Synth(\pitchandonsets);

//poll values
{

	inf.do{
		var freq, hasfreq, rmsamp;

		freq = freqbus.getSynchronous;
		hasfreq = hasfreqbus.getSynchronous;
		rmsamp = rmsampbus.getSynchronous;

		//don't allow notes of longer than 500 control periods or so
		if((hasfreq>0.5) and: (amplist.size<maxkperiods), {freqlist.add(freq)});

		if(amplist.size<maxkperiods, {amplist.add(rmsamp)});

		//poll every control period, intensive
		(waittime).wait;
	};

}.fork;

)



(
a.free; //Free the OSCresponder
x.free; // Free the synth
b.free; // Free the buffer
)

