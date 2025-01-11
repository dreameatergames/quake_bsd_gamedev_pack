void() ClipTouch =
{
	if (other.solid != SOLID_BSP)
		return;
	playsound (self, CHAN_WEAPON, "weapons/clipdrp.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() ThrowClip =
{
	local entity clip;
	local vector dir;

	makevectors (self.angles);

	clip = spawn();
	clip.owner = self;
	clip.movetype = MOVETYPE_BOUNCE;
	clip.solid = SOLID_SLIDEBOX;
	clip.angles = vectoangles(clip.velocity);
	clip.touch = ClipTouch;
	clip.avelocity = '-600 600 -600';
	clip.think = SUB_Remove;
	clip.nextthink = time + 3;

	setmodel (clip, "progs/pk_clip.mdl");
	setsize (clip, '0 0 0', '0 0 0');     
	setorigin (clip, self.origin + v_forward*12 + '0 0 16');
};

void() CasingTouch =
{
	if (other.solid != SOLID_BSP)
		return;
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
	playsound (self, CHAN_BODY, "weapons/shelldrp.wav", 1, ATTN_NORM);	// bounce sound
};

void() ThrowCasing =
{
	local entity casing;
	local vector dir;

	makevectors (self.angles);

	casing = spawn();
	casing.owner = self;
	casing.movetype = MOVETYPE_BOUNCE;
	casing.solid = SOLID_SLIDEBOX;
	casing.angles = vectoangles(casing.velocity);

	if (casing.owner.owner.weapon == W_SHOTGUN)
		casing.skin = 0;
	else
		casing.skin = 1;

	casing.velocity = casing.velocity + v_right * -80;
      casing.velocity_z = casing.velocity_z + 120;
	
	casing.classname = "casing"; // before changing check T_BulletTouch
	casing.avelocity = '-600 600 -600';
	casing.think = SUB_Remove;
	casing.touch = CasingTouch;
	casing.nextthink = time + 1.2;

	setmodel (casing, "progs/casing.mdl");
	setsize (casing, '0 0 0', '0 0 0');     
	setorigin (casing, self.origin + v_forward*12 + '0 0 16');
};

void() ThrowChunk_Think =
{
	if (self.lock_finished < time || self.flags & FL_ONGROUND)
		remove(self);
	self.nextthink = time + 0.1;
};

void() ThrowChunk =
{
	local	entity new;

	new = spawn();

	makevectors(self.angles);
	setorigin (new, self.origin);

	if (random() < 0.35)
		setmodel (new, "progs/wchunk1.mdl");
	else if (random() < 0.65)
		setmodel (new, "progs/wchunk2.mdl");
	else
		setmodel (new, "progs/wchunk3.mdl");

	setsize (new, '0 0 0', '0 0 0');

	new.velocity_x = random()*200;
	new.velocity_y = random()*200;
	new.velocity_z = random()*500+250;

	new.movetype = MOVETYPE_TOSS;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.lock_finished = time + 6 + random()*10; // time till removal
	new.think = ThrowChunk_Think;
	new.nextthink = time + 0.5;
};

void()	s_gexplode1	=	[0,		s_gexplode2] {self.nextthink = time + 0.05;};
void()	s_gexplode2	=	[1,		s_gexplode3] {self.nextthink = time + 0.05;};
void()	s_gexplode3	=	[2,		s_gexplode4] {self.nextthink = time + 0.05;};
void()	s_gexplode4	=	[3,		s_gexplode5] {self.nextthink = time + 0.05;};
void()	s_gexplode5	=	[4,		s_gexplode6] {self.nextthink = time + 0.05;};
void()	s_gexplode6	=	[5,		s_gexplode7] {self.nextthink = time + 0.05;};
void()	s_gexplode7	=	[6,		s_gexplode8] {self.nextthink = time + 0.05;};
void()	s_gexplode8	=	[7,		s_gexplode9] {self.nextthink = time + 0.05;};
void()	s_gexplode9	=	[8,		s_gexplode10] {self.nextthink = time + 0.05;};
void()	s_gexplode10	=	[9,		s_gexplode11] {self.nextthink = time + 0.05;};
void()	s_gexplode11	=	[10,		s_gexplode12] {self.nextthink = time + 0.05;};
void()	s_gexplode12	=	[11,		s_gexplode13] {self.nextthink = time + 0.05;};
void()	s_gexplode13	=	[12,		s_gexplode14] {self.nextthink = time + 0.05;};
void()	s_gexplode14	=	[13,		s_gexplode15] {self.nextthink = time + 0.05;};
void()	s_gexplode15	=	[14,		s_gexplode16] {self.nextthink = time + 0.05;};
void()	s_gexplode16	=	[15,		SUB_Remove] {self.nextthink = time + 0.05;};

void() BecomeExplosion =
{
	local entity boom;
	
	boom = spawn();
	setmodel (boom, "progs/explode1.spr");
	setorigin (boom, self.origin + v_up*25);
	boom.movetype = MOVETYPE_NOCLIP;
	boom.owner = self.owner;
	boom.touch = SUB_Null;
	boom.solid = SOLID_NOT;
	boom.velocity_z = 75;
	boom.effects = EF_DIMLIGHT;
	sound (boom, CHAN_BODY, "weapons/boom.wav", 1, ATTN_NORM);
	boom.think = s_gexplode1;
	boom.nextthink = time + 0.1;
	ThrowChunk(); ThrowChunk(); ThrowChunk();
	remove(self); // remove old entity
};

void(float u, float r, float f) MuzzleFlash =
{
	local entity flash;

	makevectors (self.angles);
	flash = spawn ();
	flash.owner = self;
	flash.movetype = MOVETYPE_NOCLIP;
	flash.solid = SOLID_NOT;
	flash.classname = "flash";
	setmodel (flash, "progs/muzflash.spr");
	setsize (flash, '0 0 0', '0 0 0');
	flash.alpha = 0.4;
	setorigin (flash, self.origin + v_forward*f + v_right*r + v_up*u);
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.04;
};

void()	muzzle2_1	=	[0,		muzzle2_2] {self.nextthink = time + 0.05;};
void()	muzzle2_2	=	[1,		muzzle2_3] {self.nextthink = time + 0.05;};
void()	muzzle2_3	=	[2,		muzzle2_4] {self.nextthink = time + 0.05;};
void()	muzzle2_4	=	[3,		muzzle2_5] {self.nextthink = time + 0.05;};
void()	muzzle2_5	=	[4,		SUB_Remove] {self.nextthink = time + 0.05;};

void(float u, float r, float f) MuzzleFlash2 =
{
	local entity flash;

	makevectors (self.angles);
	flash = spawn ();
	flash.owner = self;
	flash.movetype = MOVETYPE_NOCLIP;
	flash.solid = SOLID_NOT;
	flash.classname = "flash";
	setmodel (flash, "progs/muzflsh2.spr");
	setsize (flash, '0 0 0', '0 0 0');
	setorigin (flash, self.origin + v_forward*f + v_right*r + v_up*u);
	flash.think = muzzle2_1;
	flash.alpha = 0.4;
	flash.nextthink = time + 0.01;
};

void(float u, float r, float f) MuzzleFlash3 =
{
	local entity flash;
	local float t;

	t = random()*6;

	makevectors (self.angles);
	flash = spawn ();
	flash.owner = self;
	flash.movetype = MOVETYPE_NOCLIP;
	flash.solid = SOLID_NOT;
	flash.classname = "flash";
	flash.angles_y = self.angles_y;
	setmodel (flash, "progs/muzflsh3.mdl");
	flash.alpha = 0.4;
	setsize (flash, '0 0 0', '0 0 0');
	setorigin (flash, self.origin + v_forward*f + v_right*r + v_up*u);
	flash.frame = t;
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.1;
};

void() T_BulletTouch =
{
	local vector dir;
	local float damg;
	local float tt;

	if (other == self.owner || other.classname == "casing") // Make sure bullets aren't affected by ejecting shells
		return;

	if (!other.takedamage)
	{
		tt = ceil(random() * 3);
		if (tt == 1)
			playsound (self, CHAN_BODY, "weapons/ric1.wav", 1, ATTN_NORM);
		else if (tt == 2)
			playsound (self, CHAN_BODY, "weapons/ric2.wav", 1, ATTN_NORM);
		else
			playsound (self, CHAN_BODY, "weapons/ric3.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}
	else
	{
		other.bullettype = self.bullettype; // have monster know what type of projectile hit them before executing tdamage
		if (other.teams == "robot") // bullet hit robot armor
		{
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
		}
		if (self.bullettype == 0 || self.bullettype == 600) // 0 is corporal, 600 is the soldiers
		{
			if (other.teams != "robot")
			{
				if (other.classname != "vile")
				{
					sound (self, CHAN_BODY, "weapons/imp_flsh.wav", 1, ATTN_NORM);
				}
			}
			damg = 8;
			if (other.classname == "vile") // viles are resistant to bullets
				damg = damg * 0.8;
			T_Damage (other, self, self.owner, damg); // Pistol
		}
		if (self.bullettype == 1)
		{
			if (other.teams != "robot")
				sound (self, CHAN_BODY, "weapons/imp_flsh.wav", 1, ATTN_NORM);
			damg = 9;
			if (other.classname == "vile") // viles take more damage from buckshot
				damg = damg * 1.8;
			T_Damage (other, self, self.owner, damg); // Shotgun
		}
		if (self.bullettype == 2)
		{
			if (other.teams != "robot")
			{
				if (other.classname != "vile")
				{
					sound (self, CHAN_BODY, "weapons/imp_flsh.wav", 1, ATTN_NORM);
				}
			}
			if (self.owner.teams == "robot") // mach cannon damage
				damg = 3;
			else
				damg = 6;
			if (other.classname == "vile")
				damg = damg * 0.8;
			T_Damage (other, self, self.owner, damg); // Assault Rifle
		}
	}
	remove(self);
};

//*====*
//Knife
//*====*

void() W_FireKnife =
{
	local	vector	source, org;

	makevectors (self.angles);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*72, FALSE, self);
	if (trace_fraction == 1.0) return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		if (trace_ent.teams == "robot") // bullet hit robot armor
		{
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
			sound (self, CHAN_WEAPON, "weapons/clang.wav", 1, ATTN_NORM);
		}
		else
			sound (self, CHAN_WEAPON, "weapons/knifed.wav", 1, ATTN_NORM);

		trace_ent.bullettype = 3; // knife doesn't decapitate
		T_Damage (trace_ent, self, self, 8);
	}
};

//*====*
//Pistol
//*====*

void() W_Pistol =
{
	local entity newmis;

	makevectors (self.angles);
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_SLIDEBOX;
	newmis.velocity = aim(self, 2000);
	newmis.velocity = newmis.velocity * 2000;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = T_BulletTouch;
	newmis.classname = "projectile";
	setmodel (newmis, "progs/bullet.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin + v_forward*16 + '0 0 25');
	newmis.bullettype = 0;
};

//*====*
//Shotgun
//*====*

void() W_Shotgun =
{
	local entity newmis;

	makevectors (self.angles);
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_SLIDEBOX;
	newmis.velocity = aim(self, 3000);
	newmis.velocity = newmis.velocity * 3000;
	newmis.velocity = ((newmis.velocity + ((v_right * 850) * crandom ())) + ((v_up * 850) * crandom ()));
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = T_BulletTouch;
	newmis.classname = "projectile";
	setmodel (newmis, "progs/bullet.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin + v_forward*4 + '0 0 16');
	newmis.bullettype = 1;
};

//*====*
//W_Assault
//*====*

void() W_Assault =
{
	local entity newmis;

	makevectors (self.angles);
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_SLIDEBOX;
	newmis.velocity = aim(self, 2750);
	newmis.velocity = newmis.velocity * 2750;
	newmis.velocity = ((newmis.velocity + ((v_right * 250) * crandom ())) + ((v_up * 250) * crandom ()));
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = T_BulletTouch;
	newmis.classname = "projectile";
	setmodel (newmis, "progs/bullet.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin + v_forward*10 + v_right*7 + '0 0 22');
	newmis.bullettype = 2;
};


//*====*
//LightningDamage
//*====*
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};

void() W_SetCurrentAmmo =
{
	self.items = self.items - ( self.items & (IT_NAILS | IT_SHELLS));
	
	if (self.weapon == W_MELEE)
	{
		self.currentammo = 0;
	}
	else if (self.weapon == W_PISTOL)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == W_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == W_ASSAULT)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
};

void() ChangeWeapons =
{
	local	float	it, fl;

	it = self.items;
	
	if (self.impulse == 1)
	{
		fl = W_MELEE;
		self.armorvalue = 0;
	}
	else if (self.impulse == 2)
	{
		fl = W_PISTOL;
		self.armorvalue = self.pistol_shots;
	}
	else if (self.impulse == 3)
	{
		fl = W_SHOTGUN;
		self.armorvalue = self.shotgun_shots;
	}
	else if (self.impulse == 4)
	{
		fl = W_ASSAULT;
		self.armorvalue = self.ammo_nails;
	}

	if (!(self.items & fl))
	{	// don't have the weapon or the item
		sprint (self, "You don't have that weapon.\n");
		self.armorvalue = 0;
		return;
	}

	//
	// set weapon, set ammo, display weapon selected message
	//

	self.weapon = fl;
	W_SetCurrentAmmo ();

	if (fl == W_MELEE)
		sprint (self, "Knife selected\n");
	else if (fl == W_PISTOL)
		sprint (self, "Pistol selected\n");
	else if (fl == W_SHOTGUN)
		sprint (self, "Shotgun selected\n");
	else if (fl == W_ASSAULT)
		sprint (self, "Assault Rifle selected\n");
};

void() CycleWeaponCommand =
{
	local	float	it;

	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		if (self.weapon == W_ASSAULT)
			self.weapon = W_MELEE;
		else if (self.weapon == W_MELEE)
			self.weapon = W_PISTOL;
		else if (self.weapon == W_PISTOL)
			self.weapon = W_SHOTGUN;
		else if (self.weapon == W_SHOTGUN)
			self.weapon = W_ASSAULT;
	
		if ((it & self.weapon))
		{
			if (self.weapon == W_MELEE)
				sprint (self, "Knife selected\n");
			else if (self.weapon == W_PISTOL)
				sprint (self, "Pistol selected\n");
			else if (self.weapon == W_SHOTGUN)
				sprint (self, "Shotgun selected\n");
			else if (self.weapon == W_ASSAULT)
				sprint (self, "Assault Rifle selected\n");

			W_SetCurrentAmmo ();
			return;
		}
	}
};

void() reload =
{
	local float h;

	if (self.lock_finished > time || self.char.ladder_finished > time)
		return;

	if (self.weapon == W_PISTOL)
	{
		if (self.pistol_shots < 12)
		{
			h = 12 - self.pistol_shots; // h = how many shots fired

			if (self.ammo_nails > 0)
			{
				if (h > self.ammo_nails)
				{
					self.pistol_shots = self.pistol_shots + self.ammo_nails;
					self.ammo_nails = 0;
				}
				else
				{
					self.pistol_shots = self.pistol_shots + h;
					self.ammo_nails = self.ammo_nails - h;
				}
				self.armorvalue = self.pistol_shots;
				W_SetCurrentAmmo();
				self.lock_finished = time + 1;
			}
		}
	}
	if (self.weapon == W_SHOTGUN)
	{
		if (self.shotgun_shots < 6 && self.ammo_shells > 0)
		{
			if (self.shotgun_shots > 0)
				self.lock_finished = time + 0.4;
			else
				self.lock_finished = time + 1; // allow corporal's reload animation to insert shell before firing again
		}
	}	
};

void() door_fire;
.float order_finished;
void() checkuse =
{
	local	vector	source, org;
	local entity      stemp, y;

	self.usebutton_finished = time + 0.5; // for items on the ground

	// USE BUTTON FOR -DOORS/BUTTONS-
	makevectors (self.char.angles);
	source = self.char.origin + '0 0 16';
	traceline (source, source + v_forward*50, FALSE, self);

	org = self.char.origin + '0 0 16';

	if (developer == 1) // show traceline in developer mode
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity (MSG_BROADCAST, self);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		WriteCoord (MSG_BROADCAST, trace_endpos_x);
		WriteCoord (MSG_BROADCAST, trace_endpos_y);
		WriteCoord (MSG_BROADCAST, trace_endpos_z);
	}

	if (trace_fraction == 1.0)
		return;

	if (trace_ent.classname == "door")
	{
		if (trace_ent.targetname != "" || trace_ent.owner.targetname != "" ||  trace_ent.closed == TRUE)
		{
			sprint (self, "The door is electronically locked.\n");
			if (self.lock_finished < time)
			{
				self.lock_finished = time + 0.5;
				playsound (self, CHAN_AUTO, "doors/locked.wav", 1, ATTN_NORM);
			}
		}
		
		self.lock_finished = time + 0.2;
		self.char.nextthink = time + 0.1;
	}
	else if (trace_ent.classname == "button")
	{
		self.lock_finished = time + 0.2;
		self.char.nextthink = time + 0.1;
	}
};

void() checkheal =
{
	local string h;

	if (self.heal_uses > 0)
	{
		self.heal_uses = self.heal_uses - 1;
		self.heal_amount = self.heal_amount + 25;
		h = ftos(self.heal_uses);
		sprint (self, "You now have ");
		sprint (self, h);
		if (self.heal_uses == 1)
			sprint (self, "/4 medical kit remaining.\n");
		else
			sprint (self, "/4 medical kits remaining.\n");
		sound (self, CHAN_ITEM, "items/r_item1.wav", 1, ATTN_NORM); // change me
	}
	else
		sprint (self, "You do not have any medical kits left.\n");
};

.float medkit_count;
.float stopkey;
void() CheckImpulses =
{
	if (cutscene == TRUE)
		return;

	if (self.impulse == 50) // temp
	{
		sprint (self, "Door is out of order.\n");
		sound (self, CHAN_VOICE, "doors/locked.wav", 1, ATTN_NORM);	
	}

	if (self.char.health <= 0)
			return;

	if (self.impulse >= 1 && self.impulse <= 4)
		ChangeWeapons ();
	if (self.impulse == 11)
		reload ();
	if (self.impulse == 12)
		CycleWeaponCommand();

	if (self.pickup_finished > time)
	{
		if (self.button2 && self.lock_finished < time)
		{
			self.lock_finished = time + 0.2;
			self.char.nextthink = time + 0.1;
		}
	}
	if (self.button2) // use button
	{


		if (self.lock_finished < time)
		{
			checkuse();
			if (self.medkit_count > 1)
			{
				checkheal();
				self.medkit_count = 0;
				return;
			}
		}
		self.medkit_count = self.medkit_count + 1 * frametime; // use frametime to keep in sync for low framerates
	}
	else
	{
		self.stopkey = FALSE;
		self.medkit_count = 0;
	}

	if (self.impulse == 100)
		T_Damage (self.char, self, self.owner, 1000); // insta-death, debugging
	
	self.impulse = 0;
};
