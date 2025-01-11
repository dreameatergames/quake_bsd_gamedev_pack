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
void() LightStyles_setup;       // Entities/Lights.QC
void() precaches;

void() main = {};
void() SetNewParms = {};
void() SetChangeParms = {};
void() StartFrame = {};
void() worldspawn = {precaches(); LightStyles_setup();};

void() precaches =
{
 precache_model ("progs/player.mdl");
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
