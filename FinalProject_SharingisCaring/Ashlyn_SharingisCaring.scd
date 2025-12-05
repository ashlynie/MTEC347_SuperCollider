//Hi, this is an interative code for a midi-input synth with a visual GUI, rinspired by my busy, looping everyday life, and referencing some codes from "Sun" that Rachel showed in class,

//Please connect your midi keyboard, boost your server, and run this code. Then, try playing some notes on your midi keyboard.



(

MIDIClient.init;
MIDIIn.connectAll;

~active = IdentityDictionary.new;
~shapes = IdentityDictionary.new;

//A Synth
SynthDef(\everyday, {
    arg note=67, amp=0.3, gate=1;
    var freq, sig, env, reverb;

    freq = note.midicps;
    sig = SinOsc.ar(freq);

    env = EnvGen.kr(Env.asr(0.5, 1, 1.9), gate, doneAction:2);
    sig = sig * env * amp;

    reverb = FreeVerb.ar(sig, mix:0.3, room:1, damp:0.5);
    Out.ar(0, reverb!2);
}).add;


//GUI setup
(
~win = Window("Everyday", Rect(100,100,800,800)).front;
~view = UserView(~win, Rect(0,0,800,800));
~bgphase = 0;


//Draw the blue background
~view.drawFunc = {

    Pen.smoothing = true;

	~bgphase = ~bgphase + 0.01;
    ~blue = 0.7 + 0.3 * sin(~bgphase);
	~bgcolor = Color(0.1, 0.2,~blue);
	~view.background = ~bgcolor;

//Draw looping circles
    ~shapes.values.do { |shape|
        ~circle = shape.radius + (sin(shape.phase) * 5);
        Pen.fillColor = shape.color;
        Pen.addOval(Rect.aboutPoint(shape.pos, ~circle, ~circle));
        Pen.fill;
    };
};

//Animation
~anim = {
    loop {

        ~shapes.keysValuesDo { |note, shape|

            if (shape.fade > 0) {
                shape.alpha = shape.alpha - shape.fade;

                shape.color = Color(
                    shape.color.red,
                    shape.color.green,
                    shape.color.blue,
                    shape.alpha
                );

                if (shape.alpha <= 0) {
                    ~shapes.removeAt(note);
                };
            };
        };

        ~view.refresh;
        0.01.wait;
    }
}.fork(AppClock);
);



// Midi notes on
MIDIIn.noteOn = { |src, chan, note, vel|
    var synth, shape, baseColor;

    synth = Synth(\everyday, [\note, note, \amp, vel/119]);
    ~active[note] = synth;

    baseColor = Color(rrand(0.0,1.0), rrand(0.0,1.0), rrand(0.0,1.0), 0.8);

    shape = (
        pos: Point(rrand(50,550), rrand(50,550)),
        radius: rrand(20,40),
        phase: 0,
        alpha: 0.8,
        fade: 0,
        color: baseColor
    );

    ~shapes[note] = shape;
};

//Midi notes off
MIDIIn.noteOff = { |src, chan, note, vel|
    if (~active[note].notNil) {
        ~active[note].set(\gate, 0);
        ~active.removeAt(note);
    };

    if (~shapes[note].notNil) {
        ~shapes[note].fade = 0.02;
    };
};
)



