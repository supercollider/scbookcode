#include "SC_PlugIn.h"

static InterfaceTable *ft;

// The struct will hold the state of our plugin.
// It is first initialized in the constructor function and then accessed
// and possible mutated in every call to the call function.
struct Flanger : public Unit  {
    // it is a convention to use some kind of prefix (or postfix)
    // to distinguish member variables from local variables
    float mModRate;
    float mDelaysize;
    float mAdvance;
    float mReadpos;
    int mWritepos;
    // a pointer to the memory we'll use for our internal delay
    float *mDelayline;
};

// forward declaration
void Flanger_next(Flanger *unit, int inNumSamples);

void Flanger_Ctor(Flanger *unit) {
    // Here we must initialise *all* state variables in our Flanger struct.
    unit->mDelaysize = SAMPLERATE * 0.02f; // Fixed 20ms max delay
    float rate = IN0(1); // initial rate
    // Rather than using rate directly, we're going to calculate the size of
    // jumps we must make each time to scan through the delayline at "rate"
    unit->mAdvance = ((unit->mDelaysize * rate) / SAMPLERATE) + 1.0f;
    unit->mModRate = rate;
    unit->mWritepos = 0;
    unit->mReadpos = 0;

    // Allocate the delay line
    unit->mDelayline = (float*)RTAlloc(unit->mWorld, (int)unit->mDelaysize * sizeof(float));
    // Check the result of RTAlloc because it can fail if the RT pool is too small!
    ClearUnitIfMemFailed(unit->mDelayline);
    // Set the delay line to zeros.
    memset(unit->mDelayline, 0, unit->mDelaysize * sizeof(float));

    // IMPORTANT: This tells scsynth the name of the calculation function for this UGen.
    SETCALC(Flanger_next);

    // Should also calc 1 sample's worth of output - ensures each ugen's "pipes" are "primed"
    Flanger_next(unit, 1);
}

void Flanger_next(Flanger *unit, int inNumSamples) {
    float *in = IN(0);
    float *out = OUT(0);

    // "rate" and "depth" can be modulated at control rate
    float currate = IN0(1);
    float depth = IN0(2);

    // The compiler doesn't know that "out" can't possibly point
    // to one of our members, so it would have to reload them from
    // memory on every loop iteration. To prevent this from happening,
    // we temporarily store them in local variables.
    float rate = unit->mModRate;
    float advance = unit->mAdvance;
    float readpos = unit->mReadpos;
    int writepos = unit->mWritepos;
    const float delaysize = unit->mDelaysize; // this one is fixed
    float *delayline = unit->mDelayline;

    if (rate != currate) {
        // rate input needs updating
        rate = currate;
        advance = ((delaysize * rate) / SAMPLERATE) + 1.0f;
    }

    for (int i = 0; i < inNumSamples; ++i) {
        float val = in[i];

        // Write to the delay line
        delayline[writepos++] = val;
        if(writepos == delaysize)
            writepos = 0;

        // Read from the delay line
        float delayed = delayline[(int)readpos];
        readpos += advance;
        // Update position, NB we may be moving forwards or backwards (depending on input)
        while(readpos >= delaysize)
            readpos -= delaysize;
        while(readpos < 0)
            readpos += delaysize;

        // Mix dry and wet together, and output them
        out[i] = val + (delayed * depth);
    }

    // store them back
    unit->mModRate = rate;
    unit->mAdvance = advance;
    unit->mWritepos = writepos;
    unit->mReadpos = readpos;
}

void Flanger_Dtor(Flanger *unit) {
    // NB: it's ok to pass NULL to RTFree()
    RTFree(unit->mWorld, unit->mDelayline);
}

PluginLoad(InterfaceTable *inTable) {
    ft = inTable;

    // our Unit has a destructor!
    DefineDtorUnit(Flanger);
}
