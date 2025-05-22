f(o,i) = SinOsc.ar(freq: [i,i+1e-4]**2*f.(o,i-1), phase: f.(o,i-1)*1e-4, mul: f.(o,i-1))

i = 60, f(6,60):
SinOsc.ar(freq: [60,60+1e-4]**2*f.(6,59), phase: f.(6,59)*1e-4, mul: f.(6,59))

i = 59, f(6,59):
SinOsc.ar(freq: [59,59+1e-4]**2*f.(6,58), phase: f.(6,58)*1e-4, mul: f.(6,58))
...
...
...
i = 3, f(6,3):
SinOsc.ar(freq: [3,3+1e-4]**2*f.(6,2), phase: f.(6,2)*1e-4, mul: f.(6,2))

i = 2, f(6,2):
SinOsc.ar(freq: [2,2+1e-4]**2*f.(6,1), phase: f.(6,1)*1e-4, mul: f.(6,1))

i = 1, f(6,1):
SinOsc.ar(freq: [1,1+1e-4]**2*f.(6,0), phase: f.(6,0)*1e-4, mul: f.(6,0))

i = 0 -> i>0 == false
f(6,0) == o == 6.
terminnating scenario.

then we proceed to solving each high order recursive step :

i = 1, f(6,1):
SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6)

i = 2, f(6,2):
SinOsc.ar(freq: [2,2+1e-4]**2*SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6), phase: SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6)*1e-4, mul: f.(6,1))

i = 3, f(6,3):
SinOsc.ar(freq: [3,3+1e-4]**2*SinOsc.ar(freq: [2,2+1e-4]**2*SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6), phase: SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6)*1e-4, mul: f.(6,1)), phase: f.(6,2)*1e-4, mul: SinOsc.ar(freq: [2,2+1e-4]**2*SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6), phase: SinOsc.ar(freq: [1,1+1e-4]**2*6, phase: 6*1e-4, mul: 6)*1e-4, mul: f.(6,1)))
...
...
...