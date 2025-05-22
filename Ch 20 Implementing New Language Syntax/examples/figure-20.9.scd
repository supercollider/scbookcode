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
