vector() SetMovedir;
void() InitTrigger;

string nextmap;
void() changelevel_touch =
{
	local entity	pos;

	if (other.classname != "player")
		return;

	bprint (other.netname);
	bprint (" left the sector.\n");

	nextmap = self.map;
	self.touch = SUB_Null;
	changelevel(nextmap);
};

void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have a map\n");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};

.string closename; // targetname on func_doors to link the closedoor trigger
void() door_go_down;
void() closedoor_touch =
{
	local entity t, stemp, otemp, act;

	if (other.classname != "player")
		return;

	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, closename, self.target);
			if (!t)
				return;

			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.closed == FALSE)
			{
				door_go_down();
				self.closed = TRUE;
			}
			self = stemp;
			other = otemp;
			activator = act;
		}
		while (1);
	}
};

// trigger that can close doors when touched
void() trigger_closedoor =
{
	InitTrigger ();
	self.touch = closedoor_touch;
	if (!self.target) objerror ("no target on trigger_closedoor");
}


// if the user sets the trigger_sound's sound_max to 999 then the sound will always be triggered
// otherwise the mapper can define how many times the sound is played by changing the sound_max value.

// set these 3 flags in the map
.string sound_string;
.float sound_length;
.float sound_max;
// set these 3 flags in the map

.float sound_finished;

void() sound_touch =
{
	if (other.classname != "player" || self.sound_finished > time)
		return;

	if (self.sound_string)
	{
		if (self.cnt < self.sound_max || self.sound_max == 999)
		{
			stuffcmd (other.owner, "play ");
			stuffcmd (other.owner, self.sound_string);
			stuffcmd (other.owner, "\n");
			self.sound_finished = time + self.sound_length;
			if (self.sound_max != 999)
				self.cnt = self.cnt + 1;
			return;
		}
		if (self.cnt >= self.sound_max)
		{
			remove(self);
			return;
		}
	}
};

void() trigger_sound =
{
	precache_sound (self.sound_string);

	InitTrigger ();
	self.touch = sound_touch;

	// set defaults
	self.cnt = 0;
	if (!self.sound_max)
		self.sound_max = 1;
	if (!self.sound_length)
		self.sound_length = 1;
};

float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};

// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_killed =
{
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_touch =
{
	
	// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}
};

/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

void() briefing_think =
{
	local entity y;

	y = find(world, classname, "player");
	while (y)
	{
		if (y.owner.button0) // Skip briefing button
		{
			self.touch = SUB_Null;
			self.ammo_shells = TRUE;
			self.noise = "demon/dland2.wav";
			sound (self, CHAN_BODY, self.noise, 1, ATTN_NORM);
			self.ammo_shells = TRUE;
			remove(self);
			return;
		}
		y = find(y, classname, "player");
	}

	self.nextthink = time + 0.1;
};