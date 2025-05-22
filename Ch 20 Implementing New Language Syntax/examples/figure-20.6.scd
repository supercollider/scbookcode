(
var convertFStrings = this.preProcessor;

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
