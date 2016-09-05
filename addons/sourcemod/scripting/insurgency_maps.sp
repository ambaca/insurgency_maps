

#include <sdktools>
#include <insurgency_maps>

KeyValues kvlistmaps;

public void OnPluginStart()
{
	kvlistmaps = new KeyValues("data");
	OnConfigsExecuted();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("InsurgencyMap_MapCount", _Native_InsurgencyMap_MapCount);
	CreateNative("InsurgencyMap_MapArray", _Native_InsurgencyMap_MapArray);
	CreateNative("InsurgencyMap_MapGamemodesArray", _Native_InsurgencyMap_MapGamemodesArray);
	CreateNative("InsurgencyMap_GamemodeMapsArray", _Native_InsurgencyMap_GamemodeMapsArray);
	CreateNative("InsurgencyMap_Gamemode", _Native_InsurgencyMap_Gamemode);
	CreateNative("InsurgencyMap_GamemodeArray", _Native_InsurgencyMap_GamemodeArray);
	CreateNative("InsurgencyMap_IsGameTypeCoop", _Native_InsurgencyMap__IsGameTypeCoop);

	RegPluginLibrary("insurgency_maps");

	return APLRes_Success;
}

public int _Native_InsurgencyMap_MapCount(Handle plugin, int numParams)
{
	int value;

	if(kvlistmaps.JumpToKey("maps") && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			value++;
		}
		while(kvlistmaps.GotoNextKey(false))
	}
	kvlistmaps.Rewind();

	return value;
}

public _Native_InsurgencyMap_MapArray(Handle plugin, int numParams)
{
	char map[64];
	ArrayList array = GetNativeCell(1);

	if(array == INVALID_HANDLE) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Handle, create adt_array, \"CreateArray()\" or \"new ArrayList()\"!");

	if(kvlistmaps.JumpToKey("maps") && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			kvlistmaps.GetSectionName(map, sizeof(map));
			array.PushString(map);
		}
		while(kvlistmaps.GotoNextKey(false))
	}
	kvlistmaps.Rewind();

	return _:array;
}


public _Native_InsurgencyMap_MapGamemodesArray(Handle plugin, int numParams)
{
	ArrayList array = GetNativeCell(2);
	if(array == INVALID_HANDLE) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Handle, create adt_array, \"CreateArray()\" or \"new ArrayList()\"!");

	int len;
	GetNativeStringLength(1, len);

	if (len <= 0)
	{
	  return _:array;
	}

	char map[PLATFORM_MAX_PATH];
	char gamemode[64];
	GetNativeString(1, map, 64);
	Format(map, sizeof(map), "maps/%s", map);

	if(kvlistmaps.JumpToKey(map) && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			kvlistmaps.GetSectionName(gamemode, sizeof(gamemode));
			array.PushString(gamemode);
		}
		while(kvlistmaps.GotoNextKey(false))
	}
	kvlistmaps.Rewind();

	return _:array;
}


public _Native_InsurgencyMap_GamemodeMapsArray(Handle plugin, int numParams)
{
	ArrayList array = GetNativeCell(2);
	if(array == INVALID_HANDLE) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Handle, create adt_array, \"CreateArray()\" or \"new ArrayList()\"!");

	int len;
	GetNativeStringLength(1, len);

	if (len <= 0)
	{
	  return _:array;
	}

	char map[PLATFORM_MAX_PATH];
	char gamemode[64];
	GetNativeString(1, map, 64);
	Format(map, sizeof(map), "gamemodes/%s", map);

	if(kvlistmaps.JumpToKey(map) && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			kvlistmaps.GetSectionName(gamemode, sizeof(gamemode));
			array.PushString(gamemode);
		}
		while(kvlistmaps.GotoNextKey(false))
	}
	kvlistmaps.Rewind();

	return _:array;
}

public _Native_InsurgencyMap_Gamemode(Handle plugin, int numParams)
{
	int param_len = GetNativeCell(2);

	if (param_len <= 0)
	{
	  return;
	}

	char gamemode[64];

	int logic = GameRules_GetPropEnt("m_hLogicGameType");

	if(logic != -1)
	{
		GetEntityClassname(logic, gamemode, sizeof(gamemode));
		ReplaceString(gamemode, sizeof(gamemode), "logic_", "", false);
	}

	SetNativeString(1, gamemode, param_len, false);
}

public _Native_InsurgencyMap_GamemodeArray(Handle plugin, int numParams)
{
	char gamemode[64];
	ArrayList array = GetNativeCell(1);

	if(array == INVALID_HANDLE) return ThrowNativeError(SP_ERROR_NATIVE, "Invalid Handle, create adt_array, \"CreateArray()\" or \"new ArrayList()\"!");

	if(kvlistmaps.JumpToKey("gamemodes") && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			kvlistmaps.GetSectionName(gamemode, sizeof(gamemode));
			array.PushString(gamemode);
		}
		while(kvlistmaps.GotoNextKey(false))
	}
	kvlistmaps.Rewind();

	return _:array;
}

public int _Native_InsurgencyMap__IsGameTypeCoop(Handle plugin, int numParams)
{
	int len;
	GetNativeStringLength(1, len);

	if (len <= 0)
	{
	  return false;
	}

	char buffer[64];
	bool IsCoop;
	char gamemode[64];
	GetNativeString(1, gamemode, sizeof(gamemode));

	if(kvlistmaps.JumpToKey("type/coop") && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			kvlistmaps.GetSectionName(buffer, sizeof(buffer));
			if(StrEqual(gamemode, buffer, false))
			{
				IsCoop = true;
				break;
			}
		}
		while(kvlistmaps.GotoNextKey(false))
	}
	kvlistmaps.Rewind();

	return IsCoop;
}

public void OnConfigsExecuted()
{
	// check required file(s)
	char source[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, source, sizeof(source), "configs/insurgency_maps/main.txt");
	if(!FileExists(source)) SetFailState("Couldn't find or open \"configs/insurgency_maps/main.txt\" file.");

	// copy gamemodes in kv
	KeyValues kv = new KeyValues("data");
	if(!kv.ImportFromFile(source) || !kv.JumpToKey("gamemodes"))
	{
		delete kv;
		SetFailState("Couldn't get gamemodes from \"configs/insurgency_maps/main.txt\" file.");
	}

	kv.Rewind();

	
	char buffer[PLATFORM_MAX_PATH];
	char mapname[PLATFORM_MAX_PATH];
	char mode[PLATFORM_MAX_PATH];
	char tmp[PLATFORM_MAX_PATH];
	
	KeyValues maptxt;

	ArrayList maplist = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	int serial;
	ReadMapList(maplist, serial, "insurgency_maps plugin", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT|MAPLIST_FLAG_CLEARARRAY);

	if(maplist != INVALID_HANDLE)
	{
		SortADTArray(maplist, Sort_Ascending, Sort_String);

		int x = GetArraySize(maplist);

		for(int a = 0; a < x; a++)
		{
			GetArrayString(maplist, a, buffer, sizeof(buffer));
			//PrintToServer("finall %i %s", a, buffer);

			// find map cpsetup script file
			Format(buffer, sizeof(buffer), "maps/%s.txt", buffer);
			if(!FileExists(buffer, true, NULL_STRING)) continue;


			// copy cpsetup script file
			if(maptxt != INVALID_HANDLE) delete maptxt;
			maptxt = new KeyValues("data");
			if(!maptxt.ImportFromFile(buffer)) continue;

		
			// add map in maplist with valid cpsetup gamemodes ("configs/insurgency_maps/main.txt")
			ReplaceString(buffer, sizeof(buffer), ".txt", "", false);
			strcopy(mapname, sizeof(mapname), buffer[5]);

			if(!maptxt.GotoFirstSubKey(false)) continue;
			
			do
			{
				maptxt.GetSectionName(mode, sizeof(mode));

				kv.JumpToKey("gamemodes");
				kv.GetString(mode, tmp, sizeof(tmp), NULL_STRING);
				kv.Rewind();

				// does map cpsetup match with filter ?
				if(!StrEqual(tmp, NULL_STRING, false))
				{
					Format(buffer, sizeof(buffer), "maps/%s/%s", mapname, mode);
					kvlistmaps.SetString(buffer, tmp);

					Format(buffer, sizeof(buffer), "gamemodes/%s/%s", mode, mapname);
					kvlistmaps.SetString(buffer, tmp);

					Format(buffer, sizeof(buffer), "type/%s/%s", tmp, mode);
					kvlistmaps.SetString(buffer, tmp);
				}
			}
			while(maptxt.GotoNextKey(false))
		}
	}

	delete maplist;
	delete kv;
	delete maptxt;

	// debug kv tree
	//KvRewind(kvlistmaps);
	//KeyValuesToFile(kvlistmaps, "kv.txt");


	kvlistmaps.Rewind();

	
	
	
	// build full map list
	char gamemode[30];
	char map[64];
	char line[PLATFORM_MAX_PATH];

	File mapcycle_full = OpenFile("maps/mapcycle_full_list.bak", "wb");

	if(kvlistmaps.JumpToKey("maps", false) && kvlistmaps.GotoFirstSubKey(false))
	{
		do
		{
			kvlistmaps.GetSectionName(map, sizeof(map));

			do
			{
				kvlistmaps.GotoFirstSubKey(false);
				kvlistmaps.GetSectionName(gamemode, sizeof(gamemode));
				Format(line, sizeof(line), "%s %s", map, gamemode);
				mapcycle_full.WriteLine(line);
			}
			while(kvlistmaps.GotoNextKey(false))

			kvlistmaps.GoBack();
		}
		while(kvlistmaps.GotoNextKey(false))
	}

	kvlistmaps.Rewind();

	delete mapcycle_full;
}
