#include "SC_PlugIn.h"

static InterfaceTable *ft;

// The struct will hold the state of our plugin.
// It is first initialized in the constructor function and then accessed
// and possible mutated in every call to the call function.
struct Flanger : public Unit {
    // it is a convention to use some kind of prefix (or postfix)
    // to distinguish member variables from local variables
    float mRate;
    float mDelaysize;
    float mAdvance;
    float mReadpos;
    int mWritepos;
};

// forward declaration
void Flanger_next(Flanger *unit, int inNumSamples);

void Flanger_Ctor(Flanger *unit) {
    // Here we must initialise *all* state variables in our Flanger struct.
    unit->mDelaysize = SAMPLERATE * 0.02f; // Fixed 20ms max delay
    float rate  = IN0(1); // initial rate
	// Rather than using rate directly, we're going to calculate the size of 
	// jumps we must make each time to scan through the delayline at "rate"
    float delta = (unit->mDelaysize * rate) / SAMPLERATE;
    unit->mAdvance = delta + 1.0f;
    unit->mRate  = rate;
    unit->mWritepos = 0;
    unit->mReadpos = 0;
	
	// IMPORTANT: This tells scsynth the name of the calculation function for this UGen.
	SETCALC(Flanger_next);
	
	// Should also calc 1 sample's worth of output - ensures each ugen's "pipes" are "primed"
	Flanger_next(unit, 1);

    // store them back
    unit->mRate = rate;
    unit->mAdvance = advance;
    unit->mWritepos = writepos;
    unit->mReadpos = readpos;
}

void Flanger_next(Flanger *unit, int inNumSamples) {
	float *in = IN(0);
	float *out = OUT(0);	

    // "rate" and "depth" can be modulated at control rate
    float currate = IN0(1);
    float depth = IN0(2);
	
    float rate = unit->mRate;
    float delaysize = unit->mDelaysize;
    float advancce = unit->mAdvance;
    float readpos = unit->mReadpos;
    int writepos = unit->mWritepos;
	
    for (int i = 0; i < inNumSamples; ++i) {
        float val = in[i];
		
		// Do something to the signal before outputting
		// (not yet done)
		
		out[i] = val;
    }
}	


PluginLoad(InterfaceTable *inTable) {
	ft = inTable;
	
	DefineSimpleUnit(Flanger);
}
