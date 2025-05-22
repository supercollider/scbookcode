

/* Figure 1 */
o = Complementary_Grundgestalt.new;
[o.arrayAt(\201), o.arrayAt(\012), o.arrayAt(\021), o.arrayAt(\021)].flat;
/* End Figure 1 */
/* Figure 2 */
o = Complementary_Grundgestalt.new;
p = Complementary_Grundgestalt.new(o.a.keynum - 9);
/* End Figure 2 */
/* Figure 3 */
s = Server.local
s.boot;
(
~baseDur = 0.125;

//  E N T E R  T H E  D A T A  //

o = Complementary_Grundgestalt.new;

k = [
		[o.arrayAt(\201), o.arrayAt(\012), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\201), o.arrayAt(\102), o.arrayAt(\012), o.arrayAt(\120)],
		[o.arrayAt(\210), o.arrayAt(\201), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\012), o.arrayAt(\102), o.arrayAt(\102), o.arrayAt(\021)],

		[o.arrayAt(\201), o.arrayAt(\012), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\201), o.arrayAt(\102), o.arrayAt(\012), o.arrayAt(\120)],
		[o.arrayAt(\210), o.arrayAt(\201), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\012), o.arrayAt(\102), o.arrayAt(\102), o.arrayAt(\021)],

		[o.arrayAt(\201), o.arrayAt(\102), o.arrayAt(\012), o.arrayAt(\120)],
		[o.arrayAt(\012), o.arrayAt(\102), o.arrayAt(\102), o.arrayAt(\021)]
	].flat;

//  P R O C E S S  T H E  D A T A  //

t = Complementary_Intro_Data.new(k, ~baseDur);


//  B U I L D  A  S C O R E  //

//Complementary_Intro_Part takes a starttime, a Complementary_Intro_Data object (t),
// and an Env for the glabal dynamics. Additionally we can pass a Server object
~firstVoice = Complementary_Intro_Part.new(0.0, t,
	Env.new([0, 0.707, 0.0125], [0.01, k.size * ~baseDur], [1, -4]), server: s);

//  P L A Y  T H E  R E S U L T  //
~firstVoice.score.play;
)
/* End Figure 3 */
/* Figure 4 */
s = Server.local
s.boot;
(
~baseDur = 0.125;

~time = NRT_TimeFrame.new(starttime: {arg total, curr, dur; ((total - curr) * dur);});

///////////////////////////////////////////
//                                       //
//       E N T E R  T H E  D A T A       //
//                                       //
///////////////////////////////////////////

//FIRST VOICE
o = Complementary_Grundgestalt.new;

k = [
		[o.arrayAt(\201), o.arrayAt(\012), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\201), o.arrayAt(\102), o.arrayAt(\012), o.arrayAt(\120)],
		[o.arrayAt(\210), o.arrayAt(\201), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\012), o.arrayAt(\102), o.arrayAt(\102), o.arrayAt(\021)],

		[o.arrayAt(\201), o.arrayAt(\012), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\201), o.arrayAt(\102), o.arrayAt(\012), o.arrayAt(\120)],
		[o.arrayAt(\210), o.arrayAt(\201), o.arrayAt(\021), o.arrayAt(\021)],
		[o.arrayAt(\012), o.arrayAt(\102), o.arrayAt(\102), o.arrayAt(\021)],

		[o.arrayAt(\201), o.arrayAt(\102), o.arrayAt(\012), o.arrayAt(\120)],
		[o.arrayAt(\012), o.arrayAt(\102), o.arrayAt(\102), o.arrayAt(\021)],
		[o.arrayAt(\201), o.arrayAt(\012), o.a, o.b]
	].flat;

//SECOND VOICE
p = Complementary_Grundgestalt.new(o.a.keynum - 9);

l = [
		[p.c, p.a,],
		[p.arrayAt(\201), p.arrayAt(\102), p.arrayAt(\021), p.arrayAt(\201)],
		[p.arrayAt(\201), p.arrayAt(\201), p.arrayAt(\012), p.arrayAt(\021)],
		[p.arrayAt(\201), p.arrayAt(\201), p.arrayAt(\102), p.arrayAt(\021)],

		[p.arrayAt(\012), p.arrayAt(\012), p.arrayAt(\120), p.arrayAt(\120)],
		[p.arrayAt(\201), p.arrayAt(\102), p.arrayAt(\021), p.arrayAt(\201)],
		[p.arrayAt(\201), p.arrayAt(\201), p.arrayAt(\102), p.arrayAt(\021)],
		[p.arrayAt(\012), p.arrayAt(\012), p.arrayAt(\021), p.arrayAt(\201)],

		[p.arrayAt(\201), p.arrayAt(\201), p.arrayAt(\012), p.arrayAt(\021)],
		[p.c, p.a]
	].flat;

//THIRD VOICE
q = Complementary_Grundgestalt.new(p.a.keynum - 9);

m = [
		[q.arrayAt(\012), q.arrayAt(\012)],
		[q.arrayAt(\201), q.arrayAt(\021), q.arrayAt(\012), q.arrayAt(\201)],
		[q.arrayAt(\201), q.arrayAt(\201), q.arrayAt(\021), q.arrayAt(\012)],
		[q.arrayAt(\021), q.arrayAt(\201), q.arrayAt(\201), q.arrayAt(\021)],
		[q.arrayAt(\201), q.arrayAt(\021), q.arrayAt(\012), q.arrayAt(\201)],

		[q.arrayAt(\021), q.arrayAt(\012), q.arrayAt(\201), q.arrayAt(\021)],
		[q.arrayAt(\120), q.arrayAt(\201), q.a, q.b]
	].flat;

//FOURTH VOICE
r = Complementary_Grundgestalt.new(q.a.keynum - 9);

n = [
		[r.arrayAt(\021), r.arrayAt(\120), r.arrayAt(\012), r.arrayAt(\201)],
		[r.arrayAt(\201), r.arrayAt(\012), r.arrayAt(\201), r.arrayAt(\012)],
		[r.arrayAt(\021), r.arrayAt(\201), r.arrayAt(\102), r.arrayAt(\012)],

		[r.arrayAt(\021), r.arrayAt(\120), r.arrayAt(\012), r.arrayAt(\210)],
		[r.arrayAt(\021), r.arrayAt(\201), r.arrayAt(\102), r.arrayAt(\012)],
		[r.arrayAt(\021), r.arrayAt(\201)]
	].flat;

///////////////////////////////////////////
//                                       //
//     P R O C E S S  T H E  D A T A     //
//                                       //
///////////////////////////////////////////


//FIRST VOICE
t = Complementary_Intro_Data.new(k, ~baseDur);

//SECOND VOICE
u = Complementary_Intro_Data.new(l, ~baseDur);

//THIRD VOICE
v = Complementary_Intro_Data.new(m, ~baseDur);

//FOURTH VOICE
w = Complementary_Intro_Data.new(n, ~baseDur);

//////////////////////////////////////////
//                                      //
//      B U I L D  T H E  S C O R E     //
//                                      //
//////////////////////////////////////////

// BUILD  THE  PARTS //
~firstVoice  = Complementary_Intro_Part.new(~time.starttime(k.size, k.size, ~baseDur), t,
	Env.new([0, 0.707, 0.0125], [0.01, k.size * ~baseDur], [1, -4]), server: s);

~secondVoice = Complementary_Intro_Part.new(~time.starttime(k.size, l.size, ~baseDur), u,
	Env.new([0, 0.707, 0.0125], [0.01, l.size * ~baseDur], [1, -4]), server: s);

~thirdVoice  = Complementary_Intro_Part.new(~time.starttime(k.size, m.size, ~baseDur), v,
	Env.new([0, 0.707, 0.0125], [0.01, m.size * ~baseDur], [1, -4]), server: s);

~fourthVoice = Complementary_Intro_Part.new(~time.starttime(k.size, n.size, ~baseDur), w,
	Env.new([0, 0.707, 0.0125], [0.01, n.size * ~baseDur], [1, -4]), server: s);

// ADD  THE  PARTS  TO  A  SCORE //
//  take advantage of the fact that we can add CtkScores to a CtkScore


CtkScore.new(~firstVoice.score, ~secondVoice.score, ~thirdVoice.score, ~fourthVoice.score).play;
)


/* End Figure 4 */
