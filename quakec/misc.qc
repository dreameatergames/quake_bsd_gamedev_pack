void() worm_idle1;
void() worm_crawl1;
void() worm_death1;
void() worm_touch;

void() zombie_grounded;
void() zombie_getupcheck;
void() zombie_idle1;
void() zombie_run1;
void() zombie_death;
void() zombie_pain;
void() zombie_attack;

void() vile_idle1;
void() vile_run1;
void() vile_death;
void() vile_pain;
void() vile_attack;
void() vile_jump1;

// silently spawns monster at origin
void() monster_spawn =
{
	spawn_tdeath (self.origin, self); // frag the area to make sure the monster can spawn in properly

	if (self.cnt == 1)
	{
		self.health = 1;
		self.takedamage = DAMAGE_NO;
		self.movetype = MOVETYPE_STEP;
		self.solid = SOLID_TRIGGER;
		self.th_stand = worm_idle1;
		self.th_run = worm_crawl1;
		self.th_die = worm_death1;
		self.classname = "worm";
		self.teams = "envenom";
		self.touch = worm_touch;
		setmodel (self, "progs/worm.mdl");
		setsize (self, '0 0 0', '0 0 0');
		monster_start();
	}

	// zombie
	if (self.cnt == 2)
	{
		self.health = self.max_health = 50;
		self.movetype = MOVETYPE_STEP;

		if (!self.zombie_onground)
		{
			self.solid = SOLID_SLIDEBOX;
			self.th_stand = zombie_idle1;
			self.th_run = zombie_run1;
		}
		else
		{
			self.mode = TRUE;
			self.solid = SOLID_NOT;
			self.th_stand = zombie_grounded;
			self.th_run = zombie_getupcheck;
		}

		self.cnt = 0;
		self.speed = 4;
		self.th_die = zombie_death;
		self.th_pain = zombie_pain;
		self.th_melee = zombie_attack;
		self.classname = "zombie";
		self.teams = "envenom";
		setmodel (self, "progs/zombie.mdl");
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
		monster_start();
	}
	// 3 is baeloth

	// vile
	else if (self.cnt == 4)
	{
		self.health = self.max_health = 235;
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;

		self.th_stand = vile_idle1;
		self.th_run = vile_run1;
		self.th_die = vile_death;
		self.th_pain = vile_pain;
		self.th_melee = vile_attack;
		self.th_missile = vile_jump1;
		self.classname = "vile";
		self.teams = "envenom";
		self.speed = 11;

		setmodel (self, "progs/vile.mdl");
		setsize (self, '-12 -18 -24', '17 18 18');
		monster_start();
	}
};

void() info_monsterspawn = 
{
	setmodel (self, "progs/null.spr");
	setsize (self, '0 0 0', '0 0 0');

	if (self.cnt == 1)
	{
		precache_model ("progs/worm.mdl");
		precache_sound ("worm/squish.wav");
		precache_sound ("worm/squish2.wav");
	}
	if (self.cnt == 2)
	{
		precache_model ("progs/zmbiegib.mdl");
		precache_model ("progs/zombie.mdl");
		precache_model ("progs/nhzombie.mdl");
		precache_model ("progs/worm.mdl");
		precache_sound ("zombie/death.wav");
		precache_sound ("zombie/idle1.wav");
		precache_sound ("zombie/idle2.wav");
		precache_sound ("zombie/pain1.wav");
		precache_sound ("zombie/pain2.wav");
		precache_sound ("zombie/pain3.wav");
		precache_sound ("zombie/pain4.wav");
		precache_sound ("zombie/smack.wav");
		precache_sound ("zombie/step.wav");
		precache_sound ("zombie/splat.wav");
		precache_sound ("worm/squish.wav");
		precache_sound ("worm/squish2.wav");
	}
	else if (self.cnt == 4)
	{
		precache_model ("progs/vile.mdl");
		precache_sound ("demon/dhit2.wav");
		precache_sound ("vile/idle1.wav");
		precache_sound ("vile/idle2.wav");
		precache_sound ("vile/idle3.wav");
		precache_sound ("vile/idle4.wav");
		precache_sound ("vile/attack.wav");
		precache_sound ("vile/attack2.wav");
		precache_sound ("vile/leap.wav");
		precache_sound ("vile/pain1.wav");
		precache_sound ("vile/pain2.wav");
		precache_sound ("vile/pain3.wav");
		precache_sound ("vile/death1.wav");
		precache_sound ("vile/death2.wav");
	}
	self.mode = TRUE;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	self.use = monster_spawn;
	if (!self.targetname)
		objerror("info_monsterspawn with no targetname\n");
};


/*
=======================
DITHERED COLOURED LIGHTS
=======================
*/

void() redlight =
{
	precache_model ("progs/redlight.spr");
	setmodel (self, "progs/redlight.spr");
	makestatic(self);
};

//=======
// blood
//
// pool of blood drops underneath during death
//=======
void() blood_think =
{
	if (self.frame < self.lock_finished)
	{
		self.frame = self.frame + 1;
		if (self.owner.classname != "deadhuman")
			self.nextthink = time + 1.5; //animation speed
		else
			self.nextthink = time + 0.01;
	}
};

// how far the blood spawns forward (model dependant) and it's skin and how big the blood puddle goes
// size is 1-5 and is the animation frame
void(float bforward, float bskin, float bsize) blood =
{
	local entity pool;

	makevectors (self.angles);

	pool = spawn ();
	pool.owner = self;
	pool.movetype = MOVETYPE_TOSS;
	pool.solid = SOLID_NOT;
	pool.classname = "bloodpool";
	setmodel (pool, "progs/blood.mdl");
	setsize (pool, '0 0 0', '0 0 0');
	setorigin (pool, self.origin + v_forward*bforward);
	pool.velocity_z = -250;
	pool.alpha = 0.9;
	pool.think = blood_think;
	pool.skin = bskin;
	pool.angles_y = random()* 360;
	pool.lock_finished = bsize; // FIXME: Lock finished used as blood size. weird.
	pool.nextthink = time + 0.1;
};

void() info_camera =
{
	if (!self.targetname)
		objerror ("info_camera with no targetname\n");
};

// spark effect for damaged computers and lights
void() sparkeffect =
{
	if (self.lock_finished > 3 || self.velocity_z < 1)
		remove(self);
	self.lock_finished = self.lock_finished + 1;
	particle (self.origin, '0 0 0', 111, 5); // yellow particles
	self.nextthink = time + 0.05;
};

void() spawn_particle =
{
	local entity spark;
	local float r;

	r = rint((random() * 3) + 1);

	self.noise = "";
	if (r == 1)
		self.noise = "ambience/spark1.wav";
	else if (r == 2)
		self.noise = "ambience/spark2.wav";
	else if (r == 3)
		self.noise = "ambience/spark3.wav";
	else if (r == 4)
		self.noise = "ambience/spark4.wav";

	playsound (self, CHAN_BODY, self.noise, 1, ATTN_NORM);

	spark = spawn ();
	spark.owner = self;
	spark.movetype = MOVETYPE_TOSS;
	spark.solid = SOLID_NOT;
	spark.classname = "spark";
	setmodel (spark, "progs/null.spr");
	setsize (spark, '0 0 0', '0 0 0');
	setorigin (spark, self.origin);
	spark.think = sparkeffect;
	spark.nextthink = time + 0.1;
	self.nextthink = time + random() * 5;
};

void() info_spark =
{
	precache_sound ("ambience/spark1.wav");
	precache_sound ("ambience/spark2.wav");
	precache_sound ("ambience/spark3.wav");
	precache_sound ("ambience/spark4.wav");

	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;
	self.classname = "particle";
	setsize (self, '0 0 0', '0 0 0');
	self.think = spawn_particle;
	self.nextthink = time + random() * 3;
};

void() info_hatchedegg =
{
	precache_model ("progs/htchdegg.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.classname = "hatchedegg";
	setsize (self, '0 0 0', '0 0 0');
	setmodel (self, "progs/htchdegg.mdl");
	droptofloor();
	makestatic(self);
};

void() info_shatteredglass =
{
	precache_model ("progs/glass.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "glass";
	self.angles_y = self.angles_y + random() * 360;
	setsize (self, '0 0 0', '0 0 0');
	setmodel (self, "progs/glass.mdl");
	droptofloor();
	makestatic(self);
};

void() info_deadnerd =
{
	local float rand;
	rand = 4 + random() * 4; // random from 4 to 8

	precache_model ("progs/dednerd.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.classname = "deadhuman";
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	setmodel (self, "progs/dednerd.mdl");
	blood(0,0,rand); // f,s,sz
	droptofloor();
	makestatic(self);
};

void() info_deadhuman =
{
	local float rand;
	rand = 4 + random() * 4; // blood pool size from 4 to 8

	precache_model ("progs/dedhuman.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.classname = "deadhuman";
	setsize (self, '0 0 0', '0 0 0');
	setmodel (self, "progs/dedhuman.mdl");
	blood(0,0,rand); // f,s,sz
	droptofloor();
	makestatic(self);
};

void() info_dockedship =
{
	precache_model ("progs/ship1.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_SLIDEBOX;
	self.classname = "dockedship";
	setmodel (self, "progs/ship1.mdl");
	setsize (self, '-95 -88 -16', '110 87 36');
	droptofloor();
};

void() misc_model = 
{
	precache_model(self.model);
	setmodel(self, self.model);
};

void() gen_idle1	=	[0,		gen_idle2] 
{
	if (self.effects != EF_DIMLIGHT)
		self.effects = EF_DIMLIGHT;

	if (self.cnt == FALSE)
	{
		if (self.target)
			SUB_UseTargets();
		if (self.voice_finished < time)
		{
			if (world.model == "maps/ship1.bsp")
				playsound (self, CHAN_VOICE, "misc/roar.wav", 1, ATTN_NONE);
			playsound (self, CHAN_BODY, "misc/gen1.wav", 1, ATTN_IDLE);
			self.voice_finished = time + 1;
			self.cnt = TRUE;
		}
	}
	else
	{
		if (self.voice_finished < time)
		{
			playsound (self, CHAN_BODY, "misc/gen2.wav", 1, ATTN_IDLE);
			self.voice_finished = time + 2.1;
		}
	}
};
void() gen_idle2	=	[1,		gen_idle3] {};
void() gen_idle3	=	[2,		gen_idle1] {};

void() info_generator =
{
	precache_model ("progs/generatr.mdl");
	precache_sound ("misc/gen1.wav");
	precache_sound ("misc/gen2.wav");
	if (world.model == "maps/ship1.bsp")
		precache_sound ("misc/roar.wav");

	setmodel (self, "progs/generatr.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_SLIDEBOX;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.think = gen_idle1;
	self.frame = 3;
	droptofloor();
};

void() clipboard_use = // change messages
{
	if (self.message2)
		self.message = self.message2;
};

void() info_clipboard =
{
	precache_model ("progs/clipbord.mdl");
	precache_sound ("misc/pageturn.wav");

	setmodel (self, "progs/clipbord.mdl");
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_SLIDEBOX;
	setsize(self, '-2 -4 -12', '2 4 12');
	if (!self.message)
		self.message = "It's blank";
	if (!self.message2)
		self.message2 = "It's blank";
	self.use = clipboard_use;
};

void() info_chair =
{
	precache_model ("progs/chair.mdl");
	setmodel (self, "progs/chair.mdl");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_SLIDEBOX;
	setsize(self, '-12 -9 -1', '7 9 32');
	droptofloor();
};

void() ambient_intromusic = // used in the short introduction title screen
{
	precache_sound ("music/intro.ogg");
	ambientsound (self.origin, "music/intro.ogg", 1, ATTN_NONE);
};

void() ambient_computers =
{
	precache_sound ("ambience/computrs.wav");
	ambientsound (self.origin, "ambience/computrs.wav", 1, ATTN_STATIC);
};

void() ambient_water =
{
	precache_sound ("ambience/water.wav");
	ambientsound (self.origin, "ambience/water.wav", 1, ATTN_STATIC);
};

void() ambient_static =
{
	precache_sound ("ambience/stticlop.wav");
	ambientsound (self.origin, "ambience/stticlop.wav", 1, ATTN_STATIC);
};

void() fountain_particlethink = 
{
	if (self.lock_finished < time)
		remove(self);

	particle (self.origin, '0 0 0', 208, 20);
	self.nextthink = time + 0.01;
};

void() fountain_think =
{
	local entity part;

	part = spawn();

	part.owner = self;
	setmodel (part, "progs/null.spr");
	part.movetype = MOVETYPE_TOSS;
	part.solid = SOLID_NOT;
	part.takedamage = DAMAGE_NO;
	part.classname = "particle";
	setorigin (part, self.origin);
	setsize(part, '0 0 0', '0 0 0');

	part.angles_y = part.angles_y + random()*360;
	makevectors (part.angles);
	part.velocity = v_forward* 50;
	part.velocity_z = 150 + random()*225;

	part.lock_finished = time + 0.5 + random()*1.5;
	part.think = fountain_particlethink;
	part.nextthink = time + 0.05 + random()*0.2;
	self.nextthink = time + 0.1 + random()*0.1;
};

void() misc_fountain =
{
	setmodel (self, "progs/null.spr");
	self.think = fountain_think;
	self.nextthink = time + 0.1;
};

void() misc_hanged =
{
	precache_model ("progs/hanged.mdl");
	setmodel (self, "progs/hanged.mdl");
};

float START_OFF = 1;
void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};

void() trigger_relay =
{
	self.use = SUB_UseTargets;
};

/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};

//===
// title screen map stuff
//===

void() misc_title1 =
{
	precache_model ("progs/title.spr");
	setmodel (self, "progs/title.spr");
	makestatic (self);
};

void() misc_dynamiclight =
{
	local entity lght;

	lght = spawn ();
	lght.owner = self;
	lght.movetype = MOVETYPE_NOCLIP;
	lght.solid = SOLID_NOT;
	lght.classname = "dynamiclight";
	setmodel (lght, "progs/null.spr");
	setsize (lght, '0 0 0', '0 0 0');
	setorigin (lght, self.origin);
	lght.effects = EF_DIMLIGHT;
	lght.think = SUB_Remove;
	lght.nextthink = time + self.cnt;

	makevectors (self.angles);
	lght.velocity = aim(self, self.speed);
	lght.velocity = lght.velocity * self.speed;

	self.think = misc_dynamiclight;
	self.nextthink = time + self.cnt;
};