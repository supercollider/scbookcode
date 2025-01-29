#include "SC_PlugIn.hpp"

static InterfaceTable *ft;

// The struct will hold the state of our plugin.
// It is first initialized in the constructor function and then accessed
// and possible mutated in every call to the call function.
class Flanger : public SCUnit  {
public:
    Flanger();
    ~Flanger();
    void next(int inNumSamples);
private:
    // it is a convention to use some kind of prefix (or postfix)
    // to distinguish member variables from local variables
    float mRate;
    float mDelaysize;
    float mAdvance;
    float mReadpos;
    int mWritepos;
    // a pointer to the memory we'll use for our internal delay
    float *mDelayline;
};

Flanger::Flanger() {
    // Here we must initialise *all* state variables in our Flanger struct.
    mDelaysize = sampleRate() * 0.02f; // Fixed 20ms max delay
    float rate = IN0(1); // initial rate
    // Rather than using rate directly, we're going to calculate the size of
    // jumps we must make each time to scan through the delayline at "rate"
    mAdvance = ((mDelaysize * rate) / sampleRate()) + 1.0f;
    mRate = rate;
    mWritepos = 0;
    mReadpos = 0;

    // Allocate the delay line
    mDelayline = (float*)RTAlloc(mWorld, (int)mDelaysize * sizeof(float));
    // Check the result of RTAlloc because it can fail if the RT pool is too small!
    if (!mDelayline)
    {
        Print("RTAlloc failed!");
        // clear outputs, set calc function and set done
        ClearUnitOutputs(unit, 1);
        SETCALC(ClearUnitOutputs);
        mDone = true;
        return;
    }
    // Set the delay line to zeros.
    memset(mDelayline, 0, mDelaysize * sizeof(float));

    // sets the calc function and automatically computes 1 sample.
    set_calc_function<&Flanger::next>();
}

Flanger::~Flanger() {
    // check in case RTFree failed in the Ctor
    if (mDelayline)
        RTFree(mWorld, mDelayline);
}

void Flanger::next(int inNumSamples ) {
    float *in = in(0);
    float *out = out(0);

    // "rate" and "depth" can be modulated at control rate
    float currate = in0(1);
    float depth = in0(2);

    // The compiler doesn't know that "out" can't possibly point
    // to one of our members, so it would have to reload them from
    // memory on every loop iteration. To prevent this from happening,
    // we temporarily store them in local variables.
    float rate = mRate;
    float advance = mAdvance;
    float readpos = mReadpos;
    int writepos = mWritepos;
    const float delaysize = mDelaysize; // this one is fixed
    float *delayline = mDelayline;

    if (rate != currate) {
        // rate input needs updating
        rate = currate;
        advance = ((delaysize * rate * 2) / SAMPLERATE) + 1.0f;
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
    mRate = rate;
    mAdvance = advance;
    mWritepos = writepos;
    mReadpos = readpos;
}

PluginLoad(InterfaceTable *inTable) {
    ft = inTable;

    registerUnit<Flanger>(ft, "Flanger");
}
