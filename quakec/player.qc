$frame normal

$frame usea1 usea2 usea3 usea4 usea5 usea6 usea7

$frame useb1 useb2 useb3 useb4 useb5 useb6 useb7 useb8 useb9

$frame fall1 fall2 fall3 fall4 fall5 fall6 fall7

$frame climb1 climb2 climb3 climb4 climb5 climb6 climb7 climb8

$frame qturn1 qturn2 qturn3 qturn4

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9 stand10 stand11 stand12 stand13 stand14

$frame stancea1

$frame stanceb1

$frame stancec1

$frame stanced1

$frame shoota1 shoota2 shoota3

$frame reloada1 reloada2 reloada3 reloada4 reloada5 reloada6 reloada7 reloada8 reloada9

$frame shootb1 shootb2 shootb3 shootb4 shootb5 shootb6 shootb7 shootb8 shootb9 shootb10 shootb11 shootb12

$frame reloadb1 reloadb2 reloadb3 reloadb4 reloadb5 reloadb6

$frame shootc1 shootc2

$frame runa1 runa2 runa3 runa4 runa5 runa6

$frame runb1 runb2 runb3 runb4 runb5 runb6

$frame walka1 walka2 walka3 walka4 walka5 walka6 walka7 walka8 walka9 walka10 walka11 walka12

$frame walkb1 walkb2 walkb3 walkb4 walkb5 walkb6 walkb7 walkb8 walkb9 walkb10 walkb11 walkb12

$frame stab1 stab2 stab3

$frame slash1 slash2 slash3 slash4

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8 deathc9 deathc10

$frame type1 type2 type3 type4 type5 type6 type7 type8 type9 type10 type11 type12 type13 type14

//

.float battle_ready;
void() ThrowClip;
void() ThrowCasing;
void() W_SetCurrentAmmo;
void() reload;
void() Player_Move;
void() W_FireKnife;
void() W_Pistol;
void() W_Shotgun;
void() W_Assault;
void(float bforward, float bskin, float bsize) blood;
void(float u, float r, float f) MuzzleFlash;
void(float u, float r, float f) MuzzleFlash2;
void(float u, float r, float f) MuzzleFlash3;

void() player_type1  =[	$type1,	player_type2	] {self.owner.lock_finished = time + 1.5;self.owner.turnlock_finished = time + 1.5;};
void() player_type2  =[	$type2,	player_type3	] {};
void() player_type3  =[	$type3,	player_type4	] {};
void() player_type4  =[	$type4,	player_type5	] {};
void() player_type5  =[	$type5,	player_type6	] {};
void() player_type6  =[	$type6,	player_type7	] {};
void() player_type7  =[	$type7,	player_type8	] {};
void() player_type8  =[	$type8,	player_type9	] {};
void() player_type9  =[	$type9,	player_type10	] {};
void() player_type10  =[	$type10,	player_type11	] {};
void() player_type11  =[	$type11,	player_type12	] {};
void() player_type12  =[	$type12,	player_type13	] {};
void() player_type13  =[	$type13,	player_type14	] {};
void() player_type14  =[	$type14,	Player_Move	] {};



void() button_fire;

void() player_stab1	=[	$stab1,	player_stab2	] 
{W_FireKnife();};
void() player_stab2	=[	$stab2,	player_stab3	] {};
void() player_stab3	=[	$stab3,	Player_Move		] {};

void() player_slash1	=[	$slash1,	player_slash2	] 
{W_FireKnife();};
void() player_slash2	=[	$slash2,	player_slash3	] {};
void() player_slash3	=[	$slash3,	player_slash4	] {W_FireKnife();};
void() player_slash4	=[	$slash4,	Player_Move		] {};

void() player_shot1	=[	$shoota1,	player_shot2	] 
{
self.effects = self.effects | EF_MUZZLEFLASH;
playsound (self, CHAN_WEAPON, "weapons/pistol.wav", 1, ATTN_NORM);
MuzzleFlash(25, 0, 36); // up, right, forward
W_Pistol();
ThrowCasing();
};
void() player_shot2	=[	$shoota2,	player_shot3	] {};
void() player_shot3	=[	$shoota3,	Player_Move	] {};

void() player_reloada1	=[	$reloada1,	player_reloada2	] 
{ThrowClip();playsound (self, CHAN_WEAPON, "weapons/pclipout.wav", 1, ATTN_NORM);};
void() player_reloada2	=[	$reloada2,	player_reloada3	] {};
void() player_reloada3	=[	$reloada3,	player_reloada4	] {};
void() player_reloada4	=[	$reloada4,	player_reloada5	] {};
void() player_reloada5	=[	$reloada5,	player_reloada6	] {};
void() player_reloada6	=[	$reloada6,	player_reloada7	] {};
void() player_reloada7	=[	$reloada7,	player_reloada8	] {};
void() player_reloada8	=[	$reloada8,	player_reloada9	] {};
void() player_reloada9	=[	$reloada9,	Player_Move	] 
{playsound (self, CHAN_WEAPON, "weapons/preload.wav", 1, ATTN_NORM);};

void() player_shotgun1	=[	$shootb1,	player_shotgun2	] 
{
	MuzzleFlash2(20, 0, 30);
	ThrowCasing();
	playsound (self, CHAN_WEAPON, "weapons/shotgun1.wav", 1, ATTN_NORM);
	self.effects = self.effects | EF_MUZZLEFLASH;
	W_Shotgun();W_Shotgun();W_Shotgun();W_Shotgun();W_Shotgun();W_Shotgun();
};
void() player_shotgun2	=[	$shootb2,	player_shotgun3	] {};
void() player_shotgun3	=[	$shootb3,	player_shotgun4	] {};
void() player_shotgun4	=[	$shootb4,	player_shotgun5	] {};
void() player_shotgun5	=[	$shootb5,	player_shotgun6	] {playsound (self, CHAN_WEAPON, "weapons/shotgun2.wav", 1, ATTN_NORM);};
void() player_shotgun6	=[	$shootb6,	player_shotgun7	] {};
void() player_shotgun7	=[	$shootb7,	player_shotgun8	] {};
void() player_shotgun8	=[	$shootb8,	player_shotgun9	] {};
void() player_shotgun9  =[	$shootb9,	player_shotgun10	] {};
void() player_shotgun10  =[	$shootb10,	player_shotgun11	] {};
void() player_shotgun11  =[	$shootb11,	player_shotgun12	] {};
void() player_shotgun12	 =[	$shootb12,	Player_Move	] {};

void() player_reloadb1	=[	$reloadb1,	player_reloadb2	] {};
void() player_reloadb2	=[	$reloadb2,	player_reloadb3	] {};
void() player_reloadb3	=[	$reloadb3,	player_reloadb4	] {};
void() player_reloadb4	=[	$reloadb4,	player_reloadb5	] {};
void() player_reloadb5	=[	$reloadb5,	player_reloadb6	] {};
void() player_reloadb6	=[	$reloadb6,	Player_Move	] 
{
	local entity stemp;
	local float h;

	if (self.owner.shotgun_shots < 6 && self.owner.ammo_shells > 0)
	{
		playsound (self, CHAN_WEAPON, "weapons/sreload.wav", 1, ATTN_NORM);
		self.owner.shotgun_shots = self.owner.shotgun_shots + 1;
		self.owner.ammo_shells = self.owner.ammo_shells - 1;
		self.owner.armorvalue = self.owner.shotgun_shots;
		self.owner.lock_finished = time + 0.4;

		stemp = self;
		self = self.owner;
		W_SetCurrentAmmo(); // update ammo counter
		self = stemp;

		if (self.owner.shotgun_shots < 6 && self.owner.ammo_shells > 0)
			player_reloadb1();
		else
			return;
	}
};

void() player_assault1	=[	$shootc1,	player_assault2	] 
{
	MuzzleFlash3(17, 7, 24);
	ThrowCasing();
	playsound (self, CHAN_WEAPON, "weapons/assault.wav", 1, ATTN_NORM);
	self.effects = self.effects | EF_MUZZLEFLASH;
	W_Assault();
	self.owner.ammo_nails = self.owner.ammo_nails - 1;
};
void() player_assault2	=[	$shootc2,	Player_Move	] 
{
	if (self.owner.ammo_nails < 1)
		return; // ignore shot

	MuzzleFlash3(17, 7, 24);
	ThrowCasing();
	playsound (self, CHAN_WEAPON, "weapons/assault.wav", 1, ATTN_NORM);
	self.effects = self.effects | EF_MUZZLEFLASH;
	W_Assault();
	self.owner.ammo_nails = self.owner.ammo_nails - 1;
};

void() player_quickturn1	=[	$qturn1,	player_quickturn2	] 
{
self.angles_y = self.angles_y - 45;self.fixangle = TRUE;
playsound (self, CHAN_BODY, "player/step1.wav", 1, ATTN_NORM);
};
void() player_quickturn2	=[	$qturn2,	player_quickturn3	] {self.angles_y = self.angles_y - 45;self.fixangle = TRUE;};
void() player_quickturn3	=[	$qturn3,	player_quickturn4	] 
{
self.angles_y = self.angles_y - 45;self.fixangle = TRUE;
playsound (self, CHAN_BODY, "player/step2.wav", 1, ATTN_NORM);
};
void() player_quickturn4	=[	$qturn4,	Player_Move	] {self.angles_y = self.angles_y - 45;self.fixangle = TRUE;};

void() player_paina1  =[	$paina1,	player_paina2	] {};
void() player_paina2  =[	$paina2,	player_paina3	] {};
void() player_paina3  =[	$paina3,	player_paina4	] {};
void() player_paina4  =[	$paina4,	Player_Move	] {};

void() player_painb1  =[	$painb1,	player_painb2	] {};
void() player_painb2  =[	$painb2,	player_painb3	] {};
void() player_painb3  =[	$painb3,	player_painb4	] {};
void() player_painb4  =[	$painb4,	player_painb5	] {};
void() player_painb5  =[	$painb5,	Player_Move	] {};

void() player_pain =
{
	local float r, rs;
	local entity stemp;

	self.pain_finished = time + 0.5; // alert friendlies of injury

	r = random();
	// have friendly units apologize to corporal during misfire
	if (self.attacker.teams == self.teams)
	{
		stemp = self;
		self = self.attacker;
		self = stemp;
	}

	if (self.owner.lock_finished > time || self.health >= 30 || self.ladder_finished > time)
		return;
	if (r < 0.3)
		return;

	r = random();
	if (r < 0.5)
		player_paina1();
	else
		player_painb1();

	self.owner.lock_finished = time + 0.5; // hurt time
};

void() player_dead =
{
	self.effects = 0;
	sound (self, CHAN_VOICE, "player/death.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	self.deadflag = DEAD_DEAD;
	self.owner.items = self.owner.items | IT_DEADSIGN; // turns sbar face to "dead" sign, replaced invisibility from quake
};

void() player_decap1	=[0,		player_decap2] {player_dead();};
void() player_decap2	=[1,		player_decap3] {};
void() player_decap3	=[2,		player_decap4] {};
void() player_decap4	=[3,		player_decap5] {};
void() player_decap5	=[4,		player_decap6] 
{
	if (self.flags & FL_ONGROUND)
		playsound (self, CHAN_BODY, "misc/florhit.wav", 1, ATTN_NORM);
};
void() player_decap6	=[5,		player_decap6] {};

void() player_deatha1	=[	$deatha1,	player_deatha2	] {player_dead();};
void() player_deatha2	=[	$deatha2,	player_deatha3	] {};
void() player_deatha3	=[	$deatha3,	player_deatha4	] {};
void() player_deatha4	=[	$deatha4,	player_deatha5	] {};
void() player_deatha5	=[	$deatha5,	player_deatha6	] 
{
	if (self.flags & FL_ONGROUND)
		playsound (self, CHAN_BODY, "misc/florhit.wav", 1, ATTN_NORM);
	blood(-20,0,5);
};
void() player_deatha6	=[	$deatha6,	player_deatha6	] {};

void() player_deathb1	=[	$deathb1,	player_deathb2	] {player_dead();};
void() player_deathb2	=[	$deathb2,	player_deathb3	] {};
void() player_deathb3	=[	$deathb3,	player_deathb4	] {};
void() player_deathb4	=[	$deathb4,	player_deathb5	] {};
void() player_deathb5	=[	$deathb5,	player_deathb6	] {};
void() player_deathb6	=[	$deathb6,	player_deathb7	] {};
void() player_deathb7	=[	$deathb7,	player_deathb8	] 
{
	if (self.flags & FL_ONGROUND)
		playsound (self, CHAN_BODY, "misc/florhit.wav", 1, ATTN_NORM);
	blood(12,0,5);
};
void() player_deathb8	=[	$deathb8,	player_deathb8	] {};

void() player_deathc1	=[	$deathc1,	player_deathc2	] {player_dead();};
void() player_deathc2	=[	$deathc2,	player_deathc3	] {};
void() player_deathc3	=[	$deathc3,	player_deathc4	] {};
void() player_deathc4	=[	$deathc4,	player_deathc5	] {};
void() player_deathc5	=[	$deathc5,	player_deathc6	] {};
void() player_deathc6	=[	$deathc6,	player_deathc7	] {};
void() player_deathc7	=[	$deathc7,	player_deathc8	] {};
void() player_deathc8	=[	$deathc8,	player_deathc9	] {};
void() player_deathc9	=[	$deathc9,	player_deathc10	]
{
	if (self.flags & FL_ONGROUND)
		playsound (self, CHAN_BODY, "misc/florhit.wav", 1, ATTN_NORM);
	blood(0,0,5);
};
void() player_deathc10	=[	$deathc10,	player_deathc10	] {};

void() player_whichdeath =
{
	if (self.deathtype == 0)
	{
		local float r;

		r = random();
		if (r < 0.3)
			player_deatha1();
		else if (r < 0.7)
			player_deathb1();
		else
			player_deathc1();
	}
	else if (self.deathtype == 1)
	{
		playsound (self, CHAN_BODY, "player/decaped.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_corp.mdl", self.health);
		setmodel(self, "progs/decap.mdl");
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
		player_decap1();
		blood(-30,0,2);
	}
};

void() cross_update =
{
	if (self.owner.deadflag == DEAD_DEAD)
	{
		remove(self);
		return;
	}

	makevectors (self.owner.angles);
	traceline (self.owner.origin , (self.owner.origin+(v_forward * 500)) , FALSE , self);
	setorigin (self, trace_endpos + (v_forward * -5));
	if (trace_ent.flags & FL_MONSTER && trace_ent.teams != "human")
	{
		if (self.frame < 1)
		{
			self.frame = 1;
			sound (self.owner, CHAN_WEAPON, "misc/lockon.wav", 1, ATTN_NORM);
		}
		else
		{

			self.frame = self.frame + 1;
			if (self.frame > 2)
				self.frame = 1;
		}
	}
	else
		self.frame = 0;
	self.nextthink = time + 0.01;
};

.entity cross;
void() crosshair =
{
	local entity mycross;

	if (self.cross)
		return;

	mycross = spawn ();
	mycross.movetype = MOVETYPE_NONE;
	mycross.solid = SOLID_NOT;
	setmodel (mycross, "progs/c_hair.spr"); 
	setsize (mycross, '0 0 0', '0 0 0');

	mycross.owner = self.char;
	self.cross = mycross;
        
	mycross.classname = "crosshair";
        
	makevectors (self.angles);
	traceline (self.origin , (self.origin + (v_forward * 500)) , FALSE , self);
	setorigin (mycross, trace_endpos);
	mycross.think = cross_update;
	mycross.nextthink = time + 0.01;
};

void() Player_Climb = [0 , Player_Climb]
{
	local float tt;

	tt = ceil(random() * 4);

	if (self.owner.keyflags & KEY_UP || self.owner.keyflags & KEY_DOWN && cutscene == FALSE)
	{
		self.frame = $climb1 + self.walkframe;
		if (self.walkframe > 6)
			self.walkframe = 0;
		if (self.walkframe == 1 || self.walkframe == 5)
		{
			if (tt == 1)
				playsound (self, CHAN_AUTO, "player/lstep1.wav", 1, ATTN_NORM);
			else if (tt == 2)
				playsound (self, CHAN_AUTO, "player/lstep2.wav", 1, ATTN_NORM);
			else if (tt == 3)
				playsound (self, CHAN_AUTO, "player/lstep3.wav", 1, ATTN_NORM);
			else
				playsound (self, CHAN_AUTO, "player/lstep3.wav", 1, ATTN_NORM);
		}
		self.walkframe = self.walkframe + 1;
	}
	else
		self.frame = $climb1 + self.walkframe;
	if (self.ladder_finished < time || self.flags & FL_ONGROUND)
		Player_Move();
};

void() player_getup1	=[	$fall6,	player_getup2 ] {self.nextthink = time + 0.3;};
void() player_getup2	=[	$fall7,	Player_Move	] {};

.float jump_flag;
void() Player_Fall = [0 , Player_Fall]
{
	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
	if (self.walkframe < 4)
		self.walkframe = self.walkframe + 1;
	self.frame = $fall1 + self.walkframe;
	if (self.flags & FL_ONGROUND)
	{
		if (self.health > 0) // falling damage
		{
			if (self.jump_flag < -600)
				T_Damage (self, world, world, 15);
			else if (self.jump_flag < -800)
				T_Damage (self, world, world, 20);
			else if (self.jump_flag < -1000)
				T_Damage (self, world, world, 25);
		}

		self.jump_flag = 0;
		self.owner.lock_finished = time + 0.6;
		player_getup1();
		self.owner.turnlock_finished = time + 0.5;
		sound (self, CHAN_BODY, "player/land.wav", 1, ATTN_NORM);
		self.owner.runmode = FALSE;
	}
};

// ---
// Step sounds
// ---

void() StepSound =
{
	local float tt;

	tt = ceil(random() * 2);

	if ((self.walkframe == 2) && (self.flags & FL_ONGROUND))
	{
		if (self.flags & FL_INWATER)
		{
			if (self.waterlevel == 1)
				playsound (self, CHAN_AUTO, "player/wstep1.wav", 1, ATTN_NORM);
		}
		else
		{
			if (tt == 1)
				playsound (self, CHAN_AUTO, "player/step1.wav", 1, ATTN_NORM);
			else 
				playsound (self, CHAN_AUTO, "player/step2.wav", 1, ATTN_NORM);
		}
	}
	if ((self.walkframe == 5) && (self.flags & FL_ONGROUND))
	{
		if (self.flags & FL_INWATER)
		{
			if (self.waterlevel == 1)
				playsound (self, CHAN_AUTO, "player/wstep2.wav", 1, ATTN_NORM);
		}
		else
		{
		if (tt == 1)
			playsound (self, CHAN_AUTO, "player/step3.wav", 1, ATTN_NORM);
		else 
			playsound (self, CHAN_AUTO, "player/step4.wav", 1, ATTN_NORM);
		}
	}
};

void() Player_Move = [0 , Player_Move] 
{
	if (!self.flags & FL_ONGROUND)
	{
		if (self.ladder_finished > time)
			Player_Climb();
		else if (self.velocity_z < -175)
		{
			self.walkframe = 0;
			Player_Fall();
		}
	}

	// don't just check velocity, allow sliding without movement frames playing
	if (self.owner.keyflags & KEY_UP || self.owner.keyflags & KEY_DOWN && self.velocity_x || self.velocity_y)
	{
		if (self.owner.weapon == W_MELEE || self.owner.weapon == W_PISTOL)
		{
			if (self.owner.keyflags & KEY_DOWN && self.owner.runmode != FALSE)
				self.owner.runmode = FALSE;

			if (self.owner.runmode == FALSE)
			{
				if (self.walkframe == 6 || self.walkframe == 12 && self.flags & FL_ONGROUND && self.velocity_z > -175)
					playsound (self, CHAN_BODY, "player/step.wav", 1, ATTN_NORM);
				if (self.walkframe > 11)
					self.walkframe = 0;
				self.frame = $walka1 + self.walkframe;
			}
			else
			{
				StepSound ();
				if (self.walkframe > 5)
					self.walkframe = 0;
				self.frame = $runa1 + self.walkframe;
			}
		}
		else if (self.owner.weapon == W_SHOTGUN || self.owner.weapon == W_ASSAULT)
		{
			if (self.owner.runmode == FALSE)
			{
				if (self.walkframe == 6 || self.walkframe == 12 && self.flags & FL_ONGROUND && self.velocity_z > -175)
					playsound (self, CHAN_BODY, "player/step.wav", 1, ATTN_NORM);
				if (self.walkframe > 11)
					self.walkframe = 0;
				self.frame = $walkb1 + self.walkframe;
			}
			else
			{
				StepSound ();
				if (self.walkframe > 5)
					self.walkframe = 0;
				self.frame = $runb1 + self.walkframe;
			}
		}
	}
	else
	{
		if (self.owner.battle_ready == FALSE)
		{
			if (self.walkframe > 13)
				self.walkframe = 0;
			self.frame = $stand1 + self.walkframe;
		}
		else // battle stances
		{
			if (self.owner.weapon == W_MELEE)
				self.frame = $stancea1;
			else if (self.owner.weapon == W_PISTOL)
				self.frame = $stanceb1;
			else if (self.owner.weapon == W_SHOTGUN)
				self.frame = $stancec1;
			else if (self.owner.weapon == W_ASSAULT)
				self.frame = $stanced1;
		}
	}
	self.walkframe = self.walkframe + 1;
};

void() W_SetCurrentAmmo;
.float quickturn_finished;
void() P_Attack = 
{
	local float r;

	if (self.lock_finished > time)
		return;

	r = random();
	W_SetCurrentAmmo();

	if (self.weapon == W_MELEE)
	{
		if (self.keyflags & KEY_UP)
		{
			if (r < 0.5)
			{
				self.char.think = player_stab1;
				self.lock_finished = time + 0.5;
			}
			else
			{
				self.char.think = player_slash1;
				self.lock_finished = time + 0.8;
			}
		}
	}
	if (self.weapon == W_PISTOL)
	{
		if (self.keyflags & KEY_UP)
		{
			if (self.pistol_shots == 0 && self.ammo_nails == 0)
			{
				playsound (self.char, CHAN_WEAPON, "weapons/noammo.wav", 1, ATTN_NORM);
				self.lock_finished = time + 0.4;
				return;
			}
			if (self.pistol_shots > 0)
				self.pistol_shots = self.pistol_shots - 1;
			else
			{
				reload();
				return;
			}
			self.armorvalue = self.pistol_shots;
			self.char.hostile_finished = time + 0.3;
			self.char.think = player_shot1;
			self.lock_finished = time + 0.4;
		}
	}
	if (self.weapon == W_SHOTGUN)
	{
		if (self.keyflags & KEY_UP)
		{
			if (self.shotgun_shots == 0 && self.ammo_shells == 0)
			{
				playsound (self.char, CHAN_WEAPON, "weapons/noammo.wav", 1, ATTN_NORM);
				self.lock_finished = time + 0.4;
				return;
			}
			if (self.shotgun_shots == 0)
			{
				reload();
				return;
			}
			else
				self.shotgun_shots = self.shotgun_shots - 1;
			
			self.armorvalue = self.shotgun_shots;
			self.char.hostile_finished = time + 1;
			self.char.think = player_shotgun1;
			self.lock_finished = time + 1.5;
		}
	}
	if (self.weapon == W_ASSAULT)
	{
		self.armorvalue = self.ammo_nails;
		if (self.keyflags & KEY_UP)
		{
			if (self.ammo_nails == 0)
			{
				playsound (self.char, CHAN_WEAPON, "weapons/noammo.wav", 1, ATTN_NORM);
				self.lock_finished = time + 0.4;
				return;
			}
			// ammo delt in shooting frames
			self.char.hostile_finished = time + 0.1;
			self.char.think = player_assault1;
			self.lock_finished = time + 0.3;
		}
	}
	if (self.keyflags & KEY_DOWN && self.quickturn_finished < time)
	{
		self.char.think = player_quickturn1;
		self.char.nextthink = time + 0.01;
		self.quickturn_finished = time + 0.6;
	}
};

// =====
// flash light
// =====

void() flashlight_switch =
{
	if (self.char.deadflag != DEAD_NO)
		return;
	if (!self.chips & IT_CHIP1)
		return;

	if (self.flashlight_flag == FALSE)
	{
		sound (self.char, CHAN_BODY, "player/flash_on.wav", 1, ATTN_NORM);
		self.flashlight_flag = TRUE;
		self.char.effects = EF_DIMLIGHT;
	}
	else
	{
		sound (self.char, CHAN_BODY, "player/flash_of.wav", 1, ATTN_NORM);
		self.flashlight_flag = FALSE;
		self.char.effects = 0;
	}
};

/*
============
View Weapons
============
*/

void() VWep_Think =
{
	if (self.owner.char.health < 1)
	{
		remove(self);
		return;
	}

	if (self.owner.weapon == W_MELEE)
		setmodel(self, "progs/vw_knife.mdl");
	else if (self.owner.weapon == W_PISTOL)
		setmodel(self, "progs/vw_pist.mdl");
	else if (self.owner.weapon == W_SHOTGUN)
		setmodel(self, "progs/vw_shotg.mdl");
	else if (self.owner.weapon == W_ASSAULT)
		setmodel(self, "progs/vw_asalt.mdl");
	else
		setmodel(self, string_null);

	self.frame = self.owner.char.frame;
	self.origin = self.owner.char.origin;
//	self.angles_x = self.owner.char.angles;
	self.nextthink = time + 0.01;
};

void() VWep =
{
	local entity vwep;

	vwep = spawn();
	vwep.owner = self;
	vwep.classname = "vwep";
	vwep.movetype  = MOVETYPE_NOCLIP;
	vwep.solid     = SOLID_NOT;
	vwep.think = VWep_Think;
	vwep.nextthink = time + 0.1;
};

void() Setup_Player =
{
	local entity bot, spoint;
	bot = spawn();

	spoint = find(world, classname, "info_player_start");
	setorigin(bot, spoint.origin);
	setmodel(bot, "progs/corporal.mdl");
	setsize (bot, VEC_HULL_MIN, VEC_HULL_MAX);
	bot.solid = SOLID_SLIDEBOX;
	bot.takedamage = DAMAGE_AIM;
	bot.owner = self;
	bot.classname = "player";
	bot.netname = "player";
	bot.movetype = MOVETYPE_WALK;
	bot.angles = spoint.angles;
	bot.fixangle = TRUE;
	self.char = bot;
	bot.think = Player_Move;
	bot.nextthink = time;
	bot.max_health = 100;
	bot.health = decode(parm1, 1);
	bot.deadflag = DEAD_NO;
	bot.th_die = player_whichdeath;
	bot.th_pain = player_pain;
	bot.teams = "human";
	if (self.chips & IT_CHIP2) // spawn crosshair with chip
		crosshair();
	VWep();
	self.goalentity = bot; // camera tracks corporal every map change
};
