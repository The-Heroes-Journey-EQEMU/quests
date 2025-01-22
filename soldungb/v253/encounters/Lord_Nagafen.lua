local nagafen_id = 32040;
local controller_id = 201078; --No idea what a good controller would be.  Definitely not the echo though.
local respawn_millis = 30000;
local base_stats = {
	["hp"] = 32000,
	["ac"] = 230,
	["min_hit"] = 85,
	["max_hit"] = 300,
	["delay"] = 30,
	["mr"] = 340,
	["cr"] = 70,
	["fr"] = 425,
	["dr"] = 340,
	["pr"] = 340,
};

function get_bucket_key(suffix)
	return string.format("%d_nagafen_event_%s", eq.get_expedition():GetInstanceID(), suffix);
end

function get_progress()
	local key = get_bucket_key("inprogress");
	local data_str = eq.get_data(key);
	if data_str == nil then
		data_str = "0";
	end

	local counter = tonumber(data_str);
	if counter == nil then
		counter = 0;
	end

	return counter;
end

function evt_controller_spawn(e)
	e.self:Say("A valiant effort hero!");
end

function evt_controller_say(e)
	if e.message:findi("hail") then
		local counter = eq.get_data(get_bucket_key("finished"));
		if counter == "0" or counter == "1" then
			e.self:Say("It was a noble attempt.  I pray your future endeavors bear more fruit.");
		else
			e.self:Say("You have defeated the lord of the mountain an impressive "..counter.." times!  I commend you for your bravery.");
		end
	end

	if e.message:find("max") then
		local key = "nagafen_253_counter_max";
		local max = e.other:GetBucket(key);
		if max == nil or max == "" then
			e.self:Say("I'm afraid I have no record of your previous attempts to challenge the lord.");
		else
			e.self:Say("My records show you successfully defeated the lord "..max.." times on your best attempt.");
		end
	end

	if e.other:GetGM() and e.message:findi("reset") then
		eq.set_data(get_bucket_key("inprogress"), "0", "14h");
		e.self:Say("The lord is ready to accept your challenge again.");
	end
end

function evt_nagafen_prepare_spawn(e)
	local counter = get_progress();
	if counter == -1 then
		local controller = eq.get_entity_list():GetNPCByNPCTypeID(controller_id);
		if not controller.valid then
			eq.spawn2(controller_id, 0, 0, -832, -1399, 88.1, 4.25);
		end

		return -1;
	end

	return 0;
end

function evt_nagafen_spawn(e)
	local counter = get_progress();

	local hp = base_stats["hp"] + (100000 * counter);
	local ac = base_stats["ac"] + (100 * counter);
	local min_hit = base_stats["min_hit"] + (25 * counter);
	local max_hit = base_stats["max_hit"] + (50 * counter);
	local delay = base_stats["delay"] - math.max(counter-5, 0);

	-- His base resists are already kinda absurd so lets actually start them at a lower level and then build back up to it
	local resist_modifier = math.min(counter + 5, 15) / 15;
	local mr = math.floor(base_stats["mr"] * resist_modifier);
	local cr = math.floor(base_stats["cr"] * resist_modifier);
	local fr = math.floor(base_stats["fr"] * resist_modifier);
	local dr = math.floor(base_stats["dr"] * resist_modifier);
	local pr = math.floor(base_stats["pr"] * resist_modifier);

	-- eq.debug(string.format("hp %d ac %d min_hit %d max_hit %d delay %d mr %d cr %d fr %d dr %d pr %d", hp, ac, min_hit, max_hit, delay, mr, cr, fr, dr, pr));

	e.self:ModifyNPCStat("max_hp", tostring(hp));
	e.self:ModifyNPCStat("ac", tostring(ac));
	e.self:ModifyNPCStat("min_hit", tostring(min_hit));
	e.self:ModifyNPCStat("max_hit", tostring(max_hit));
	e.self:ModifyNPCStat("attack_delay", tostring(delay));
	e.self:ModifyNPCStat("mr", tostring(mr));
	e.self:ModifyNPCStat("cr", tostring(cr));
	e.self:ModifyNPCStat("fr", tostring(fr));
	e.self:ModifyNPCStat("dr", tostring(dr));
	e.self:ModifyNPCStat("pr", tostring(pr));
	e.self:HealDamage(hp);
end

function evt_nagafen_death(e)
	local counter = get_progress();

	counter = counter + 1;

	eq.set_data(get_bucket_key("inprogress"), tostring(counter), "14h");

	eq.update_spawn_timer(6461, respawn_millis, eq.get_zone_instance_id());

	eq.zone_emote(MT.Yellow, "The lord's power grows with each attempt on his life.  Prepare yourself for his imminent return.");
end

function evt_player_death(e)
	local counter = get_progress();
	local client_list = eq.get_entity_list():GetClientList();
	for c in client_list.entries do
		local key = "nagafen_253_counter_max";
		local current_max_str = c:GetBucket(key);
		if current_max_str == nil then
			current_max_str = "0";
		end

		local current_max = tonumber(current_max_str);
		if current_max == nil then
			current_max = 0;
		end

		c:SetBucket(key, tostring(math.max(counter, current_max)));
	end

	eq.set_data(get_bucket_key("inprogress"), "-1", "14h");
	eq.set_data(get_bucket_key("finished"), tostring(counter), "14h");
	eq.get_entity_list():GetNPCByNPCTypeID(nagafen_id):Depop(false);
	e.self:SetHP(e.self:GetMaxHP());
	eq.spawn2(controller_id, 0, 0, -832, -1399, 88.1, 4.25);

	return 1;
end

function event_encounter_load(e)
	local expedition = eq.get_expedition();
	if not expedition.valid or expedition:GetName() ~= "Nagafen's Lair (Event)" then
		return
	end

	eq.register_npc_event(Event.prepare_spawn,  nagafen_id, evt_nagafen_prepare_spawn);
	eq.register_npc_event(Event.spawn,          nagafen_id, evt_nagafen_spawn);
	eq.register_npc_event(Event.death_complete, nagafen_id, evt_nagafen_death);
	eq.register_npc_event(Event.say,            nagafen_id,    evt_nagafen_say);

	eq.register_npc_event(Event.spawn,          controller_id,    evt_controller_spawn);
	eq.register_npc_event(Event.say,            controller_id,    evt_controller_say);

	eq.register_player_event(Event.death, evt_player_death);
end
