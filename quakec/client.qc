/*
+------+
|Client|
+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

// background music
.float bgm_count;
.float bgm_length;

void(entity reciever, float vol, float attenuation, float soundnum, vector where, float chan) music;
void() CheckImpulses;
void() W_SetCurrentAmmo;

void() ClientKill = {};
void() ClientConnect = {};
void() ClientDisconnect = {};

float (float y1, float y2) angcomp = 
{
	local float answer;

	y1 = anglemod(y1);
	y2 = anglemod(y2);

	answer = y1 - y2;
	if (answer > 180) answer = (360 - answer) * -1;
	else if (answer < -180) answer = answer + 360;
	return answer;
};

.float flashtime_finished; // flash lights time
.float spawntime;
.float blackbars_finished; // animation time for black cutscene borders

void() PlayerPreThink =
{
	local vector view;
	local float plyr_y;

	if (self.spawntime)
	{
		if (time > self.spawntime)
		{

			stuffcmd(self, "viewsize 100\n");
			stuffcmd(self, "-mlook;sv_maxvelocity 3500;name Corporal;exec controls.cfg;scr_centertime 5;sensitivity 0;crosshair 0\n");
			self.spawntime = 0;
		}
	}

	if (self.goalentity)
	{
		view = vectoangles(self.goalentity.origin - self.origin); // track any goal entity
		self.angles_x = view_x * -1;
		self.angles_y = view_y;

		if (self.cam_style == 1)
		{
			if (self.goalentity.ladder_finished < time)
			{
				if (self.test_org_z < self.goalentity.origin_z)
					self.test_org_z = self.test_org_z + 50 * frametime;
				if (self.test_org_z > self.goalentity.origin_z)
					self.test_org_z = self.test_org_z - 50 * frametime;
				self.origin_z = self.test_org_z;
			}
			else
				self.test_org_z = self.goalentity.origin_z;
		}
		self.fixangle = TRUE;
	}

	
	self.test_org = self.origin;
};

.float heart_finished; // low health indicator
void() PlayerPostThink =
{
	local vector tree, source;
	local entity stemp;

	//* title screen *
	if (world.model == "maps/start.bsp")
	{
		if (self.button0)
		{
			if (title1_finished > time)
				return;
			sound (self, CHAN_VOICE, "items/pk_wep.wav", 1, ATTN_NONE);
			title1_finished = time + 1.5;
			self.mode = 1;
		}
		if (title1_finished < time && self.mode == 1)
			changelevel ("ship1");

		if (self.v_angle != self.lock_view.angles)
		{
			self.angles = self.lock_view.angles;
			self.fixangle = TRUE;
		}
		return;
	}


	// FrikaC: keyflag control system begin (suggested improvements by LordHavoc)
	if (self.origin != self.test_org)
	{
		makevectors(self.v_angle);
		self.keyflags = 0;
		tree = self.test_org - self.origin;
		if (tree_z < -1)
			self.keyflags = self.keyflags | KEY_UP;
		else if (tree_z > 1)
			self.keyflags = self.keyflags | KEY_DOWN;
		if (v_right * tree < -1)
			self.keyflags = self.keyflags | KEY_RIGHT;
		else if (v_right * tree > 1)
			self.keyflags = self.keyflags | KEY_LEFT;
	}
	else
		self.keyflags = 0;

	if (self.char != world && self.char.deadflag == DEAD_NO)
	{
		if (self.flashlight_flag && self.char.health > 0) // flashlight on
		{
			if (self.flashtime_finished < time)
			{
				self.flashjuice = self.flashjuice + 1;
				self.flashtime_finished = time + 1;
				if (self.flashjuice == 1)
					sprint (self, "Flashlight Power: 100%\n");
				else if (self.flashjuice == 11)
					sprint (self, "Flashlight Power: 75%\n");
				else if (self.flashjuice == 23)
					sprint (self, "Flashlight Power: 50%\n");
				else if (self.flashjuice == 34)
					sprint (self, "Flashlight Power: 25%\n");
			}
			if (self.flashjuice >= 45)
			{
				sprint (self, "Flashlight Power: Depleted.\n");
				sound (self.char, CHAN_BODY, "player/flash_of.wav", 1, ATTN_NORM);
				self.flashlight_flag = FALSE;
				self.char.effects = 0;
			}
			else
				self.char.effects = EF_DIMLIGHT;
		}
		else if (self.chips & IT_CHIP1) // flash light recharges
		{
			if (self.flashtime_finished < time && self.flashjuice > 0)
			{
				self.flashjuice = self.flashjuice - 1;
				self.flashtime_finished = time + 0.5;
				if (self.flashjuice == 1)
					sprint (self, "Flashlight Power: 100%\n");
				else if (self.flashjuice == 11)
					sprint (self, "Flashlight Power: 75%\n");
				else if (self.flashjuice == 23)
					sprint (self, "Flashlight Power: 50%\n");
				else if (self.flashjuice == 34)
					sprint (self, "Flashlight Power: 25%\n");
			}
		}
		// display health on sbar
		if (self.char.health > 0)
			self.health = self.char.health;
		else
			self.health = 1;

		// gradual healing from medical kits
		if (self.heal_amount > 0)
		{
			if (self.heal_finished < time) // using up to 3 health kits at once will result in health
			{					 // being gained back very quickly
				self.heal_amount = self.heal_amount - 1;
				if (self.char.health < self.char.max_health)
					self.char.health = self.char.health + 1;
				if (self.heal_amount <= 25)
					self.heal_finished = time + 0.4;
				else if (self.heal_amount > 25 && self.heal_amount < 50)
					self.heal_finished = time + 0.2;
				else
					self.heal_finished = time + 0.1;
			}
		}

		// ladder climbing main code
		if (self.char.ladder_finished > time && self.noladder_finished < time)
		{
			self.char.velocity_x = self.char.velocity_y = 0;
			self.runmode = FALSE;
			if (self.char.movetype != MOVETYPE_FLY)
				self.char.movetype = MOVETYPE_FLY;
			if (self.keyflags & KEY_UP || self.keyflags & KEY_DOWN)
			{
				if (self.keyflags & KEY_UP)
					self.char.velocity_z = 30;
				else
					self.char.velocity_z = -50;
			}
			else
				self.char.velocity = '0 0 0';
		}
		else if (self.char.movetype != MOVETYPE_STEP)
			self.char.movetype = MOVETYPE_STEP;

		if (self.char.flags & FL_ONGROUND)
		{
			self.char.flags = self.char.flags - FL_ONGROUND;
			if (self.battle_ready == FALSE) // Can't move in fighting stance
			{
				if (self.keyflags & KEY_UP || self.keyflags & KEY_DOWN && self.lock_finished < time)
				{
					// Double tap Run - Start
					if (self.dbltime == 0)
						self.dbltime = time + 0.5;
					else if (self.dbltime < 0)
					{
						if ((0 - self.dbltime) >= time && (self.keyflags & KEY_UP)) // Up only
						{
	                                    if (self.runmode == FALSE)
								self.runmode = TRUE;
						}
						else
						{
							self.dbltime = time;
						}
					}
					// Double tap Run - End

					makevectors (self.char.angles);
					if (self.keyflags & KEY_UP)
					{
						if (self.runmode == FALSE)
							self.char.velocity = v_forward * 70; // Non running foward speed
						else
							self.char.velocity = v_forward * 110; // Running forward speed
					}
					else
					{
						if (self.char.ladder_finished > time) // needed to help corporal get on ladders faster
							self.char.velocity = v_forward * -120; // when going back down them
						else
							self.char.velocity = v_forward * -35;
					}
				}
				else
				{
					if (self.runmode == TRUE)
						self.runmode = FALSE;
					self.char.velocity = '0 0 0';
					// Double tap Run - Start
					if (self.dbltime > 0)
					{
						if (self.dbltime >= time)
							self.dbltime = 0 - (time + 0.5);
						else
							self.dbltime = 0;
					}
					else if (self.dbltime < 0)
					{
						if ((0 - self.dbltime) < time)
							self.dbltime = 0;
					}
					// Double tap Run - End
				}
			}
			else
			{
				P_Attack();
				self.char.velocity = '0 0 0';
			}

			if (self.char.ladder_finished < time && self.turnlock_finished < time)
			{
				if (self.keyflags & (KEY_LEFT | KEY_RIGHT))
				{
					if (self.keyflags & KEY_RIGHT)
					{
						if (self.battle_ready == FALSE)
							self.char.angles_y = self.char.angles_y - 240 * frametime;
						else
							self.char.angles_y = self.char.angles_y - 140 * frametime;
					}
					else
					{
						if (self.battle_ready == FALSE)
							self.char.angles_y = self.char.angles_y + 240 * frametime;
						else
							self.char.angles_y = self.char.angles_y + 140 * frametime;
					}
				}
				if (self.button0) // attack stance
					self.battle_ready = TRUE;
				else
					self.battle_ready = FALSE;
			}
		}
	}

	// beating heart, damage indicator
	if (self.heart_finished < time && self.char.health < 40 && self.char.deadflag != DEAD_DEAD && cutscene == FALSE)
	{
		if (self.char.health < 40 && self.char.health > 30)
			self.heart_finished = time + 2;
		else if (self.char.health < 30 && self.char.health > 20)
			self.heart_finished = time + 1.5;
		else if (self.char.health < 20 && self.char.health > 10)
			self.heart_finished = time + 1;
		else if (self.char.health < 10)
			self.heart_finished = time + 0.5;
		else
			self.heart_finished = time + 3;

		if (coop) // in coop this shouldn't be heard by other clients

			stuffcmd (self, "play misc/heart.wav");
		else
			sound (self, CHAN_BODY, "misc/heart.wav", 1, ATTN_NORM);
	}
	// music code
	if (self.bgm_length < time)
	{
		if (self.musicstate == 1)
		{
			music(self, 1, ATTN_NONE, 1, self.origin, CHAN_MUSIC);
			self.bgm_length = time + self.bgm_count;
		}
		if (self.musicstate == 2)
		{
			music(self, 1, ATTN_NONE, 2, self.origin, CHAN_MUSIC);
			self.bgm_length = time + self.bgm_count;
		}
	}

	CheckImpulses();
	setorigin(self, self.test_org);
	self.velocity = '0 0 0';
};

void() cameradie =
{
	sound (self, CHAN_BODY, "intro/camdie.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_NONE;
	self.view_ofs = '0 0 0';
	self.velocity = '0 0 0';
};

// Put trigger_camera around start position.
void() PutClientInServer =
{
	local entity spoint, targ;

//	setmodel (self, "progs/null.spr");
	self.spawntime = time + 0.1;

	spoint = find (world, classname, "info_player_start");
	self.classname = "camera";
	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_WALK; 
	self.flags = FL_CLIENT;
	self.origin = spoint.origin;
//	setmodel (self, "progs/null.spr");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.view_ofs = '0 0 22';
	self.velocity = '0 0 0';
	self.modelindex = 0;
	self.angles = '0 -90 0';
	return;
	
};