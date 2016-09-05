


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
		DisplayChangeLevelMenu(param);
	}
}

// Admin menu/Server Commands/Change Level
void DisplayChangeLevelMenu(int client)
{
	Menu menu = new Menu(MenuHandler_ChangeLevel);

	char title[100];
	Format(title, sizeof(title), "Change level");
	menu.SetTitle(title);
	menu.ExitBackButton = true;

	menu.AddItem("", 		"Choose map with current gamemode");
	menu.AddItem("", 		"Choose map -> gamemode");
	menu.AddItem("", 		"Choose gamemode -> map");

	menu.Display(client, MENU_TIME_FOREVER);
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
				char gamemode[64];
				InsurgencyMap_Gamemode(gamemode, sizeof(gamemode));

				if(strlen(gamemode) <= 0)
				{
					hTopMenu.Display(param1, TopMenuPosition_LastCategory);
					return;
				}

				ArrayList array = new ArrayList(ByteCountToCells(64));
				InsurgencyMap_GamemodeMapsArray(gamemode, array);

				int count = GetArraySize(array);

				if(count <= 0)
				{
					delete array;
					hTopMenu.Display(param1, TopMenuPosition_LastCategory);
					return;
				}

				Menu newmenu = new Menu(MenuHandler_Map);

				char info[64];
				char map[64];
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

				char info[64];
				char map[64];

				Format(info, sizeof(info), "Choose map -> next gamemode");
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
			}
		}
		hTopMenu.Display(param1, TopMenuPosition_LastCategory);
	}
}

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
		char info[64];
		menu.GetItem(param2, info, sizeof(info));
		ForceChangeLevel(info, "Insurgency_maps menu");
		//hTopMenu.Display(param1, TopMenuPosition_LastCategory);
	}
}

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
		char map[64];
		menu.GetItem(param2, map, sizeof(map));

		ArrayList array = new ArrayList(ByteCountToCells(64));
		InsurgencyMap_MapGamemodesArray(map, array);

		int count = GetArraySize(array);

		if(count <= 0)
		{
			delete array;
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
			return;
		}

		Menu newmenu = new Menu(MenuHandler_MapGamemodeFinal);

		char info[64];
		char gamemode[64];
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

public int MenuHandler_MapGamemodeFinal(Menu menu, MenuAction action, int param1, int param2)
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
		char info[64];
		menu.GetItem(param2, info, sizeof(info));
		ForceChangeLevel(info, "Insurgency_maps menu");
	}
}