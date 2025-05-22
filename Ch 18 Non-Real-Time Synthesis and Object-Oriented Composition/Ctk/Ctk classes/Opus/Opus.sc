/*
Encapsulates everything for an entire piece. We want to see 'Opus(path)' which points to a folder of OpusInput, OpusProcess and OpusEvent objects. This should allow fixed pieces, GUI and improv like interfaces. Uses Ctk as the main driver.
Opus will also store all info about a performance in a dated folder, and will act as a layer above Ctk objects
*/

Opus : CtkObj {
	classvar baseAudioRoutePath = "/audioRoute";
	classvar baseSynthPath = "/synths";
	classvar baseEventPath = "/events";
	classvar baseProcessPath = "/processes";
	classvar baseScorePath = "/scores";
	// contains the elements that init and kill every piece in a CtkPEvent list
	classvar baseMainPath = "/main.scd";
	classvar baseAudioInPath = "/audioIn.scd";
	classvar baseAudioOutPath = "/audioOut.scd";
	classvar baseInitPath = "/init";
	classvar baseInitModPath = "/init.scd";
	classvar baseKillModPath = "/kill.scd";

	var <path, basePath, <audioRoutePath, <synthPath, eventPath, <processesPath, <scoresPath, initPath,
	<audioInPath, <audioOutPath, <mainPath;
	// dictionaries that hold instances of OpusInput, OpusProcess and OpusEvent
	var <synths, synthNames, <processes, <scores, <events, <>mainFunc, <>pevents, <initModPath, <killModPath;
	var <>initMod, <>killMod, <id, <inputs, <outputs, <>onReadyFunc;
	var resourcesToFree;
	var <server, <data, <buffers, createIfMissing;

	*new {arg path, server = Server.default, createIfMissing = true;
		var newOpus;
		newOpus = super.new;
		newOpus.init(path, server, createIfMissing);
		^newOpus;
	}

	init {arg argPath, argServer, argCreateIfMissing = false;
		path = argPath;
		"Opus init".postln;
		createIfMissing = argCreateIfMissing;
		server = argServer;
		basePath = PathName(path);
		basePath.isFolder.not.if({
			("No folder was found at " ++ basePath.absolutePath).warn;
			createIfMissing.not.if({
				^nil;
			})
		});
		audioRoutePath = PathName(basePath.absolutePath ++ baseAudioRoutePath);
		synthPath = PathName(basePath.absolutePath ++ baseSynthPath);
		eventPath = PathName(basePath.absolutePath ++ baseEventPath);
		processesPath = PathName(basePath.absolutePath ++ baseProcessPath);
		scoresPath = PathName(basePath.absolutePath ++ baseScorePath);
		initPath = PathName(basePath.absolutePath ++ baseInitPath);
		initModPath = PathName(initPath.absolutePath ++ baseInitModPath);
		killModPath = PathName(initPath.absolutePath ++ baseKillModPath);
		mainPath = PathName(basePath.absolutePath ++ baseMainPath);
		audioInPath = PathName(audioRoutePath.absolutePath ++ baseAudioInPath);
		audioOutPath = PathName(audioRoutePath.absolutePath ++ baseAudioOutPath);
		synths = IdentityDictionary.new;
		processes = IdentityDictionary.new;
		synthNames = IdentityDictionary.new;
		events = IdentityDictionary.new;
		inputs = IdentityDictionary.new;
		outputs = IdentityDictionary.new;
		data = IdentityDictionary.new;
		buffers = IdentityDictionary.new;
		scores = IdentityDictionary.new;
		resourcesToFree = Array.new;
	}

	setup {
		server.boot;
		server.waitForBoot({
			this.prLoadFolders(createIfMissing);
			this.loadFiles;
			this.loadMain(mainPath, true);
			onReadyFunc.value(this);
		})
	}

	eventFromProcess {arg eventId, pmodKey ... args;
		var pmod = processes[pmodKey].value(this, *args);
		pmod.notNil.if({
			events[eventId] = pmod;
		});
		^pmod;
	}

	runMain {
		mainFunc.value(this);
	}

	openMain {
		Document.open(mainPath.absolutePath);
	}

	addResourcesToFree {arg ... args;
		resourcesToFree = resourcesToFree.addAll(args);
	}

	freeResources {
		resourcesToFree.do({arg thisResource;
			thisResource.free;
		});
	}

	addBufferForKey {arg buffer, key;
		buffers.add(key -> buffer);
	}

	bufferForKey {arg key;
		^buffers[key];
	}

	freeBufferForKey {arg buffer, key;
		buffers[key].free;
	}

	freeBuffers {
		buffers.keysValuesDo({arg key, value;
			value.free;
		});
		buffers.removeAll;
	}

	*initAtPath {arg path;
		var startHerePath, cmd, fileStr;
		("mkdir " ++ path).unixCmd;
		startHerePath = path ++ "/startHere.scd";
		fileStr = "(
s = Server.local;
s.options.memSize_(32768).numOutputBusChannels_(8).numInputBusChannels_(8);

// path to the directory where this file is
o = Opus(\"" ++ path ++ "\".standardizePath, server: s)
.onReadyFunc_({arg opus;
	opus.runMain;
});
)

// o.setup
";
		this.prCreateTemplateWithStringAtPath(name, startHerePath, fileStr, true);
	}

	copyToNewOpus {arg newBasePathName;
		("cp -r "++ path ++ " " ++ newBasePathName).unixCmd;
	}

	prLoadFolders {arg createIfMissing;
		if(createIfMissing){
			[basePath, audioRoutePath, synthPath, eventPath, processesPath, scoresPath, initPath].do({arg thisPath;
				var exists;
				exists = File.exists(thisPath.absolutePath);
				exists.not.if({
					("Creating folder at " ++ thisPath.absolutePath).warn;
					File.mkdir(thisPath.absolutePath, "rw");
				})
			});
		};
	}

	loadFiles {
		this.loadAudioRoutes(true);
		this.prLoadSynths;
		this.prLoadProcesses;
		this.prLoadScores;
		this.loadInitialProcesses;
		// this.prLoadEvents;
	}

	prLoadSynths {
		synthPath.filesDo({arg filePath;
			this.prLoadSynthsAtPath(filePath);

		});
	}

	prLoadProcesses {
		processesPath.filesDo({arg filePath;
			this.prLoadProcessAtPath(filePath);
		});
	}

	prLoadEvents {
		eventPath.filesDo({arg filePath;
			this.prLoadEventAtPath(filePath);
		});
	}

	prLoadScores {
		scoresPath.filesDo({arg filePath;
			this.prLoadScoreAtPath(filePath);
		});
	}

	loadEvents {
		this.prLoadEvents;
	}
	// returns a valid PathName if successful, nil if not
	*prCreateTemplateWithStringAtPath {arg name, filePath, fileStr, force = false;
		var file, pathName;
		force.not.if({
			var exists;
			exists = File.exists(filePath);
			exists.if({
				"The template you are trying to create at " ++ name ++ " exists. Please choose another name, or set the force argument to true".warn;
				^nil;
			})
		});
		file = File.new(filePath, "w");
		file.putString(fileStr);
		file.close;
		pathName = PathName(filePath);
		^pathName;
	}

	prCreateTemplateWithStringAtPath {arg name, filePath, fileStr, force = false;
		^Opus.prCreateTemplateWithStringAtPath(name, filePath, fileStr, force);
	}

}