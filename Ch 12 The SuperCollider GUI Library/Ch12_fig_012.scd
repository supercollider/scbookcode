// figure 12.12

(
~sliders = View()
.background_(Color.rand)
.layout_(HLayout(
	Slider(), Slider(), Slider(), Slider()
));
~buttons = View()
.background_(Color.rand)
.layout_(HLayout(
	Button(), Button(), Button(), Button()
));
~knobs = View()
.background_(Color.rand)
.layout_(HLayout(
	Knob(), Knob(), Knob(), Knob()
));

~mainView = View()
.background_(Color.gray(0.5))
.layout_(VLayout(~buttons, ~sliders, ~knobs));

w = Window.new("hierarchical views", Rect(100,100,300,400))
.layout_(VLayout(~mainView))
.front;
)