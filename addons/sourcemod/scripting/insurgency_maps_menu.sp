

#include <insurgency_maps>
#undef REQUIRE_PLUGIN
#include <adminmenu>

TopMenu hTopMenu;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_changelevel", sm_changelevel, ADMFLAG_CHANGEMAP, "sm_slap <#userid|name> [damage]");

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

void DisplayChangeLevelMenu(int client)
{
	Menu menu = new Menu(MenuHandler_ChangeLevel);
	
	char title[100];
	Format(title, sizeof(title), "Change level!");
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	

	ArrayList maps = new ArrayList(ByteCountToCells(64));
	InsurgencyMap_MapArray(maps);

	char name[64];
	int x = GetArraySize(maps);
	for(int a = 0; a < x; a++)
	{
		GetArrayString(maps, a, name, sizeof(name));
		menu.AddItem(name, name);
	}
	delete maps;
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
		char info[64];		
		menu.GetItem(param2, info, sizeof(info));
		PrintToServer(info);

		
		hTopMenu.Display(param1, TopMenuPosition_LastCategory);
	}
}