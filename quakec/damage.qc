/*
+-------+
|Damage |
+-------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Damage related functions							           |
| 				                       			                 |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

void(vector org, float vel, float color) SpawnMeatSpray;
void() SUB_Null;
void() SUB_Remove;
float() crandom;

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};

/*
============
Killed
============
*/

void(entity targ, entity atker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;

	if (self.ai_poscheck) // be sure to remove ai set waypoint
	{
		self.ai_poscheck.think = SUB_Remove;
		self.ai_poscheck.nextthink = time + 0.1;
		self.ai_poscheck_touched = FALSE;
		self.goalentity = world;
		self.ai_poscheck = world;
	}

	if (self.health < -99) self.health = -99;

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = self.attacker = atker;

	// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}
	if (self.ai_poscheck)
	{
		self.ai_poscheck.think = SUB_Remove;
		self.ai_poscheck.nextthink = time + 0.1;
		self.ai_poscheck_touched = FALSE;
		self.ai_poscheck = world;
	}

	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;	
	self.touch = SUB_Null;
	self.th_die ();
	self = oself;
};

/*
============
T_Damage
============
*/

void(entity targ, entity inflictor, entity atker, float damage) T_Damage =
{
	local	vector	dir;
	local	entity	oldself;
	local	float	take;

	if (!targ.takedamage) return;

	// do the damage
	if (targ.teams == "human" && targ.classname != "player")
	{
		if (targ.friend)
			targ.health = targ.health - damage * 1.6;
		else // soldiers die 3 times faster if Corporal isn't around
			targ.health = targ.health - damage * 3;
	}
	else
		targ.health = targ.health - damage;

/*			
	// figure momentum add
	if ((inflictor != world) && (targ.takedamage) && targ.classname != "player")
	{
		if (inflictor.bullettype == 1) // pellets
		{
			makevectors (targ.angles);
			dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
			dir = normalize(dir);
			targ.origin_z = targ.origin_z + 1;
			targ.velocity = targ.velocity + dir*damage*6;
			targ.velocity_z = random()*175;
			if (targ.flags & FL_ONGROUND)
				targ.flags = targ.flags - (self.flags & FL_ONGROUND);
		}
	}
*/

	if (targ.health < 1)
	{
		Killed (targ, atker);
		return;
	}

	// react to the damage
	oldself = self;
	self = targ;

	self.attacker = atker;
	if (atker.takedamage && atker != world && atker != self.enemy && (self.flags & FL_MONSTER) && atker != self && range(self.enemy) > RANGE_NEAR)
	{
		if (atker.teams != self.teams && atker.classname != "worm")
		{
			self.enemy = atker;
			FoundTarget ();
		}
	}

	if (self.th_pain)
		self.th_pain (atker, damage);

	// red blood spawn
	if (self.classname == "zombie" || self.classname == "soldier")
		SpawnMeatSpray (self.origin, crandom() * 200, 0);
	if (self.classname == "vile")
		SpawnMeatSpray (self.origin, crandom() * 200, 1);
	if (self.classname == "baeloth")
		SpawnMeatSpray (self.origin, crandom() * 200, 2);

	if (self.teams == "robot") // robots all 'bleed' the same way
	{
		if (self.health < self.max_health / 2)
		{
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
			SpawnMeatSpray (self.origin, crandom() * 200, 3);
		}
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity atker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == atker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
						T_Damage (head, inflictor, atker, points);
				}
			}
		}
		head = head.chain;
	}
};

vector(float dm) VelocityForDamage =
{
	local vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 100 + 50 * random();

	if (dm > -50)
		v = v * 0.7;
	else if (dm > -200)
		v = v * 2;
	else
		v = v * 10;

	return v;
};

void(string gibname, float dm) ThrowHead =
{
	local	entity new;

	new = spawn();
	setorigin (new, self.origin + v_up*8);
	setmodel (new, gibname);
	setsize (new, '-16 -16 0', '16 16 56');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
};

/*
================
SpawnMeatSpray
================
*/
void() MeatSprayParticle =
{
	if (self.cnt > 35 || self.flags & FL_ONGROUND)
		SUB_Remove();
	else
		self.cnt = self.cnt + 1;

	if (self.frags == 0)
		particle (self.origin, '0 0 0', 73, 6); // red
	else if (self.frags == 1)
		particle (self.origin, '0 0 0', 62, 6); // green
	else if (self.frags == 2)
		particle (self.origin, '0 0 0', 43, 6); // blue
	else if (self.frags == 3)
		particle (self.origin, '0 0 0', 111, 9); // yellow (sparks)

	self.nextthink = time + 0.05;
};

void(vector org, float vel, float color) SpawnMeatSpray =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

      missile.velocity_x = missile.velocity_y = vel;
	missile.velocity_z = missile.velocity_z + 50 + 50*random();
	
	// set missile duration
	missile.nextthink = time + 0.1;
	missile.think = MeatSprayParticle;
	missile.frags = color;
	missile.cnt = 0;

	setmodel (missile, "progs/null.spr");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

void() tdeath_touch =
{
	if (other == self.owner)
		return;

	// frag anyone who teleports in on top of an invincible player
	if (other.health)
		T_Damage (other, self, self, 50000);
};

void(vector org, entity death_owner) spawn_tdeath =
{
	local entity death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	force_retouch = 2;		// make sure even still objects get hit
};