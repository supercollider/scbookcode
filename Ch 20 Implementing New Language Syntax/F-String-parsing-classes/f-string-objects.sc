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

	/*** code generation ***/

	streamCode { |stream| stream << string }

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

SCBookExpressionNode : SCBookAbstractParseNode {
	doParse { |stream|
		var ch;
		var new;
		var str = String.new;
		while {
			ch = stream.next;
			ch.notNil
		} {
			switch(ch)
			{ $f } {
				ch = stream.next;
				if(ch == $") {
					new = SCBookFStringNode(this).parse(stream);
					children = children.add(str).add(new);
					str = String.new;
				} {
					str = str ++ $f ++ ch;
				};
			}
			{ $$ } {
				new = SCBookCharLiteralNode(this).parse(stream);
				children = children.add(str).add(new);
				str = String.new;
			}
			{ $" } {
				new = SCBookNormalStringNode(this).parse(stream);
				children = children.add(str).add(new);
				str = String.new;
			}
			{ $' } {
				new = SCBookNormalStringNode(this).parse(stream);
				children = children.add(str).add(new);
				str = String.new;
			} {
				str = str ++ ch;
			};
		};
		children = children.add(str);  // trailing characters
	}

	streamCode { |stream|
		children.do { |child, i|
			child.streamCode(stream)
		};
	}
}

SCBookFExprNode : SCBookAbstractParseNode {
	doParse { |stream|
		var ch;
		var new;
		var str = String.new;
		begin = begin - 1;  // preserve opening bracket in 'string'
		while {
			ch = stream.next;
			ch.notNil and: { ch != $} }
		} {
			switch(ch)
			{ $\\ } {
				str = str ++ stream.next;  // drop escape \
			}
			{ $f } {
				ch = stream.next;
				if(ch == $") {
					new = SCBookFStringNode(this).parse(stream);
					children = children.add(str).add(new);
					str = String.new;
				} {
					str = str ++ $f;
					stream.rewind(1);  // might be closing brace
				};
			}
			{
				str = str ++ ch;
			}
		};
		if(ch.isNil) {
			Error("open-ended f-string argument at "
				++ stream.collection[begin .. begin + 10]
			).throw;
		};
		children = children.add(str);  // trailing characters
	}

	streamCode { |stream|
		children.do { |child|
			child.streamCode(stream)
		}
	}
}

SCBookFStringNode : SCBookAbstractParseNode {
	var formatStr;
	doParse { |stream|
		var ch, new;
		formatStr = String.new;
		begin = begin - 1;  // preserve opening quote in 'string'
		while {
			ch = stream.next;
			ch.notNil and: { ch != $" }
		} {
			switch(ch)
			{ $\\ } {
				formatStr = formatStr ++ ch ++ stream.next;
			}
			{ ${ } {
				formatStr = formatStr ++ "%";
				new = SCBookFExprNode(this).parse(stream);
				children = children.add(new);
			}
			{ formatStr = formatStr ++ ch };
		};
		if(ch.isNil) {
			Error("open-ended f-string at "
				++ stream.collection[begin .. begin + 10]
			).throw;
		};
	}

	streamCode { |stream|
		stream <<< formatStr;
		if(children.size > 0) {
			stream << ".format(";
			children.do { |child, i|
				if(i > 0) { stream << ", " };
				child.streamCode(stream);
			};
			stream << ")";
		};
	}
}

SCBookNormalStringNode : SCBookAbstractParseNode {
	var delimiter;
	doParse { |stream|
		var ch;
		begin = begin - 1;  // preserve opening quote in 'string'
		delimiter = stream.collection[begin /*stream.pos - 1*/];
		while {
			ch = stream.next;
			ch.notNil and: { ch != delimiter }
		} {
			if(ch == $\\) {
				ch = stream.next;
			};
		};
	}
	// streamCode: inherited
}

SCBookCharLiteralNode : SCBookAbstractParseNode {
	var char;
	doParse { |stream|
		var ch;
		begin = begin - 1;  // preserve opening $ in 'string'
		ch = stream.next;
		if(ch == $\\) {
			ch = stream.next;
		};
		char = ch;
	}
	streamCode { |stream|
		stream <<< char
	}
}

// streamCode compatibility
+ String {
	streamCode { |stream|
		stream << this
	}
}
