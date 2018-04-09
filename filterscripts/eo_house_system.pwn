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

#define COL_WHITE       "{FFFFFF}"
#define COL_YELLOW      "{FFFF00}"
#define COL_GREY        "{737373}"

// Dialogs
#define DIALOG_EO_HOUSE_MSG             8500
#define DIALOG_EO_HOUSE_INTERIORS       8501
#define DIALOG_EO_HOUSE_CREATE          8502
#define DIALOG_EO_HOUSE_CREATE_INTID    8503
#define DIALOG_EO_HOUSE_CREATE_PRICE    8504
#define DIALOG_EO_HOUSE_CREATE_OWNER    8505

// Enumerators --------------------------------------------
enum E_PLAYER
{
    e_userid,
    e_interior,
    e_virtualWorld,
    Float:e_position[E_COORDINATES]
}

enum E_BUILDER
{
    e_interior,
    e_ownerid,
    e_cost,
    Float:e_pos[E_COORDINATES],
    bool:e_locked
}

// Variables ----------------------------------------------
new
    pInfo[MAX_PLAYERS][E_PLAYER],
    bInfo[MAX_PLAYERS][E_BUILDER],
    MySQL:handle;

// Functions --------------------------------------------------
bool:isNumber(const numString[])
{
    for(new i, j = strlen(numString); i!=j; i++)
    {
        if(numString[i] < 48 || numString[i] > 57)
            return false;
    }

    return true;
}

GetPlayerNameEx(playerid)
{
    new playerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    return playerName;
}

GetPlayerNameFromId(userid)
{
    new Cache:result, query[100], playerName[MAX_PLAYER_NAME];

    mysql_format(handle, query, sizeof(query), "SELECT `username` FROM `Users` WHERE `userid` = %d", userid);
    result = mysql_query(handle, query, true);
    if(cache_num_rows())
        cache_get_value_name(0, "username", playerName, MAX_PLAYER_NAME);
    else
        strcpy(playerName, "None");
    cache_delete(result);

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
    new action[10];
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You do not have permission to use this command!");
    if(sscanf(params, "s[10] ", action)) 
    {
        SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse [action]");
        ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_MSG, DIALOG_STYLE_TABLIST, "EO House - Help", "\
        /eohouse create\tCreate a new house\n\
        /eohouse destroy\tDelete a house permanently\n\
        /eohouse edit\tModify a house\n\
        /eohouse interiors\tPreview all available interiors\n\
        /eohouse tpos\tTeleport to raw coordinates", "Close", "");
    }

    else
    {
        if(!strcmp(action, "create", true))
        {
            new interior, cost, Float:posX, Float:posY, Float:posZ, content[500];
    
            if(sscanf(params, "{s[10]}dd", interior, cost)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse create [interior id] [price]");
            if(cost < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: The house cost cannot be lower than $0");
            if(interior >= MAX_INTERIORS || interior < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: The interior id must be greater than or equal to 0 and lower than "#MAX_INTERIORS"!");

            GetPlayerPos(playerid, posX, posY, posZ);
            bInfo[playerid][e_ownerid] = -1;
            bInfo[playerid][e_interior] = interior;
            bInfo[playerid][e_cost] = cost;
            bInfo[playerid][e_pos][e_posX] = posX;
            bInfo[playerid][e_pos][e_posY] = posY;
            bInfo[playerid][e_pos][e_posZ] = posZ;
            bInfo[playerid][e_locked] = true;

            format(content, sizeof(content), ""COL_GREY"\
            "COL_GREY"Interior ID\t"COL_GREY"%d\n\
            "COL_GREY"Interior\t"COL_GREY"%d\n\
            "COL_GREY"Interior label\t"COL_GREY"%s\n\
            "COL_GREY"Price\t"COL_GREY"%d\n\
            "COL_GREY"Owner\t"COL_GREY"%s\n\
            "COL_GREY"Locked\t"COL_GREY"%s\n"COL_GREY"------------------------------\t"COL_GREY"------------------------------\n\
            Edit interior ID\nEdit price\nEdit owner\n"COL_YELLOW"Create house",
            bInfo[playerid][e_interior],
            intInfo[bInfo[playerid][e_interior]][e_intId],
            intInfo[bInfo[playerid][e_interior]][e_intLabel],
            bInfo[playerid][e_cost],
            (bInfo[playerid][e_ownerid] == -1 ? "None" : GetPlayerNameFromId(bInfo[playerid][e_ownerid])),
            (bInfo[playerid][e_locked] == true ? "True" : "False"));
            ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE, DIALOG_STYLE_TABLIST, "EO House - Create", content, "Select", "Cancel");
        }

        else if(!strcmp(action, "destroy", true))
        {
            new houseid;
    
            if(sscanf(params, "{s[10]}d", houseid)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse destroy [house id]");

            SendClientMessage(playerid, -1, "This is the destroy option");
        }

        else if(!strcmp(action, "edit", true))
        {
            new houseid;
    
            if(sscanf(params, "{s[10]}d", houseid)) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /eohouse edit [house id]");

            SendClientMessage(playerid, -1, "This is the edit option");
        }

        else if(!strcmp(action, "interiors", true))
        {
            new content[500] = "ID\tInterior\tLabel\n";

            format(content, sizeof(content), "%s\tX\t%d\tTeleport back to your previous position\n", content, pInfo[playerid][e_interior]);
            for(new i = 0, j = sizeof(intInfo); i<j; i++)
                format(content, sizeof(content), "%s%d\t%d\t%s\n", content, i, intInfo[i][e_intId], intInfo[i][e_intLabel]);

            ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_INTERIORS, DIALOG_STYLE_TABLIST_HEADERS, "House interiors", content, "Teleport", "Close");
        }

        else if(!strcmp(action, "tpos", true))
        {
            new interior, Float:coordinates[E_COORDINATES], message[128];
            if(sscanf(params, "{s[10]}dfff ", interior, coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ])) return SendClientMessage(playerid, COLOR_WHITE, "[USAGE]: /tpos [interior] [x] [y] [z]");

            SavePlayerPosition(playerid);
            TogglePlayerControllable(playerid, false);
            SetPlayerPos(playerid, coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ]);
            SetPlayerInterior(playerid, interior);
            format(message, sizeof(message), "[INFO]: You have teleported to (x: %f, y: %f, z: %f) - interior: %d", coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ], interior);
            SendClientMessage(playerid, COLOR_YELLOW, message);
            TogglePlayerControllable(playerid, true);
        }

        else
            return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid action, try using /eohouse for help");
    }

    return CMD_SUCCESS;
}

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
        case DIALOG_EO_HOUSE_INTERIORS :
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

        case DIALOG_EO_HOUSE_CREATE :
        {
            if(!response) return 0;

            switch(listitem)
            {
                case 7: ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_INTID, DIALOG_STYLE_INPUT, "EO House - Create - Edit Interior ", "Input a valid interior [Refere to \"/eohouse interiors\"]", "Edit", "Back");
                case 8: ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_PRICE, DIALOG_STYLE_INPUT, "EO House - Create - Edit Price ", "Input a valid price [Must not be lower than $0]", "Edit", "Back");
                case 9: ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_OWNER, DIALOG_STYLE_INPUT, "EO House - Create - Edit Owner ", "Input a valid userid [Must be a valid userid (not playerid)]", "Edit", "Back");
                
                case 10:
                {
                    new houseid = Iter_Free(House), Float:coordinates[E_COORDINATES], interior = bInfo[playerid][e_interior];
            
                    GetPlayerPos(playerid, coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ]);
                    CreateHouse(houseid, -1, coordinates[e_posX], coordinates[e_posY], coordinates[e_posZ], intInfo[interior][e_intPos][e_posX], intInfo[interior][e_intPos][e_posY], intInfo[interior][e_intPos][e_posZ], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), houseid, intInfo[interior][e_intId], bInfo[playerid][e_cost], bInfo[playerid][e_locked]);
                }

                default:
                {
                    new content[500];

                    format(content, sizeof(content), ""COL_GREY"\
                    "COL_GREY"Interior ID\t"COL_GREY"%d\n\
                    "COL_GREY"Interior\t"COL_GREY"%d\n\
                    "COL_GREY"Interior label\t"COL_GREY"%s\n\
                    "COL_GREY"Price\t"COL_GREY"%d\n\
                    "COL_GREY"Owner\t"COL_GREY"%s\n\
                    "COL_GREY"Locked\t"COL_GREY"%s\n"COL_GREY"------------------------------\t"COL_GREY"------------------------------\n\
                    Edit interior ID\nEdit price\nEdit owner\n"COL_YELLOW"Create house",
                    bInfo[playerid][e_interior],
                    intInfo[bInfo[playerid][e_interior]][e_intId],
                    intInfo[bInfo[playerid][e_interior]][e_intLabel],
                    bInfo[playerid][e_cost],
                    (bInfo[playerid][e_ownerid] == -1 ? "None" : GetPlayerNameFromId(bInfo[playerid][e_ownerid])),
                    (bInfo[playerid][e_locked] == true ? "True" : "False"));
                    ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE, DIALOG_STYLE_TABLIST, "EO House - Create", content, "Select", "Cancel");
                }
            }
        }

        case DIALOG_EO_HOUSE_CREATE_INTID :
        {
            if(response)
            {
                new interior = strval(inputtext);
                if(strlen(inputtext) == 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You have to input a value first!") && ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_INTID, DIALOG_STYLE_INPUT, "EO House - Create - Edit Interior ", "Input a valid interior [Refere to \"/eohouse interiors\"]", "Edit", "Back");
                if(!isNumber(inputtext) || (interior >= MAX_INTERIORS || interior < 0)) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You have to input a valid interior [must be a number]!") && ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_INTID, DIALOG_STYLE_INPUT, "EO House - Create - Edit Interior ", "Input a valid interior [Refere to \"/eohouse interiors\"]", "Edit", "Back");

                bInfo[playerid][e_interior] = interior;
            }

            new content[500];

            format(content, sizeof(content), ""COL_GREY"\
            "COL_GREY"Interior ID\t"COL_GREY"%d\n\
            "COL_GREY"Interior\t"COL_GREY"%d\n\
            "COL_GREY"Interior label\t"COL_GREY"%s\n\
            "COL_GREY"Price\t"COL_GREY"%d\n\
            "COL_GREY"Owner\t"COL_GREY"%s\n\
            "COL_GREY"Locked\t"COL_GREY"%s\n"COL_GREY"------------------------------\t"COL_GREY"------------------------------\n\
            Edit interior ID\nEdit price\nEdit owner\n"COL_YELLOW"Create house",
            bInfo[playerid][e_interior],
            intInfo[bInfo[playerid][e_interior]][e_intId],
            intInfo[bInfo[playerid][e_interior]][e_intLabel],
            bInfo[playerid][e_cost],
            (bInfo[playerid][e_ownerid] == -1 ? "None" : GetPlayerNameFromId(bInfo[playerid][e_ownerid])),
            (bInfo[playerid][e_locked] == true ? "True" : "False"));
            ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE, DIALOG_STYLE_TABLIST, "EO House - Create", content, "Select", "Cancel");
        }

        case DIALOG_EO_HOUSE_CREATE_PRICE :
        {
            if(response)
            {
                new price = strval(inputtext);
                if(strlen(inputtext) == 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You have to input a value first!") && ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_PRICE, DIALOG_STYLE_INPUT, "EO House - Create - Edit Price ", "Input a valid price [Must not be lower than $0]", "Edit", "Back");
                if(!isNumber(inputtext) || price < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You have to input a valid price [must be a number and greater than or equal to 0]!") && ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_PRICE, DIALOG_STYLE_INPUT, "EO House - Create - Edit Price ", "Input a valid price [Must not be lower than $0]", "Edit", "Back");

                bInfo[playerid][e_cost] = price;
            }

            new content[500];

            format(content, sizeof(content), ""COL_GREY"\
            "COL_GREY"Interior ID\t"COL_GREY"%d\n\
            "COL_GREY"Interior\t"COL_GREY"%d\n\
            "COL_GREY"Interior label\t"COL_GREY"%s\n\
            "COL_GREY"Price\t"COL_GREY"%d\n\
            "COL_GREY"Owner\t"COL_GREY"%s\n\
            "COL_GREY"Locked\t"COL_GREY"%s\n"COL_GREY"------------------------------\t"COL_GREY"------------------------------\n\
            Edit interior ID\nEdit price\nEdit owner\n"COL_YELLOW"Create house",
            bInfo[playerid][e_interior],
            intInfo[bInfo[playerid][e_interior]][e_intId],
            intInfo[bInfo[playerid][e_interior]][e_intLabel],
            bInfo[playerid][e_cost],
            (bInfo[playerid][e_ownerid] == -1 ? "None" : GetPlayerNameFromId(bInfo[playerid][e_ownerid])),
            (bInfo[playerid][e_locked] == true ? "True" : "False"));
            ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE, DIALOG_STYLE_TABLIST, "EO House - Create", content, "Select", "Cancel");
        }

        case DIALOG_EO_HOUSE_CREATE_OWNER :
        {
            if(response)
            {
                new userid = strval(inputtext);
                if(strlen(inputtext) == 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You have to input a value first!") && ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_OWNER, DIALOG_STYLE_INPUT, "EO House - Create - Edit Owner ", "Input a valid userid [Must be a valid userid (not playerid)]", "Edit", "Back");
                if(!isNumber(inputtext)) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You have to input a valid userid or else the house won't have an owner [must be a number]!") && ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE_OWNER, DIALOG_STYLE_INPUT, "EO House - Create - Edit Owner ", "Input a valid userid [Must be a valid userid (not playerid)]", "Edit", "Back");

                bInfo[playerid][e_ownerid] = userid;
            }

            new content[500];

            format(content, sizeof(content), ""COL_GREY"\
            "COL_GREY"Interior ID\t"COL_GREY"%d\n\
            "COL_GREY"Interior\t"COL_GREY"%d\n\
            "COL_GREY"Interior label\t"COL_GREY"%s\n\
            "COL_GREY"Price\t"COL_GREY"%d\n\
            "COL_GREY"Owner\t"COL_GREY"%s\n\
            "COL_GREY"Locked\t"COL_GREY"%s\n"COL_GREY"------------------------------\t"COL_GREY"------------------------------\n\
            Edit interior ID\nEdit price\nEdit owner\n"COL_YELLOW"Create house",
            bInfo[playerid][e_interior],
            intInfo[bInfo[playerid][e_interior]][e_intId],
            intInfo[bInfo[playerid][e_interior]][e_intLabel],
            bInfo[playerid][e_cost],
            (bInfo[playerid][e_ownerid] == -1 ? "None" : GetPlayerNameFromId(bInfo[playerid][e_ownerid])),
            (bInfo[playerid][e_locked] == true ? "True" : "False"));
            ShowPlayerDialog(playerid, DIALOG_EO_HOUSE_CREATE, DIALOG_STYLE_TABLIST, "EO House - Create", content, "Select", "Cancel");
        }
    }

    return 1;
}

#endif