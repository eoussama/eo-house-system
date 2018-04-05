/*

                            _____ _____   _   _                        _____           _                 
                            |  ___|  _  | | | | |                      /  ___|         | |                
                            | |__ | | | | | |_| | ___  _   _ ___  ___  \ `--. _   _ ___| |_ ___ _ __ ___  
                            |  __|| | | | |  _  |/ _ \| | | / __|/ _ \  `--. \ | | / __| __/ _ \ '_ ` _ \ 
                            | |___\ \_/ / | | | | (_) | |_| \__ \  __/ /\__/ / |_| \__ \ ||  __/ | | | | |
                            \____/ \___/  \_| |_/\___/ \__,_|___/\___| \____/ \__, |___/\__\___|_| |_| |_|
                                                                            __/ |                      
                                                                            |___/                 
                                                    
                                    @title:                 EO House System
                                    @author:                EOussama a.k.a Compton
                                    @date:                  4/3/2018
                                    @github repository:     https://github.com/EOussama/EO-House-System

                                    > House filterscript
*/
#define FILTERSCRIPT
#if defined FILTERSCRIPT

// Libraries ----------------------------------------------
#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <YSI\y_iterate>
#include <sscanf2>
#include <izcmd>

#include "utils/eo_house.inc"

// Constants ----------------------------------------------
#define MYSQL_HOST      "localhost"
#define MYSQL_USER      "root"
#define MYSQL_PASSWORD  ""
#define MYSQL_DATABASE  "eo_house_system"

// Colors
#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_RED       0xFF000080
#define COLOR_YELLOW    0xFFFF0080

// Dialogs
#define DIALOG_EO_INTERIORS 8500

// Enumerators --------------------------------------------
enum E_PLAYER
{
    e_userid,
    e_interior,
    e_virtualWorld,
    Float:e_position[E_COORDINATES]
}

// Variables ----------------------------------------------
new
    pInfo[MAX_PLAYERS][E_PLAYER],
    MySQL:handle;

// Callbacks ----------------------------------------------
public OnFilterScriptInit()
{
    new MySQLOpt:options = mysql_init_options();

    handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    mysql_set_option(options, AUTO_RECONNECT, true);

    if(handle && mysql_errno(handle) == 0)
    {
        print("Connection to "#MYSQL_DATABASE" was successfull!");
        DisableInteriorEnterExits();
    }

    else
    {
        print("Connection to "#MYSQL_DATABASE" failed!");
        SendRconCommand("unloadfs eo_house_system");
    }

    return 1;
}

public OnFilterScriptExit()
{
    print("Filterscript terminated!");
    mysql_close(handle);

    return 1;
}

public OnPlayerConnect(playerid)
{
    new query[100];

    mysql_format(handle, query, sizeof(query), "SELECT `userid` FROM `Users` WHERE `username` = '%e';", GetPlayerNameEx(playerid));
    mysql_tquery(handle, query, "CheckAccount", "i", playerid);

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_EO_INTERIORS :
        {
            if(!response) return 0;

            if(listitem == 0)
            {
                TogglePlayerControllable(playerid, false);
                SetPlayerPos(playerid, pInfo[playerid][e_position][e_posX], pInfo[playerid][e_position][e_posY], pInfo[playerid][e_position][e_posZ]);
                SetPlayerInterior(playerid, pInfo[playerid][e_interior]);
                SetPlayerVirtualWorld(playerid, pInfo[playerid][e_virtualWorld]);
                TogglePlayerControllable(playerid, true);
                SendClientMessage(playerid, COLOR_YELLOW, "[INFO]: You have teleported back to your previous position!");
            }

            else
            {
                new message[100];

                SavePlayerPosition(playerid);
                format(message, sizeof(message), "%d - %s", intInfo[listitem - 1][e_intId], intInfo[listitem - 1][e_intLabel]);

                TogglePlayerControllable(playerid, false);
                SetPlayerPos(playerid, intInfo[listitem - 1][e_intPos][e_posX], intInfo[listitem - 1][e_intPos][e_posY], intInfo[listitem - 1][e_intPos][e_posZ]);
                SetPlayerInterior(playerid, intInfo[listitem - 1][e_intId]);
                TogglePlayerControllable(playerid, true);
                GameTextForPlayer(playerid, message, 1000, 1);

                return cmd_eohouse(playerid, "interiors");
            }
        }
    }

    return 1;
}

// Functions --------------------------------------------------
GetPlayerNameEx(playerid)
{
    new playerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    return playerName;
}

SavePlayerPosition(playerid)
{
    new Float:currentCoordinates[E_COORDINATES];

    GetPlayerPos(playerid, currentCoordinates[e_posX], currentCoordinates[e_posY], currentCoordinates[e_posZ]);
    pInfo[playerid][e_position] = currentCoordinates;
    pInfo[playerid][e_interior] = GetPlayerInterior(playerid);
    pInfo[playerid][e_virtualWorld] = GetPlayerVirtualWorld(playerid);
}

forward CheckAccount(playerid);
public CheckAccount(playerid)
{
    if(cache_num_rows() == 0)
    {
        new query[100];

        mysql_format(handle, query, sizeof(query), "INSERT INTO `Users`(`username`) VALUES('%e');", GetPlayerNameEx(playerid));
        mysql_query(handle, query, false);
    }

    else
        cache_get_value_name_int(0, "userid", pInfo[playerid][e_userid]);
}

// Commands ------------------------------------------------------
CMD:eohouse(playerid, params[])
{
    new action[10], extra[50];
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You do not have permission to use this command!");
    if(sscanf(params, "s[10] ", action)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse [action: create/destroy/edit/interiors]");

    if(!strcmp(action, "create", true))
    {
        new interior, cost, houseid, Float:posX, Float:posY, Float:posZ;
   
        if(sscanf(extra, "{s[8]}dd", interior, cost)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse create [interior id] [cost]");
        if(cost < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: The house cost cannot be lower than $0");
        if(interior > MAX_INTERIORS - 1 || interior < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: The interior id must be greater than or equal to 0 and lower than "#MAX_INTERIORS"!");

        houseid = Iter_Free(House);
        GetPlayerPos(playerid, posX, posY, posZ);
        CreateHouse(handle, houseid, -1, posX, posY, posZ, intInfo[interior][e_intPos][e_posX], intInfo[interior][e_intPos][e_posY], intInfo[interior][e_intPos][e_posZ], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), houseid, intInfo[interior][e_intId], cost);
        SendClientMessage(playerid, -1, "House was created!");
    }

    else if(!strcmp(action, "destroy", true))
    {
        new houseid;
   
        if(sscanf(extra, "{s[8]}d", houseid)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse destroy [house id]");

        SendClientMessage(playerid, -1, "This is the destroy option");
    }

    else if(!strcmp(action, "edit", true))
    {
        new houseid;
   
        if(sscanf(extra, "{s[8]}d", houseid)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse edit [house id]");

        SendClientMessage(playerid, -1, "This is the edit option");
    }

    else if(!strcmp(action, "interiors", true))
    {
        new content[500] = "ID\tInterior\tLabel\n";

        format(content, sizeof(content), "%s\tX\t%d\tTeleport back to your previous position\n", content, pInfo[playerid][e_interior]);
        for(new i = 0, j = sizeof(intInfo); i<j; i++)
            format(content, sizeof(content), "%s%d\t%d\t%s\n", content, i, intInfo[i][e_intId], intInfo[i][e_intLabel]);

        ShowPlayerDialog(playerid, DIALOG_EO_INTERIORS, DIALOG_STYLE_TABLIST_HEADERS, "House interiors", content, "Teleport", "Close");
    }

    else
        return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid action!");

    return CMD_SUCCESS;
}

CMD:tpos(playerid, params[])
{
    new interior, Float:coordinates[E_COORDINATES], message[128];
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You do not have permission to use this command!");
    if(sscanf(params, "dfff ", interior, coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ])) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /tpos [interior] [x] [y] [z]");

    SavePlayerPosition(playerid);
    TogglePlayerControllable(playerid, false);
    SetPlayerPos(playerid, coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ]);
    SetPlayerInterior(playerid, interior);
    format(message, sizeof(message), "[INFO]: You have teleported to (x: %f, y: %f, z: %f) - interior: %d", coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ], interior);
    SendClientMessage(playerid, COLOR_YELLOW, message);
    TogglePlayerControllable(playerid, true);

    return CMD_SUCCESS;
}

#endif