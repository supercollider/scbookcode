+ Opus {

	loadInitialProcesses {
		this.prLoadInitProcessAtPath(this.initModPath);
		this.prLoadKillProcessAtPath(this.killModPath);
	}


	prLoadInitProcessAtPath {arg filePath;
		var fileName, process, key, name, splits, pmod;
		fileName = filePath.fileName;
		filePath.postln;
		process = thisProcess.interpreter.executeFile(filePath.absolutePath);
		pmod = process.value(this);
		pmod.isKindOf(CtkPMod).if({
			this.initMod = pmod;
		}, {
			("The file for the init process in the init folder should be a Function that returns a CtkPMod. Please check the file at "++ filePath.absolutePath ++ " to fix this").warn;
			this.createTemplateInitProcess(true);
		});
		fileName.postln;
	}

	openInitFile {
		var filePath;
		filePath = this.initModPath.absolutePath;
		Document.open(filePath);
	}

	createTemplateInitProcess{arg force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
This is a special instance of CtkPMod that will include code that should be run whenever the piece starts, regardless of what event you run first.
*/
{arg opus; // add additional args here that you can feed into instances of CktPMod
	var pmod;
	pmod = CtkPMod(starttime: 0,
		// condition shows this should only run the function once
		condition: 1,
		amp: 0.dbamp,
		// this is a good argument to pass in so you can provide
		// unique IDs
		id: \\init,
		outbus: 0,
		numChannels: 2,
		addAction: 0,
		target: 1,
		server: s);
	pmod.function_({arg pmod, group, routeOut, inc, routeIn, server;
		\"Init runs\".postln;
	});
    pmod;
}
";
		filePath = this.initModPath.absolutePath;
		pathName = this.prCreateTemplateWithStringAtPath("init", filePath, fileStr, force);
		pathName.notNil.if({
			this.prLoadInitProcessAtPath(pathName);
		});
		}

	openKillFile {
		var filePath;
		filePath = this.killModPath.absolutePath;
		Document.open(filePath);
	}

	prLoadKillProcessAtPath {arg filePath;
		var fileName, process, key, name, splits, pmod;
		fileName = filePath.fileName;
		filePath.postln;
		process = thisProcess.interpreter.executeFile(filePath.absolutePath);
		pmod = process.value(this);
		pmod.isKindOf(CtkPMod).if({
			this.killMod = pmod;
		}, {
			("The file for the kill process in the init folder should be a Function that returns a CtkPMod. Please check the file at "++ filePath.absolutePath ++ " to fix this").warn;
			this.createTemplateKillProcess(true);
		});
		fileName.postln;
	}

	createTemplateKillProcess{arg force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
This is a special instance of CtkPMod that will include code that should be run whenever the piece is finished and the Kill command is sent (via GUI or code).
*/
{arg opus; // add additional args here that you can feed into instances of CktPMod
	var pmod;
	pmod = CtkPMod(starttime: 0,
		// condition shows this should only run the function once
		condition: 1,
		amp: 0.dbamp,
		// this is a good argument to pass in so you can provide
		// unique IDs
		id: \\kill,
		outbus: 0,
		numChannels: 2,
		addAction: 0,
		target: 1,
		server: s);
	pmod.function_({arg pmod, group, routeOut, inc, routeIn, server;
		\"Kill runs\".postln;
        opus.freeResources;
		{opus.pevents.gui.window.close}.defer;
	});
    pmod;
}
";
		filePath = this.killModPath.absolutePath;

		pathName = this.prCreateTemplateWithStringAtPath("kill", filePath, fileStr, force);
		pathName.notNil.if({
			this.prLoadKillProcessAtPath(pathName);
		});
		}

}