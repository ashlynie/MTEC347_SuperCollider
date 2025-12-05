# Analysis

*super collide me, by Luisa Mei*

##music
1. "colliding sound" - prosody 
2. contrast of sound between pickle synth and bass synth
3. use of effects like reverb and fade-in/out


##coding
**Quote from Luisa**  - "*I had several synthdefs running, one that took in sound, several effects, some granular synthesis I think...I use Pbindefs to make sequences... I sampled some guitar as the sound source.*"


####Luisa's code:                       
**// looper synthdef**

		SynthDef.new(\looper, {arg rate=1, in, out = ~bus3, buf, bufG, gate=1, t_rec=0, t_reset=1, t_chop=0, plvl=1, switch=0,
			frombeat=0, grainsize=1, numbeats=4, numsubcycles=4, amp=1, wet=1;
			var dry, dryG, loopgate, time, grainlength, grainframes, subcycles, cycles, grains, trigcounter,
			grainstart, grainend, rlvl, xfade, playenv, prelevelenv, env, player, playerG, phase, grainer, grainerG, fx, pitchshift;

				//buf,bufG - audio buffer for recording/playback
				//t_rec - trigger for recording
				//t_reset - reset playback phrase
				//t_chop - trigger for chopping playback
				//plvl - pre-level for recorder, how much old audio remains
				//switch - between normal and granular playback modes
				//numbeats,numsubcycles - control subdivision of the loop
				//dry,dryGain - unprocessed audio signal, amplitude multiplier
				//loopgate - binary
				//grainlength,grainframes - duration in seconds/ sample frames
				//grains - number of grians active
				//rlvl - release level
				//xfade - crossfade amount
				//prelevelenv - for fade-in
				//grainer,grainerG - main granular synth unit
				//pitchshift - 1normal;2octave up


			rate = Lag2.kr(rate,0.1);
				// controls loopgate and rlvl
			trigcounter = PulseCount.kr(t_rec, t_reset);
				// for the fader and for loopbuf as a trigger
			xfade = Lag.kr(switch.linlin(0, 1, -1, 1), 0.1);
				// audio input
			dry = In.ar(in,2);
			dryG = In.ar(in,1);

			loopgate = trigcounter > 1;
				//open loopgate once start recording
			playenv = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), loopgate);
			env = EnvGen.kr(Env.asr(0.04, 1, 0.04), gate, doneAction:2);
			prelevelenv = 1 - EnvGen.kr(Env.asr(0.1, 1, 0.1), t_chop);
			rlvl = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), trigcounter % 2);
				//how much new audio recorded
			time = Latch.kr(Timer.kr(t_rec), loopgate);
				//Latch - Holds input signal value when triggered

			grainlength = time / (numbeats * numsubcycles);
			grainframes = (grainlength * SampleRate.ir).round(1);
			grainstart = grainframes * frombeat * numsubcycles;
			grainend = grainstart + (grainframes * grainsize);
				//calculate total length and subdivides into grains
			subcycles = TDuty.kr(grainlength / (rate.abs), loopgate, 1) * loopgate;
			cycles = Trig.kr(PulseCount.kr(subcycles, t_reset) % (numbeats * numsubcycles), 0.01) + Trig.kr(trigcounter, 0.01);
			grains = TDuty.kr(grainlength * grainsize / (rate.abs), switch, 1);
				//TDuty and PulseCount as rhythmic clocks; TDuty - A value is demanded each UGen in the list and output as a trigger according to a stream of duration values; PulseCount - Each trigger increments a counter which is output as a signal.
				
				// players and recorder, 
			player = PlayBuf.ar(2, buf, BufRateScale.kr(buf)*rate, cycles, loop:1);
			playerG = PlayBuf.ar(1, bufG, BufRateScale.kr(bufG)*rate, cycles, loop:1);

			//pitchshift = PitchShift.ar(player,0.2,1/(rate.abs),0,0.01);
			//player = pitchshift;
			phase = Phasor.ar(grains, rate, grainstart, grainend, grainstart);

			grainer = BufRd.ar(2, buf, phase);
			grainer = PitchShift.ar(grainer,0.2,1/(rate.abs),0,0.01);
			grainerG = BufRd.ar(1,bufG, phase);

			RecordBuf.ar(dry <! player, buf, recLevel: rlvl, preLevel:plvl, loop:1, trigger: cycles);
			RecordBuf.ar(dryG <! playerG, bufG, recLevel: rlvl, preLevel:plvl, loop:1, trigger: cycles);


			fx = LinXFade2.ar(player, grainer, xfade, playenv);
			// output fader between player and grainer
			ReplaceOut.ar(out, XFade2.ar(dry, fx, 1 ) * env * amp);
			//ReplaceOut.ar(out, dry * env * amp);

		}).add;



**// granular synth**
 
		SynthDef(\gs,
			{arg buf, out, pan=0, amp=1, rate=1, pitch=1,
				atk=0.1, sus=1, rls=0.4,
				speed, length, centerPos;
				var env, sound, trig;
				env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rls]) , doneAction:2);
				trig = Impulse.kr(speed);
				centerPos = centerPos*BufDur.kr(buf);
				Demand.kr(trig, 0, [centerPos, rate, speed, length, amp]);

				sound = TGrains.ar(
					numChannels: 2,
					trigger: trig,
					bufnum: buf,
					rate: rate,
					centerPos: centerPos,
					dur: length,
					pan: pan,
					amp: amp,
				);

				//sound = PitchShift.ar(sound, 0.2, (1/(rate.abs))*((pitch-84).midiratio),0.0,0.001);
				sound = PitchShift.ar(sound, 0.2, (1/(rate.abs))*(pitch.midiratio),0.0,0.001);
				sound = Pan2.ar(sound,pan);
				sound = sound*amp*env;
				Out.ar(out,sound);
		}).add;



**// delay effect**     

	SynthDef(\delay,
		{arg in, out, decay = 4.5, mix, amp=1, mod;
			var sound, pan;
			sound = In.ar(in,1);
			sound = CombC.ar(sound,5,Lag.kr((1.45*mod + 0.05),0.2),mix+decay);
			sound = Pan2.ar(sound,LFNoise1.kr(2.95*mod + 0.05.reciprocal).range(-0.6,0.6),amp);
				//LFNoise - Generates linearly interpolated random values at a rate given by the nearest integer division of the sample rate by the freq argument.
			XOut.ar(out,mix,sound);
	}).add;



**// reverb effect**  

	SynthDef(\reverb,
		{arg in=0, out=0, mod=0, mix=0, dec=4, lpf=1500;
		// mod - modulation, control input gain
		// mix - dry/wet
		//dec - decay time
		//lpf - low-pass filter cutoff
			var sig;
			sig = In.ar(in, 1)*mod;
			sig = DelayN.ar(sig, 0.03, 0.03);
			//delay UGen, no interpolation, DelayL - linear; DelayC - cubic interpolation
			sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, dec);
			//create combo filter, echo tail
			sig = SplayAz.ar(2, sig);
			//spread across 2 channels, stereo
			sig = LPF.ar(sig, lpf);
			5.do{sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.099)}!2, 3)};
			//create 5 allpass filter, more layers
			sig = LPF.ar(sig, lpf);
			sig = LeakDC.ar(sig);
			//high-pass filter to remove DirectCurrent bias from a signal
			sig = Pan2.ar(sig,0);
			XOut.ar(out, mix, sig);
	}).add;