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

#include "utils/eo_house.inc"

// Constants ----------------------------------------------
#define MYSQL_HOST      "localhost"
#define MYSQL_USER      "root"
#define MYSQL_PASSWORD  ""
#define MYSQL_DATABASE  "eo_house_system"

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
}

public OnFilterScriptExit()
{
    print("Filterscript terminated!");
    mysql_close(handle);
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
        print(query);
        mysql_query(handle, query, false);

        SendClientMessage(playerid, -1, "Welcome to our server, thanks for registering!");
    }

    else 
    {
        cache_get_value_name_int(0, "userid", pInfo[playerid]);
        printf("Your userid is %d", pInfo[playerid]);
        SendClientMessage(playerid, -1, "Welcome back to our server, thanks for loging-in!");
    }
}

#endif