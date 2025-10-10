


//original code:
(
{
	var a, freq, trig;                //a format of variables from Desq UGen
	a = Dseq([60,65,69],inf).midicps;               //play "C F A" infinitely as a sequence
	trig = Impulse.kr(Lag.kr(MouseY.kr(1,19),0.3));
	//scales mouse Y position to 1-19Hz, change every 0.3sec smoothly
	freq = Demand.kr(trig, 0, a)*Lag.kr(MouseX.kr(1,2),0.3);
	//scales mouse X position to 1-2Hz, change every 0.3sec smoothly
	SinOsc.ar(freq) * 0.2!2           //generates a sine wave, amplitude 0.2, stereo output
}.play;
)



//140 character limit:
play{SinOsc.ar(Demand.kr(Impulse.kr(Lag.kr(MouseY.kr(1,19),0.3)), 0,Dseq([60,65,69],inf).midicps)*Lag.kr(MouseX.kr(1,2),0.3))*0.2!2}




