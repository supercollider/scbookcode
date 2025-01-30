#include <SC_Unit.h>

struct Test : Unit {
    float mMul;
    float mAdd;
};

void Test_next1(Test *unit, int inNumSamples) {
    float *in = IN(0);
    float *out = OUT(0);
    for (int i = 0; i < inNumSamples; ++i) {
        // mMul and mAdd will be reloaded from memory
        // on every iteration, because the compiler does not
        // know that 'out' can't possible point to them.
        out[i] = in[i] * unit->mMul + unit->mAdd;
    }
}

void Test_next2(Test *unit, int inNumSamples) {
    float *in = IN(0);
    float *out = OUT(0);
    // this tells the compiler that it should keep the variables in registers.
    const float mul = unit->mMul;
    const float add = unit->mAdd;
    for (int i = 0; i < inNumSamples; ++i) {
        out[i] = in[i] * mul + add;
    }
}
