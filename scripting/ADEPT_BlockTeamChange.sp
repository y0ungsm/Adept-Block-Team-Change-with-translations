#include <cstrike>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

ConVar gc_Enable, gc_AllowAdmin, gc_MOD_TAG, gc_ChangeTeamNotification;

char MOD_TAG[64];

public Plugin myinfo = 
{
	name = "ADEPT --> BlockTeamChange", 
	description = "Autorski Plugin StudioADEPT.net", 
	author = "Brum Brum", 
	version = "0.1", 
	url = "http://www.StudioADEPT.net/forum", 
};

public void OnPluginStart()
{
	gc_Enable = CreateConVar("sm_blockteamchange_enable", "1", "1-Zakazuje zmiany teamu po wybraniu 0-Zezwala na zmianę teamu", _, true, 0.0, true, 1.0);
	gc_AllowAdmin = CreateConVar("sm_blockteamchange_admin", "0", "1-Zezwala na zmiane teamu adminom", _, true, 0.0, true, 1.0);
	gc_ChangeTeamNotification = CreateConVar("sm_blockteamchange_notification", "1", "0-off 1-chat 2-hint", _, true, 0.0, true, 2.0);
	gc_MOD_TAG = CreateConVar("sm_blockteamchange_mod_tag", "ADEPT", "TAG pokazywany na czacie/hudzie");
	gc_MOD_TAG.AddChangeHook(MOD_TAGNameChanged);
	gc_MOD_TAG.GetString(MOD_TAG, sizeof(MOD_TAG));
	AddCommandListener(JoinTeam, "jointeam");
	AddCommandListener(JoinTeam, "spectate");
	AutoExecConfig(true, "ADEPT_BlockTeamChange");
	LoadTranslations("blockteamchange.phrases.txt");
}

public void MOD_TAGNameChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Format(MOD_TAG, sizeof(MOD_TAG), newValue);
}

public Action JoinTeam(int client, const char[] command, int args)
{
	if (!gc_Enable.BoolValue)return Plugin_Continue;
	
	if (GetClientTeam(client) == CS_TEAM_NONE || GetClientTeam(client) == CS_TEAM_SPECTATOR)return Plugin_Continue;
	
	if (gc_AllowAdmin.BoolValue && IsPlayerAdmin(client))return Plugin_Continue;
	
	NotifyClient(client);
	return Plugin_Handled;
}

void NotifyClient(int client)
{
	if (!IsValidClient(client))return;
	if (!gc_ChangeTeamNotification.BoolValue)return;
	
	switch (gc_ChangeTeamNotification.IntValue)
	{
		case 1:CPrintToChat(client, "%t","BlockTeam_Chat", MOD_TAG);
		case 2:PrintHintText(client, "%t","BlockTeam_Hint", MOD_TAG);
	}
	return;
}

bool IsPlayerAdmin(int client)
{
	if (GetUserFlagBits(client) & ADMFLAG_GENERIC)return true;
	if (GetUserFlagBits(client) & ADMFLAG_ROOT)return true;
	
	return false;
}

bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || !IsClientConnected(client) || IsFakeClient(client) || IsClientSourceTV(client))
		return false;
	
	return true;
} 