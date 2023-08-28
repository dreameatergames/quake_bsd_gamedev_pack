//+----+
//|Main|
//+----+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Contains some 'base' subroutines. As a general rule nothing in this file   |
//| does much, except to setup basic variables and entities.                   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

float framecount;

void() main = {};
void() worldspawn = 
{
	//Forced Normal Quake precaches
	precache_model("progs/null.spr");
	precache_model("progs/s_explod.spr");
	precache_model("progs/player.mdl");
	precache_model("progs/missile.mdl");
	precache_model("progs/s_bubble.spr");
	precache_sound("demon/dland2.wav");
	precache_sound("weapons/sgun1.wav");
	//Forced Normal Quake precaches
};

void() SetNewParms = {};
void() SetChangeParms = {};
void() StartFrame = {};