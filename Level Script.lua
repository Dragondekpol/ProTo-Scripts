-- ## Level Script by ProTo, do not share it outside of proshine-bot.com!
name = "ProTo's Script"
author = "ProTo"
description = [[
-------------------------------------
HINT: This script was made while high. Try to check every possibility, if something is missing message me on Discord.
WARNING: Using rebuy might end you up in jail. Since the Pathfinder walks through some serverside check`s!
Usage: Press on 'Show Settings', then configurate the script.
Options: Place to level/farm - Desired place like 'Route 8' without ''!
Options: Desired Pokemon - Name of the Pokemon your hunting like 'Abra' without ''!
Options: Grass/Water/Custom - The level location where you want to level/farm.
Options: Level Bot - Kill every pokemon encountered besides shinies and desired.
Options: Catch uncaught - Complete Pokedex by catching missing entrys.
Options: Max Level - Max Level?
Options: Ball to catch/buy - The ball to use, like: 'Pokeball' without ''!
HINT: The bot uses other balls if you dont have desired one's.
Options: Max $$$ - The ammount of Pokedollas you want to stop the bot at.
]]
-- ##

-- ## Settings
local PathFinder = require "Pathfinder/MoveToApp"
local map = nil

CatchUncaught = 0
MaxX=49
MaxY=63
MinX=30
MinY=62
wildencounters = 0
catchonlycounter = 0
wantedcatch = 0
shinycounter = 0
shinycatch = 0
levelupcounter = 0
missedshinies = 0
maxlevel = 100
-- ## End Settings

-- ## GUI Settings
tab = {"Catch Uncaught", "Catch desired Pokemon", "Level Bot", "Rebuy"}
for i = 1, 4 do
	setOptionName(i, tab[i] .. "")
	setTextOptionName(1, "Place to level/farm ")
	setTextOption(1, getMapName())
	setTextOptionName(2, "Desired Pokemon")
	setTextOption(2, "")
	setTextOptionName(3, "Grass/Water/Custom")
	setTextOption(3, "Grass")
	setTextOptionName(4, "Max Level")
	setTextOption(4, maxlevel)
	setTextOptionName(5, "Ball to catch/buy")
	setTextOption(5, "Pokeball")
	setTextOptionName(6, "x? rebuy")
	setTextOption(6, "5")
	setTextOptionName(7, "Max $$$")
	setTextOption(7, "500000")
end
-- ## End GUI Settings

-- ## Functions
function onStart()
	log(" ")
	log("Starting Script for Location: " .. getTextOption(1))
	log("Desired Pokemon: " .. getTextOption(2))
	log("Wanted Location: " .. getTextOption(3))
	log("1st Pokemon Level: " .. tonumber(getPokemonLevel(1)))
end

function onPause()
	log("ProToScript | Paused")
end

function onResume()
	log("ProToScript | Resumed")
end

function onPathAction()
	map = getMapName()
	if tonumber(getTextOption(4)) == tonumber(getPokemonLevel(1)) or tonumber(getTextOption(4)) < tonumber(getPokemonLevel(1)) then
		log("Reached level: " .. getTextOption(4))
		fatal()
	elseif (getMoney() == tonumber(getTextOption(7))) or (getMoney() > tonumber(getTextOption(7))) then
		log("Reached $$$: " .. getMoney() .. "P$")
		fatal()
	elseif isPokemonUsable(1) and getItemQuantity(getTextOption(5)) > 5 then
		if getMapName() == getTextOption(1) then
			if getTextOption(3) == "Water" then
				moveToWater()
			elseif getTextOption(3) == "Custom" then
				moveToRectangle(MinX, MinY, MaxX, MaxY)
			else
				moveToGrass()
			end
		else
			PathFinder.moveTo(map, getTextOption(1))
		end
	elseif not isPokemonUsable(1) then
		log(" - -  Need Pokecenter  - -")
		PathFinder.useNearestPokecenter(map)
	elseif (getItemQuantity(getTextOption(5)) < 5 and getMoney() > 1000) and (getOption(6) == true) then  --## IDK how2 PokeMart
		log(" - -  Need Pokemart  - -")
		if getMapName() == "Route 22" then
			log("You dont wan`t to go to jail or? Use rebuy later! Buy Balls yourself then start the bot!")
			fatal()
		else
			PathFinder.useNearestPokemart(map, getTextOption(5), tonumber(getTextOption(6)))
		end
	elseif (getOption(2) == false) then
		if isPokemonUsable(1) and getMapName() == getTextOption(1) then
			if getTextOption(3) == "Water" then
				moveToWater()
			elseif getTextOption(3) == "Custom" then
				moveToRectangle(MinX, MinY, MaxX, MaxY)
			else
				moveToGrass()
			end
		else
			PathFinder.moveTo(map, getTextOption(1))
		end
	end
end

function onBattleAction()
	-- Removed old shit
	return checkOperation()
end

function onBattleMessage(wild)
	if stringContains(wild, "A Wild SHINY ") then
		shinycounter = shinycounter + 1
		wildencounters = wildencounters + 1
	elseif stringContains(wild, "A Wild ") then
		wildencounters = wildencounters + 1
	elseif stringContains(wild, "You have won the battle.") then
		log("- -  Statistic  - -")
		log("Pokemons encountered: " .. wildencounters)
		log("Shinies encountered: " .. shinycounter)
		log("Catched desired poke: " .. wantedcatch)
		log("Completed Level's: ".. levelupcounter)
		log("Missed Shinies: " .. missedshinies)
		log("- -  - -  - -  - -  - -")
	elseif stringContains(wild, "Success! You caught") and not isOpponentShiny() then
		wantedcatch = wantedcatch + 1
		log("Catched desired Pokemon! Nr. " .. wantedcatch)
	elseif stringContains(wild, "Success! You caught") and isOpponentShiny() then
		shinycatch = shinycatch + 1
		log("Catched shinies: " .. shinycatch)
	end
	if stringContains(wild, "has grown to") then
		levelupcounter = levelupcounter + 1
	end
end

function catchFunction()
	if isPokemonUsable(1) and getItemQuantity(getTextOption(5)) > 0 then
		useItem(getTextOption(5))
	elseif isPokemonUsable(1) and getItemQuantity("Pokeball") > 0 then
		useItem("Pokeball")
	elseif isPokemonUsable(1) and getItemQuantity("Great Ball") > 0 then
		useItem("Great Ball")
	elseif isPokemonUsable(1) and getItemQuantity("Ultra Ball") > 0 then
		useItem("Ultra Ball")
	end
end

function checkOperation() -- New Catch Function made while stoned second try
	if (getOption(1) == true and isAlreadyCaught() == false) and not isOpponentShiny() then -- Catch Uncaught
		if isPokemonUsable(1) and (getItemQuantity(getTextOption(5)) > 0 or getItemQuantity("Great Ball") > 0 or getItemQuantity("Ultra Ball") > 0 or getItemQuantity("Pokeball") > 0) then
			return catchFunction()
		else
			return run()
		end
	elseif (getOption(2) == true and getOpponentName() == getTextOption(2)) and not isOpponentShiny() then -- Catch desired
		if isPokemonUsable(1) and (getItemQuantity(getTextOption(5)) > 0 or getItemQuantity("Great Ball") > 0 or getItemQuantity("Ultra Ball") > 0 or getItemQuantity("Pokeball") > 0) then
			return catchFunction()
		else
			return run()
		end
	elseif getOption(3) == true and not isOpponentShiny() then -- Level Bot
		if getOption(1) == true and isAlreadyCaught() == true then
			return attack() or run() or sendUsablePokemon() or sendAnyPokemon()
		elseif getOption(1) == true and isAlreadyCaught() == false then
			return catchFunction()
		else
			return attack() or run() or sendUsablePokemon() or sendAnyPokemon()
		end
	elseif isOpponentShiny() then -- Shiny encounter
		if isPokemonUsable(1) and (getItemQuantity(getTextOption(5)) > 0 or getItemQuantity("Great Ball") > 0 or getItemQuantity("Ultra Ball") > 0 or getItemQuantity("Pokeball") > 0) then
			return catchFunction()
		else
			missedshinies = missedshinies + 1
			return run()
		end
	else -- Nothing
		return run()
	end
end
-- ## End Functions