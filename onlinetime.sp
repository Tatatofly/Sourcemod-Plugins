#include <sourcemod>

static String:KVPath[PLATFORM_MAX_PATH];
new Handle:ClientTimer[32];
public Minutes[32];
public timeOnline[32];
public timeOnlineTotal[32];

public Plugin:myinfo = {
	name = "onlinetime",
	author = "Tatu Toikkanen",
	description = "Time online",
	url = "https://tatu.moe"
};

public OnPluginStart()
{
	BuildPath(Path_SM, KVPath, sizeof(KVPath), "data/onlinetime.txt");
	RegConsoleCmd("sm_timeonline", Command_getInfo, "");
}

public OnClientPutInServer(client)
{
	SavePlayerInfo(client, 1);
	ClientTimer[client] = CreateTimer(60.0, TimerAddMinutes, client, TIMER_REPEAT);
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
	
	if(args > 1){
		PrintToConsole(client, "[SM]: sm_timeonline");
		return Plugin_Handled;
	}
	timeOnlineTotal[client] = timeOnline[client] + Minutes[client];
	
	PrintToChatAll("%s has played for %d minutes on this server", Name, timeOnlineTotal[client]);
	return Plugin_Handled;
}

public Action:TimerAddMinutes(Handle:timer, any:client)
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
			
			new conTime = KvGetNum(DB, "conTime", 0);
			new timeOnlines = KvGetNum(DB, "minutes", 0);
			timeOnline[client] = timeOnlines;
			
		
		
			KvSetNum(DB, "conTime", ++conTime);
			KvSetNum(DB, "minutes", timeOnlines);
			KvSetString(DB, "name", name);
		
		}
	} else if(connection == 0)
	{
		if(KvJumpToKey(DB, SID, true))
		{
			timeOnlineTotal[client] = timeOnline[client] + Minutes[client];
			KvSetNum(DB, "minutes", timeOnlineTotal[client]);
		}
	}
	KvRewind(DB);
	KeyValuesToFile(DB, KVPath);
	CloseHandle(DB);
	timeOnline[client] = 0;
}