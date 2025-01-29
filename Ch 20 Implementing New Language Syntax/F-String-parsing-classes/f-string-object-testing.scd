// f-string objects testing
c = CollStream("f\"abc = {abc}\"; xyz");
t = SCBookExpressionNode.new.parse(c);

t.children
t.children[1].dump

c = CollStream("f\"abc = {abc}, def = {def}\"; xyz");
t = SCBookExpressionNode.new.parse(c);
d = CollStream.new;
t.streamCode(d);
d.collection;

t.children
t.children[1].dump
t.children[1].children[0].dump


(
thisProcess.interpreter.preProcessor = { |str|
	var source = CollStream(str);
	var tree = SCBookExpressionNode.new.parse(source);
	var target = CollStream.new;
	tree.streamCode(target);
	target.collection
};
)


f"A random number = {1.0.rand}; and another = {2.0.rand}"


(
var convertFStrings = { |str|
	var source = CollStream(str);
	var tree = SCBookExpressionNode.new.parse(source);
	var target = CollStream.new;
	tree.streamCode(target);
	target.collection
};

c = "f\"abc = {abc}, def = {def}\"; xyz";
convertFStrings.(c).debug("basic case, 2 expressions");

c = "var abc = 10.rand; f\"abc = {abc ++ f\"nested string {xyz}\"}\".postln;";
convertFStrings.(c).debug("nested conversion");

c = "f\"random = {{ 1.0.rand \\}.value}\"";
convertFStrings.(c).debug("escaped braces");

c = "\"normal \\\"string\\\" ending with f\".postln";
convertFStrings.(c).debug("escaped \"quotes\" and closing f");

c = "'abcdef\"xyz'";
convertFStrings.(c).debug("weird symbol");

try {
	convertFStrings.("f\"{abcxyz\"")
} { |error|
	if(error.errorString.beginsWith("ERROR: open-ended f-string argument")) {
		"open-ended f-string argument detected OK".debug;
	} {
		error.throw;
	}
};

try {
	convertFStrings.("f\"{abc}xyz; 123")
} { |error|
	if(error.errorString.beginsWith("ERROR: open-ended f-string")) {
		"open-ended f-string detected OK".debug;
	} {
		error.throw;
	}
};
)



(
c = CollStream("(
var a = \"Testing regular string with trailing f\";
var b = $\\\";  // test char literal
var c = f\"Testing f string with one expression = {1.0.rand}\";

a ++ b ++ c
)");

t = SCBookExpressionNode.new.parse(c);
)

t.children
/*
-> [ (
var a = , a SCBookNormalStringNode, ;
var b = , a SCBookCharLiteralNode, ;  // test char literal
var c = , a SCBookFStringNode, ;

a ++ b ++ c
) ]
*/

t.children[1].dump  // delim = $", string dropped open quote (which I don't really like)

t.children[3].dump  // char OK, string drops open $

t.children[5].dump  // formatStr OK; string dropped open quote (which I don't really like)
t.children[5].string.postcs

t.children[5].children[0].dump  // FExprNode; string dropped opening {


d = CollStream.new; t.streamCode(d); d.collection.interpret




// tree expressions
"Random number = %".format(rrand(1, 5) * 2);

f"Hello, my name is {nameView.value}".postln;


t = SCBookExpressionNode.new.parse(CollStream("f\"Hello, my name is {nameView.value}\".postln;"));
t.children
t.children[1].children

(
var c = Complex(cos(2pi * 0.1), sin(2pi * 0.1));

10.do { |i|
	f"(c ** i) = {c ** i}".postln;
};

"And we're done"
)