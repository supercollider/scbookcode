// Usage of Syntax Shortcuts
Routine{"x".postln;1.wait;"y".postln}.play
r{"x".postln;1.wait;"y".postln}.play

{SinOsc.ar((1,3..13)*100).sum/8}.play // Array Creation Shortcuts
{SinOsc.ar([1,3,5,7,9,11,13]*100).sum/8}.play

play{Mix(SinOsc.ar((0..100)))} // Partial Application
play{Mix(SinOsc.ar(_)!100)}

// Receiver vs Functional vs Binary Operator notations

rrand(2,9) // Functional Notation
2.rrand(9) // Receiver Notation
2 min: 9 // Binary Operator Notation

{SinOsc.ar(440)}.play 
play{SinOsc.ar(440)}

play{ar(SinOsc,440)}
play{SinOsc.ar(440)}
play{SinOsc ar:440}

// Sucessive Chained Methods
{x=SinOsc.ar(440);x=x.softclip;x=x.cubed;x=x.rand}.play
play{SinOsc.ar(440).softclip.cubed.rand}

// Assign UGens to Variables
x=SinOsc;{x.ar(440)/2 * x.kr(1)}.play
{SinOsc.ar(440)/2 * SinOsc.kr(1)}.play

// Assign Variables Inside Statements
play{x=PinkNoise.ar();BLowPass4.ar(x*2) * x}
play{BLowPass4.ar(2*x=PinkNoise.ar)*x}

// Left to Right Order of Precedence
1+2*3 
3*(1+2)

play{x=SinOsc;x.ar(1+x.ar(5)*1e3)}
play{x=SinOsc;x.ar(1e3*(x.ar(5)+1))}