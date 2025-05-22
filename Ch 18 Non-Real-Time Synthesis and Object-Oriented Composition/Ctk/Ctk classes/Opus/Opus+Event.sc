+ Opus {

	prLoadEventAtPath {arg filePath;
		var fileName, process, key, name, splits, pmod, fileKey;
		fileName = filePath.fileName.splitext;
		fileKey = fileName;
		(fileName.size > 0).if({
			fileKey = fileName[0].asSymbol;
		});
		filePath.postln;
		thisProcess.interpreter.executeFile(filePath.absolutePath).value(this, fileKey);
	}

	newEventFromProcess {arg processID, eventID ... args;
		var event, process;
		process = processes[processID];
		process.postln;
		event = process.value(this, eventID, *args);
		event.postln;
		event.notNil.if({
			event.isKindOf(CtkPMod).if({
			var key;
				key = event.id;
				events.add(key -> event);
			})
		});
		^event;
	}

	createTemplateProcessWithName {arg name, force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
Event files should contain a Function that takes an instance of Opus and fileKey that is generated for you from the file name. Saving this as ev.scd, will create an event in the Opus:events Dictionary with the key \ev, and give the CtkPMod the same ID.
Calling opus:newEventFromProcess expects the processKey to use for creating the new CtkPMod, and the fileKey to use to create the unique event ID. All other arguments that follow are fed into the rest of your process Function template.
Template below. The insance of opus, and an event ID generated from the event file name are passed in for you.
*/
{arg opus, fileKey;
    opus.newEventFromProcess(\enterProcessKeyHere, fileKey); // enter additional args if needed
}
";
		filePath = this.eventPath.absolutePath ++ "/" ++ name ++ ".scd";

		pathName = this.prCreateTemplateWithStringAtPath(name, filePath, fileStr, force);
		pathName.notNil.if({
			this.prLoadEventAtPath(pathName);
		});
	}

	openEventFile {arg name;
		var filePath;
		filePath = this.eventPath.absolutePath ++ "/" ++ name ++ ".scd";
		Document.open(filePath);
	}
}