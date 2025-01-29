play{ar(r=RLPF,Saw.ar([200,302]).mean,5**(n={LFNoise1.kr(1/8)})*1e3,0.6)+r.ar(Saw ar:Amplitude.kr(3**n*3e3*InFeedback.ar(0)+1,4,4),1e3)/5!2}

// 1 - regular indentation
(
{
	ar(
		r=RLPF,
		Saw.ar([200,302]).mean,5**(n={LFNoise1.kr(1/8)})*1e3,
		0.6
	)
	+r.ar(
		Saw ar:Amplitude.kr(3**n*3e3*InFeedback.ar(0)+1,4,4),
		1e3
	)/5!2
}.play;
)

// 2 - seperate variable definitions, functional/receiver notation changes
(
{
	r=RLPF;
	n={LFNoise1.kr(1/8)};
	r.ar(
		Saw.ar([200,302]).mean,
		5**n*1e3,
		0.6
	)
	+r.ar(
		Saw.ar(
			Amplitude.kr(
				3**n*3e3*InFeedback.ar(0)+1,
				4,
				4)
		),
		1e3
	)/5!2
}.play;
)

// 3 - convert to keyword argument style
(
{
	RLPF.ar(
		in: Saw.ar(freq:[200,302]).mean,
		freq: 5**(LFNoise1.kr(1/8))*1e3,
		rq: 0.6
	)
	+RLPF.ar(
		in: Saw.ar(
		 freq: Amplitude.kr(
				in: 3**LFNoise1.kr(1/8)*3e3*InFeedback.ar(0)+1,
				attackTime: 4,
				releaseTime: 4)
		),
		freq: 1e3
	)/5!2
}.play;
)