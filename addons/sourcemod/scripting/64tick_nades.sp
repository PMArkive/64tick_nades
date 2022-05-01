#include <sourcemod>
#include <dhooks>

DynamicHook gH_StartGrenadeThrow;

public void OnPluginStart()
{
	int offset;

	GameData gamedata = new GameData("64tick_nades.games");

	if (gamedata == null)
	{
		SetFailState("Failed to load 64tick_nades gamedata");
	}

	if ((offset = gamedata.GetOffset("CBaseGrenade::StartGrenadeThrow")) == -1)
	{
		LogError("Couldn't get the offset for \"CBaseGrenade::StartGrenadeThrow\" - make sure your gamedata is updated!");
	}

	gH_StartGrenadeThrow = new DynamicHook(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity);

	delete gamedata;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	static const char nades[][] = {
		"weapon_hegrenade",
		"weapon_smokegrenade",
		"weapon_flashbang",
		"weapon_molotov",
		"weapon_incgrenade",
		"weapon_decoy"
	};

	for (int i = 0; i < sizeof(nades); i++)
	{
		if (StrEqual(classname, nades[i]))
		{
			//PrintToServer("hooking %s %d", classname, entity);
			gH_StartGrenadeThrow.HookEntity(Hook_Post, entity, DHook_StartGrenadeThrow_Post);
			return;
		}
	}
}

// void CBaseGrenade::StartGrenadeThrow()
public MRESReturn DHook_StartGrenadeThrow_Post(int pThis)
{
	/*
	(1/64) * 6   = 0.09375
	(1/64) * 7   = 0.109375
	(1/128) * 12 = 0.09375
	(1/128) * 13 = 0.1015625
	(1/128) * 14 = 0.109375
	*/
	float newtime = GetGameTime() + 0.109375;
	//PrintToServer("replacing throw time %f with %f", GetEntPropFloat(pThis, Prop_Send, "m_fThrowTime"), newtime);
	SetEntPropFloat(pThis, Prop_Send, "m_fThrowTime", newtime);
	return MRES_Ignored;
}
