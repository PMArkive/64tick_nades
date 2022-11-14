#include <sourcemod>
#include <dhooks>

DynamicDetour gH_StartGrenadeThrow;

public void OnPluginStart()
{
	GameData gamedata = new GameData("64tick_nades.games");

	if (gamedata == null)
	{
		SetFailState("Failed to load 64tick_nades gamedata");
	}

	gH_StartGrenadeThrow = new DynamicDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);

	if (!DHookSetFromConf(gH_StartGrenadeThrow, gamedata, SDKConf_Signature, "CBaseGrenade::StartGrenadeThrow"))
	{
		SetFailState("Couldn't get the signature for \"CBaseGrenade::StartGrenadeThrow\" - make sure your gamedata is updated!");
	}

	if (!gH_StartGrenadeThrow.Enable(Hook_Post, DHook_StartGrenadeThrow_Post))
	{
		SetFailState("Couldn't enable detour for \"CBaseGrenade::StartGrenadeThrow\" - make sure your gamedata is updated!");
	}

	delete gamedata;
}

// void CBaseGrenade::StartGrenadeThrow()
public MRESReturn DHook_StartGrenadeThrow_Post(int pThis)
{
	/*
	Throwtime = curtime() + 0.1;
	(1/64) * 6   = 0.09375
	               0.1
	(1/64) * 7   = 0.109375  // throws here
	(1/128) * 12 = 0.09375
	               0.1
	(1/128) * 13 = 0.1015625 // throws here
	(1/128) * 14 = 0.109375
	*/
	float newtime = GetGameTime() + 0.109375;
	//PrintToServer("replacing throw time %f with %f", GetEntPropFloat(pThis, Prop_Send, "m_fThrowTime"), newtime);
	SetEntPropFloat(pThis, Prop_Send, "m_fThrowTime", newtime);
	return MRES_Ignored;
}
