+ Opus {

	prLoadSynthsAtPath {arg filePath;
		var fileName, sd, key, name, splits, fileKey;
		filePath.postln;
		fileName = filePath.fileName.splitext;
		fileKey = fileName;
		(fileName.size > 0).if({
			fileKey = fileName[0].asSymbol;
		});
		sd = thisProcess.interpreter.executeFile(filePath.absolutePath).value(this, fileKey);
			sd.isKindOf(CtkSynthDef).if({
				key = filePath.fileNameWithoutExtension.asSymbol;
				name = sd.synthdef.name.asSymbol;
				synthNames[name].notNil.if({
					var lastFilePath;
					lastFilePath = synthNames[name];
					("Overwriting synth with name "++name++ " with file at path " ++ filePath.absolutePath++". Please use a unique name in your CtkSynthDef, otherwise bad things will likely happen. Check the file at "++lastFilePath++".").warn;
				});
				synthNames.add(name -> filePath.absolutePath);
				synths.add(key -> sd);
			});
			fileName.postln;
	}

	createTemplateSynthWithName {arg name, force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
Synth files should contain a Function that returns a CtkSynthDef. These can be used in your CtkPMods that are created from the Functions created in Opus processes, or referenced for CtkScores. Each file should contain one CtkSynthDef that is the last statement in the file, and it should have a unique name (preferably the sdKey passed in to the Function).
*/
{arg opus, sdKey;
var sd;
sd = CtkSynthDef(sdKey, {arg outBus = 0, inBus = 2, freq, dur = 1;
	Out.ar(outBus, SinOsc.ar(freq, 0, 0.2) * EnvGen.kr(Env([0, 1, 0], [0.5, 0.5], \\sin), timeScale: dur, doneAction: 2))
});
sd
}
";
		filePath = this.synthPath.absolutePath ++ "/" ++ name ++ ".scd";

		pathName = this.prCreateTemplateWithStringAtPath(name, filePath, fileStr, force);
		pathName.notNil.if({
			this.prLoadSynthsAtPath(pathName);
		})
	}

	openSynthFile {arg name;
		var filePath;
		filePath = this.synthPath.absolutePath ++ "/" ++ name ++ ".scd";
		Document.open(filePath);
	}
}