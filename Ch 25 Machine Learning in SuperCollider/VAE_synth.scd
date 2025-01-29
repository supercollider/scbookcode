(
n = NetAddr("127.0.0.1", 57120); // local machine
~magbus = Bus.control(s, 512);
SynthDef(\vaesynth, {
	var in, chain;
	SendReply.kr(Impulse.kr(20), '/mouse', [MouseX.kr(-2,2), MouseY.kr(-2,2)]);
	in = WhiteNoise.ar(0.8);
	chain = FFT(LocalBuf(1024), in); // encode to frequency domain
	chain = chain.pvcalc(512, {|mags, phases|
		[~magbus.kr, phases].flop.clump(2).flop.flatten
	}, tobin: 512);
	Out.ar(0,IFFT(chain)!2); // decode to time domain
}).add;
)

(
~vaesynth = Synth(\vaesynth);
)


(

OSCdef(\vaeReceiver, {|msg, time, addr, recvport|
	msg[1..].postln;
	~magbus.setn(msg[1..] * 4000); //scale up values
}, '/spec');

OSCdef(\trigReceive, {|msg, time, addr, recvport|
	var mousex, mousey;
	var vaeServer = NetAddr("127.0.0.1", 57030); // loopback
	mousex = msg[3];
	mousey = msg[4];
	// [mousex,mousey].postln;
	vaeServer.sendMsg("/vae", mousex, mousey);

}, '/mouse', s.addr);

)
