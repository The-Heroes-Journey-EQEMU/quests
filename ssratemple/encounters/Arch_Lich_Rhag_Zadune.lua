local zhezum_id = 162178;  -- Use the following to reset the event: #npctypespawn 162178
local mozdezh_id = 162192;
local lich_id = 162177;

local STATE_START = 0;
local STATE_ZHEZUM_DEAD = 1;
local STATE_MOZDEZH_DEAD = 2;
local STATE_END = 255;

function get_data_key(suffix)
	return string.format("ssratemple_%d_lich_%s", eq.get_zone_instance_id(), suffix);
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

function evt_zhezum_spawn(e)
	set_state(STATE_START);

	local entities = eq.get_entity_list();
	for i,id in ipairs({mozdezh_id, lich_id}) do
		local mob = entities:GetMobByNpcTypeID(id);
		if mob.valid then
			mob:Depop();
		end
	end
end

function evt_zhezum_death(e)
	set_state(STATE_ZHEZUM_DEAD);
	eq.unique_spawn(mozdezh_id, 0, 0, 634.3, -280.5, 147.6, 383.2);
end

function evt_mozdezh_death(e)
	set_state(STATE_MOZDEZH_DEAD);
	eq.unique_spawn(lich_id, 0, 0, 420, -144, 270.1, 0);
end

function evt_lich_death(e)
	set_state(STATE_END);
end

function reset(e, new_state)
	eq.depop_all(zhezum_id);
	eq.depop_all(mozdezh_id);
	eq.depop_all(lich_id);

	set_state(new_state);
	check_state(e);
end

function check_state(e)
	local state = get_state();
	if state == -1 then
		return
	end

	if state == STATE_START then
		eq.unique_spawn(zhezum_id, 0, 0, 547, -412, 9.1, 0);
	end

	if state == STATE_ZHEZUM_DEAD then
		evt_zhezum_death(e);
	end

	if state == STATE_MOZDEZH_DEAD then
		evt_mozdezh_death(e);
	end
end

function GMControl(e)
	if e.self:Admin() <= 100 then
		return
	end

	if e.message:findi("help") then
		e.self:Message(1, "Control options for Rhag cycle event: ["..eq.say_link("status_rhag", true).."] to view current state.  ["..eq.say_link("reset_rhag", true).."] to reset to beginning.  ["..eq.say_link("state1_rhag", true).."] to reset to mozdezh spawned.  ["..eq.say_link("state2_rhag", true).."] to reset to arch lich spawned.");
		return;
	end

	if e.message:findi("status_rhag") then
		local state = get_state();
		if state == STATE_START then
			e.self:Message(1, "Zhezum is up and waiting to be killed to start event.");
		elseif state == STATE_ZHEZUM_DEAD then
			e.self:Message(1, "Zhezum has been killed and Mozdezh has spawned.");
		elseif state == STATE_MOZDEZH_DEAD then
			e.self:Message(1, "Zhezum and Mozdezh have been killed and Arch Lich Rhag Zadune has spawned.");
		elseif state == STATE_END then
			e.self:Message(1, "Arch lich has been killed and cycle is complete.");
		else
			e.self:Message(1, "Unrecognized state: "..state);
		end

		return;
	end

	if e.message:findi("reset_rhag") then
		reset(e, STATE_START);
		e.self:Message(1, "Rhag cycle reset to start");
		return;
	end

	if e.message:findi("state1_rhag") then
		reset(e, STATE_ZHEZUM_DEAD);
		e.self:Message(1, "Rhag cycle reset to Zhezum dead and Mozdezh spawned.");
		return;
	end

	if e.message:findi("state2_rhag") then
		reset(e, STATE_MOZDEZH_DEAD);
		e.self:Message(1, "Rhag cycle reset to Mozdezh dead and arch lich spawned.");
		return;
	end
end

function event_encounter_load(e)
	eq.register_npc_event(Event.spawn,          zhezum_id,  evt_zhezum_spawn);
	eq.register_npc_event(Event.death_complete, zhezum_id,  evt_zhezum_death);
	eq.register_npc_event(Event.death_complete, mozdezh_id, evt_mozdezh_death);
	eq.register_npc_event(Event.death_complete, lich_id,    evt_lich_death);

	eq.register_player_event(Event.say, GMControl);

	check_state(e);
end
