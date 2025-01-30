+ Opus {

	loadMain {arg filePath = nil, force = false;
		var fileName, main, key, name, splits, pathName;
		filePath.isNil.if({
			filePath = this.mainPath;
		});
		fileName = filePath.fileName;
		filePath.postln;
		main = thisProcess.interpreter.executeFile(filePath.absolutePath);
		main.notNil.if({
			this.mainFunc = main;
			"Main loaded".postln;
		}, {
			"No main function found".warn;
			force.if({
				var pathName;
				pathName = this.createTemplateMain(force);
				pathName.notNil.if({
					"Created a template main.".postln;
					this.loadMain(filePath, false);
				});
			}, {
				"No main function has been loaded".warn;
			})
		})
	}

	createTemplateMain {arg force = false;
		var fileStr, file, filePath, pathName;
		fileStr = "/*
A sample main function for an Opus instance. The instance of Opus that runs this should pass itself into this function
*/
{arg opus;
	var pevents;

	CtkObj.latency_(0.03);

	// the Opus:addResourcesToFree method takes any number of resources that will
	// need to be freed later when the piece is done.
	// call Opus:freeResources in your killMod, and they will be released.

	pevents = CtkPEvents([
		[[nil], [nil]], // an array of things to start and a second of things to kill
		[[nil], [nil]]
	],
	amp: 0.dbamp,
	out: 0,
	init: opus.initMod,
	kill: opus.killMod,
	id: opus.id);

	// store this to the instance Opus
	opus.pevents = pevents;
	// throw up the performance GUI
	pevents.makeGUI;

}";
		filePath = this.mainPath.absolutePath;

		^this.prCreateTemplateWithStringAtPath("main", filePath, fileStr, force);
	}

	openMainFile {
		var filePath;
		filePath = this.mainPath.absolutePath;
		Document.open(filePath);
	}
}