+ Opus {

	loadAudioRoutes {arg force = false;
		this.prLoadAudioInRoutes(force);
		this.prLoadAudioOutRoutes(force);
	}

	prLoadAudioInRoutes {arg force = false;
		var inputs;
		inputs = thisProcess.interpreter.executeFile(audioInPath.absolutePath);
		inputs.notNil.if({
			"Inputs".postln;
			inputs.do({arg inputArray;
				var key, idx, numChannels, audioBus;
				#key, idx, numChannels = inputArray;
				audioBus = CtkAudio.play(numChannels, idx + this.server.options.numOutputBusChannels, this.server);
				this.inputs.add(key -> audioBus);
			})
		}, {
			force.if({
				var pathName;
				pathName = this.createTemplateAudioInRoute(force);
				pathName.notNil.if({
					"Created a template audio input file..".postln;
					this.prLoadAudioInRoutes(false);
				});
			}, {
				"No audio inputs have been loaded".warn;
			})
		})
	}

	prLoadAudioOutRoutes {arg force = false;
		var outputs;
		outputs = thisProcess.interpreter.executeFile(audioOutPath.absolutePath);
		outputs.notNil.if({
			"Outputs".postln;
			outputs.do({arg outputArray;
				var key, idx, numChannels, audioBus;
				#key, idx, numChannels = outputArray;
				audioBus = CtkAudio.play(numChannels, idx, this.server);
				this.outputs.add(key -> audioBus);
			})
		}, {
			force.if({
				var pathName;
				pathName = this.createTemplateAudioOutRoute(force);
				pathName.notNil.if({
					"Created a template audio input file..".postln;
					this.prLoadAudioOutRoutes(false);
				});
			}, {
				"No audio inputs have been loaded".warn;
			})
		})
	}


	createTemplateAudioInRoute {arg force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
A sample set of audio inputs. This should be an array of arrays. Each secondary array should contain a key to access the input with, and a 0 based index for a channel on the physical device followed by the number of channels.
*/
[
    [\\myInputOne, 0, 1],
    [\\myInputTwo, 1, 1],
];";
		filePath = this.audioInPath.absolutePath;
		filePath.postln;
		^this.prCreateTemplateWithStringAtPath("inputs", filePath, fileStr, force);
	}

	createTemplateAudioOutRoute {arg force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
A sample set of audio outputs. This should be an array of arrays. Each secondary array should contain a key to access the output with, and a 0 based index for a channel on the physical device followed by the number of channels.
*/
[
    [\\myStereoOutput, 0, 2],
    [\\myStereoMonitorOutput, 2, 1],
];";
		filePath = this.audioOutPath.absolutePath;

		^this.prCreateTemplateWithStringAtPath("outputs", filePath, fileStr, force);
	}
}