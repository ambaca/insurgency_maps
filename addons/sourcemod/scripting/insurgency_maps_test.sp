
#include <insurgency_maps>

public OnPluginStart()
{
	RegConsoleCmd("sm_test", test);
}

public Action test(int client, int agrs)
{
	PrintToServer("maps %i", InsurgencyMap_MapCount());

	ArrayList array = new ArrayList(ByteCountToCells(64));

	InsurgencyMap_MapArray(array);

	char map[64];
	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, map, sizeof(map));
		PrintToServer(map);
	}

	array.Clear();


	InsurgencyMap_MapGamemodesArray("baghdad_b5", array);
	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, map, sizeof(map));
		PrintToServer("++%s", map);
	}

	array.Clear();


	InsurgencyMap_GamemodeMapsArray("ambush", array);
	for(int i = 0; i < array.Length; i++)
	{
		array.GetString(i, map, sizeof(map));
		PrintToServer("-%s", map);
	}
	
	delete array;


	InsurgencyMap_Gamemode(map, sizeof(map));
	PrintToServer("+%s", map);
	return Plugin_Handled;
}