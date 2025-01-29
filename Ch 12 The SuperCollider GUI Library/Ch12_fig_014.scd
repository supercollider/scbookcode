// figure 12.14

(
var slider, spec;
spec = ControlSpec.new(0, 16383, \lin);
MIDIIn.connectAll;
MIDIdef.bend(\pitchbend, { |bendval|
	{ slider.valueAction_(spec.unmap(bendval)) }.defer;
});

slider = Slider()
	.acceptsMouse_(false) // user can't change; for display only
	.value_(0.5)
	.action_({ |v| v.value.postln; });

w = Window.new("MIDI pitch bend", Rect(100,100,200,400))
.onClose_({ MIDIdef(\pitchbend).free })
.layout_(HLayout(slider))
.front;
)

MIDIIn.doBendAction(1, 0, 100); // spoof a pitch bend message