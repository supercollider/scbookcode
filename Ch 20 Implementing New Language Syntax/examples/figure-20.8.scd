SCBookAbstractParseNode {
	// these variables are general to parsing
	var <>begin, <>end, <>string, <>parentNode, <>children;

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

	/*** code generation template ***/

	streamCode { |stream| stream << string }

	/*** utility method ***/
	/* may be useful for all subclasses */
	/* maybe delete this in the printed text */
	skipSpaces { |stream|
		var ch;
		while {
			ch = stream.next;
			ch.notNil and: { ch.isSpace }
		};
		if(ch.notNil) { stream.rewind(1) };
	}
}
