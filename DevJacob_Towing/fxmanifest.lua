fx_version "cerulean"
lua54 "yes"
game "gta5"

author "DevJacob"
description "A realistic towing script for FiveM"
version "0.1.0"

shared_scripts {
	"shared/config.lua",
}

client_scripts {
	"client/utils.lua",
	"client/classes/towTruck.lua",
	"client/classes/scoopBased.lua",
	"client/classes/propBased.lua",
	"client/main.lua",
}