


#include <insurgency_maps>
#undef REQUIRE_PLUGIN
#include <adminmenu>

TopMenu hTopMenu;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_changelevel", sm_changelevel, ADMFLAG_CHANGEMAP, "sm_changelevel <map> <gamemode>]");

	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null)) OnAdminMenuReady(topmenu);
}

public Action sm_changelevel(int client, int args)
{
	return Plugin_Handled;
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	if(topmenu == hTopMenu) return;

	hTopMenu = topmenu;
	TopMenuObject server_commands = hTopMenu.FindCategory(ADMINMENU_SERVERCOMMANDS);

	if(server_commands != INVALID_TOPMENUOBJECT)
	{
		hTopMenu.AddItem("sm_changelevel", AdminMenu_ChangeLevel, server_commands, "sm_changelevel", ADMFLAG_CHANGEMAP);
	}
}

// Admin menu/Server Commands/
public void AdminMenu_ChangeLevel(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Change level");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		Menu menu = new Menu(MenuHandler_ChangeLevel);

		char title[100];
		Format(title, sizeof(title), "Change level");
		menu.SetTitle(title);
		menu.ExitBackButton = true;

		InsurgencyMap_Gamemode(title, sizeof(title));
		Format(title, sizeof(title), "Choose map with current gamemode (%s)", title);
		
		menu.AddItem("", 		title);
		menu.AddItem("", 		"Choose map and gamemode");
		menu.AddItem("", 		"Choose gamemode and map");

		menu.Display(param, MENU_TIME_FOREVER);
	}
}


public int MenuHandler_ChangeLevel(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0:
			{
				char gamemode[PLATFORM_MAX_PATH];
				InsurgencyMap_Gamemode(gamemode, sizeof(gamemode));

				if(strlen(gamemode) <= 0)
				{
					hTopMenu.Display(param1, TopMenuPosition_LastCategory);
					return;
				}

				ArrayList array = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
				InsurgencyMap_GamemodeMapsArray(gamemode, array);

				int count = GetArraySize(array);

				if(count <= 0)
				{
					delete array;
					hTopMenu.Display(param1, TopMenuPosition_LastCategory);
					return;
				}

				Menu newmenu = new Menu(MenuHandler_Map);

				char info[PLATFORM_MAX_PATH];
				char map[PLATFORM_MAX_PATH];
				Format(info, sizeof(info), "Choose map (%s)", gamemode);

				newmenu.SetTitle(info);
				newmenu.ExitBackButton = true;

				for(int x = 0; x < count; x++)
				{
					array.GetString(x, map, sizeof(map));
					Format(info, sizeof(info), "%s %s", map, gamemode);
					newmenu.AddItem(info, map);
				}
				newmenu.Display(param1, MENU_TIME_FOREVER);

				delete array;
				return;
			}
			case 1:
			{
				ArrayList maps = new ArrayList(ByteCountToCells(64));
				InsurgencyMap_MapArray(maps);

				int count = GetArraySize(maps);

				if(count <= 0)
				{
					delete maps;
					hTopMenu.Display(param1, TopMenuPosition_LastCategory);
					return;
				}

				Menu newmenu = new Menu(MenuHandler_MapGamemode);

				char info[PLATFORM_MAX_PATH];
				char map[PLATFORM_MAX_PATH];

				Format(info, sizeof(info), "Choose map, then next gamemode");
				newmenu.SetTitle(info);

				newmenu.ExitBackButton = true;

				for(int x = 0; x < count; x++)
				{
					maps.GetString(x, map, sizeof(map));
					newmenu.AddItem(map, map);
				}
				newmenu.Display(param1, MENU_TIME_FOREVER);

				delete maps;
				return;
			}
			case 2:
			{
				ArrayList gamemodes = new ArrayList(ByteCountToCells(64));
				InsurgencyMap_GamemodeArray(gamemodes);

				int count = GetArraySize(gamemodes);

				if(count <= 0)
				{
					delete gamemodes;
					hTopMenu.Display(param1, TopMenuPosition_LastCategory);
					return;
				}

				Menu newmenu = new Menu(MenuHandler_GamemodeMap);

				char info[PLATFORM_MAX_PATH];
				char gamemode[PLATFORM_MAX_PATH];

				Format(info, sizeof(info), "Choose gamemode, then next map");
				newmenu.SetTitle(info);

				newmenu.ExitBackButton = true;

				for(int x = 0; x < count; x++)
				{
					gamemodes.GetString(x, info, sizeof(info));
					Format(gamemode, sizeof(gamemode), "%s    %s", info, InsurgencyMap_IsGameTypeCoop(info) ? "coop":"pvp");
					newmenu.AddItem(info, gamemode);
				}
				newmenu.Display(param1, MENU_TIME_FOREVER);

				delete gamemodes;
				return;
			}
		}
		hTopMenu.Display(param1, TopMenuPosition_LastCategory);
	}
}



// case 0
public int MenuHandler_Map(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[PLATFORM_MAX_PATH];
		menu.GetItem(param2, info, sizeof(info));

		PrintToChatAll("[SM] Changing map to %s", info);
		
		DataPack pack;
		CreateDataTimer(5.0, timer_changemap, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(info);
		pack.Reset();
	}
}

// case 1
public int MenuHandler_MapGamemode(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char map[PLATFORM_MAX_PATH];
		menu.GetItem(param2, map, sizeof(map));

		ArrayList array = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
		InsurgencyMap_MapGamemodesArray(map, array);

		int count = GetArraySize(array);

		if(count <= 0)
		{
			delete array;
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
			return;
		}

		Menu newmenu = new Menu(MenuHandler_Final);

		char info[PLATFORM_MAX_PATH];
		char gamemode[PLATFORM_MAX_PATH];
		Format(info, sizeof(info), "Choose gamemode (%s)", map);

		newmenu.SetTitle(info);
		newmenu.ExitBackButton = true;

		for(int x = 0; x < count; x++)
		{
			array.GetString(x, gamemode, sizeof(gamemode));
			Format(info, sizeof(info), "%s %s", map, gamemode);
			Format(gamemode, sizeof(gamemode), "%s    %s", gamemode, InsurgencyMap_IsGameTypeCoop(gamemode) ? "coop":"pvp");
			newmenu.AddItem(info, gamemode);
		}
		newmenu.Display(param1, MENU_TIME_FOREVER);

		delete array;
		return;
	}
}


// case 2
public int MenuHandler_GamemodeMap(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char gamemode[PLATFORM_MAX_PATH];
		menu.GetItem(param2, gamemode, sizeof(gamemode));

		ArrayList array = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
		InsurgencyMap_GamemodeMapsArray(gamemode, array);

		int count = GetArraySize(array);

		if(count <= 0)
		{
			delete array;
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
			return;
		}

		Menu newmenu = new Menu(MenuHandler_Final);

		char info[PLATFORM_MAX_PATH];
		char map[PLATFORM_MAX_PATH];
		Format(info, sizeof(info), "Choose map (%s)", gamemode);

		newmenu.SetTitle(info);
		newmenu.ExitBackButton = true;

		for(int x = 0; x < count; x++)
		{
			array.GetString(x, map, sizeof(map));
			Format(info, sizeof(info), "%s %s", map, gamemode);
			newmenu.AddItem(info, map);
		}
		newmenu.Display(param1, MENU_TIME_FOREVER);

		delete array;
		return;
	}
}

public int MenuHandler_Final(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[PLATFORM_MAX_PATH];
		menu.GetItem(param2, info, sizeof(info));

		PrintToChatAll("[SM] Changing map to %s", info);
		
		DataPack pack;
		CreateDataTimer(5.0, timer_changemap, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(info);
		pack.Reset();
	}
}

public Action timer_changemap(Handle timer, DataPack pack)
{
	char info[PLATFORM_MAX_PATH];
	pack.ReadString(info, sizeof(info));
	ForceChangeLevel(info, "Insurgency_maps menu");
}


