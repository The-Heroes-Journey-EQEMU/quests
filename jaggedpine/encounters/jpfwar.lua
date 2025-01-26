-- Jaggedpine Forest War Encounter

local	gnoll_table			= {};
local	jardor				= nil;
local	gnoll				= 0;
local 	gnollcount			= 0;
local	villagedeathcount	= 0;
local	setup_npc			= 181192;
local	Sergeant_Caelin		= 181328;
local	Sergeant_Trade		= 181348;
local	Jardor_Darkpaw		= 181349;
local	barduck				= 181070;
local	gnoll_id			= 181316;
local	assassin_id			= 181347;

local	static_village_npcs	= {181175,181205,181166,181103,181085,181086,181173,181195,181206,181090,181160,181180,181182,181203,181210,181165,181179,181099,181183,181163,181161}

-- (Faction 1474)
local VILLAGE_WAR_SPAWN = {
	SHAYNA		= 181319, -- NPC: ##Shayna_Thunderhand
	KAITHYS		= 181320, -- NPC: ##Kaithys_Galestrider
	ANNOUS		= 181321, -- NPC: ##Annous_Pineshadow
	DEIRA		= 181323, -- NPC: ##Lady_Deira
	NOLAN		= 181324, -- NPC: ##Nolan_Greenwood
	CHEYLOH		= 181325, -- NPC: ##Cheyloh_Greenwood
	FINEWINE	= 181326, -- NPC: ##Guard_Finewine
	BOSSAMIR	= 181327, -- NPC: ##Guard_Bossamir
	JEREMY		= 181329, -- NPC: ##Jeremy_Leafrunner
	DERICK		= 181331, -- NPC: ##Derick_Goodroot
	CATHLEEN	= 181333, -- NPC: ##Cathleen_Goodroot
	SELIA		= 181334, -- NPC: ##Selia_Wetstone
	MORGAN		= 181335, -- NPC: ##Morgan_Wetstone
	TALLIEN		= 181336, -- NPC: ##Tallien_Brightflash
	NERDALA		= 181338, -- NPC: ##Nerdala_Darkcloud
	PERGAN		= 181340, -- NPC: ##Pergan_Darkcloud
	BANKER		= 181341, -- NPC: ##Banker_Mardalson
	RALLEFORD	= 181342, -- NPC: ##Ralleford_Twothorns
	DONNA		= 181345, -- NPC: ##Donna_Twothorns
	DIEDRA		= 181346, -- NPC: ##Diedra_Twothorns
};

function BarducksDeath(e)
	eq.signal(setup_npc,1);
end

function ResetSpawn(e)
	gnollcount = 0;
	villagedeathcount = 0;

	for i = 0, 44 do
		gnoll_table["gnoll"..i] = nil;
	end

	for i = 1, 4 do
		gnoll_table["assassin"..i] = nil;
	end
end

function WarSignal(e)
	if e.signal == 1 then
		eq.set_timer("timertostart", 5 * 60 * 1000);
	elseif e.signal == 2 then
		eq.stop_timer("gnollspawn");
		eq.set_timer("WarEnd",10 * 60 * 1000);
	elseif e.signal == 3 then
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(181341) then -- NPC: ##Banker_Mardalson
			eq.get_entity_list():GetMobByNpcTypeID(181341):Say("Another one down, someone help! Quickly!");
		elseif eq.get_entity_list():IsMobSpawnedByNpcTypeID(181326) then -- NPC: ##Guard_Finewine
			eq.get_entity_list():GetMobByNpcTypeID(181326):Say("I'm next, I just know it!");
		end

		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(Sergeant_Caelin) then -- NPC: ##Sergeant_Caelin
			eq.get_entity_list():GetMobByNpcTypeID(Sergeant_Caelin):Say("The gnolls have broken through! Regroup and try harder or we're doomed!");
		end
	elseif e.signal == 4 then
		eq.spawn2(Sergeant_Caelin,0,0,1988,1084,-11,196); -- NPC: ##Sergeant_Caelin
		gnoll = 0;
		villagedeathcount = 0;
		eq.set_timer("gnollspawn",3 * 1000);
	end
end

function WarTimer(e)
	if e.timer == "timertostart" then
		eq.stop_timer("timertostart");
		eq.zone_emote(MT.White,"The sound of war drums echo through the forest and a rough inhuman voice calls out a war cry. 'Brothers, now is the time of our revenge! Destroy the human settlement and claim it as our own! For Barducks and clan Darkpaw!'");
		eq.set_timer("gnollspawn",3 * 1000);
	elseif e.timer == "WarEnd" then
		eq.stop_timer("WarEnd");
		gnollcount = 0;
		villagedeathcount = 0;
		eq.depop_all(gnoll_id); -- NPC: #a_gnoll
		eq.depop_all(assassin_id); -- NPC: a_gnoll_assassin
		for _, id in ipairs(VILLAGE_WAR_SPAWN) do
			eq.depop(id);
		end
	elseif e.timer == "gnollspawn" then
		gnollcount = gnollcount + 1;
		gnoll = gnoll_id;
		if gnollcount == 1 then
			VillageWarSpawn(e);
			StaticVillageDepop(e);
		elseif gnollcount == 2 then
			gnoll_table["gnoll0"] = GnollSpawnLocation(spn);
		elseif gnollcount == 3 then
			gnoll_table["gnoll1"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll0"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll0"]:GetID()) then
				gnoll_table["gnoll0"]:CastToNPC():MoveTo(1878,1086,-10,0,true);
			end
		elseif gnollcount == 4 then
			gnoll_table["gnoll2"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll1"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll1"]:GetID()) then
				gnoll_table["gnoll1"]:CastToNPC():MoveTo(1840,1078,-10,0,true);
			end
		elseif gnollcount == 5 then
			gnoll_table["gnoll3"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll2"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll2"]:GetID()) then
				gnoll_table["gnoll2"]:CastToNPC():MoveTo(1892,1053,-10,0,true);
			end
		elseif gnollcount == 6 then
			gnoll_table["gnoll4"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll3"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll3"]:GetID()) then
				gnoll_table["gnoll3"]:CastToNPC():MoveTo(2059,1055,-11,0,true);
			end
		elseif gnollcount == 7 then
			gnoll_table["gnoll5"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll4"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll4"]:GetID()) then
				gnoll_table["gnoll4"]:CastToNPC():MoveTo(2096,1072,-11,0,true);
			end
		elseif gnollcount == 8 then
			gnoll_table["gnoll6"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll5"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll5"]:GetID()) then
				gnoll_table["gnoll5"]:CastToNPC():MoveTo(2096,1079,-11,0,true);
			end
		elseif gnollcount == 9 then
			gnoll_table["gnoll7"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll6"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll6"]:GetID()) then
				gnoll_table["gnoll6"]:CastToNPC():MoveTo(2013,1090,-11,0,true);
			end
		elseif gnollcount == 10 then
			gnoll_table["gnoll8"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll7"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll7"]:GetID()) then
				gnoll_table["gnoll7"]:CastToNPC():MoveTo(2016,1108,-11,0,true);
			end
		elseif gnollcount == 11 then
			gnoll_table["gnoll9"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll8"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll8"]:GetID()) then
				gnoll_table["gnoll8"]:CastToNPC():MoveTo(2049,1123,-11,0,true);
			end
		elseif gnollcount == 12 then
			gnoll_table["gnoll10"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll9"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll9"]:GetID()) then
				gnoll_table["gnoll9"]:CastToNPC():MoveTo(1919,1259,-11,0,true);
			end
		elseif gnollcount == 13 then
			gnoll_table["gnoll11"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll10"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll10"]:GetID()) then
				gnoll_table["gnoll10"]:CastToNPC():MoveTo(1953,1329,-11,0,true);
			end
		elseif gnollcount == 14 then
			gnoll_table["gnoll12"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll11"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll11"]:GetID()) then
				gnoll_table["gnoll11"]:CastToNPC():MoveTo(2048,1211,-12,0,true);
			end
		elseif gnollcount == 15 then
			gnoll_table["gnoll13"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll12"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll12"]:GetID()) then
				gnoll_table["gnoll12"]:CastToNPC():MoveTo(1981,957,-12,0,true);
			end
		elseif gnollcount == 16 then
			gnoll_table["gnoll14"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll13"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll13"]:GetID()) then
				gnoll_table["gnoll13"]:CastToNPC():MoveTo(1994,1084,-11,0,true);
			end
		elseif gnollcount == 17 then
			if gnoll_table["gnoll14"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll14"]:GetID()) then
				gnoll_table["gnoll14"]:CastToNPC():MoveTo(1994,1084,-11,0,true);
			end
			eq.set_timer("gnollspawn",245000);
		elseif gnollcount == 18 then
			gnoll_table["gnoll15"] = GnollSpawnLocation(spn);
		elseif gnollcount == 19 then
			gnoll_table["gnoll16"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll15"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll15"]:GetID()) then
				gnoll_table["gnoll15"]:CastToNPC():MoveTo(1878,1086,-10,0,true);
			end
		elseif gnollcount == 20 then
			gnoll_table["gnoll17"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll16"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll16"]:GetID()) then
				gnoll_table["gnoll16"]:CastToNPC():MoveTo(1840,1078,-10,0,true);
			end
		elseif gnollcount == 21 then
			gnoll_table["gnoll18"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll17"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll17"]:GetID()) then
				gnoll_table["gnoll17"]:CastToNPC():MoveTo(1892,1053,-10,0,true);
			end
		elseif gnollcount == 22 then
			gnoll_table["gnoll19"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll18"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll18"]:GetID()) then
				gnoll_table["gnoll18"]:CastToNPC():MoveTo(2059,1055,-11,0,true);
			end
		elseif gnollcount == 23 then
			gnoll_table["gnoll20"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll19"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll19"]:GetID()) then
				gnoll_table["gnoll19"]:CastToNPC():MoveTo(2096,1072,-11,0,true);
			end
		elseif gnollcount == 24 then
			gnoll_table["gnoll21"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll20"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll20"]:GetID()) then
				gnoll_table["gnoll20"]:CastToNPC():MoveTo(2096,1079,-11,0,true);
			end
		elseif gnollcount == 25 then
			gnoll_table["gnoll22"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll21"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll21"]:GetID()) then
				gnoll_table["gnoll21"]:CastToNPC():MoveTo(2013,1090,-11,0,true);
			end
		elseif gnollcount == 26 then
			gnoll_table["gnoll23"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll22"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll22"]:GetID()) then
				gnoll_table["gnoll22"]:CastToNPC():MoveTo(2016,1108,-11,0,true);
			end
		elseif gnollcount == 27 then
			gnoll_table["gnoll24"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll23"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll23"]:GetID()) then
				gnoll_table["gnoll23"]:CastToNPC():MoveTo(2049,1123,-11,0,true);
			end
		elseif gnollcount == 28 then
			gnoll_table["gnoll25"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll24"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll24"]:GetID()) then
				gnoll_table["gnoll24"]:CastToNPC():MoveTo(1919,1259,-11,0,true);
			end
		elseif gnollcount == 29 then
			gnoll_table["gnoll26"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll25"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll25"]:GetID()) then
				gnoll_table["gnoll25"]:CastToNPC():MoveTo(1953,1329,-11,0,true);
			end
		elseif gnollcount == 30 then
			gnoll_table["gnoll27"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll26"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll26"]:GetID()) then
				gnoll_table["gnoll26"]:CastToNPC():MoveTo(2048,1211,-12,0,true);
			end
		elseif gnollcount == 31 then
			gnoll_table["gnoll28"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll27"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll27"]:GetID()) then
				gnoll_table["gnoll27"]:CastToNPC():MoveTo(1981,957,-12,0,true);
			end
		elseif gnollcount == 32 then
			gnoll_table["gnoll29"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll28"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll28"]:GetID()) then
				gnoll_table["gnoll28"]:CastToNPC():MoveTo(1994,1084,-11,0,true);
			end
		elseif gnollcount == 33 then
			if gnoll_table["gnoll29"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll29"]:GetID()) then
				gnoll_table["gnoll29"]:CastToNPC():MoveTo(1994,1084,-11,0,true);
			end
			eq.set_timer("gnollspawn",245000);
		elseif gnollcount == 34 then
			gnoll_table["gnoll30"] = GnollSpawnLocation(spn);
		elseif gnollcount == 35 then
			gnoll_table["gnoll31"]		= GnollSpawnLocation(spn);
			gnoll_table["assassin1"]	=	eq.spawn2(assassin_id,0,0,2027,1140,-12,0); -- NPC: a_gnoll_assassin
			if gnoll_table["gnoll30"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll30"]:GetID()) then
				gnoll_table["gnoll30"]:CastToNPC():MoveTo(1878,1086,-10,0,true);
			end
		elseif gnollcount == 36 then
			gnoll_table["gnoll32"]		= GnollSpawnLocation(spn);
			gnoll_table["assassin2"]	= eq.spawn2(assassin_id,0,0,1852,1269,-12,0); -- NPC: a_gnoll_assassin
			if gnoll_table["gnoll31"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll31"]:GetID()) then
				gnoll_table["gnoll31"]:CastToNPC():MoveTo(1840,1078,-10,0,true);
			end

			if gnoll_table["assassin1"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["assassin1"]:GetID()) then
				gnoll_table["assassin1"]:CastToNPC():MoveTo(2013,1090,-11,0,true);
			end
		elseif gnollcount == 37 then
			gnoll_table["gnoll33"]		= GnollSpawnLocation(spn);
			gnoll_table["assassin3"]	= eq.spawn2(assassin_id,0,0,1794,1042,-12,0); -- NPC: a_gnoll_assassin
			if gnoll_table["gnoll32"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll32"]:GetID()) then
				gnoll_table["gnoll32"]:CastToNPC():MoveTo(1892,1053,-10,0,true);
			end

			if gnoll_table["assassin2"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["assassin2"]:GetID()) then
				gnoll_table["assassin2"]:CastToNPC():MoveTo(1953,1329,-11,0,true);
			end
		elseif gnollcount == 38 then
			gnoll_table["gnoll34"]		= GnollSpawnLocation(spn);
			gnoll_table["assassin4"]	=	eq.spawn2(assassin_id,0,0,2031,1148,-12,0); -- NPC: a_gnoll_assassin
			if gnoll_table["gnoll33"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll33"]:GetID()) then
				gnoll_table["gnoll33"]:CastToNPC():MoveTo(2059,1055,-11,0,true);
			end

			if gnoll_table["assassin3"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["assassin3"]:GetID()) then
				gnoll_table["assassin3"]:CastToNPC():MoveTo(1892,-829,-10,0,true);
			end
		elseif gnollcount == 39 then
			gnoll_table["gnoll35"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll34"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll34"]:GetID()) then
				gnoll_table["gnoll34"]:CastToNPC():MoveTo(2096,1072,-11,0,true);
			end

			if gnoll_table["assassin4"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["assassin4"]:GetID()) then
				gnoll_table["assassin4"]:CastToNPC():MoveTo(2096,1072,-11,0,true);
			end
		elseif gnollcount == 40 then
			gnoll_table["gnoll36"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll35"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll35"]:GetID()) then
				gnoll_table["gnoll35"]:CastToNPC():MoveTo(2096,1079,-11,0,true);
			end
		elseif gnollcount == 41 then
			gnoll_table["gnoll37"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll36"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll36"]:GetID()) then
				gnoll_table["gnoll36"]:CastToNPC():MoveTo(2013,1090,-11,0,true);
			end
		elseif gnollcount == 42 then
			gnoll_table["gnoll38"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll37"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll37"]:GetID()) then
				gnoll_table["gnoll37"]:CastToNPC():MoveTo(2016,1108,-11,0,true);
			end
		elseif gnollcount == 43 then
			gnoll_table["gnoll39"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll38"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll38"]:GetID()) then
				gnoll_table["gnoll38"]:CastToNPC():MoveTo(2049,1123,-11,0,true);
			end
		elseif gnollcount == 44 then
			gnoll_table["gnoll40"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll39"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll39"]:GetID()) then
				gnoll_table["gnoll39"]:CastToNPC():MoveTo(1919,1259,-11,0,true);
			end
		elseif gnollcount == 45 then
			gnoll_table["gnoll41"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll40"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll40"]:GetID()) then
				gnoll_table["gnoll40"]:CastToNPC():MoveTo(1953,1329,-11,0,true);
			end
		elseif gnollcount == 46 then
			gnoll_table["gnoll42"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll41"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll41"]:GetID()) then
				gnoll_table["gnoll41"]:CastToNPC():MoveTo(2048,1211,-12,0,true);
			end
		elseif gnollcount == 47 then
			gnoll_table["gnoll43"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll42"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll42"]:GetID()) then
				gnoll_table["gnoll42"]:CastToNPC():MoveTo(1981,957,-12,0,true);
			end
		elseif gnollcount == 48 then
			gnoll_table["gnoll44"] = GnollSpawnLocation(spn);
			if gnoll_table["gnoll43"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll43"]:GetID()) then
				gnoll_table["gnoll43"]:CastToNPC():MoveTo(1994,1084,-11,0,true);
			end
		elseif gnollcount == 49 then
			if gnoll_table["gnoll44"] ~= nil and eq.get_entity_list():IsMobSpawnedByEntityID(gnoll_table["gnoll44"]:GetID()) then
				gnoll_table["gnoll44"]:CastToNPC():MoveTo(1994,1084,-11,0,true);
			end
			eq.set_timer("gnollspawn",245000);
		elseif gnollcount == 50 then
			if eq.get_entity_list():IsMobSpawnedByNpcTypeID(Sergeant_Caelin) and villagedeathcount == 0 then -- NPC: ##Sergeant_Caelin
				gnoll = Jardor_Darkpaw;
				eq.stop_timer("gnollspawn");
				eq.zone_emote(MT.White,"an inhuman voice screams from the distance, 'You may have defeated some of my brothers but clan Darkpaw is far from broken!  Prepare yourselves, for you shall soon know my wrath!'");
				jardor = GnollSpawnLocation(spn);
				eq.depop(Sergeant_Caelin); -- NPC: ##Sergeant_Caelin
				jardor:CastToNPC():AssignWaypoints(342);
			end
		elseif gnollcount == 51 then
			eq.stop_timer("gnollspawn");
			eq.set_timer("FinalWarEnd", 15 * 60 * 1000);
			if eq.get_entity_list():IsMobSpawnedByNpcTypeID(Sergeant_Caelin) then -- NPC: ##Sergeant_Caelin
				if villagedeathcount >= 5 then
					eq.get_entity_list():GetMobByNpcTypeID(Sergeant_Caelin):Shout("It appears the gnolls have been routed but at what a cost? Many of the innocents I have sworn to protect have perished this day. Karana forgive my dreadful failure. If you can show me that you assisted in defense of the fort, you shall be compensated.");
				elseif villagedeathcount > 0 then
					eq.get_entity_list():GetMobByNpcTypeID(Sergeant_Caelin):Shout("It appears the gnolls have been routed. Alas some of the residents of Fort Jaggedpine have perished. Those who can present proof they have helped in defending the fort this day shall be rewarded.");
				elseif villagedeathcount == 0 then
					eq.get_entity_list():GetMobByNpcTypeID(Sergeant_Caelin):Shout("It appears the gnolls have been routed with nary a casualty to report! My thanks to everyone, all that can prove they have assisted with this spectacular victory shall be richly rewarded!");
				end
				eq.depop_all(gnoll_id); -- NPC: #a_gnoll
				eq.depop_all(assassin_id); -- NPC: a_gnoll_assassin
				eq.unique_spawn(Sergeant_Trade,0,0,1988,1084,-11,196); -- NPC: Sergeant_Caelin 
				eq.depop(Sergeant_Caelin);
			end
		end
	elseif e.timer == "FinalWarEnd" then
		eq.stop_timer("FinalWarEnd");
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(Sergeant_Trade) then -- NPC: Sergeant_Caelin 
			eq.get_entity_list():GetMobByNpcTypeID(Sergeant_Trade):Say("What a day. I'm going to rest now. Thank you everyone.");
		end
		gnollcount = 0;
		villagedeathcount = 0;
		eq.depop(Sergeant_Trade); -- NPC: Sergeant_Caelin 
		for _, id in ipairs(VILLAGE_WAR_SPAWN) do
			eq.depop(id);
		end
	end
end

function GnollSpawn(e)
	e.self:SetRunning(true);
end

function SergeantDeath(e)
	eq.signal(setup_npc,2);
end

function SergeantSay(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetCleanName() .. ". If you're not good with a weapon, fast with a spell or strong at heart I suggest you run with all haste away from this place. If you are however, we could really use some help to protect these people and I may be able to compensate you for your efforts. That is... If we survive the battle of course.");
	end
end

function DeathCount(e)
	villagedeathcount = villagedeathcount + 1;
	eq.signal(setup_npc,3);
end

function SergeantTrade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 8368}) then -- Item: Runed Gnollish Tome
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8389,8392),5000); -- Items: Cloth Cord of Mourning or Blue Colored Fluid
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8384,8389),10000); -- Items: Bracelet of the Defender or Cloth Cord of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8384,8376),15000); -- Items: Bracelet of the Defender or Orb of the Defender
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8369}) then -- Item: Gnoll Warriors Crest
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8390,8393),5000); -- Items: Belt of Mourning or Good Berries
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8385,8390),10000); -- Items: Bracer of the Defender or Belt of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8385,8377),15000); -- Items: Bracer of the Defender or Long Sword of the Defender
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8370}) then -- Item: Book of Gnollish Hymns
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9187,8394),5000); -- Items: Belt of Mourning, Feline Elixir
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9174,9187),10000); -- Items: Bracer of the Defender, Belt of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,9174,15000); -- Item: Bracer of the Defender -- Missing Mace of the Defender
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8371}) then -- Item: Gnoll Pitfighter Gloves
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8391,8395),5000); -- Items: Sash of Mourning, Griffon Wing
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8386,8391),10000); -- Items: Wrist Wraps of the Defender, Sash of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8386,8391),15000); -- Items: Wrist Wraps of the Defender, Sash of Mourning
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8372}) then -- Item: Gnollish Holy Symbol
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9189,8396),5000); -- Items: Sash of Mourning, Elixir of Promise
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8388,9189),10000); -- Items: Wristband of the Defender, Sash of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8388,8380),15000); -- Items: Wristband of the Defender, Helm of the Defender
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8373}) then -- Item: Stolen Seeds
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9190,8397),5000); -- Items: Sash of Mourning, Essence of Rose
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8387,9190),10000); -- Items: Wrist Guards of the Defender, Sash of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(8387,8381),15000); -- Items: Wrist Guards of the Defender, Circlet of the Defender
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8374}) then -- Item: Gnoll Oracle Medicine Bag
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9191,8398),5000); -- Items: Sash of Mourning, Herb of Recovery
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,9191,10000); -- Item: Sash of Mourning -- Missing 9186 Wristband of the Defender
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,8382,15000); -- Item: Wreath of the Defender -- Missing 9186 Wristband of the Defender
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 8375}) then -- Item: Gnoll Dousing Rod
		if villagedeathcount >= 5 then
			ThirdTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9188,8399),5000); -- Items: Belt of Mourning, Fiery Red Fluid
		elseif villagedeathcount > 0 then
			SecondTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9185,9188),10000); -- Items: Bracer of the Defender, Belt of Mourning
		elseif villagedeathcount == 0 then
			FirstTier(e);
			e.other:QuestReward(e.self,0,0,0,0,eq.ChooseRandom(9185,8383),15000); -- Items: Bracer of the Defender, Coif of the Defender
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function JardorSpawn(e)
	e.self:SetRunning(true);
end

function JardorWaypoint(e)
	if e.wp == 2 then
		eq.signal(setup_npc,4);
	end
end

function JardorDeath(e)
	eq.signal(setup_npc,4);
end

function JardorCombat(e)
	if e.joined then
		if not eq.is_paused_timer("depop") then
			eq.pause_timer("depop");
		end
	else
		eq.resume_timer("depop");
	end
end

function ThirdTier(e)
	e.self:Say("You are brave and a valiant one, " .. e.other:GetCleanName() .. ". Alas, the people whom I have been sworn to protect have been mostly wiped out. Take this as a token of my gratitude for your assistance today.");
	e.other:Faction(1597,10);	-- Faction: Residents of Jaggedpine
	e.other:Faction(272,5);		-- Faction: Jaggedpine Treefolk
	e.other:Faction(302,5);		-- Faction: Protectors of Pine
	e.other:Faction(262,1);		-- Faction: Guards of Qeynos
end

function SecondTier(e)
	e.self:Say("Thank you for your help. Without you, things may have been much worse. Loss of life is a tragic thing indeed. Wear this in remembrance of this day.");
	e.other:Faction(1597,25);	-- Faction: Residents of Jaggedpine
	e.other:Faction(272,12);	-- Faction: Jaggedpine Treefolk
	e.other:Faction(302,12);	-- Faction: Protectors of Pine
	e.other:Faction(262,2);		-- Faction: Guards of Qeynos
end

function FirstTier(e)
	e.self:Say("That was excellent work on your part! Take this as your reward, we all owe you our lives!");
	e.other:Faction(1597,50);	-- Faction: Residents of Jaggedpine
	e.other:Faction(272,25);	-- Faction: Jaggedpine Treefolk
	e.other:Faction(302,25);	-- Faction: Protectors of Pine
	e.other:Faction(262,5);		-- Faction: Guards of Qeynos
end

function VillageWarSpawn(e)
	eq.spawn2(VILLAGE_WAR_SPAWN.SHAYNA,0,0,2083,1120,-11,104);		-- NPC: ##Shayna_Thunderhand
	eq.spawn2(VILLAGE_WAR_SPAWN.KAITHYS,0,0,1895,1007,-11,127);		-- NPC: ##Kaithys_Galestrider
	eq.spawn2(VILLAGE_WAR_SPAWN.ANNOUS,0,0,2074,1206,-12,208);		-- NPC: ##Annous_Pineshadow
	eq.spawn2(VILLAGE_WAR_SPAWN.DEIRA,0,0,1970,1233,-11,126);		-- NPC: ##Lady_Deira	
	eq.spawn2(VILLAGE_WAR_SPAWN.NOLAN,0,0,1820,1064,-10,64);		-- NPC: ##Nolan_Greenwood
	eq.spawn2(VILLAGE_WAR_SPAWN.CHEYLOH,0,0,1967,1267,-11,126);		-- NPC: ##Cheyloh_Greenwood
	eq.spawn2(VILLAGE_WAR_SPAWN.FINEWINE,0,0,1931,1225,-11,131);	-- NPC: ##Guard_Finewine
	eq.spawn2(VILLAGE_WAR_SPAWN.BOSSAMIR,0,0,1856,1000,-10,130);	-- NPC: ##Guard_Bossamir
	eq.spawn2(VILLAGE_WAR_SPAWN.JEREMY,0,0,1981,957,-13,227);		-- NPC: ##Jeremy_Leafrunner
	eq.spawn2(VILLAGE_WAR_SPAWN.DERICK,0,0,1953,1329,-11,132);		-- NPC: ##Derick_Goodroot
	eq.spawn2(VILLAGE_WAR_SPAWN.CATHLEEN,0,0,1919,1259,-11,3);		-- NPC: ##Cathleen_Goodroot
	eq.spawn2(VILLAGE_WAR_SPAWN.SELIA,0,0,2049,1115,-11,137);		-- NPC: ##Selia_Wetstone
	eq.spawn2(VILLAGE_WAR_SPAWN.MORGAN,0,0,2020,1108,-11,72);		-- NPC: ##Morgan_Wetstone
	eq.spawn2(VILLAGE_WAR_SPAWN.TALLIEN,0,0,2020,1090,-11,72);		-- NPC: ##Tallien_Brightflash
	eq.spawn2(VILLAGE_WAR_SPAWN.NERDALA,0,0,2088,1079,-11,197);		-- NPC: ##Nerdala_Darkcloud
	eq.spawn2(VILLAGE_WAR_SPAWN.PERGAN,0,0,2088,1072,-11,197);		-- NPC: ##Pergan_Darkcloud
	eq.spawn2(VILLAGE_WAR_SPAWN.BANKER,0,0,2059,1055,-11,6);		-- NPC: ##Banker_Mardalson
	eq.spawn2(VILLAGE_WAR_SPAWN.RALLEFORD,0,0,1892,1053,-10,194);	-- NPC: ##Ralleford_Twothorns
	eq.spawn2(VILLAGE_WAR_SPAWN.DONNA,0,0,1840,1078,-10,10);		-- NPC: ##Donna_Twothorns
	eq.spawn2(VILLAGE_WAR_SPAWN.DIEDRA,0,0,1878,1086,-10,137);		-- NPC: ##Diedra_Twothorns
	eq.spawn2(Sergeant_Caelin,0,0,1988,1084,-11,196);				-- NPC: ##Sergeant_Caelin
end

function StaticVillageDepop(e)
	for i = 1, #static_village_npcs do
		eq.depop_with_timer(static_village_npcs[i]);
	end
end

function GnollSpawnLocation(spn)
	local gnollspawn = math.random(80);

	if gnollspawn < 2 then
		spn = eq.spawn2(gnoll,0,0,732,1382,-29,0);
	elseif gnollspawn < 4 then
		spn = eq.spawn2(gnoll,0,0,354,-951,-28,0);
	elseif gnollspawn < 6 then
		spn = eq.spawn2(gnoll,0,0,913,688,-19,0);
	elseif gnollspawn < 8 then
		spn = eq.spawn2(gnoll,0,0,1562,1481,11,0);
	elseif gnollspawn < 10 then
		spn = eq.spawn2(gnoll,0,0,255,-823,-12,0);
	elseif gnollspawn < 12 then
		spn = eq.spawn2(gnoll,0,0,434,998,-19,0);
	elseif gnollspawn < 14 then
		spn = eq.spawn2(gnoll,0,0,419,1288,-13,0);
	elseif gnollspawn < 16 then
		spn = eq.spawn2(gnoll,0,0,1171,-1292,14,0);
	elseif gnollspawn < 18 then
		spn = eq.spawn2(gnoll,0,0,260,436,-22,0);
	elseif gnollspawn < 20 then
		spn = eq.spawn2(gnoll,0,0,435,-1772,-12,0);
	elseif gnollspawn < 22 then
		spn = eq.spawn2(gnoll,0,0,467,1841,-20,0);
	elseif gnollspawn < 24 then
		spn = eq.spawn2(gnoll,0,0,1028,-1872,25,0);
	elseif gnollspawn < 26 then
		spn = eq.spawn2(gnoll,0,0,684,950,-30,0);
	elseif gnollspawn < 28 then
		spn = eq.spawn2(gnoll,0,0,643,347,-21,0);
	elseif gnollspawn < 30 then
		spn = eq.spawn2(gnoll,0,0,1302,-1641,-13,0);
	elseif gnollspawn < 32 then
		spn = eq.spawn2(gnoll,0,0,348,557,-18,0);
	elseif gnollspawn < 34 then
		spn = eq.spawn2(gnoll,0,0,772,220,-15,0);
	elseif gnollspawn < 36 then
		spn = eq.spawn2(gnoll,0,0,594,-391,29,0);
	elseif gnollspawn < 38 then
		spn = eq.spawn2(gnoll,0,0,1277,-117,-19,0);
	elseif gnollspawn < 40 then
		spn = eq.spawn2(gnoll,0,0,475,294,-18,0);
	elseif gnollspawn < 42 then
		spn = eq.spawn2(gnoll,0,0,209,1522,-28,0);
	elseif gnollspawn < 44 then
		spn = eq.spawn2(gnoll,0,0,1285,-1646,-13,0);
	elseif gnollspawn < 46 then
		spn = eq.spawn2(gnoll,0,0,768,1113,-13,0);
	elseif gnollspawn < 48 then
		spn = eq.spawn2(gnoll,0,0,219,-796,-9,0);
	elseif gnollspawn < 50 then
		spn = eq.spawn2(gnoll,0,0,297,1660,-15,0);
	elseif gnollspawn < 52 then
		spn = eq.spawn2(gnoll,0,0,630,-1867,40,0);
	elseif gnollspawn < 54 then
		spn = eq.spawn2(gnoll,0,0,217,1541,-28,0);
	elseif gnollspawn < 56 then
		spn = eq.spawn2(gnoll,0,0,1044,1595,-12,0);
	elseif gnollspawn < 58 then
		spn = eq.spawn2(gnoll,0,0,984,-1004,80,0);
	elseif gnollspawn < 60 then
		spn = eq.spawn2(gnoll,0,0,1652,1732,4,0);
	elseif gnollspawn < 62 then
		spn = eq.spawn2(gnoll,0,0,398,445,-14,0);
	elseif gnollspawn < 64 then
		spn = eq.spawn2(gnoll,0,0,915,977,8,0);
	elseif gnollspawn < 66 then
		spn = eq.spawn2(gnoll,0,0,883,1150,-5,0);
	elseif gnollspawn < 68 then
		spn = eq.spawn2(gnoll,0,0,295,-71,-9,0);
	elseif gnollspawn < 70 then
		spn = eq.spawn2(gnoll,0,0,430,684,-26,0);
	elseif gnollspawn < 72 then
		spn = eq.spawn2(gnoll,0,0,1697,-1335,7,0);
	elseif gnollspawn < 74 then
		spn = eq.spawn2(gnoll,0,0,723,-898,-24,0);
	elseif gnollspawn < 76 then
		spn = eq.spawn2(gnoll,0,0,678,-1725,21,0);
	elseif gnollspawn < 78 then
		spn = eq.spawn2(gnoll,0,0,822,-1741,68,0);
	elseif gnollspawn <= 80 then
		spn = eq.spawn2(gnoll,0,0,153,620,-13,0);
	end

	return spn;
end

function event_encounter_load(e)
	eq.register_npc_event(Event.death,				barduck,			BarducksDeath);
	eq.register_npc_event(Event.spawn,				setup_npc,			ResetSpawn);
	eq.register_npc_event(Event.signal,				setup_npc,			WarSignal);
	eq.register_npc_event(Event.timer,				setup_npc,			WarTimer);
	eq.register_npc_event(Event.spawn,				gnoll_id,			GnollSpawn);
	eq.register_npc_event(Event.death,				Sergeant_Caelin,	SergeantDeath);
	eq.register_npc_event(Event.say,				Sergeant_Caelin,	SergeantSay);
	eq.register_npc_event(Event.trade,				Sergeant_Trade,		SergeantTrade);
	eq.register_npc_event(Event.spawn,				Jardor_Darkpaw,		JardorSpawn);
	eq.register_npc_event(Event.waypoint_arrive,	Jardor_Darkpaw,		JardorWaypoint);
	eq.register_npc_event(Event.death,				Jardor_Darkpaw,		JardorDeath);
	eq.register_npc_event(Event.combat,				Jardor_Darkpaw,		JardorCombat);

	for _, id in ipairs(VILLAGE_WAR_SPAWN) do
		eq.register_npc_event(Event.death, id, DeathCount);
	end
end