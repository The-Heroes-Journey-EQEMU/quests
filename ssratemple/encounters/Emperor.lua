local blood_id = 162189; -- To reset encounter: #npctypespawn 162189
local empfake_id = 162065;
local empreal_id = 162227;
local wraith_id = 162210;
local memory_id = 26000;

local STATE_START = 0;
local STATE_BLOOD_DEAD = 1;
local STATE_END = 255;

function get_data_key(suffix)
	return string.format("ssratemple_%d_emp_%s", eq.get_zone_instance_id(), suffix);
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

function evt_blood_spawn(e)
	set_state(STATE_START);
	eq.unique_spawn(empfake_id, 0, 0, 990, -325, 415, 384);
end

function evt_blood_death(e)
	set_state(STATE_BLOOD_DEAD);
	eq.depop(empfake_id);
	eq.unique_spawn(empreal_id, 0, 0, 997, -325, 415, 384); 
end

function evt_emp_death(e)
	set_state(STATE_END);
	e.self:Emote("'s corpse says 'How...did...ugh...'");
	eq.spawn2(wraith_id, 0, 0, 877, -326, 408, 385);
	eq.spawn2(wraith_id, 0, 0, 953, -293, 404, 385);
	eq.spawn2(wraith_id, 0, 0, 953, -356, 404, 385);
	eq.spawn2(wraith_id, 0, 0, 773, -360, 403, 128);
	eq.spawn2(wraith_id, 0, 0, 770, -289, 403, 128);

	local memory_npc = eq.spawn2(memory_id, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading());
	if memory_npc ~= nil then
		local name = string.lower(e.self:GetCleanName());
		name = string.gsub(name, "^[#%s]+", "");
		name = string.gsub(name, "[#%s]+", "");

		memory_npc:SetEntityVariable("Flag-Name", name);
		memory_npc:SetEntityVariable("Stage-Name", "PoP");
	end
end

function evt_emp_slay(e)
	e.self:Say("Your god has found you lacking.");
end

function evt_wraith_spawn(e)
	e.self:SetTimer("depop", 1800);
end

function evt_wraith_combat(e)
	if e.joined == true then
		if not e.self:IsPausedTimer("depop") then
			e.self:PauseTimer("depop");
		end
	else
		e.self:ResumeTimer("depop");
	end
end

function evt_wraith_timer(e)
	if e.timer == "depop" then
		e.self:Depop()
	end
end

function reset(e, new_state)
	eq.depop_all(blood_id);
	eq.depop_all(empfake_id);
	eq.depop_all(empreal_id);
	eq.depop_all(wraith_id);
	eq.depop_all(memory_id);

	set_state(new_state);

	check_state(e);
end

function check_state(e)
	local state = get_state();
	if state == -1 then
		return
	end

	if state == STATE_START then
		eq.unique_spawn(blood_id, 0, 0, 874, -325.4, 404, 384);
	end

	if state == STATE_BLOOD_DEAD then
		evt_blood_death(e);
	end
end

function GMControl(e)
	if e.self:Admin() <= 100 then
		return
	end

	if e.message:findi("help") then
		e.self:Message(1, "Control options for Emperor event: ["..eq.say_link("status_emp", true).."] to view current state.  ["..eq.say_link("reset_emp", true).."] to reset to beginning.  ["..eq.say_link("state1_emp", true).."] to reset to real Emperor spawn.");
		return;
	end

	if e.message:findi("status_emp") then
		local state = get_state();
		if state == STATE_START then
			e.self:Message(1, "Emperor is currently in its initial state, waiting on blood golem to be killed.");
		elseif state == STATE_BLOOD_DEAD then
			e.self:Message(1, "Blood golem has been killed and real emperor has been spawned.");
		elseif state == STATE_END then
			e.self:Message(1, "Emperor has been killed.");
		else
			e.self:Message(1, "Unrecognized state: "..state);
		end

		return;
	end

	if e.message:findi("reset_emp") then
		reset(e, STATE_START);
		e.self:Message(1, "Emp reset to start.");
		return;
	end

	if e.message:findi("state1_emp") then
		reset(e, STATE_BLOOD_DEAD);
		e.self:Message(1, "Emp reset to blood golem dead and real Emp spawned.");
		return;
	end
end

function event_encounter_load(e)
	eq.register_npc_event(Event.spawn,          blood_id,   evt_blood_spawn);
	eq.register_npc_event(Event.death_complete, blood_id,   evt_blood_death);
	eq.register_npc_event(Event.death_complete, empreal_id, evt_emp_death);
	eq.register_npc_event(Event.slay,           empreal_id, evt_emp_slay);
	eq.register_npc_event(Event.spawn,          wraith_id,  evt_wraith_spawn);
	eq.register_npc_event(Event.combat,         wraith_id,  evt_wraith_combat);
	eq.register_npc_event(Event.timer,          wraith_id,  evt_wraith_timer);

	eq.register_player_event(Event.say, GMControl);

	check_state(e);
end
