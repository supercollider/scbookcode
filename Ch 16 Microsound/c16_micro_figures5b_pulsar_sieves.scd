/*
Quarks.install("miSCellaneous_lib");
*/

// Make sieves, combine them and play them
// These examples use the Sieve class from Daniel Meyer's miSCellaneous_lib

~size = 24; //size limit for all generated sieves

// make 4 sieves to play with
a = Sieve(3, `~size);
b = Sieve(5, `~size);
c = Sieve(7, `~size);
d = Sieve(11, `~size);

//two methods for transforming sieves to pulsar masks

// sequential bit mask
~pointsToSeqBits = { |points|
	var extractPoints = points.list;
	var bits = 0.dup(extractPoints.last);
	// put 1 at all points indices
	extractPoints.drop(-1).do(bits.put(_, 1));
	bits
};

~pointsToSeqBits.(a); // multiples of 3, as 1 0 0, 1 0 0


// alternating segments bit mask:
~pointsToSegments = { |points|
	points.list.differentiate.collect { |interval, index|
		// at every interval, switch between 1 and 0
		Array.fill(interval, { index.odd.asInteger })
	}.flatten;
};

~pointsToSegments.(a); // multiples of 3, as burst/rest pattern

// set operations on sieves as masking sequences

// union of a and b: all multiples of 3 and 5
~pointsToSeqBits.(a|b);
// symmetrical difference of 3 and 5 - removes common multiples 0 and 15
~pointsToSeqBits.(a--b);

//union of all four - all multiples of 3, 5, 7, 11
~pointsToSeqBits.(a|b|c|d);  // as sequence
-> [ 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0 ]

~pointsToSegments.(a|b|c|d); // as segments
-> [ 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1 ]


///// TODO: explain correctly and/or explain as material for live codable experimentation

//an intersection (&) of symmetrical difference (--) of a and b with a union (|) of a and d
~pointsToSeqBits.(a--b&a|d);
-> [ 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0 ]

~pointsToSegments.(a--b&a|d);
-> [ 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1 ]

//a difference of union of a and b with a union of a and d
~pointsToSeqBits.(a|b-c|a|d);
-> [ 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0 ]

~pointsToSegments.(a|b-c|a|d);
-> [ 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1 ]

//symmetrical difference of a and d
~pointsToSeqBits.(a--d);
-> [ 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0 ]

~pointsToSegments.(a--d);
-> [ 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1 ]

//union of symmetrical difference of a and c with a symmetrical dufference of b and d
~pointsToSeqBits.(a--c|b--d);
-> [ 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0 ]

~pointsToSegments.(a--c|b--d);
-> [ 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1 ]


///// bonus track 1: post bit patterns

~bitprint = { |bitsArray| bitsArray.collect (".1".at(_)).join.postln; };
~bitprint.(~pointsToSeqBits.(a));


///// bonus track 2: play bit patterns while live coding masks

//define a simple pulse synth
SynthDef(\pulse, { |amp = 0.1, freq = 440|
	Out.ar(0, XLine.ar(amp, 0.001, 0.1, 1,0,2) * SinOsc.ar(freq) ! 2)
}).add;

//test it
(instrument: \pulse).play;

//an example sieve-mask
~sieveMask = ~pointsToSegments.(a--d);

//set the speed
~dt = 0.2;
//define a Tdef to play the pulse synth with mapped sieve-based mask
Tdef(\sivPat, {
	loop {
		var points = ~sieveMask.postln;
		// then play the inter
		~sieveMask.size.do { |i|
			if (points[i] == 1) {
				(instrument: \pulse, note: 12 ).play;
				points[i] .post;
			} { ".".post; };
			~dt.wait;
		};
		"".postln;
	};
}).play;


// try different speeds
~dt = 0.1;
~dt = 0.05;
~dt = 0.025;
//and different sieve masks
~sieveMask = ~pointsToSeqBits.(a|b);
~sieveMask = ~pointsToSeqBits.(a|b|c|d);
~sieveMask = ~pointsToSegments.(a|b|c|d);
~sieveMask = ~pointsToSegments.(a|b-c|a|d);
~sieveMask = ~pointsToSegments.(a|d);
~sieveMask = ~pointsToSegments.(a--c|b--d);

//modify the Tdef to map the structure of the sieve-mask to note values
Tdef(\sivPat, {
	loop {
		var points = ~sieveMask.postln;
		// then play the inter
		~sieveMask.size.do { |i|
			if (points[i] == 1) {
				(instrument: \pulse, note: 12 + i ).play;
				points[i] .post;
			} { ".".post; };
			~dt.wait;
		};
		"".postln;
	};
}).play;

