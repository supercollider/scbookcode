# CTK
The Composer's Tool Kit
## Introduction
CTK - The Composer's Tool Kit - is a set of Object classes to aid specifically in the creation of fixed pieces through the use of a Score-like structure. To make general usage easier, the CTK Objects also support real-time control through the .play method. The objects included in the CTK are:

* CtkScore
* CtkSynthDef
* CtkProtoNotes
* CtkNote
* CtkBuffer
* CtkControl
* CtkAudio
* CtkEvent
* CtkGroup

The CTK Objects can be used as a replacement for the object oriented classes in the standard SuperCollider distribution (Synth, Buffer, Group, and Bus). The main difference is that these classes can easily be used to populate a CtkScore for non-real-time (NRT) synthesis.

CTK classes were originally developed by Josh Parmenter. Other contributors include Michael McCrea, Daniel Peterson, and Marcin Pączkowski.

### Disadvantages to the standard object classes:
* Since the classes can operate in both modes, CtkNotes (the CTK equivalent of a Synth) needs to be explicitly told to 'play'. Synthesis does not begin automatically.
* CtkNotes are prototyped according to an actual SynthDef, as a result some of the objects syntax is a little different. Arguments are passed to the CtkNote instance in a different way than Synth and may take some getting used to (though the syntax is more in line with the getter and setter methods of other SC objects... more below).
* To make these Objects as flexible as possible with other Ctk objects, the classes check for quite a bit internally. This of course adds some overhead to the language side of SuperCollider, though performance problems generally have not been noticed by the users.
### Advantages to the standard object classes:
* Very easy to use in both real-time and non-real-time mode.
* Arguments to instances of CtkNote are set through more traditional getter and setter methods. When a CtkNoteObject is created, methods are added to its instance that correspond with the Control parameters of a SynthDef (including array parameters).
* In real-time mode, the change of an argument's value will be reflected in the running synth.
* Better support for playing CtkScore in real-time. Instances of CtkBuffer will be allocated before the score is played, allowing for loading of large buffers before notes are played. CtkBuffers also de-allocate themselves after the CtkScore finishes playing.
