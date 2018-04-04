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
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED   0xFF000080

// Dialogs
#define DIALOG_EO_INTERIORS 8500

// Variables ----------------------------------------------
new
    pInfo[MAX_PLAYERS],
    MySQL:handle;

// Callbacks ----------------------------------------------
public OnFilterScriptInit()
{
    new MySQLOpt:options = mysql_init_options();

    handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    mysql_set_option(options, AUTO_RECONNECT, true);

    if(handle && mysql_errno(handle) == 0)
        print("Connection to "#MYSQL_DATABASE" was successfull!");
    else
    {
        print("Connection to "#MYSQL_DATABASE" failed!");
        SendRconCommand("unloadfs eo_house_system");
    }
    
    for(new i; i<sizeof(intInfo); i++)
    {
        printf("[%d]\tInterior: %d\tLabel: %s\tCoordinates: X: %f\tY: %f\tZ: %f", i, intInfo[i][e_intId], intInfo[i][e_intLabel], intInfo[i][e_intPos][e_posX], intInfo[i][e_intPos][e_posY], intInfo[i][e_intPos][e_posZ]);
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

// Functions --------------------------------------------------
GetPlayerNameEx(playerid)
{
    new playerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    return playerName;
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
        cache_get_value_name_int(0, "userid", pInfo[playerid]);
}

// Commands ------------------------------------------------------
CMD:eohouse(playerid, params[])
{
    new action[8], extra[50];
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You do not have permission to use this command!");
    if(sscanf(params, "s[8] ", action)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse [action: create/destroy/edit]");

    if(!strcmp(action, "create", true))
    {
        new interior, cost, Float:posX, Float:posY, Float:posZ;
   
        if(sscanf(extra, "{s[8]}dd", interior, cost)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse create [interior id] [cost]");
        if(cost < 0) return SendClientMessage(playerid, COLOR_RED, "[House] The house cost cannot be lower than $0");

        GetPlayerPos(playerid, posX, posY, posZ);
        //CreateHouse(handle, houseid, -1, posX, posY, posZ, Float:intX, Float:intY, Float:intZ, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), intVW, intInt, cost);
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
        SendClientMessage(playerid, -1, "Interior dialog opened!");
    }

    else if(!strcmp(action, "interiors", true))
    {
        new content[500];

        ShowPlayerDialog(playerid, DIALOG_EO_INTERIORS, DIALOG_STYLE_TABLIST_HEADERS, "House interiors", content, "Teleport", "Close");
    }

    else
        return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid action!");

    return CMD_SUCCESS;
}

#endif