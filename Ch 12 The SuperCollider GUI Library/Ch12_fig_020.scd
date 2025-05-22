// figure 12.20

(
~data = 0.5;
~dataSim = Routine({
	inf.do({ |n|
		~data = sin(n * 0.01).linlin(-1,1,0.2,0.8) + rrand(-0.02, 0.02);
		(1/120).wait; // 120 data values per second
	});
}).play;

~slider = Slider().value_(~data).enabled_(false);
w = Window.new("SkipJack", Rect(100, 100, 150, 500))
.layout_(VLayout(~slider))
.onClose_({ ~dataSim.stop; ~sj.stop; })
.front;

~sj = SkipJack({ ~slider.value_(~data) }, 0.2);
)

w.close; // also stops the Routine and SkipJack