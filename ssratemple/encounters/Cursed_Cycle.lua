local controller_id = 162255;  -- Use the following to reset the event: #npctypespawn 162255
local serpent_triggers = {162012, 162021, 162013, 162060, 162024, 162011, 162059, 162258, 162089, 162023}; -- 7 Taskmasters, 2 Rhzoth, 1 Warder
local serpent_triggers_s2 = {33885, 33891, 33886, 33964, 33895, 33884, 33963, 37145, 34043, 34235}; -- Spawn2 ids for the above triggers
local serpent_id = 162261;
local exiled_id = 162232;
local cursed_id = 162206;

local STATE_START = 0;
local STATE_TRIGGERS_DEAD = 1;
local STATE_SERPENT_DEAD = 2;
local STATE_EXILED_DEAD = 3;
local STATE_END = 255;

function get_data_key(suffix)
	return string.format("ssratemple_%d_cursed_%s", eq.get_zone_instance_id(), suffix);
end

function get_state()
	if eq.get_zone_instance_id() == 0 then
		return -1;
	end

	local state_str = eq.get_data(get_data_key("state"));
	if state_str == nil then
		state_str = "0";
	end

	local state = tonumber(state_str);
	if state == nil then
		state = 0;
	end

	return state;
end

function set_state(new_state)
	local instance_id = eq.get_zone_instance_id();
	if instance_id == 0 then
		-- Let the open world be governed by the agents of chaos
		return;
	end

	eq.set_data(get_data_key("state"), tostring(new_state), "14h");
end

function evt_controller_spawn(e)
	set_state(STATE_START);
end

function check_serpent_triggers(e)
	local state = get_state();
	if state ~= STATE_START then
		return;
	end

	local entity_list = eq.get_entity_list();
	for i,id in ipairs(serpent_triggers) do
		local mob = entity_list:GetMobByNpcTypeID(id);
		if mob.valid then
			return;
		end
	end

	spawn_serpent(e);
end

function spawn_serpent(e)
	set_state(STATE_TRIGGERS_DEAD);
	local mob = eq.unique_spawn(serpent_id, 0, 0, -30, -10, -223, 130);
	mob:Shout("I will not be contained! My prison weakens, and I will claw my way back into this world, even if it dooms me!");

	-- Depop controller
	if e ~= nil then
		e.self:Depop(true);
	end
end

function evt_serpent_death(e)
	set_state(STATE_SERPENT_DEAD);
	local mob = eq.unique_spawn(exiled_id, 0, 0, -30, -10, -223, 130);
	mob:Shout("FOOLS! Your doom approaches!");
end

function evt_exiled_death(e)
	set_state(STATE_EXILED_DEAD);
	local mob = eq.unique_spawn(cursed_id, 0, 0, -30, -10, -223, 130);
	mob:Shout("FOOLS! Your doom is here! TREMBLE!");
end

function evt_cursed_death(e)
	set_state(STATE_END);
end

function reset(e, new_state)
	eq.depop_all(controller_id);
	for i,id in ipairs(serpent_triggers) do
		eq.depop_all(id);
	end
	eq.depop_all(serpent_id);
	eq.depop_all(exiled_id);
	eq.depop_all(cursed_id);

	set_state(new_state);
	check_state(e);
end

function check_state(e)
	local state = get_state();
	if state == -1 then
		return
	end

	if state == STATE_START then
		eq.unique_spawn(controller_id, 0, 0, 0, 0, 0, 0);
		local entity_list = eq.get_entity_list();
		for i,id in ipairs(serpent_triggers) do
			local mob = entity_list:GetMobByNpcTypeID(id);
			if not mob.valid then
				local sp2 = serpent_triggers_s2[i];
				eq.spawn_from_spawn2(sp2);
			end
		end
	end

	if state == STATE_TRIGGERS_DEAD then
		spawn_serpent(nil);
	end

	if state == STATE_SERPENT_DEAD then
		evt_serpent_death(e);
	end

	if state == STATE_EXILED_DEAD then
		evt_exiled_death(e);
	end
end

function GMControl(e)
	if e.self:Admin() <= 100 then
		return
	end

	if e.message:findi("help") then
		e.self:Message(1, "Control options for Cursed cycle event: ["..eq.say_link("status_cursed", true).."] to view current state.  ["..eq.say_link("reset_cursed", true).."] to reset to beginning.  ["..eq.say_link("state1_cursed", true).."] to reset to all triggers killed and serpent spawned.  ["..eq.say_link("state2_cursed", true).."] to reset to exiled spawned. ["..eq.say_link("state3_cursed", true).."] to reset to Vyzh`dra spawned.");
		return;
	end

	if e.message:findi("status_cursed") then
		local state = get_state();
		if state == STATE_START then
			e.self:Message(1, "Event is at the start waiting on the initial 10 triggers to be killed.");
		elseif state == STATE_TRIGGERS_DEAD then
			e.self:Message(1, "Triggers have been killed and serpent has been spawned.");
		elseif state == STATE_SERPENT_DEAD then
			e.self:Message(1, "Serpent has been killed and exiled has been spawned.");
		elseif state == STATE_EXILED_DEAD then
			e.self:Message(1, "Exiled has been killed and Vyzh`dra the Cursed has been spawned.");
		elseif state == STATE_END then
			e.self:Message(1, "Vhyz`dra encounter has ended.");
		else
			e.self:Message(1, "Unrecognized state: "..state);
		end

		return;
	end

	if e.message:findi("reset_cursed") then
		reset(e, STATE_START);
		e.self:Message(1, "Reset to start");
		return;
	end

	if e.message:findi("state1_cursed") then
		reset(e, STATE_TRIGGERS_DEAD);
		e.self:Message(1, "Reset to serpent spawned");
		return;
	end

	if e.message:findi("state2_cursed") then
		reset(e, STATE_SERPENT_DEAD);
		e.self:Message(1, "Reset to exiled spawned");
		return;
	end

	if e.message:findi("state3_cursed") then
		reset(e, STATE_EXILED_DEAD);
		e.self:Message(1, "Reset to Vhyz`dra spawned");
		return;
	end
end

function event_encounter_load(e)
	eq.register_npc_event(Event.tick,           controller_id, check_serpent_triggers);
	eq.register_npc_event(Event.spawn,          controller_id, evt_controller_spawn);
	eq.register_npc_event(Event.death_complete, serpent_id,    evt_serpent_death);
	eq.register_npc_event(Event.death_complete, exiled_id,     evt_exiled_death);
	eq.register_npc_event(Event.death_complete, cursed_id,     evt_cursed_death);

	eq.register_player_event(Event.say, GMControl);

	check_state(e);
end
