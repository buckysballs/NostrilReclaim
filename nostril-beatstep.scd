s.boot;
MIDIClient.init;

//check here for instantiating new classes just compiled
Platform.userExtensionDir

(
SynthDef(\betterSound, { |freq = 440, amp = 0.5, gate = 1, pan = 0|
  var signal, env;

  // The envelope controls the volume shape
  env = Env.asr(0.01, 0.9, 0.5).kr(gate: gate, doneAction: 2);

  // Create a fuller sound with multiple oscillators
  signal = Saw.ar(freq * [1.0, 1.005, 0.995]);

  // Apply a low-pass filter
  signal = LPF.ar(signal, freq * 4 + 2000);

  // Add a touch of reverb
  signal = FreeVerb.ar(signal, mix: 0.2, room: 0.8, damp: 0.5);

  // Apply the envelope and pan, and scale the overall amplitude
  Out.ar(0, Pan2.ar(signal * env * amp, pan));
}).add;
)

(
SynthDef(\simpleSine, {
    arg out=0, freq=440, amp=0.5;
    Out.ar(out, SinOsc.ar(freq, 0, amp) * 0.5);
}).add;
)

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

(
SynthDef(\beatSynth, { |out=0, freq=440, amp=0.1, cutoff=1000, sustain=1|
    var env = EnvGen.ar(
        Env.perc(0.01, sustain, curve: -4),
        doneAction: 2
    );
    var sig = Saw.ar(freq);
    sig = RLPF.ar(sig, cutoff, 0.5);
    Out.ar(out, Pan2.ar(sig * amp * env));
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

~mySynth = Synth(\simpleSine);
~midiVolume = 0.5;

MIDIdef.cc(\volume_cc7, {
arg val, ccNum, chan, src;

~midiVolume = val.linlin(0, 127, 0.0, 1.0);

"MIDI Volume (CC#7): %".postf(~midiVolume);

if (~mySynth.notNil) {
~mySynth.set(\amp, ~midiVolume);
	}
}, 7);

~mySynth.free;