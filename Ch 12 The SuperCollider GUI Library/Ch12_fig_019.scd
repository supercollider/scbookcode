// figure 12.19

s.boot;

(
~env = Env([0, 1, 0], [0.5, 0.5], \lin);
~timeSpec = ControlSpec(0.001, 1, \lin); // avoid zero-duration env segments
~envView = EnvelopeView().setEnv(~env)
.keepHorizontalOrder_(true) // prevent points from crossing one another
.setEditable(0, false).setEditable(2, false) // only the middle point is editable
.action_({ |v|
	~env.levels_([ 0, v.value[1][1], 0 ]);
	~env.times_([ v.value[0][1], 1 - v.value[0][1] ]);
	~env.changed; // broadcast change to dependants
});

~envSliders = [
	Slider().value_(0.5),
	Slider().value_(1),
	Slider().value_(0.5)
].do({ |v|
	v.action_({
		defer{ // update data
			~env.levels_([0, ~envSliders[1].value, 0]);
			~env.times_([
				~timeSpec.map(~envSliders[0].value),
				~timeSpec.map(~envSliders[2].value)
			].normalizeSum);
		};
		~env.changed; // broadcast change to dependants
	});
});

w = Window.new("envelope GUI", Rect(100, 100, 300, 400))
.layout_(VLayout(
	~envView,
	HLayout(~envSliders[0], ~envSliders[1], ~envSliders[2]),
	HLayout(
		StaticText().string_("attack").align_(\center),
		StaticText().string_("peak level").align_(\center),
		StaticText().string_("release").align_(\center)
	)
))
.onClose_({ ~env.removeDependant(~update); r.stop; }) // cleanup
.front;

~update = { |env|
	defer{
		~envView.setEnv(env);
		~envSliders[0].value_(~timeSpec.unmap(env.times[0]));
		~envSliders[1].value_(env.levels[1]);
		~envSliders[2].value_(~timeSpec.unmap(env.times[1]));
	};
};

~env.addDependant(~update);

r = Routine({
	loop{
		{ SinOsc.ar([300, 310]) * ~env.kr(2) * 0.2 }.play(fadeTime:0);
		1.wait;
	};
}).play;
)