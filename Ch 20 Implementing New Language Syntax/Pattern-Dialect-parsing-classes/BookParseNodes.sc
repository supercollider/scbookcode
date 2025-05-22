SCBookAbstractPatternNode {
	// these variables are general to parsing
	var <>begin, <>end, <>string, <>parentNode, <>children;

	// these are specific to this chapter's handling of time
	var <>time, <>dur;

	*new { |parentNode|
		^super.new.init(parentNode)
	}

	init { |argParent|
		parentNode = argParent;
		children = Array.new;
	}

	parse { |stream|
		begin = stream.pos;

		this.doParse(stream);

		if(end.isNil) { end = stream.pos - 1 };
		if(string.isNil) {
			if(end >= begin) {
				string = stream.collection[begin .. end]
			} {
				string = String.new;
			};
		};
	}

	doParse { ^this.subclassResponsibility(thisMethod) }

	/*** code generation ***/

	streamCode { |stream| stream << string }

	setTime { |onset(0), argDur(4)|
		time = onset;
		dur = argDur;
	}
	isSpacer { ^false }
	lastNote { ^this }

	/*** utility method ***/
	/* may be useful for all subclasses */
	skipSpaces { |stream|
		var ch;
		while {
			ch = stream.next;
			ch.notNil and: { ch.isSpace }
		};
		if(ch.notNil) { stream.pos = stream.pos - 1 };
	}
}

SCBookNoteNode : SCBookAbstractPatternNode {
	var <>endTest;

	*new { |parentNode, endTest|
		^super.new.init(parentNode, endTest)
	}

	init { |parentNode, endTestFunc|
		super.init(parentNode);
		endTest = endTestFunc;
	}

	doParse { |stream|
		var str = String.new, ch;
		if(endTest.isNil) { endTest = { |ch| ch == $\" } };
		while {
			ch = stream.next;
			ch.notNil and: { endTest.value(ch).not }
		} {
			str = str.add(ch);
		};
		if(ch.notNil) { stream.rewind(1) };
	}
	symbol { ^string.asSymbol }
	setTime { |onset, argDur, remainder|
		time = onset;
		dur = argDur + remainder
	}
	streamCode { |stream|
		stream << "(id: " <<< this.symbol
		<< ", time: " << time
		<< ", dur: " << dur
		<< ")"
	}
	isSpacer { ^string.every(_ == $.) }
}

SCBookNumberNode : SCBookAbstractPatternNode {
	// does *not* skip the first digit!
	doParse { |stream|
		var str = String.new, ch;
		while {
			ch = stream.next;
			ch.notNil and: { ch.isDecDigit or: { "*/".includes(ch) } }
		} {
			str = str.add(ch);
		};
		if(ch.notNil) { stream.rewind(1) };
	}
	streamCode { |stream|
		stream << string
	}
}

SCBookSpacerNode : SCBookNoteNode {
	doParse { |stream|
		endTest = { |ch| ch != $. };
		// "skipped delimiter" but there is no delimiter
		stream.rewind(1);
		begin = begin - 1;
		super.doParse(stream);
	}
	setTime { |onset, argDur, remainder|
		super.setTime(onset, argDur, remainder);
		^this.dur  // tell upstream that this contributes to remainder
	}
	streamCode {}
	isSpacer { ^true }
}

SCBookBracketNode : SCBookAbstractPatternNode {
	var <>isTopLevel = true;

	// likewise assumes you've skipped the opening bracket
	doParse { |stream|
		var ch;
		var child;

		while {
			ch = stream.next;
			ch.notNil and: { ch != $] }
		} {
			case

			// recursive case: bracket within bracket
			// the inner bracket group's 'parent' is 'this'!
			{ ch == $[ } {
				child = SCBookBracketNode(this)
				.isTopLevel_(false);
				children = children.add(child);
				child.parse(stream);
			}
			{ ch.isAlphaNum } {
				stream.rewind(1);  // undo 'next' in the while check
				child = SCBookNoteNode(this,
					endTest: { |ch| ch.isAlphaNum.not }
				);
				children = children.add(child);
				child.parse(stream);
			}
			{ ch == $. } {
				child = SCBookSpacerNode(this);
				children = children.add(child);
				child.parse(stream);
			}
			{ ch.isSpace } {
				0  // just keep going
			}

			// default case is unrecognized = syntax error
			{ Error("Unrecognized item in bracket group").throw };
		};
		// reached end before terminating
		if(ch.notNil) {
			// should also include opening bracket
			begin = begin - 1;
		} {
			Error("Unclosed opening bracket").throw;
		};
	}

	childDur { |argDur|
		^(dur ?? { argDur }) / children.size
	}

	lastNote {
		// traverse down the rightmost branch of the tree
		// other node types just return 'this' = non-recursive branch
		^children.last.lastNote
	}

	// break the interface: setTime returns initial rest duration
	setTime { |onset, argDur, remainder(0)|
		var nextSib, lastNote;
		var childDur = argDur / children.size;
		time = onset;
		dur = argDur;
		children.reverseDo { |child, i|
			var j = children.size - 1 - i;
			var childOnset = childDur * j + onset;
			var dur = childDur;

			remainder = child.setTime(childOnset, childDur, remainder);
			if(remainder.isNumber.not) {
				remainder = 0;
			};
			nextSib = child;
		};
		^remainder
	}

	streamCode { |stream|
		var needComma = false;
		var firstNonSpacer = children.detect { |child| child.isSpacer.not };
		var restTime;
		if(children.notEmpty) {
			stream << "Pseq([";
			if(isTopLevel and: { children.first.isSpacer }) {
				if(firstNonSpacer.notNil) {
					restTime = firstNonSpacer.time;
				} {
					restTime = dur;
				};
				stream << "(id: Rest(0), time: 0.0, dur: "
				<< restTime << ")";
				needComma = true;
			};
			children.do { |child|
				if(child.isSpacer.not) {
					if(needComma) {
						stream << ", ";
					};
					child.streamCode(stream);
					needComma = true;
				};
			};
			stream << "], 1)";
		};
	}
}

SCBookPatternNode : SCBookAbstractPatternNode {
	var <beatsPerBar, <notes;

	doParse { |stream|
		var child;
		var ch;

		this.skipSpaces(stream);

		if(stream.peek.isDecDigit) {
			child = SCBookNumberNode(this);
			children = children.add(child);
			child.parse(stream);
			beatsPerBar = child.string.interpret;
		} {
			beatsPerBar = TempoClock.beatsPerBar;
		};

		this.skipSpaces(stream);

		ch = stream.next;
		if(ch == $[) {
			notes = SCBookBracketNode(this);
			children = children.add(notes);
			notes.parse(stream);
		} {
			Error("Improper opening delimiter for bracket group").throw;
		}
	}

	setTime { |onset(0)|
		notes.setTime(onset, beatsPerBar)
	}

	streamCode { |stream|
		notes.streamCode(stream)
	}
}
