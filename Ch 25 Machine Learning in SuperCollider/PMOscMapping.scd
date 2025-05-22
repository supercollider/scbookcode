(
//[0] data management
~inputBuffer = Buffer.alloc(s,2);
~outputBuffer = Buffer.loadCollection(s,[0.1, 0.9, 0.2, 0.3, 0.8, 0.3, 0.2, 0.7, 0.2]); // 9 control parameters
~inData = FluidDataSet(s);
~outData = FluidDataSet(s);
)

(
//[1] make a complex synth with multiple (unintuitive) params
~pmsynth = {
	var p = FluidBufToKr.kr(~outputBuffer);
	var op1 = PMOsc.ar(p[0].linexp(0,1,20,2000), p[1].linexp(0,1,0.1,2000), p[2]*pi*2,0);
	var op2 = PMOsc.ar(p[3].linexp(0,1,0.1,200),p[4].linexp(0,1,0.1,2000), p[5]*pi*2, op1);
	PMOsc.ar(p[6].linexp(0,1,0.1,200),p[7].linexp(0,1,0.1,2000), p[8]*pi*2, op2);
};
SynthDef(\pmsynth, {
	Out.ar(0,~pmsynth.()!2);
}).play;
)

(
//[2] explore the parameter space randomly. Choose a sound that you like
~outputBuffer.setn(0, {1.0.rand} ! 9);
)

(
//[3] This synth will collect mouse coordinates to associate with the current sound
~inData.size({|dataSize|
	{
		FluidKrToBuf.kr([MouseX.kr, MouseY.kr],~inputBuffer);
		FluidDataSetWr.kr(~inData, idNumber: dataSize, buf:~inputBuffer, trig:1);
		Line.kr(dur:ControlDur.ir, doneAction:2);
	}.play;

	~outData.addPoint(dataSize,~outputBuffer);
});
)

//[4] repeat steps [2] and [3] to collect data that associates mouse positions with sounds

(
// (peek in on the datasets if you want)
~inData.print;
~outData.print;
)

(
//[5] initialise a neural network
~nn = FluidMLPRegressor(s,[7],activation: 1,outputActivation: 1,maxIter: 1000,learnRate: 0.1,momentum: 0,batchSize: 2,validation: 0);
)

(
//[6] train: keep running this until the error is small (< 0.05)
~nn.fit(~inData,~outData,{|x| [\error,x].postln;});
)

(
//[7] stop the current synth, and run this one instead
//this synth predicts the synth parameters based on the mouse position, using the neural network
SynthDef(\pmsynthPrediction, {
	FluidKrToBuf.kr([MouseX.kr, MouseY.kr],~inputBuffer);
	~nn.kr(Impulse.kr(30), ~inputBuffer, ~outputBuffer);
	Out.ar(0,~pmsynth.() ! 2);
}).play;
)