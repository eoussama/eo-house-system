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
#define MAX_INTERIORS 	28
#define MAX_HOUSES 		500

#define PICKUP_FOR_SALE	1273
#define PICKUP_SOLD		1272
#define PICKUP_OWNED	1318
#define PICKUP_CLOSED	19522

#define ICON_FOR_SALE	31
#define ICON_SOLD		32

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
	Float:e_intPos[E_COORDINATES]
}

enum E_HOUSE
{
	e_ownerid,
	Float:e_extPos[E_COORDINATES],
	Float:e_intPos[E_COORDINATES],
	e_extVW,
	e_extInt,
	e_intVW,
	e_intInt,
	e_cost,
	bool:e_locked
}

// Variables -----------------------------------
new
	const intInfo[MAX_INTERIORS][E_INTERIOR] = {
		{1, "Denise room", {244.411987, 305.032989, 999.148437} },
		{2, "Katie room", {266.7248, 305.0676, 999.1484} },
		{3, "Helena room", {292.8466, 310.1198, 999.1484} },
		{4, "Michelle room", {302.180999, 300.722991, 999.148437} },
		{6, "Millie room", {343.8689, 304.8184, 999.1484} },
		{3, "B Dup's house", {1531.2728, -6.8206, 1002.0971} },
		{2, "B Dup's crack pad", {1520.4670, -48.1052, 1002.1310} },
		{3, "Cj's house", {2495.9702, -1692.3313, 1014.7422} },
		{5, "Madd Doggs mansion", {1260.6549, -785.7318, 1091.9063} },
		{3, "Og Loc's house", {516.9117, -14.9512, 1001.5653} },
		{2, "Ryders house", {2468.8284, -1698.1252, 1013.5078} },
		{1, "Sweet's house", {2524.1548, -1679.2579, 1015.4986} },
		{5, "Gang house", {2352.6592, -1181.0431, 1027.9766} },
		{8, "Colonel Furhberger's", {2807.7183, -1174.7272, 1025.5703} },
		{5, "Crack den", {318.5060, 1114.6956, 1083.8828} },
		{12, "Unused safe house", {2324.5520, -1149.5435, 1050.7101} },
		{3, "Burglary house 1", {235.3611, 1186.6804, 1080.2578} },
		{2, "Burglary house 2", {226.7767, 1239.9183, 1082.1406} },
		{1, "Burglary house 3", {222.9783, 1287.0762, 1082.1406} },
		{7, "Burglary house 4", {225.5619, 1021.6281, 1084.0172} },
		{15, "Burglary house 5", {295.3352, 1472.2603, 1080.2578} },
		{15, "Burglary house 6", {327.9531, 1477.7252, 1084.4375} },
		{15, "Burglary house 7", {387.1272, 1471.7672, 1080.1875} },
		{1, "Woozies Apartment", {-2159.0950, 643.1011, 1052.3750} },
		{9, "Golden bed motel room", {2255.4873, -1139.9259, 1050.6328} },
		{10, "Hashbury House", {2270.3167, -1210.4602, 1047.5625} },
		{10, "Red Bed Motel Room", {2259.4170, -1135.7371, 1050.6403} },
		{8, "Verdant Bluffs Safehouse", {2365.4050, -1135.5947, 1050.8826} }
	};

new
	hInfo[MAX_HOUSES][E_HOUSE],
	Iterator:House<MAX_PLAYERS>;


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

stock setHouseCoordinates(houseid, Float:posX, Float:posY, Float:posZ, type)
{
	new oldCoordinates[E_COORDINATES];

	switch(type)
	{
		case TYPE_EXTERIOR :
		{
			oldCoordinates[e_posX] = hInfo[houseid][e_extPos][e_posX];
			oldCoordinates[e_posY] = hInfo[houseid][e_extPos][e_posY];
			oldCoordinates[e_posZ] = hInfo[houseid][e_extPos][e_posZ];
			
			hInfo[houseid][e_extPos][e_posX] = posX;
			hInfo[houseid][e_extPos][e_posY] = posY;
			hInfo[houseid][e_extPos][e_posZ] = posZ;
		}

		case TYPE_INTERIOR :
		{
			oldCoordinates[e_posX] = hInfo[houseid][e_intPos][e_posX];
			oldCoordinates[e_posY] = hInfo[houseid][e_intPos][e_posY];
			oldCoordinates[e_posZ] = hInfo[houseid][e_intPos][e_posZ];
			
			hInfo[houseid][e_intPos][e_posX] = posX;
			hInfo[houseid][e_intPos][e_posY] = posY;
			hInfo[houseid][e_intPos][e_posZ] = posZ;
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
			oldVW = hInfo[houseid][e_extVW];
			hInfo[houseid][e_extVW] = virtualWorld;
		}

		case TYPE_INTERIOR :
		{
			oldVW = hInfo[houseid][e_intVW];
			hInfo[houseid][e_intVW] = virtualWorld;
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
			oldInt = hInfo[houseid][e_extInt];
			hInfo[houseid][e_extInt] = virtualWorld;
		}

		case TYPE_INTERIOR :
		{
			oldInt = hInfo[houseid][e_intInt];
			hInfo[houseid][e_intInt] = virtualWorld;
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

stock CreateHouse(houseid, ownerid, Float:extX, Float:extY, Float:extZ, Float:intX, Float:intY, Float:intZ, extVW, extInt, intVW, intInt, cost, bool:locked = true)
{
	Iter_Add(House, houseid);
	setHouseOwner(houseid, ownerid);
	setHouseCost(houseid, cost);
	setHouseCoordinates(houseid, extX, extY, extZ, TYPE_EXTERIOR);
	setHouseCoordinates(houseid, intX, intY, intZ, TYPE_INTERIOR);
	setHouseInterior(houseid, extInt, TYPE_EXTERIOR);
	setHouseInterior(houseid, intInt, TYPE_INTERIOR);
	setHouseVirtualWorld(houseid, extVW, TYPE_EXTERIOR);
	setHouseVirtualWorld(houseid, intVW, TYPE_INTERIOR);
	LockHouse(houseid, locked);

	new label[200], costString[50];

	format(costString, sizeof(costString), "{FFFF00}$%d", cost);
	format(label, sizeof(label), "%s{FFFFFF}\nPress 'N' to interact", ownerid == -1 ? costString : "");
	CreateDynamicPickup(ownerid == -1 ? PICKUP_FOR_SALE : PICKUP_OWNED, 1, extX, extY, extZ, extVW, extInt, -1, STREAMER_PICKUP_SD);
	CreateDynamic3DTextLabel(label, -1, extX, extY, extZ, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, extVW, extInt, -1, STREAMER_3D_TEXT_LABEL_SD);
	CreateDynamicMapIcon(extX, extY, extZ, ownerid == -1 ? ICON_FOR_SALE : ICON_SOLD, 0xFFFFFF, extVW, extInt, -1, STREAMER_MAP_ICON_SD, MAPICON_LOCAL_CHECKPOINT);
	/*mysql_format(sqlHandle, query, sizeof(query), "INSERT INTO `Houses` VALUES(%d, %d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %d, %d, %d);", houseid, ownerid, extX, extY, extZ, intX, intY, intZ, extVW, extInt, intVW, intInt, cost, locked);
	mysql_query(sqlHandle, query);*/
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