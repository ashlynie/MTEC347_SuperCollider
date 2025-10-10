# Project1 - 140character
## What I did & How I did
**Intentions:** 
I want to create a sequence looping forever, while its pitch and speed can be changed through the movement of the mouse
**Steps:**   
1. searched "sequence" in SC search bar and found out "Dseq" UGen.   
2. looked up and found out "Lag" UGen from "https://www.youtube.com/watch?v=JCqBPmpj8Gc".    
3. write the original code in Dseq UGen format.  
4. rewrite it into shorter code within 140 character


## Problems & How I overcame
**Problem1 - Lag not working**   
Lag(MouseY.kr(1,19),0.3), same with Lag(MouseX.kr(1,2),0.3)      
**Solution1 - forget .kr**     
suppose to be Lag.kr(MouseY.kr(1,19),0.3) and Lag.kr(MouseX.kr(1,2),0.3).    
**Problem2 - wrong code for stereo output**    
SinOsc.ar(freq) * 0.2 * !2  
**Solution2**       
change to SinOsc.ar(freq) * 0.2!2      
**Problem3 - shorter code not working**     
play{SinOsc.ar(Demand.kr(Impulse.kr(Lag.kr(MouseY.kr(1,19),0.3)),0,Dseq([60,65,69],inf).midicps*Lag.kr(MouseX.kr(1,2),0.3)))*0.2!2}
**Solution3 - group it wrong**    
suppose to be(trig, 0, a), forget the ")"after "midicps"
