fig-xx-olofsson-recursive-tweet0011-expansion

//--tweet0011
play{f={|o,i|if(i>0,{SinOsc.ar([i,i+1e-4]**2*f.(o,i-1),f.(o,i-1)*1e-4,f.(o,i-1))},o)};f.(60,6)/60}//#SuperCollider

// 1 - regular indetation, explicit argument show up
play{
	f={|o,i|
		if(i>0,
			{SinOsc.ar(
				freq: [i,i+1e-4]**2*f.(o,i-1),
				phase: f.(o,i-1)*1e-4,
				mul: f.(o,i-1))
			},
			{o}
		)
	};
	f.(60,6)/60
}