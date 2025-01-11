/*
+------+
|Client|
+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/
void() CheckImpulses;

void() ClientKill = {};
void() ClientConnect = {};
void() ClientDisconnect = {};
.float spawntime;
void() PlayerPreThink =
{
	local vector view;
	local float plyr_y;

	if (self.spawntime)
	{
		if (time > self.spawntime)
		{
			self.spawntime = 0;
		}
	}

		if (self.weaponframe > 0)
			self.weaponframe = self.weaponframe - 1;
		else if (world.model != "maps/start.bsp")
		{
			stuffcmd(self, "viewsize 100\n");
			self.weaponmodel = "";
		}

	self.test_org = self.origin;
};
void() PlayerPostThink =
{
	local vector tree, source;
	local entity stemp;

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

	self.keyflags = 0;

	if (self.char != world && self.char.deadflag == DEAD_NO)
	{
		// display health on sbar
		if (self.char.health > 0)
			self.health = self.char.health;
		else
			self.health = 1;

		
		if (self.char.movetype != MOVETYPE_STEP)
			self.char.movetype = MOVETYPE_STEP;

		if (self.char.flags & FL_ONGROUND)
		{
			self.char.flags = self.char.flags - FL_ONGROUND;
        }
	}
	CheckImpulses();
	setorigin(self, self.test_org);
	self.velocity = '0 0 0';
};
void() PutClientInServer =
{
local entity spawn_spot;             // This holds where we want to spawn
spawn_spot = find (world, classname, "info_player_start"); // Find it :)

self.classname = "player";           // I'm a player!
self.health = self.max_health = 100; // My health (and my max) is 100
self.takedamage = DAMAGE_AIM;        // I can be fired at
self.solid = SOLID_SLIDEBOX;         // Things sort of 'slide' past me
self.movetype = MOVETYPE_WALK;       // Yep, I want to walk.
self.flags = FL_CLIENT;              // Yes, I'm a client.

self.origin = spawn_spot.origin + '0 0 1'; // Move to the spawnspot location
self.angles = spawn_spot.angles;     // Face the angle the spawnspot indicates
self.fixangle = TRUE;                // Turn this way immediately

setmodel (self, "progs/player.mdl"); // Set my player to the player model
setsize (self, VEC_HULL_MIN, VEC_HULL_MAX); // Set my size

self.view_ofs = '0 0 22';            // Center my view
self.velocity = '0 0 0';             // Stop any old movement
};