s.boot;
MIDIClient.init;

//check here for instantiating new classes just compiled
Platform.userExtensionDir

(
SynthDef(\mySynth, { |out=0, freq=440, amp=0.1, cutoff=1000, sustain=1|
    var env = EnvGen.ar(
        Env.perc(0.01, sustain, curve: -4),
        doneAction: 3
    );
    var sig = Saw.ar(freq);
    sig = RLPF.ar(sig, cutoff, 0.5);
    Out.ar(out, Pan2.ar(sig * amp * env));
}).add;
)

(
SynthDef(\drum, { |out=0, freq=100, amp=0.5, pan=0, sustain=0.1, decay=0.2, attack=0.01|
    var env = EnvGen.kr(Env.perc(attack, sustain), doneAction: 2);
    var snd = WhiteNoise.ar(env) * amp;
    Out.ar(out, Pan2.ar(snd, pan));
}).add;
)


~beatstep = ArturiaBeatStep();


(
~beatstep.pads.do { |pad, i|
    pad.onPress = { |val|
        Synth.new(\drum, [\freq, (60 + i).midicps, \amp, val.linexp(1, 127, 0.01, 1.0)]);
    };
    pad.onRelease = { |val|
		Synth.new(\drum, [\freq, (60 + i).midicps, \amp, val.linexp(1, 127, 0.01, 1.0)]);
    };
};
)

(
~beatstep.knobs.do { |knob, i|
    knob.onChange = { |val|
        "Knob % value %".postf(i + 1, val).postln;
		Synth.new(\mySynth, [\freq, (60 + i).midicps, \amp, val.linexp(1, 127, 0.01, 1.0)]);

    };
};
)
