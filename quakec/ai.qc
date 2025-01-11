void() SUB_Remove;
.float ai_angry; // AI is angry at ally and attacks
.float following; // boolean
entity	sight_entity;
float	sight_entity_time;
.float noturn; // true means monsters won't turn
.entity ai_poscheck;
.float ai_poscheck_touched; // boolean

float(float pang) anglemod =
{
	while (pang > 360) pang = pang - 360;
	while (pang < 0) pang = pang + 360;
	return pang;
};

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range =
{
	local vector	spot1, spot2;
	local float		r;	

	spot1 = self.origin;
	spot2 = targ.origin;
	
	r = vlen (spot1 - spot2);
	if (r < 55)
		return RANGE_MELEE;
	if (r < 90)
		return RANGE_CLOSE;
	if (r < 125)
		return RANGE_NEAR;
	if (r < 500)
		return RANGE_MID;
	return RANGE_FAR;
};

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible =
{
	local vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents
	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if (dot > 0.3)
		return TRUE;
	return FALSE;
};

void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
};
 
void() FoundTarget =
{
	local entity stemp;
	HuntTarget ();
};

/*
=============
ai_face
turn towards the enemy
=============
*/
void() ai_face =
{
	if (self.goalentity)
	{
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		ChangeYaw ();
	}
};

void() ai_quickturn =
{
	local vector view;

	if (self.goalentity)
	{
		view = vectoangles(self.goalentity.origin - self.origin);
		self.angles_y = view_y;
		self.fixangle = TRUE;
	}
};

void() ai_stand;

.float	lefty;

void() CheckTouch =
{
	if (other.flags & FL_MONSTER)
	{
		if (other.ai_poscheck == self && other.goalentity != world)
		{
			other.ai_poscheck_touched = TRUE;
			other.angles_y = self.angles_y;
			other.goalentity = world;
			other.enemy = world;
			remove(self);
			return;
		}
	}
};

.float jump_finished;
void() ai_jump =
{
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 175 + '0 0 285';
	if (self.flags & FL_ONGROUND)
	{
		self.flags = self.flags - FL_ONGROUND;
		self.jump_finished = time + 0.1;
	}
};

void() soldier_jumpa1;
void() check_for_ledge =
{
	local vector spot;

	makevectors (self.angles);
	spot = self.origin + (v_forward * 35 - v_up * 35);
	if (pointcontents(spot) == CONTENT_EMPTY)
	{
		if (self.classname == "soldier")
			soldier_jumpa1();
	}
	if (self.jump_finished < time)
		self.velocity = v_forward * 235;
};

/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/

.vector dest;
.float search_count;

void(float dist) ai_run =
{
	local float r, r2;
	local entity check;
	local vector org;

	// this code is to make the AI properly interact with moving plats
	if (self.goalentity.classname == "plat")
	{
		check = spawn();
		check.movetype = MOVETYPE_NONE;
		check.solid = SOLID_NOT;
		setmodel (check, "progs/corporal.mdl");
		setorigin (check, self.goalentity.origin);

		r = range(self.goalentity);

		if (self.goalentity.enemy.state == STATE_LOWERED)
		{
			if (r > RANGE_CLOSE)
			{
				bprint ("Monster needs to get closer to plat\n");
				self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
				ChangeYaw ();
				movetogoal(self.speed);
			}
			else
			{
				bprint ("Monster is close enough to plat, stay!\n");
				self.th_stand();
				return;			
			}
		}
		if (self.goalentity.enemy.state == STATE_RAISED)
		{
			if (r < RANGE_CLOSE)
			{
				self.ideal_yaw = vectoyaw(self.goalentity.origin + self.origin);
				ChangeYaw ();
				movetogoal(self.speed);
			}
			else
			{
				self.th_stand();
				return;
			}
		}
		return;
	}

	// the monster here is trying it's hardest to find it's enemy again
	if (!self.enemy && self.ai_poscheck != world && self.ai_poscheck_touched == TRUE)
	{
		if (self.search_count >= 40)
		{
			self.noturn = FALSE;
			self.th_stand();
			self.search_count = 0;
		}
		else
			self.search_count = self.search_count + 1;
	}

	if (self.enemy)
	{
		self.state = FALSE;
		if (self.enemy.health <= 0)
		{
			self.ai_angry = FALSE; // avoid shooting teammates
			self.enemy = world;
			self.th_stand();
			return;
		}

		if (!visible(self.enemy))
		{
			if (!self.ai_poscheck) // the monster here is recording the last position and angle he saw the player
			{
				check = spawn();
				check.movetype = MOVETYPE_NONE;
				check.solid = SOLID_TRIGGER;
				setmodel (check, string_null);
				check.touch = CheckTouch;
				check.angles_y = self.enemy.angles_y;
				setsize (check, '-16 -16 0', '16 16 56');
				setorigin (check, self.enemy.origin);
				self.search_count = 0;
				self.ideal_yaw = vectoyaw(check.origin - self.origin);
				self.ai_poscheck = check;
				self.goalentity = self.ai_poscheck;
				ai_quickturn();
			}
		}
		else
		{
			if (self.ai_poscheck) // remove the recorded entity because he saw his enemy again
			{
				self.ai_poscheck.think = SUB_Remove;
				self.ai_poscheck.nextthink = time + 0.1;
				self.ai_poscheck_touched = FALSE;
				self.goalentity = self.enemy;
				self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
				self.ai_poscheck = world;
			}
			ai_face();
		}

		if (CheckAttack())
			return;
	}
			if (self.ai_poscheck) // remove the recorded entity because the soldier saw corporal again
			{
				self.ai_poscheck.think = SUB_Remove;
				self.ai_poscheck.nextthink = time + 0.1;
				self.ai_poscheck_touched = FALSE;
				self.goalentity = self.friend;
				self.ideal_yaw = vectoyaw(self.friend.origin - self.origin);
				self.ai_poscheck = world;
			}
			// only smart path find under these 2 conditions:
			// A) If the user is within 5 units of the soldiers Z origin (this allows soldiers to climb the
			// giant staircase in the Cargo Deck.
			// B) If goalentity range is over melee, so the soldier doesn't constantly run into corporal
			// even while in the soldiers idle zone.
			if (self.origin_z < self.friend.origin_z + 5 && self.origin_z > self.friend.origin_z - 5)
			{
				r = range(self.friend);
				if (r > RANGE_MELEE)
				{
					makevectors (self.angles);
					traceline(self.origin, self.friend.origin, TRUE, self);
					if (trace_fraction == 1 || trace_ent == self.friend)
						self.dest = self.friend.origin;
					self.ideal_yaw = vectoyaw(self.dest - self.origin);
				}
			}
			check_friendly();
			self.search_count = 0;
		}
	}
	ai_targetsearch();

 	setorigin(self, self.origin); // helps monsters touch solid_trigger entities

	if (self.search_count > 0 && self.ai_poscheck != world && self.ai_poscheck_touched == TRUE)
	{
		// coffee's tutorbot roaming code
		if (walkmove (self.angles_y, self.speed) == FALSE)
			if (walkmove (self.angles_y + self.button1, self.speed) == FALSE)
				self.angles_y = self.angles_y + (self.button1 / 2);

		// every so often, we'll change the wall-hugging direction
		if (random() <= 0.02)
			if (self.button1 == 90)
				self.button1 = -90;
			else
				self.button1 = 90;
	}
	else
	{
		if (!walkmove(self.angles_y, dist))
			movetogoal(dist);
	}
};


void() walkmonster_start_go =
{
	local string	stemp;
	local entity	etemp;

	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	if (!self.mode)
		droptofloor();
	
	self.flags = self.flags | FL_MONSTER;
	self.th_stand (); // start thinking
	// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};

void() monster_start =
{
	// delay drop to floor to make sure all doors have been spawned
	// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = walkmonster_start_go;
	total_monsters = total_monsters + 1;
};