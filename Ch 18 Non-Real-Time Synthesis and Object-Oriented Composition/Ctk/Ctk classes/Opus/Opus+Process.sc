+ Opus {

	prLoadProcessAtPath {arg filePath;
		var fileName, process, key, name, splits, pmod;
		fileName = filePath.fileName;
		filePath.postln;
		process = thisProcess.interpreter.executeFile(filePath.absolutePath);
		pmod = process.value(this, fileName);
		pmod.isKindOf(CtkPMod).if({
			key = filePath.fileNameWithoutExtension.asSymbol;
			processes.add(key -> process);
		}, {
			("Files in the processes folder should be a Function that returns a CtkPMod. Please check the file at "++ filePath.absolutePath ++ " to fix this").warn;
		});
		fileName.postln;
	}

	argsForProcessAtKey {arg key;
		var process, returnArray;
		returnArray = [];
		process = processes[key];
		process.notNil.if({
			returnArray = process.def.argNames;
			("Arguments for process "++key++" are: "++returnArray).postln;
			"When creating an event with Opus:newEventFromProcess, the opus arg is passed in for you".postln;
		});
		^returnArray;
	}

	createTemplateProcessWithName {arg name, force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
Process files should contain a Function that takes an instance of Opus, and unique eventID to use for the new instance of CtkPMod and additional arguments that are needed to drive new
instances of your CtkPMod. When you ask Opus for an 'pmodFromProcess', a new instance
of this CtkPMod will be created for you.
Template below. The insance of opus, and an event ID generated from the event file name are passed in for you.
*/
{arg opus, eventID; // add additional args here that you can feed into instances of CktPMod
	var pmod;
	pmod = CtkPMod(starttime: 0,
		// condition could also be a number that says how many
		condition: Env([0, 1, 0], [1, 1], \\sin, 1),
		amp: 0.dbamp,
		// this is a good argument to pass in so you can provide
		// unique IDs
		id: eventID,
		outbus: 0,
		numChannels: 2,
		addAction: 0,
		target: 1,
		server: s);
	pmod.function_({arg pmod, group, routeOut, inc, routeIn, server;
		// process what you need, and set up CtkNotes to create.
		// collect notes
		pmod.collect(nil);
		// schedule when it should fire again
		pmod.next_(0.2);
	});
    pmod;
}
";
		filePath = this.processesPath.absolutePath ++ "/" ++ name ++ ".scd";

		pathName = this.prCreateTemplateWithStringAtPath(name, filePath, fileStr, force);
		pathName.notNil.if({
			this.prLoadProcessAtPath(pathName);
		});
		}
}