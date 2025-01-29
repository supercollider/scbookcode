(
//[0] data management
s.waitForBoot({
	~analysisBuffer = Buffer.alloc(s,13); // by default FluidMFCC will return 13 coefficients
	~outputBuffer = Buffer.alloc(s,1); // a 1 frame buffer for receiving the classification on the server
	~inData = FluidDataSet(s);
	~labels = FluidLabelSet(s);
});
)

(
//[1] a function to get MFCCs from audio input
~analyseSound = {
	var mic = SoundIn.ar([0]);
	FluidMFCC.kr(mic,startCoeff:1);
};
SynthDef(\analysis_synth,{
	var mfccs = ~analyseSound.();
	FluidKrToBuf.kr(mfccs,~analysisBuffer);
}).play;
)

(
//[2] define a function for adding 30 labels over the course of 1 second
~add_labels = {
	arg label;
	~inData.size({
		arg size;
		fork{
			30.do{
				arg i;
				var id = size + i;
				id.postln;
				~inData.addPoint(id,~analysisBuffer);
				~labels.addLabel(id,label);
				30.reciprocal.wait;
			};
		};
	});
};
)

//[3] add some labels for a first class (try whistling for example)
~add_labels.("class A");

//[4] add some labels for a second class (try hissing "sssss" for example)
~add_labels.("class B");

//[5] peek in on the data
(
~inData.print;
~labels.print;
)

//[6] initialise a neural network
(
~nn = FluidMLPClassifier(s,[8],activation: FluidMLPClassifier.tanh, maxIter: 1000,learnRate: 0.1,momentum: 0.9,batchSize: 8,validation: 0);
)

(
//[7] keep running this until the error is small (< 0.05)
~nn.fit(~inData,~labels,{|x| [\error,x].postln;});
)

//[8] run this synth to classify the incoming sound and adjust the filter according to the classification
(
{
	var oscs, mfccs, trig = Impulse.kr(SampleRate.ir/512), classification;
	mfccs = ~analyseSound.();
	FluidKrToBuf.kr(mfccs,~analysisBuffer);
	~nn.kr(trig, ~analysisBuffer, ~outputBuffer);
	classification = FluidBufToKr.kr(~outputBuffer);
	classification.poll; // 0 is the "zeroth" label introduced to the LabelSet, 1 is the "first" label introduced, etc.
	oscs = ({Saw.ar(100 + 5.0.rand)}!20).mean!2;
	BMoog.ar(oscs, classification.lag2.madd(2000,500), 0.2)
}.play;
)


