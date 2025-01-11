/*
============
PlaceItem

plants the object on the floor
============
*/

void() stareffect_think = {remove(self);return;};

.float mdl;
void() ItemSparkle =
{
	local entity new;
	new = spawn();

	new.movetype = MOVETYPE_FLY;
	new.solid = SOLID_NOT;
	new.think = stareffect_think;
	new.nextthink = time + 0.1;

	setmodel (new, "progs/star.spr");
	setsize (new, '0 0 0', '0 0 0');
	setorigin (new, self.origin + '0 0 8');
	new.think = stareffect_think;
	new.alpha = 0.3;
	new.nextthink = time + 0.1;
	self.nextthink = time + 3;
};

void() PlaceItem =
{
	local float	oldz;

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;
	if (!droptofloor())
	{
		dprint ("Item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
		return;
	}
	self.think = ItemSparkle;
	self.nextthink = time + 3;
};

void() bound_other_ammo =
{
	if (other.owner.ammo_nails > 150)
		other.owner.ammo_nails = 150;
	if (other.owner.ammo_shells > 16)
		other.owner.ammo_shells = 16;
};

/*
=============
weapon_touch
=============
*/
void() W_SetCurrentAmmo;
void() weapon_touch =
{
	local float new;
	local entity stemp;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	other.owner.pickup_finished = time + 0.1;

	if (other.getitem_finished < time)
		return;

	sprint (other.owner, "You found a");
	if (self.netname == "assault rifle")
		sprint (other.owner, "n");
	sprint (other.owner, " ");
	sprint (other.owner, self.netname);
	sprint (other.owner, ".\n");

	if (self.netname == "pistol")
	{
		new = W_PISTOL;
		if (other.owner.items & W_PISTOL)
		{
			other.owner.ammo_nails = other.owner.ammo_nails + 12;
			sprint (other.owner, "You already own that weapon, +12 bullets to stock.\n");
		}
		else
			other.owner.pistol_shots = other.owner.pistol_shots + 12;
	}
	if (self.netname == "shotgun")
	{
			new = W_SHOTGUN;
		if (other.owner.items & W_SHOTGUN)
		{
			other.owner.ammo_shells = other.owner.ammo_shells + 4;
			sprint (other.owner, "You already own that weapon, +4 shells to stock.\n");
		}
		else
			other.owner.shotgun_shots = other.owner.shotgun_shots + 4;
	}
	if (self.netname == "assault rifle")
	{
		if (!self.owner.weapon & W_ASSAULT)
			new = W_ASSAULT;
	}
	playsound (self, CHAN_BODY, "items/pk_wep.wav", 1, ATTN_NORM);
	other.owner.items = other.owner.items | new;

	bound_other_ammo ();

	stemp = self;
	self = other.owner;
	W_SetCurrentAmmo();
	self = stemp;

	self.model = string_null;
	self.solid = SOLID_NOT;
	self.think = SUB_Null;
};

void() item_pistol =
{
	precache_model ("progs/pk_pist.mdl");
	setmodel (self, "progs/pk_pist.mdl");
	self.weapon = W_PISTOL;
	self.netname = "pistol";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	PlaceItem();
};

void() item_shotgun =
{
	precache_model ("progs/pk_shotg.mdl");
	setmodel (self, "progs/pk_shotg.mdl");
	self.weapon = W_SHOTGUN;
	self.netname = "shotgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	PlaceItem();
};

void() item_assault =
{
	precache_model ("progs/pk_asult.mdl");
	setmodel (self, "progs/pk_asult.mdl");
	self.weapon = W_ASSAULT;
	self.netname = "assault rifle";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	PlaceItem();
};


/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
	local float new;
	local entity stemp;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	other.owner.pickup_finished = time + 0.1;

	if (other.getitem_finished < time)
		return;
	
	if (self.classname == "item_clip")
		other.owner.ammo_nails = other.owner.ammo_nails + 12;
	if (self.classname == "item_shells")
		other.owner.ammo_shells = other.owner.ammo_shells + 4;

	sprint (other.owner, "You found ");
	sprint (other.owner, self.netname);
	sprint (other.owner, ".\n");

	bound_other_ammo ();

	stemp = self;
	self = other.owner;
	W_SetCurrentAmmo();
	self = stemp;

	playsound (self, CHAN_BODY, "items/pk_ammo.wav", 1, ATTN_NORM);

	self.model = string_null;
	self.solid = SOLID_NOT;
	self.think = SUB_Null;
};

void() item_clip =
{
	precache_model ("progs/pk_clip.mdl");
	setmodel (self, "progs/pk_clip.mdl");
	self.netname = "a clip";
	setsize (self, '-16 -16 0', '16 16 56');
	self.touch = ammo_touch;
	PlaceItem();
};

void() item_shells =
{
	precache_model ("progs/pk_shell.mdl");
	setmodel (self, "progs/pk_shell.mdl");
	self.netname = "some shells";
	setsize (self, '-16 -16 0', '16 16 56');
	self.touch = ammo_touch;
	PlaceItem();
};

void() health_touch =
{
	local	float amount;
	local	string s, h;
	
	if (other.classname != "player")
		return;

	other.owner.pickup_finished = time + 0.1;

	if (other.getitem_finished < time)
		return;
	if (other.owner.heal_uses > 3) // can only hold 4 max
		return;

	other.owner.heal_uses = other.owner.heal_uses + 1; // add one medical kit

	h = ftos(other.owner.heal_uses);
	sprint (other.owner, "You now possess ");
	sprint (other.owner, h);
	sprint (other.owner, "/4 medical kits.\n");

	// health touch sound
	playsound (self, CHAN_BODY, "items/r_item2.wav", 1, ATTN_NORM); // change me
	
	self.model = string_null;
	self.solid = SOLID_NOT;
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
	self.think = SUB_Null;
};	

void() item_medkit =
{
	precache_model ("progs/medic.mdl");
	setmodel (self, "progs/medic.mdl");
	self.netname = "small medical kit";
	setsize (self, '-3 -4 0', '3 3 11');
	self.touch = health_touch;
	PlaceItem();
};



void() flashlight_touch =
{
	if (other.classname != "player" || other.health <= 0)
		return;

	other.owner.pickup_finished = time + 0.1;

	if (other.getitem_finished < time)
		return;

	sprint (other.owner, " Ãèéð õðçòáäåº Flashlight obtained!\n");
	other.owner.chips = other.owner.chips | self.items;
	self.model = string_null;
	self.solid = SOLID_NOT;
	sound (self, CHAN_BODY, "items/pk_chip.wav", 1, ATTN_NORM);
	self.think = SUB_Null;
};

void() item_flashlight =
{
	precache_model ("progs/chip.mdl");
	precache_sound ("items/pk_chip.wav");
	setmodel (self, "progs/chip.mdl");
	self.touch = flashlight_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	self.items = IT_CHIP1;
	self.think = PlaceItem;
	self.nextthink = time + 0.2;
};

void() targetter_touch =
{
	local entity stemp;

	if (other.classname != "player" || other.health <= 0)
		return;

	other.owner.pickup_finished = time + 0.1;

	if (other.getitem_finished < time)
		return;

	sprint (other.owner, " Ãèéð õðçòáäåº Aiming System obtained!\n");
	other.owner.chips = other.owner.chips | self.items;
	if (!other.owner.flags & IT_CHIP2)
	{
		stemp = self;
		self = other.owner;
		crosshair();
		self = stemp;
	}
	self.model = string_null;
	self.solid = SOLID_NOT;
	sound (self, CHAN_BODY, "items/pk_chip.wav", 1, ATTN_NORM);
	self.think = SUB_Null;
};

void() item_aimingsys =
{
	precache_model ("progs/chip.mdl");
	precache_sound ("items/pk_chip.wav");
	setmodel (self, "progs/chip.mdl");
	self.touch = targetter_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	self.items = IT_CHIP2;
	self.think = PlaceItem;
	self.nextthink = time + 0.2;
};
