/*
+----+
|Main|
+----+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Contains some 'base' subroutines. As a general rule nothing in this file   |
| does much, except to setup basic variables and entities.                   |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

void() main = {};
void() MusicPrecache;
void() worldspawn =
{
	MusicPrecache();

	// Stuff that needs to be precached
	precache_model ("progs/player.mdl");
	precache_model ("progs/null.spr");
	precache_sound ("misc/h2ohit1.wav");
	// Stuff that needs to be precached

	if (self.model == "maps/tscreen.bsp") // change to intro.bsp
		precache_sound ("intro/camdie.wav");
	else if (self.model == "maps/start.bsp")
	{
		precache_sound ("items/pk_wep.wav");
		precache_sound ("music/tscreen.ogg");
	}

	// In game precaches
	if (self.model != "maps/start.bsp")
	{
		precache_model ("progs/vm_black.mdl");
		precache_model ("progs/star.spr");
		precache_model ("progs/muzflash.spr");
		precache_model ("progs/muzflsh2.spr");
		precache_model ("progs/muzflsh3.mdl");
		precache_model ("progs/explode1.spr");
		precache_model ("progs/c_hair.spr");
		precache_model ("progs/blood.mdl");
		precache_model ("progs/corporal.mdl");
		precache_model ("progs/h_corp.mdl");
		precache_model ("progs/decap.mdl");
		precache_model ("progs/bullet.mdl");
		precache_model ("progs/wchunk1.mdl");
		precache_model ("progs/wchunk2.mdl");
		precache_model ("progs/wchunk3.mdl");
		precache_model ("progs/casing.mdl");
		precache_model ("progs/vw_knife.mdl");
		precache_model ("progs/vw_pist.mdl");
		precache_model ("progs/vw_shotg.mdl");
		precache_model ("progs/vw_asalt.mdl");

		precache_sound ("items/r_item1.wav"); // change me
		precache_sound ("items/r_item2.wav"); // change me

		precache_sound ("weapons/ric1.wav");
		precache_sound ("weapons/ric2.wav");
		precache_sound ("weapons/ric3.wav");
		precache_sound ("weapons/imp_flsh.wav");
		precache_sound ("weapons/noammo.wav");
		precache_sound ("weapons/shelldrp.wav");
		precache_sound ("weapons/clipdrp.wav");
		precache_sound ("weapons/boom.wav");
		precache_sound ("weapons/knifed.wav");
		precache_sound ("weapons/clang.wav");
		precache_sound ("weapons/pistol.wav");
		precache_sound ("weapons/preload.wav");
		precache_sound ("weapons/pclipout.wav");
		precache_sound ("weapons/sreload.wav");
		precache_sound ("weapons/shotgun1.wav");
		precache_sound ("weapons/shotgun2.wav");
		precache_sound ("weapons/assault.wav");
		precache_sound ("misc/heart.wav");
		precache_sound ("misc/lockon.wav");
		precache_sound ("misc/florhit.wav");
		precache_sound ("items/pk_wep.wav");
		precache_sound ("items/pk_ammo.wav");
		precache_sound ("player/step.wav");
		precache_sound ("player/flash_on.wav");
		precache_sound ("player/flash_of.wav");
		precache_sound ("player/decaped.wav");
		precache_sound ("player/step1.wav");
		precache_sound ("player/step2.wav");
		precache_sound ("player/step3.wav");
		precache_sound ("player/step4.wav");
		precache_sound ("player/lstep1.wav");
		precache_sound ("player/lstep2.wav");
		precache_sound ("player/lstep3.wav");
		precache_sound ("player/lstep4.wav");
		precache_sound ("player/wstep1.wav");
		precache_sound ("player/wstep2.wav");
		precache_sound ("player/death.wav");
		precache_sound ("player/land.wav");
		precache_sound ("player/order1.wav");
		precache_sound ("player/order2.wav");
		precache_sound ("demon/dland2.wav");
		precache_sound ("misc/talk.wav");
		precache_sound ("doors/locked.wav");
	}

	//
	// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
	//

	// 0 normal
	lightstyle(0, "m");
	
	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");
};

float(float f) fixbyte =
{
	f = rint(f);
	if (f > 255)
		f = 255;
	else if (f < 0)
		f = 0;
	return f & 255;
};

// no bit 24!! FIXME! For now use low values for 1st parm :)
float(float s1, float s2, float s3) encode =
{
	return fixbyte(s1) * 65536 + fixbyte(s2) * 256 + fixbyte(s3);
};

float(float parm, float which) decode =
{
	if (which == 1)
		return (parm / 65536) & 255;
	else if (which == 2)
		return (parm / 256) & 255;
	else
		return parm & 255;
};

void() StartFrame = 
{
	developer = cvar("developer");
};

void() SetNewParms = 
{
	parm1 = encode(100, 0, 0);
	parm2 = 0;
	parm3 = encode(0, 0, 0);
	parm4 = 0;
	parm5 = encode(0, 0, 0);
};

void() SetChangeParms =
{
	parm1 = encode(self.health, self.ammo_shells, self.ammo_nails);
	parm2 = self.items;
	parm3 = encode(self.pistol_shots, self.shotgun_shots, self.flashjuice);
	parm4 = self.chips;
	parm5 = encode(self.flashlight_flag, self.heal_uses, 0);
};

void() DecodeLevelParms =
{
	if (parm1 == 0)
		SetNewParms();

	self.health = decode(parm1, 1);
	self.ammo_shells = decode(parm1, 2);
	self.ammo_nails = decode(parm1, 3);
	self.items = parm2 | W_MELEE;
	self.pistol_shots = decode(parm3, 1);
	self.shotgun_shots = decode(parm3, 2);
	self.flashjuice = decode(parm3, 3);
	self.chips = parm4;
	self.flashlight_flag = decode(parm5, 1);
	self.heal_uses = decode(parm5, 2);
};

//=====
// echoing sounds -
// sounds echo in a fake way
//=====

.float echo; // if true, entity sound will echo
void() do_echo =
{
	if (self.cnt == 0)
	{
			 // entity              // sample      // volume               // sound channel
		sound (self.enemy, CHAN_AUTO, self.netname, (self.ammo_nails * 0.5), self.ammo_cells);
		self.cnt = self.cnt + 1;
	}
	else
	{
		sound (self.enemy, CHAN_AUTO, self.netname, (self.ammo_nails * 0.2), self.ammo_cells);
		remove(self);
		return;
	}

	self.nextthink = time + 0.3;
	self.think = do_echo;
};

void(entity e, float chan, string samp, float vol, float atten) playsound =
{
	sound(e, chan, samp, vol, atten);
      if (self.echo) // set by triggers
	{
		local entity snd;
		snd = spawn();
		snd.nextthink = time + 0.3;
		snd.think = do_echo;
		snd.health = chan;
		snd.netname = samp;
		snd.frags = vol;
		snd.ammo_cells = atten;
		snd.ammo_nails = vol;
		snd.enemy = e;
	}
};