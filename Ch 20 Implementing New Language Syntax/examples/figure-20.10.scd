(
this.preProcessor = { |str|
	var source = CollStream(str);
	var tree = SCBookExpressionNode.new.parse(source);
	var target = CollStream.new;
	tree.streamCode(target);
	target.collection
};
)
