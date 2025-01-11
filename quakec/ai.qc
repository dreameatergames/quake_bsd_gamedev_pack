void() SUB_Remove;
.entity friend;
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

void() FollowFriendly =
{
	local float r;

	if (self.goalentity.classname == "plat")
		return;

	r = range (self.friend);

	self.following = TRUE;
	self.goalentity = self.friend;
	self.think = self.th_run;
	if (r == RANGE_MELEE)
		self.ideal_yaw = vectoyaw(self.friend.origin - self.origin); // avoid if too close
	else
		self.ideal_yaw = vectoyaw(self.friend.origin - self.origin); // else, follow
	self.nextthink = time + 0.1;
};
 
void() FoundTarget =
{
	local entity stemp;

//	if (self.teams == "human")
//	{
//		if (self.enemy.teams != "human") // shout taunt at enemy
//			soldier_speak(0); - replace with other variable
//		else // human team member was betrayed
//		{
//			self.friend = world;
//			self.voice_finished = time;
//			soldier_speak(8); - replace with other variable
//		}
//	}
//	HuntTarget ();
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

void() FindFriendly =
{
	local entity love;

	// have soldiers follow player
	love = find(world, classname, "player");
	while (love)
	{
		if (visible(love) && infront(love) && love.health > 0)
		{
			if (!self.enemy)
// 				soldier_speak(4); - replace with other variable
			self.friend = love;
			FollowFriendly();
			return;
		}
		love = find(love, classname, "player");
	}
};


// ==============
// FindTarget
// ===============

.float lasthate_time;
.string enemyteam;
float() FindTarget =
{
	local entity hate, y;

	hate = find(world, teams, self.enemyteam);

	// soldier does a radius seach for worms around him
	if (self.teams == "human")
	{
		y = findradius(self.origin + v_up * 4, 80);
		while (y)
		{
			if (y.classname == "worm" && y.health > 0 && visible(y))
			{
				self.enemy = y;
				FoundTarget ();
				return TRUE;
			}
			y = y.chain;
		}
	}

	while (hate)
	{

		if (infront(hate) && visible(hate))
			break;

		hate = find(hate, teams, self.enemyteam);
	}

	if (hate == self.enemy)
		return FALSE;
	if (hate.health <= 0)
		return FALSE;
	if (hate.classname == "player")
	{
		if (hate.owner.flags & FL_NOTARGET)
			return FALSE;
	}

	self.enemy = hate;
	FoundTarget ();
	return TRUE;
};

void() ai_stand;
void() check_friendly = // soldiers do a check up on corporal almost every frame
{
	local float r;

	if (self.friend.pain_finished > time && visible(self.friend))
	{
		if (!self.enemy && self.friend.attacker.teams != "human")
		{
			self.enemy = self.friend.attacker;
			FoundTarget ();
			return;
		}
	}

	if (self.friend.health <= 0)
	{
		if (self.teams == "human" && visible(self.friend))
//			soldier_speak(6); - replace with other variable

		self.friend = world;
		self.following = FALSE;
		if (!visible(self.enemy))
			self.th_stand();
		return;
	}

	if (self.following == TRUE)
	{
		r = range (self.friend);
		if (r == RANGE_CLOSE)
		{
			self.following = FALSE;
			self.th_stand();
			return;
		}
	}
	else if (self.orders != AI_WAIT)
	{
		r = range (self.friend);
		if (r != RANGE_CLOSE)
			FollowFriendly();			
	}
};

.float searchteam;
void() ai_targetsearch =
{
	if (!self.friend && self.teams == "human" && self.ai_angry == FALSE)
		FindFriendly();

	if (self.searchteam == 0)
	{
		// Search #1
		if (self.teams == "human")
			self.enemyteam = "envenom"; // human vs envenom
		else if (self.teams == "envenom")
			self.enemyteam = "baeloth"; // envenom vs baeloth
		else if (self.teams == "baeloth")
			self.enemyteam = "robot"; // baeloth vs robot
		else if (self.teams == "robot")
			self.enemyteam = "envenom"; // robot vs envenom
		if (FindTarget())
			return;
	}
	else if (self.searchteam == 1)
	{
		// Search #2
		if (self.teams == "human")
			self.enemyteam = "baeloth"; // human vs baeloth
		else if (self.teams == "envenom")
			self.enemyteam = "human"; // envenom vs human
		else if (self.teams == "baeloth")
			self.enemyteam = "envenom"; // baeloth vs envenom
		else if (self.teams == "robot")
			self.enemyteam = "human"; // robot vs human
		if (FindTarget())
			return;
	}
	else if (self.searchteam == 2)
	{
		// Search #3
		if (self.teams == "human")
			self.enemyteam = "robot"; // human vs robot
		else if (self.teams == "envenom")
			self.enemyteam = "robot"; // envenom vs robot
		else if (self.teams == "baeloth")
			self.enemyteam = "human"; // baeloth vs human
		else if (self.teams == "robot")
			self.enemyteam = "baeloth"; // robot vs baeloth
		if (FindTarget())
			return;
	}

	if (self.searchteam < 2)
		self.searchteam = self.searchteam + 1;
	else
		self.searchteam = 0;
};

float() CheckAttack =
{
	local	vector	source;
	local float r;

	makevectors (self.angles);

	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*99999, FALSE, self);
	if (trace_fraction == 1)
		return FALSE;

	if (trace_ent.takedamage && trace_ent.health > 0)
	{
		r = range(self.enemy);

		if (self.teams == trace_ent.teams && self.ai_angry == FALSE)
			return FALSE;
		else
		{
			ai_face();
			self.hostile_finished = time + 1;
			if (r == RANGE_MELEE)
			{
				if (self.th_melee)
				{
					if (self.teams == "human")
					{
						if (self.th_missile)
							self.th_missile();
						return TRUE;
					}
					else
					{
						self.th_melee();
						return TRUE;
					}
				}
				else // lack of melee attack
				{
					if (self.th_missile)
						self.th_missile();
					return TRUE;
				}
			}
			if (r > RANGE_MELEE)
			{
				if (self.th_missile)
				{
					self.th_missile();
					return TRUE;
				}
			}
		}
	}
	return FALSE; // can't attack
};

.float	lefty;
void() ai_strafe =
{
	local float	ofs;

	ai_face();

	if (self.lefty) ofs = 90;
	else ofs = -90;


	self.lefty = 1 - self.lefty;

	walkmove (self.ideal_yaw - ofs, 45);

};

void() ai_stand =
{
	if (!walkmove(0,0))
	{
		if (self.classname != "worm")
		{
			dprint ("monster stuck or in void at: ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
	}

	if (self.enemy)
	{
		ai_face();
		if (CheckAttack())
			return;
	}
	else
	{
		if (self.friend)
			check_friendly();

		// ai looks around
		if (random() < 0.1 && self.flags & FL_ONGROUND && self.noturn == FALSE)
		{
			if (random() < 0.5)
				self.ideal_yaw = self.angles_y + (crandom()*360);
			ChangeYaw();
		}
	}
	ai_targetsearch();
};

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

void() check_for_ledge =
{
	local vector spot;

	makevectors (self.angles);
	spot = self.origin + (v_forward * 35 - v_up * 35);
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

		if (self.goalentity.enemy.state == STATE_BOTTOM)
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
		if (self.goalentity.enemy.state == STATE_TOP)
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
	if (!self.enemy && self.ai_poscheck != world && self.ai_poscheck_touched == TRUE && self.teams != "human")
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
			if (self.teams == "human" && visible(self.enemy))
// 				soldier_speak(5); - replace with other variable
			self.enemy = world;
			self.th_stand();
			if (self.friend && visible(self.friend))
				FollowFriendly();
			return;
		}

		if (self.enemy.classname == "worm" && self.teams == "human") // tell soldier to step on worm
		{
			r = range(self.enemy);
			if (r < RANGE_CLOSE && visible(self.enemy))
			{
				self.th_melee();
				return;
			}
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

		// strafing routines
		if (self.enemy.hostile_finished > time && infront(self.enemy) && visible(self.enemy))
		{
			r2 = random();
			if (r2 > 0.6)
			{
				if (self.teams == "baeloth")
					ai_strafe();
				return;
			}
		}

		//
		// combat
		//

		if (CheckAttack())
			return;
	}
	else if (self.friend)
	{
		if (!visible(self.friend))
		{
			if (self.following == TRUE)
			{
				check_for_ledge(); // Soldiers are able to jump off ledges like Corporal
				if (!self.ai_poscheck) // the soldier here is recording the last position and angle he saw the player
				{
					check = spawn();
					check.movetype = MOVETYPE_NONE;
					check.solid = SOLID_TRIGGER;
					setmodel (check, string_null);
					check.touch = CheckTouch;
					check.angles_y = self.friend.angles_y;
					setsize (check, '-16 -16 0', '16 16 56');
					setorigin (check, self.friend.origin);
					self.search_count = 0;
					self.ideal_yaw = vectoyaw(check.origin - self.origin);
					self.ai_poscheck = check;
					self.goalentity = self.ai_poscheck;
					ai_quickturn();
				}
				if (self.search_count >= 80)
				{
					if (self.ai_poscheck) // remove the recorded entity because the soldier saw corporal again
					{
						self.ai_poscheck.think = SUB_Remove;
						self.ai_poscheck.nextthink = time + 0.1;
						self.ai_poscheck_touched = FALSE;
						self.goalentity = world;
						self.ai_poscheck = world;
					}
					self.search_count = 0;
// 					soldier_speak(7); - replace with other variable
					self.friend = world;
					self.th_stand();
					return;
				}
			}
			self.search_count = self.search_count + 1;
		}
		else
		{
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