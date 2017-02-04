#include <sourcemod>
#include <geoip>

public Plugin:myinfo = {
	name = "joinmesg",
	author = "Tatatofly",
	description = "Gives info from player who joins server",
	url = "https://tatu.moe"
};

public OnClientPutInServer(client)
{
	new String:ip[16];
	new String:name[32];
	new String:country[45];
	GetClientIP(client, ip, sizeof(ip));
	GeoipCountry(ip, country, sizeof(country));
	GetClientName(client, name, sizeof(name));
	PrintToChatAll("[INFO] %s joined from %s", name, country);
}