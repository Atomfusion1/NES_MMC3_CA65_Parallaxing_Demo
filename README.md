# NES_MMC3_CA65_Parallaxing_Demo
 MMC3 NES Demo Cartridge with Parallaxing and Movement
 
 Ca65 MMC3 Parallax NES Demo Cart 
Ok so I’m two weeks into my programming and have been working on MMC3 Cart
I have a Demo with Ripped Graphics which includes. 
1. Selectable PRG ROM Banks (Changes Background Color)
2. Scrolling IRQ With 4 layers of Parallax Ground 
3. CHR Bank Switching with Clouds 
You can Fly around the screen shoot a fireball and watch the world go by , no collision or enemy’s yet 
It Reminds me a lot of UN Squadron for the SNES 

Create NES Game using Ca65 and famitone5 Background, Sprites, Controller, Audio, sfx. 
When i think of an NES Demo/Tutorial I think of Background,Forground,Controller Input,Music,sfx 
No AUDIO or SFX in this demo to keep code smaller Next demo should have it or see my previous project for audio 

I Tried to get into NES assembly programming from C++ but it has taken me a week to get/build a demo from many different demos that does a little bit of everything. 
Most Demos have no Sound, Those that do are written so far Past a Starter Demo that you cant understand any of it. 
I feel this gives a great starting rom that can be loaded into Mesen (my fav) or fceux 
Setup Controller one and press the buttons, You will move around a sprite, Start Music, play Sound effects, ect. 

This Project contains everything needed to compile your nes cart 
I find Youtube NESHacker very informative but he does not have a Demo Cart like this at 4/18/22
https://www.youtube.com/watch?v=RtY5FV5TrIU
Use your Editor of Choice , I like VSCode extension ca65 Macro assembler 


Download Famitracker http://famitracker.com/ to Edit/Make your own songs then 
WARNING When making songs in famitracker, don't use ROWS = 256. text2data (or any variation) won't work right, and will only output empty songs.
1 Export them as Text file, then 
2 setup and run the bat file in the Sound\famitone5\text2data 
3 Change include path to new *Song*.s
4 Change ldx and ldy pointer to first program line in *Song.s* 
Example 
LDX #<Song_music_data
LDY #>FF1_music_data

You can also download NSFImport.exe http://famitracker.com/forum/posts.php?id=2284 This will let you load any NSF File and convert it to a file famitracker and open then convert to txt file and text2data .. JUST WARNING dont use ROWS = 256 (This caused me hours of headach) I just put it to 255 and put up with the note missing 

I have Just Started my Rabbit Hole of Assembly and NES programming, The point of this code is not that its perfect and Fast for a production game but Cleaned up enough that another noob trying their hand can take it and just Start trying it out 


