#include <sourcemod>

static String:KVPath[PLATFORM_MAX_PATH];
new Handle:ClientTimer[32];
static Minutes[32];

public Plugin:myinfo = {
	name = "onlinetimer",
	author = "Tatu Toikkanen",
	description = "Time online",
	url = "https://tatu.moe"
};

public OnPluginStart()
{
	BuildPath(Path_SM, KVPath, sizeof(KVPath), "data/onlinetime.txt");
	RegConsoleCmd("sm_info", Command_getInfo, "");
}

public OnClientPutInServer(client)
{
	SavePlayerInfo(client, 1);
	ClientTimer[client] = CreateTimer(60.0, TimerAddTime, client, TIMER_REPEAT);
}

public OnClientDisconnect(client)
{
	CloseHandle(ClientTimer[client]);
	SavePlayerInfo(client, 0);
}

public Action:Command_getInfo(client, args)
{
	new String:Name[32];
	GetClientName(client, Name, sizeof(Name));
	
	PrintToChatAll("%s has played %d minutes in server", Name, Minutes[client]);
	return Plugin_Handled;
}

public Action:TimerAddTime(Handle:timer, any:client)
{
	if(IsClientConnected(client) && IsClientInGame(client))
	{
		Minutes[client]++;
	}
}

public SavePlayerInfo(client, connection)
{
	new Handle:DB = CreateKeyValues("PlayerInfo");
	FileToKeyValues(DB, KVPath);
	
	new String:SID[32];
	GetClientAuthString(client, SID, sizeof(SID));
	if(connection == 1){
		if(KvJumpToKey(DB, SID, true))
		{
			new String:name[32], String:temp_name[32];
			GetClientName(client, name, sizeof(name));
		
			KvGetString(DB, "name", temp_name, sizeof(temp_name), "NULL");
		
			Minutes[client] = KvGetNum(DB, "minutes", 0);
		
			new conTime = KvGetNum(DB, "conTime", 0);
		
			if(StrEqual(temp_name, "NULL") && conTime == 0)
			{
				PrintToChatAll("%s is new to the server!", name);
			} 
			else {
				PrintToChatAll("%s has connected %d times to the server.", name, conTime);
			}
		
			KvSetNum(DB, "conTime", ++conTime);
			KvSetString(DB, "name", name);
		
		}
	} else if(connection == 0)
	{
		if(KvJumpToKey(DB, SID, true))
		{
			KvSetNum(DB, "minutes", Minutes[client]);
		}
	}
	KvRewind(DB);
	KeyValuesToFile(DB, KVPath);
	CloseHandle(DB);
}