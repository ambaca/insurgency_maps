
#include <insurgency_maps>

public OnPluginStart()
{
	RegConsoleCmd("sm_test", test);
}

public Action test(int client, int agrs)
{
	PrintToServer("InsurgencyMap_MapCount() = %i", InsurgencyMap_MapCount());

	ArrayList array = new ArrayList(ByteCountToCells(64));

	InsurgencyMap_MapArray(array);

	char buffer[64];
	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, buffer, sizeof(buffer));
		PrintToServer("InsurgencyMap_MapArray %i %s", i, buffer);
	}

	array.Clear();

	InsurgencyMap_MapGamemodesArray("market", array);

	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, buffer, sizeof(buffer));
		PrintToServer("InsurgencyMap_MapGamemodesArray(market) %i %s", i, buffer);
	}

	array.Clear();

	InsurgencyMap_GamemodeMapsArray("push", array);

	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, buffer, sizeof(buffer));
		PrintToServer("InsurgencyMap_GamemodeMapsArray(push) %i %s", i, buffer);
	}

	InsurgencyMap_Gamemode(buffer, sizeof(buffer));
	PrintToServer("InsurgencyMap_Gamemode %s", buffer);


	array.Clear();

	InsurgencyMap_GamemodeArray(array);

	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, buffer, sizeof(buffer));
		PrintToServer("InsurgencyMap_GamemodeArray %i %s %s", i, buffer, InsurgencyMap_IsGameTypeCoop(buffer) ? "coop":"pvp");
	}
	delete array;



	return Plugin_Handled;
}