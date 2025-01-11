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

	if (self.health < -99)
        self.health = -99;

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
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
	if (targ.classname != "player")
	{
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

	self = oldself;
};