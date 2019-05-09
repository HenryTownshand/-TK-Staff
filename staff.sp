#include <sourcemod>
#include <sdktools>
#include <csgo_colors>

const int g_iCount = 2;
char g_sText[][] =  { "Мина", "Снежок", "Щит" };
bool g_bCount[MAXPLAYERS + 1][g_iCount + 1];

public Plugin myinfo = 
{
	name = "[TK]Stuff", 
	author = "HenryTownshand", 
	description = "CSGO Stuff", 
	version = "1.00", 
	url = "https://vk.com/heathercs"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_stuff", Command, ADMFLAG_BAN);
	HookEvent("round_start", RoundStart);
	ResetStatus();
}

stock void ResetStatus()
{
	for (int i = 0; i < g_iCount + 1; i++)
	for (int j = 0; j < MAXPLAYERS + 1; j++)
	g_bCount[j][i] = true;
}

public void RoundStart(Event event, const char[] name, bool dbc)
{
	ResetStatus();
}

public Action Command(int iClient, int iArg)
{
	if (iArg < 2 || iArg > 2)
	{
		NewWeapon(iClient);
	}
	
	char szBuffer[64];
	char sTargetName[MAX_TARGET_LENGTH];
	int iTargetList[MAXPLAYERS];
	int iTargetCount;
	bool bMore;
	
	GetCmdArg(1, szBuffer, sizeof(szBuffer));
	
	if ((iTargetCount = ProcessTargetString(szBuffer, iClient, iTargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_BOTS, sTargetName, sizeof(sTargetName), bMore)) <= 0)
	{
		//ReplyToTargetError(iClient, iTargetCount);
		return Plugin_Handled;
	}
	
	int iNum;
	GetCmdArg(2, szBuffer, sizeof(szBuffer));
	iNum = StringToInt(szBuffer);
	
	for (int i = 0; i < iTargetCount; i++)
	{
		Commands(iNum, iTargetList[i]);
		g_bCount[i][iNum] = false;
	}
	
	return Plugin_Handled;
}

stock void Commands(int iCommands, int iClient)
{
	if (g_bCount[iClient][iCommands])
	{
		if (iCommands == 0)
			GivePlayerItem(iClient, "weapon_bumpmine");
		if (iCommands == 1)
			for (int i = 0; i < 5; i++)
		GivePlayerItem(iClient, "weapon_snowball");
		if (iCommands == 2)
			GivePlayerItem(iClient, "weapon_shield");
		
		g_bCount[iClient][iCommands] = false;
	} else {
		CGOPrintToChat(iClient, "{DEFAULT}[{BLUE}TK{DEFAULT}] {PURPLE}%N {DEFAULT}уже получал предмет: {RED}%s", iClient, g_sText[iCommands]);
	}
}

public void NewWeapon(int iClient)
{
	Menu hMenu = new Menu(NewWeaponItems);
	hMenu.ExitButton = true;
	hMenu.SetTitle("Меню предметов \n ");
	
	for (int i = 0; i < g_iCount + 1; i++)
	{
		if (g_bCount[iClient][i])
		{
			hMenu.AddItem(NULL_STRING, g_sText[i]);
		} else {
			hMenu.AddItem(NULL_STRING, g_sText[i], ITEMDRAW_DISABLED);
		}
	}
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int NewWeaponItems(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	
	switch (action)
	{
		case MenuAction_End:delete hMenu;
		case MenuAction_Select:
		{
			switch (iItem)
			{
				case 0:
				{
					Commands(0, iClient);
					//g_bCount[iClient][0] = false;
					NewWeapon(iClient);
				}
				case 1:
				{
					Commands(1, iClient);
					//g_bCount[iClient][1] = false;
					NewWeapon(iClient);
				}
				case 2:
				{
					Commands(2, iClient);
					//g_bCount[iClient][2] = false;
					NewWeapon(iClient);
				}
			}
			NewWeapon(iClient);
		}
	}
} 