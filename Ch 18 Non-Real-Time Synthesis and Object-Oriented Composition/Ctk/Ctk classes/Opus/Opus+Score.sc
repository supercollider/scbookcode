+ Opus {
	prLoadScoreAtPath {arg filePath;
		var fileName, process, key, name, splits, pmod, fileKey, score;
		fileName = filePath.fileName.splitext;
		fileKey = fileName;
		(fileName.size > 0).if({
			fileKey = fileName[0].asSymbol;
		});
		filePath.postln;
		score = thisProcess.interpreter.executeFile(filePath.absolutePath).value(this, fileKey);
					score.isKindOf(CtkScore).if({
				key = filePath.fileNameWithoutExtension.asSymbol;
				scores.add(key -> score);
			});
			fileName.postln;
	}

	newScore {arg scoreID, initScoreFunction ... args;
		var score;
		score = initScoreFunction.value(this, *args);
		score.id = scoreID;
		score.postln;
		score.notNil.if({
			score.isKindOf(CtkScore).if({
			var key;
				key = score.id;
				scores.add(key -> score);
			})
		});
		^score;
	}

	createTemplateScoreWithName {arg name, force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
Score files should contain a Function that takes an instance of Opus and fileKey that is generated for you from the file name. Saving this as ev.scd, will create an event in the Opus:scores Dictionary with the key \ev, and give the CtkScore the same ID.
Calling opus:newScoreFromProcess expects the processKey to use for creating the new CtkPMod, and the fileKey to use to create the unique event ID. All other arguments that follow are fed into the rest of your process Function template.
Template below. The insance of opus, and an event ID generated from the event file name are passed in for you.
*/
{arg opus, fileKey;
    opus.newScore(fileKey, {
        // return a CtkScore
        CtkScore.new;
}); // enter additional args if needed
}
";
		filePath = this.scoresPath.absolutePath ++ "/" ++ name ++ ".scd";

		pathName = this.prCreateTemplateWithStringAtPath(name, filePath, fileStr, force);
		pathName.notNil.if({
			this.prLoadScoreAtPath(pathName);
		});
	}

	openScoreFile {arg name;
		var filePath;
		filePath = this.scoresPath.absolutePath ++ "/" ++ name ++ ".scd";
		Document.open(filePath);
	}
}