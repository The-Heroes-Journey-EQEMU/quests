--- PoM 2.0 Bristlebane

-- Variables
local bristlebane_id		= 126373;
local mischievous_jester_id	= 126012;
local event_adds			= {126375,126376,126377,126378};
local next_hp_event			= 90;
local event_stat_stages		= {
	-- [Percent]			= {AC, Min Attack, Max Attack, Attack Delay, mr, cr, fr, pr, dr, "Emote"}
	[10]					= {1587	,572	,1560	,18	,144	,144	,144	,144	,144	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a string of mystical words and suddenly his skin takes on a rock like apppearance and his muscles bulge with incomprehensible strength."},
	[20]					= {1087	,572	,1560	,18	,500	,500	,500	,500	,500	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a string of mystical words and is suddenly surrounded by a magical glowing aura and his muscles bulge with incomprehensible strength."},
	[30]					= {1087	,528	,1440	,14	,500	,500	,500	,500	,500	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a string of mystical words and is suddenly surrounded by a magical glowing aura and his attacks become a blur as he launches into a quickened attack routine."},
	[40]					= {1587	,528	,1440	,18	,500	,500	,500	,500	,500	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a string of mystical words and is suddenly surrounded by a magical glowing aura and his skin takes on a rock like appearance."},
	[50]					= {1087	,572	,1560	,18	,144	,144	,144	,144	,144	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a mystical word of power and suddenly his muscles bulge with incomprehensible strength."},
	[60]					= {1087	,528	,1440	,18	,500	,500	,500	,500	,500	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a mystical word of power and is suddenly surrrounded by a magical glowing aura."},
	[70]					= {1087	,572	,1440	,18	,200	,200	,200	,200	,200	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a mystical word of power and suddenly his muscles bulge with incomprehensible strength."},
	[80]					= {1087	,544	,1523	,18	,500	,500	,500	,500	,500	,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a mystical word of power and is suddenly surrrounded by a magical glowing aura."},
	[90]					= {1587	,544	,1523	,18	,144	,96		,96		,96		,96		,"Bristlebane the King of Thieves shakes with laughter and says, 'You are much stronger than I thought. Looks like I'm gonna have to use all the tricks of the trade!' He then shouts a mystical word of power and suddenly his skin begins to take on a rock like appearance."},
	[100]					= {548	,544	,1523	,18	,144	,96		,96		,96		,96		,"You dare try to trick me!"} -- Base Stats
};

-- Scaling Variables
local enable_scaling = true;
local counter_max = 10;         -- How many kills to reach maximum effect
local counter_min = -10;
local max_hit_adjust = -200;    -- Maximum amount max attack can be lowered
local min_hit_adjust = 381;
local max_hit_adjust2 = -200;   -- Maximum amount min attack can be lowered
local min_hit_adjust2 = 132;
local max_delay_adjust = 10;    -- Maximum amount delay can be increased
local min_delay_adjust = -6;
local max_resist_adjust = -200; -- Maximum amount resists can be lowered
local min_resist_adjust = 0;
local upsidedown_mobs = {126067,126075,126076,126066,126073,126074,126069,126070,126071,126065,126072,126077,126068,126372};
local alice_mobs = {126023,126052,126046,126048,126050,126047,126049,126051,126040,126042,126043,126037,126039,126041,126038,126044,126045,126309,126307,126308};
local chess_mobs = {126053,126054,126055,126056,126057,126058,126059,126159,126167,126264};
local bw_mobs = {126060,126061,126062,126063,126064};
local theater_mobs = {126029,126100,126101,126102,126103,126104,126105,126106,126107,126108,126109,126110,126111,126112,126113,126114,126115,126116,126117,126118,126119,126120,126121,126122,126123,126124,126125,126126,126304,126305};
local hardmode_mobs = {126312}; -- white stallion in northwest corner of entry forest

-- Event
function evt_bristlebane_spawn(e)
	next_hp_event = 90;
	set_phase(e, 100);
	eq.set_next_hp_event(next_hp_event);
	eq.set_timer("despawn", 2 * 60 * 60 * 1000); -- 2 Hours
end

function evt_bristlebane_combat(e)
	if e.joined then
		eq.stop_timer("reset_event");
		eq.pause_timer("despawn");
		eq.set_timer("aggrolink", 3 * 1000);
	else
		eq.set_timer("reset_event", 60 * 1000); -- 1 Minute Reset
		eq.resume_timer("despawn");
		eq.stop_timer("aggrolink");
	end
end

function evt_bristlebane_hp(e)
	if e.hp_event == next_hp_event and next_hp_event > 0 then
		set_phase(e,next_hp_event);
		next_hp_event = next_hp_event - 10;
		eq.set_next_hp_event(next_hp_event);

		local scale_adds = false;
		if enable_scaling then
			local add_counter = increment_get_scale_data("adds", 0);
			if add_counter > 0 and counter_max > 0 and add_counter / counter_max > 0.5 then
				scale_adds = true;
			end
		end

		if e.hp_event == 80 then
			eq.spawn2(126375,0,0,-88,886,178,384):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_devious_guardian_jokester
			if not scale_adds then
				eq.spawn2(126376,0,0,-157,886,178,128):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_tricky_guardian_jester 
			end
		elseif e.hp_event == 50 then
			eq.spawn2(126375,0,0,-88,886,178,384):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_devious_guardian_jokester
			eq.spawn2(126378,0,0,-157,886,178,128):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_charming_guardian_jester
			if not scale_adds then
				eq.spawn2(126377,0,0,-127,840,178,0):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_dazed_guardian_jester
			end
		elseif e.hp_event == 20 then
			eq.spawn2(126377,0,0,-88,886,178,384):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_dazed_guardian_jester
			eq.spawn2(126378,0,0,-157,886,178,128):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_charming_guardian_jester
			eq.spawn2(126377,0,0,-146,840,178,0):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_dazed_guardian_jester
			if not scale_adds then
				eq.spawn2(126377,0,0,-110,840,178,0):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_dazed_guardian_jester
				eq.spawn2(126375,0,0,-127,840,178,0):AddToHateList(e.self:GetHateRandom(),1);	-- NPC: a_devious_guardian_jokester
			end
		end
	end
end

function evt_bristlebane_timer(e)
	if e.timer == "despawn" then
		depop_all_event_mobs(e);
		eq.depop();
	elseif e.timer == "reset_event" then
		reset_event(e);
	elseif e.timer == "aggrolink" then
		local npc_list =  eq.get_entity_list():GetNPCList();
		for npc in npc_list.entries do
			if npc.valid and not npc:IsEngaged() and (npc:GetNPCTypeID() == 126375 or npc:GetNPCTypeID() == 126376 or npc:GetNPCTypeID() == 126377 or npc:GetNPCTypeID() == 126378) then
				npc:AddToHateList(e.self:GetHateRandom(),1);
			end
		end
	end
end

function reset_event(e)
	depop_all_event_mobs(e);
	e.self:WipeHateList();
	e.self:GotoBind();
	e.self:BuffFadeAll();
	e.self:SetHP(e.self:GetMaxHP());

	set_phase(e,100);
	next_hp_event = 90;
	eq.set_next_hp_event(next_hp_event);
end

function set_phase(e, hp_event)
	local hit_counter, delay_counter, resist_counter = 0, 0, 0;
	if enable_scaling then
		hit_counter = increment_get_scale_data("hit", 0);
		delay_counter = increment_get_scale_data("delay", 0);
		resist_counter = increment_get_scale_data("resist", 0);
	end

	e.self:ModifyNPCStat("ac",				tostring(event_stat_stages[hp_event][1]));
	e.self:ModifyNPCStat("min_hit",			tostring(scale_value(event_stat_stages[hp_event][2], hit_counter, max_hit_adjust2, min_hit_adjust2)));
	e.self:ModifyNPCStat("max_hit",			tostring(scale_value(event_stat_stages[hp_event][3], hit_counter, max_hit_adjust, min_hit_adjust)));
	e.self:ModifyNPCStat("attack_delay",	tostring(scale_value(event_stat_stages[hp_event][4], delay_counter, max_delay_adjust, min_delay_adjust)));
	e.self:ModifyNPCStat("mr",				tostring(scale_value(event_stat_stages[hp_event][5], resist_counter, max_resist_adjust, min_resist_adjust)));
	e.self:ModifyNPCStat("cr",				tostring(scale_value(event_stat_stages[hp_event][6], resist_counter, max_resist_adjust, min_resist_adjust)));
	e.self:ModifyNPCStat("fr",				tostring(scale_value(event_stat_stages[hp_event][7], resist_counter, max_resist_adjust, min_resist_adjust)));
	e.self:ModifyNPCStat("pr",				tostring(scale_value(event_stat_stages[hp_event][8], resist_counter, max_resist_adjust, min_resist_adjust)));
	e.self:ModifyNPCStat("dr",				tostring(scale_value(event_stat_stages[hp_event][9], resist_counter, max_resist_adjust, min_resist_adjust)));

	eq.local_emote({e.self:GetX(), e.self:GetY(), e.self:GetZ()},MT.LightBlue,500,event_stat_stages[hp_event][10]);
end

function depop_all_event_mobs(e)
	for i = 1, #event_adds do
		eq.depop_all(event_adds[i]);
	end
end

function evt_bristlebane_death(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id);
    if killer and math.random(1, 100) == 1 then
        killer:CastToClient():SetBucket('flag-semaphore', '204');
        killer:Signal(100);
    end
end

function evt_add_spawn(e)
	eq.set_timer("depop", 2 * 60 * 60 * 1000);
end

function evt_add_combat(e)
	if e.joined then
        if not eq.is_paused_timer("depop") then
            eq.pause_timer("depop");
        end
    else
        eq.resume_timer("depop");
    end
end

function evt_add_timer(e)
	if e.timer == "depop" then
        eq.depop();
    end
end

function evt_jester_death(e)
	eq.unique_spawn(bristlebane_id,0,0,-127,938,186.125,264);	--NPC: Bristlebane_the_King_of_Thieves
	eq.zone_emote(MT.Yellow, "Merry laughter echoes throughout the castle and a cheerful voice is heard saying, 'Come on then if you seek the King of Thieves you must choose wisely! Hurry up lads and lasses!")
end

function get_bucket_key(suffix)
	return string.format("%d_bb_scale_%s", eq.get_expedition():GetInstanceID(), suffix);
end

function increment_get_scale_data(suffix, amount)
	local key = get_bucket_key(suffix);

	local data_str = eq.get_data(key);
	if data_str == nil then
		data_str = "0";
	end

	local data = tonumber(data_str);
	if data == nil then
		data = 0;
	end

	if amount == 0 then
		return data;
	end

	data = data + amount;

	eq.set_data(key, tostring(data), "14h");

	--eq.debug(string.format("%s - %d", suffix, data));

	return data;
end

function scale_resist()
	local val = increment_get_scale_data("resist", 1);
	if val == 1 then
		eq.zone_emote(MT.Yellow, "The walls of the palace rumble as the minions of mischief dwindle.")
	end
end

function scale_hit()
	local val = increment_get_scale_data("hit", 1);
	if val == 1 then
		eq.zone_emote(MT.Yellow, "The air thickens as the minions of mischief dwindle.")
	end
end

function scale_delay()
	local val = increment_get_scale_data("delay", 1);
	if val == 1 then
		eq.zone_emote(MT.Yellow, "Time seems to move faster as the minions of mischief dwindle.")
	end
end

function scale_adds()
	local val = increment_get_scale_data("adds", 1);
	if val == 1 then
		eq.zone_emote(MT.Yellow, "Order descends upon the castle as the minions of mischief dwindle.")
	end
end

function scale_hardmode()
	increment_get_scale_data("hit", counter_min);
	increment_get_scale_data("delay", counter_min);
	increment_get_scale_data("resist", counter_min);
	eq.zone_emote(MT.Yellow, "A booming voice echos from the depths of the castle, 'Some lines must never be crossed in the pursuit of mischief!'")
	--Don't need to adjust adds since they remain unchanged between versions
end

function scale_all()
	increment_get_scale_data("adds", 1);
	increment_get_scale_data("hit", 1);
	increment_get_scale_data("delay", 1);
	increment_get_scale_data("resist", 1);
end

function scale_value(initial, counter, max_effect, min_effect)
	if counter == 0 then
		return initial;
	end

	if counter > counter_max then
		counter = counter_max;
	end

	if counter < counter_min then
		counter = counter_min;
	end

	local effect_to_use = max_effect;
	local max_counters = counter_max;
	if counter < 0 then
		effect_to_use = min_effect;
		max_counters = counter_min;
	end

	if max_counters == 0 then
		return initial;
	end

	local percent = counter / max_counters;
	local adjust_amount = math.ceil(percent * effect_to_use);

	local retVal = initial + adjust_amount;
	if retVal < 0 then
		return 0;
	end

	return retVal;
end

function event_encounter_load(e)
	eq.register_npc_event(Event.spawn,			bristlebane_id, evt_bristlebane_spawn);
	eq.register_npc_event(Event.combat,			bristlebane_id, evt_bristlebane_combat);
	eq.register_npc_event(Event.hp,				bristlebane_id, evt_bristlebane_hp);
	eq.register_npc_event(Event.timer,			bristlebane_id, evt_bristlebane_timer);
	eq.register_npc_event(Event.death_complete,	bristlebane_id, evt_bristlebane_death);

	for i = 1, #event_adds do
		eq.register_npc_event(Event.spawn,			event_adds[i], evt_add_spawn);
		eq.register_npc_event(Event.combat,			event_adds[i], evt_add_combat);
		eq.register_npc_event(Event.timer,			event_adds[i], evt_add_timer);
	end

	eq.register_npc_event(Event.death_complete,	mischievous_jester_id, evt_jester_death);

	if not enable_scaling then
		return
	end

	local expedition = eq.get_expedition()
	if not expedition.valid or expedition:GetName() ~= "The Plane of Mischief (Non-Respawning)" then
		return
	end

	eq.set_data(get_bucket_key("resist"), "0", "14h");
	eq.set_data(get_bucket_key("delay"), "0", "14h");
	eq.set_data(get_bucket_key("hit"), "0", "14h");
	eq.set_data(get_bucket_key("adds"), "0", "14h");

	for i = 1, #bw_mobs do
		eq.register_npc_event(Event.death_complete, bw_mobs[i], scale_adds);
	end

	for i = 1, #chess_mobs do
		eq.register_npc_event(Event.death_complete, chess_mobs[i], scale_hit);
	end

	for i = 1, #upsidedown_mobs do
		eq.register_npc_event(Event.death_complete, upsidedown_mobs[i], scale_delay);
	end

	for i = 1, #alice_mobs do
		eq.register_npc_event(Event.death_complete, alice_mobs[i], scale_resist);
	end

	for i = 1, #hardmode_mobs do
		eq.register_npc_event(Event.death_complete, hardmode_mobs[i], scale_hardmode);
	end

	--For simple testing
	--for i = 1, #theater_mobs do
	--	eq.register_npc_event(Event.death_complete, theater_mobs[i], scale_all);
	--end
	
	--run_tests();
end

function run_tests()
	local orig_max = counter_max;
	local orig_min = counter_min;

	counter_max = 10;
	counter_min = -10;

	-- Basic scale test
	local test_result = scale_value(1560, 10, -200, 200);
	if test_result ~= 1360 then
		eq.debug(string.format("Test 1 failed: %d != 1360", test_result));
	else
		eq.debug("Test 1 passed");
	end

	-- Testing what happens if we go over the counter limit
	test_result = scale_value(1560, 20, -200, 200);
	if test_result ~= 1360 then
		eq.debug(string.format("Test 2 failed: %d != 1360", test_result));
	else
		eq.debug("Test 2 passed");
	end

	-- Testing negative effects
	test_result = scale_value(1560, -10, -200, 200);
	if test_result ~= 1760 then
		eq.debug(string.format("Test 3 failed: %d != 1760", test_result));
	else
		eq.debug("Test 3 passed");
	end

	-- Testing counter limit on negative values
	test_result = scale_value(1560, -20, -200, 200);
	if test_result ~= 1760 then
		eq.debug(string.format("Test 4 failed: %d != 1760", test_result));
	else
		eq.debug("Test 4 passed");
	end

	-- Testing when counter hasn't been incremented
	test_result = scale_value(1560, 0, -200, 200);
	if test_result ~= 1560 then
		eq.debug(string.format("Test 5 failed: %d != 1560", test_resuilt));
	else
		eq.debug("Test 5 passed");
	end

	-- Making sure no effect is applied when limit is set to 0
	test_result = scale_value(1560, 10, 0, 200);
	if test_result ~= 1560 then
		eq.debug(string.format("Test 6 failed: %d != 1560", test_resuilt));
	else
		eq.debug("Test 6 passed");
	end

	test_result = scale_value(1560, -10, -200, 0);
	if test_result ~= 1560 then
		eq.debug(string.format("Test 7 failed: %d != 1560", test_resuilt));
	else
		eq.debug("Test 7 passed");
	end

	-- Making sure we cant scale into a negative number
	test_result = scale_value(100, 10, -200, 200);
	if test_result ~= 0 then
		eq.debug(string.format("Test 8 failed: %d != 0", test_result));
	else
		eq.debug("Test 8 passed");
	end

	-- Testing divide-by-zero protections
	counter_max = 0;
	test_result = scale_value(1560, 10, -200, 200);
	if test_result ~= 1560 then
		eq.debug(string.format("Test 9 failed: %d != 1560", test_resuilt));
	else
		eq.debug("Test 9 passed");
	end

	counter_min = 0;
	test_result = scale_value(1560, -10, -200, 200);
	if test_result ~= 1560 then
		eq.debug(string.format("Test 10 failed: %d != 1560", test_resuilt));
	else
		eq.debug("Test 10 passed");
	end

	counter_max = 10;
	counter_min = -10;

	-- Following tests are verifying the adjust globals are configured properly
	test_result = scale_value(1560, 10, max_hit_adjust, min_hit_adjust);
	if test_result > 1560 then
		eq.debug("Test 11 failed.  Expected result to be lower than original amount");
	else
		eq.debug("Test 11 passed");
	end

	test_result = scale_value(1560, -10, max_hit_adjust, min_hit_adjust);
	if test_result < 1560 then
		eq.debug("Test 12 failed.  Expected result to be greater than original amount");
	else
		eq.debug("Test 12 passed");
	end

	test_result = scale_value(18, 10, max_delay_adjust, min_delay_adjust);
	if test_result < 18 then
		eq.debug("Test 13 failed.  Expected result to be greater than original amount");
	else
		eq.debug("Test 13 passed");
	end

	test_result = scale_value(18, -10, max_delay_adjust, min_delay_adjust);
	if test_result > 18 then
		eq.debug("Test 14 failed.  Expected result to be lower than original amount");
	else
		eq.debug("Test 14 passed");
	end

	test_result = scale_value(500, 10, max_resist_adjust, min_resist_adjust);
	if test_result > 500 then
		eq.debug("Test 15 failed.  Expected result to be lower than original amount");
	else
		eq.debug("Test 15 passed");
	end

	test_result = scale_value(500, -10, max_resist_adjust, min_resist_adjust);
	if test_result < 500 then
		eq.debug(string.format("Test 16 failed.  Expected result to be greater than original amount: %d", test_result));
	else
		eq.debug("Test 16 passed");
	end

	counter_max = orig_max;
	counter_min = orig_min;
end
