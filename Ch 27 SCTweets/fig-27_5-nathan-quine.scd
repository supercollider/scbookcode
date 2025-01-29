interpret(x="/******/play{RLPF.ar(COsc.ar(b=Buffer.loadCollection(s,x.ascii.normalize(-1,1)),Osc.kr(b,1,0,65,35)),Osc.kr(b,0.1,0,300,1e3))/5}")

// 1 - regular indetation, functional/receiver notation changes
(
x="/******/play{RLPF.ar(COsc.ar(b=Buffer.loadCollection(s,x.ascii.normalize(-1,1)),Osc.kr(b,1,0,65,35)),Osc.kr(b,0.1,0,300,1e3))/5}";
{
	RLPF.ar(
		COsc.ar(
			b=Buffer.loadCollection(s,x.ascii.normalize(-1,1)),
			Osc.kr(b,1,0,65,35)
		),
		Osc.kr(b,0.1,0,300,1e3)
	)/5
}.play;
)


// 3 - explicit argument show up
(
x="/******/play{RLPF.ar(COsc.ar(b=Buffer.loadCollection(s,x.ascii.normalize(-1,1)),Osc.kr(b,1,0,65,35)),Osc.kr(b,0.1,0,300,1e3))/5}";
{
	RLPF.ar(
		in: COsc.ar(
			bufnum: Buffer.loadCollection(s,x.ascii.normalize(-1,1)),
			freq: Osc.kr(
				bufnum: Buffer.loadCollection(s,x.ascii.normalize(-1,1)),
				freq: 1, phase: 0, mul: 65, add: 35
			)
		),
		freq: Osc.kr(
			bufnum: Buffer.loadCollection(s,x.ascii.normalize(-1,1)),
			freq: 0.1,phase: 0,mul: 300,add: 1e3
		)
	)/5
}.play;
)
