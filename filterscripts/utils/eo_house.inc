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

                                    > House include

*/

// Constants -----------------------------------
#define MAX_INTERIORS 	17
#define MAX_HOUSES 		500

#define TYPE_EXTERIOR	0
#define TYPE_INTERIOR	1

// Enumerators ---------------------------------
enum E_COORDINATES
{
	Float:e_posX,
	Float:e_posY,
	Float:e_posZ
}

enum E_INTERIOR {
	e_intId,
	e_intLabel[30],
	e_intPos[E_COORDINATES]
}

enum E_HOUSE
{
	e_ownerid,
	e_extPos[E_COORDINATES],
	e_intPos[E_COORDINATES],
	e_extVW,
	e_extInt,
	e_intVW,
	e_intInt,
	e_cost,
	bool:e_locked
}

// Variables -----------------------------------
new
	intInfo[MAX_INTERIORS][E_INTERIOR] = {
		{1, "Denise room", {244.411987, 305.032989, 999.148437} },
		{2, "Katie room", {271.884979, 306.631988, 999.148437} },
		{3, "Helena room", {291.282989, 310.031982, 999.148437} },
		{4, "Michelle room", {302.180999, 300.722991, 999.148437} },
		{5, "Barbara room", {322.197998, 302.497985, 999.148437} },
		{6, "Millie room", {346.870025, 309.259033, 999.155700} },
		{3, "B Dup's house", {1523.509887, -47.821197, 1002.130981} },
		{2, "B Dup's crack pad", {1523.509887, -47.821197, 1002.130981 } },
		{3, "Cj's house", {2496.049804, -1695.238159, 1014.742187} },
		{5, "Madd Doggs mansion", {1267.663208, -781.323242, 1091.906250} },
		{3, "Og Loc's house", {513.882507, -11.269994, 1001.565307} },
		{2, "Ryders house", {2454.717041, -1700.871582, 1013.515197} },
		{1, "Sweet's house", {2527.654052, -1679.388305, 1015.498596} },
		{5, "Gang house", {2350.339843, -1181.649902, 1027.976562} },
		{8, "Colonel Furhberger's", {2807.619873, -1171.899902, 1025.570312} },
		{5, "Crack den", {318.564971, 1118.209960, 1083.882812} },
		{12, "Unused safe house", {2324.419921, -1145.568359, 1050.710083} }
	},
	hInfo[MAX_HOUSES][E_HOUSE];


// Functions -----------------------------------
stock getHouseOwner(houseid)
	return hInfo[houseid][e_ownerid];

stock setHouseOwner(houseid, ownerid)
{
	new oldOwner = hInfo[houseid][e_ownerid];

	hInfo[houseid][e_ownerid] = ownerid;
	return oldOwner;
}

stock getHouseCoordinates(houseid, &Float:posX, &Float:posY, &Float:posZ, type)
{
 	switch(type)
	{
		case TYPE_EXTERIOR :
		{
			posX = hInfo[houseid][e_extX];
			posY = hInfo[houseid][e_extY];
			posZ = hInfo[houseid][e_extZ];
		}

		case TYPE_INTERIOR :
		{
			posX = hInfo[houseid][e_intX];
			posY = hInfo[houseid][e_intY];
			posZ = hInfo[houseid][e_intZ];
		}
	}
}

stock setHouseCoordinates(houseid, &Float:posX, &Float:posY, &Float:posZ, type)
{
	new oldCoordinates[E_COORDINATES];

	switch(type)
	{
		case TYPE_EXTERIOR :
		{
			oldCoordinates = {hInfo[houseid][e_intX], hInfo[houseid][e_intY], hInfo[houseid][e_intZ]};
			hInfo[houseid][e_extPos] = {posX, posY, posZ};
		}

		case TYPE_INTERIOR :
		{
			oldCoordinates = {hInfo[houseid][e_intX], hInfo[houseid][e_intY], hInfo[houseid][e_intZ]};
			hInfo[houseid][e_extPos] = {posX, posY, posZ};
		}
	}

	return oldCoordinates;
}

stock getHouseVirtualWorld(houseid, type)
	return type == TYPE_EXTERIOR ? hInfo[houseid][extVW] : hInfo[houseid][intVW];

stock setHouseVirtualWorld(houseid, virtualWorld, type)
{
	new oldVW;

	switch(type)
	{
		case TYPE_EXTERIOR :
		{
			oldVW = hInfo[houseid][extVW];
			hInfo[houseid][extVW] = virtualWorld;
		}

		case TYPE_INTERIOR :
		{
			oldVW = hInfo[houseid][intVW];
			hInfo[houseid][intVW] = virtualWorld;
		}
	}

	return oldVW;
}

stock getHouseInterior(houseid, type)
	return type == TYPE_EXTERIOR ? hInfo[houseid][extInt] : hInfo[houseid][intInt];

stock setHouseInterior(houseid, virtualWorld, type)
{
	new oldInt;

	switch(type)
	{
		case TYPE_EXTERIOR :
		{
			oldInt = hInfo[houseid][extInt];
			hInfo[houseid][extInt] = virtualWorld;
		}

		case TYPE_INTERIOR :
		{
			oldInt = hInfo[houseid][intInt];
			hInfo[houseid][intInt] = virtualWorld;
		}
	}

	return oldInt;
}

stock getHouseCost(houseid)
	return hInfo[houseid][e_cost];

stock setHouseCost(houseid, cost)
{
	new oldCost = hInfo[houseid][e_cost];

	hInfo[houseid][e_cost] = cost;
	return oldCost;
}

stock isHouseLocked(houseid)
	return hInfo[houseid][e_locked];

stock LockHouse(houseid, bool:_state)
    hInfo[houseid][e_locked] = _state;

stock CreateHouse(MySQL:sqlHandle, houseid, ownerid, Float:extX, Float:extY, Float:extZ, Float:intX, Float:intY, Float:intZ, extVW, extInt, intVW, intInt, cost, bool:locked = true)
{
	new query[300];

	Iter_Add(House, houseid);
	hInfo[houseid][ownerid] = ownerid;
	hInfo[houseid][e_extPos] = {extX, extY, extZ};
	hInfo[houseid][e_intPos] = {intX, intY, intZ};
	hInfo[houseid][e_extVW] = extVW;
	hInfo[houseid][e_intVW] = intVW;
	hInfo[houseid][e_extInt] = extInt;
	hInfo[houseid][e_intInt] = intInt;
	hInfo[houseid][e_cost] = cost;
	hInfo[houseid][e_locked] = locked;

	mysql_format(sqlHandle, query, "INSERT INTO `Houses` VALUES(%d, %d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %d, %d, %d);", houseid, ownerid, extX, extY, extZ, intX, intY, intZ, extVW, extInt, intVW, intInt, cost, locked);
	mysql_query(sqlHandle, query);
}

stock DestroyHouse(MySQL:sqlHandle, houseid)
{
	new query[100], oldHouseId = houseid;

	Iter_Remove(houseid);
	mysql_format(sqlHandle, query, "DELETE FROM `Houses` WHERE `houseid` = %d;", houseid);
	mysql_query(sqlHandle, query);

	return oldHouseId;
}

stock EditHouse(MySQL:sqlHandle, houseid, ownerid, Float:extX, Float:extY, Float:extZ, Float:intX, Float:intY, Float:intZ, extVW, extInt, intVW, intInt, cost, bool:locked = true)
{
	new query[300];

	hInfo[houseid][ownerid] = ownerid;
	hInfo[houseid][e_extPos] = {extX, extY, extZ};
	hInfo[houseid][e_intPos] = {intX, intY, intZ};
	hInfo[houseid][e_extVW] = extVW;
	hInfo[houseid][e_intVW] = intVW;
	hInfo[houseid][e_extInt] = extInt;
	hInfo[houseid][e_intInt] = intInt;
	hInfo[houseid][e_cost] = cost;
	hInfo[houseid][e_locked] = locked;

	mysql_format(sqlHandle, query, "UPDATE `Houses` SET `ownerid` = %d, `extX` = %f, `extY` = %f, `extZ` = %f, `intX` = %f, `intY` = %f, `intZ` = %f, `extVW` = %d, `extInt` = %d, `intVW` = %d, `intInt` = %d, `cost` = %d, `locked` = %d WHERE `houseid` = %d;", ownerid, extX, extY, extZ, intX, intY, intZ, extVW, extInt, intVW, intInt, cost, locked, houseid);
	mysql_query(sqlHandle, query);
}

stock DestroyAllHouses(MySQL:sqlHandle)
{
	new query[100];

	Iter_Clear(House);

	mysql_format(sqlHandle, query, "DELETE FROM `Houses` WHERE `houseid` = %d;", houseid);
	mysql_query(sqlHandle, query);
}