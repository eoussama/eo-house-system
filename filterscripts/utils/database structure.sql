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

                                    > Database structure
*/

CREATE DATABASE `eo_house_system`;
USE `eo_house_system`;

-- Users table
CREATE TABLE `Users`(
    `userid` INT(8) NOT NULL AUTO_INCREMENT,
    `username` NVARCHAR(25) NOT NULL,

    CONSTRAINT pk_uid PRIMARY KEY(`userid`)
);

-- Houses table
CREATE TABLE `Houses`(
    `houseid` INT(8) NOT NULL,
    `ownerid` INT(8) NOT NULL,
    `intInt` INT(8) NOT NULL,
	`extPosX` FLOAT NOT NULL,
    `extPosY` FLOAT NOT NULL,
    `extPosZ` FLOAT NOT NULL,
	`extVW` INT(10) NOT NULL DEFAULT 0,
	`extInt` INT(8) NOT NULL,
	`cost` INT(10) NOT NULL,
	`locked` TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT pk_hid PRIMARY KEY(`houseid`),
    CONSTRAINT fk_uid FOREIGN KEY(`ownerid`) REFERENCES `Users`(`userid`)
);