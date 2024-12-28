-- If you found this, please don't spoil it for everyone else. This will be EPIC.
-- If I catch you spoiling this before velious release, you WILL be banned.

local phase = 1;
local current_target = nil;
local ignore_reengage = false;
local ignore_disengage = false;
local hate_to_add = 3000;

function event_spawn(e)
	phase = 1;
	e.self:Shout("Insolent lesser races, in thanks for freeing me from centuries of slumber, I shall grant you a quick death!");

	

    eq.get_entity_list():FindDoor(46):ForceOpen(e.self);
	eq.set_next_hp_event(90);
end

-- when combat starts/ends.  Joins = starts, else = ends
function event_combat(e)	
	if (e.joined) then
		--check to see if we purposefully wiped the hate list, if so ignore this
		if(ignore_reengage) then
			ignore_reengage=false;
			return;
		end
		phase = 1;
		e.self:Emote(" ROARS!");

		if eq.get_data("sleeper_awake") == nil or eq.get_data("sleeper_awake") == "" then
			local target = e.self:GetTarget();
			if target then
				local tar_name = target:GetCleanName();
				local message = string.format(
					"A low rumbling can be felt in the distance. In the darkness, a terrifying presence can be felt. Kerafyrm has been awakened once more! The clashing of steel and the screams of chaos echo again throughout the beast's tomb. %s has awoken The Sleeper!",
					tar_name
				);
		
				eq.world_wide_marquee(MT.Yellow, 510, 1, 100, 10000, message);
				eq.discord_send("ooc", message);
				eq.set_data("sleeper_awake", tar_name);
		
				e.self:Shout(
					tar_name .. "! You are no Trylun! Your companions are no army of Rallos Zek! The Sleeper shall grant you a swift death!"
				);
			end
		end			

		--lets get some pressure on the tank, and anyone who is stupid enough
		--be in front of the mob :)
		eq.set_timer("TankAEDMG", math.random(1000,3000));
		eq.stop_timer("reset");
		
	else
		--check to see if we purposefully wiped the hate list, if so ignore this
		if(ignore_disengage) then
			ignore_disengage=false;
			return;
		end
		--check to see if we purposefully wiped the hate list, if so ignore this
		eq.stop_timer("TankAEDMG");
		eq.stop_timer("AE");
		eq.set_timer("reset",10000);
	end
end

function event_timer(e)
	if(e.timer == "TankAEDMG") then
		eq.stop_timer(e.timer);
		eq.set_timer("TankAEDMG",10000);
		--Fire beam, 6k -250 FR resist. 300 resist diff is about 40% partial resist and 60% full
		--AOE dmg around the tank
		e.self:CastSpell(42231,e.self:GetTarget():GetID());
	
	elseif (e.timer == "AE") then
		eq.stop_timer(e.timer);
		--big bada boom time, once every 60 sec
		eq.zone_emote(MT.Emote, "The dragon thrashes about!");
		e.self:CameraEffect(1000,5);
		e.self:CastSpell(23150,e.self:GetID())
		--lets not overlap our tank buster AE with the 60 sec AE
		eq.stop_timer("TankAEDMG");
		eq.set_timer("TankAEDMG",6000);
		--lets go again in 30 sec!
		if(phase == 7 ) then
			--if under 25% change to every 15 seconds
			eq.set_timer("AE", 15000);
		else
			--if above 25% every 30 sec
			eq.set_timer("AE", 30000);
		end

	elseif (e.timer == "SpawnAdds") then
		eq.stop_timer(e.timer);
		SpawnAdds(e);
	elseif (e.timer == "reset") then
		eq.stop_timer(e.timer);
		e.self:SetHP(e.self:GetMaxHP())
		phase = 1;
		eq.set_next_hp_event(90);
		DepopAdds(e);
	end
end

function SpawnAdds(e)
	local xloc = e.self:GetX()+75;
	local yloc = e.self:GetY()+25;
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	-- sanity depop
	eq.depop_all(128020);
	eq.zone_emote(MT.Emote,"Cultists of the Prismatic Scale have arrived!");
	
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading);
end
	
function SpawnWarder(e)

    local xloc = e.self:GetX()
    local yloc = e.self:GetY()
    local zloc = e.self:GetZ()
    local heading = e.self:GetHeading()

    -- randomly select one of these NPC IDs: 128090, 128091, 128092, 128093
    local npc_ids = {128090, 128091, 128092, 128093}
    local random_npc_id = npc_ids[math.random(#npc_ids)]

    -- sanity depop
    eq.depop_all(random_npc_id)

    local npc = eq.spawn2(random_npc_id, 0, 0, xloc + 75, yloc + 25, zloc, heading)

    if npc.valid then
        npc:Shout("I LIVE AGAIN! Master, your wish is my command!")
        current_target = e.self:GetHateDamageTop(e.self);
        e.self:AddToHateList(current_target,2000);
    end
end

function DepopAdds(e)
    eq.depop_all()
end

function event_hp(e)
	if (e.hp_event <= 90 and phase == 1) then
		phase = 2;
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		--terrifying roar, -1k resist poison, 300 range
		e.self:CastSpell(6790,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateDamageTop(e.self);
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		--e.self:AddToHateList(current_target,2000);		
		eq.set_next_hp_event(85);
	
	elseif (e.hp_event <= 85 and phase == 2) then
		phase = 3;
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		--terrifying roar, -1k resist poison, 300 range
		e.self:CastSpell(6790,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateRandom();
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		--e.self:AddToHateList(current_target,3000);
		eq.set_next_hp_event(80);
	elseif (e.hp_event <=80 and phase == 3) then
		phase = 4;
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		-- remove red head
		--terrifying roar, -1k resist poison, 300 range
		e.self:CastSpell(6790,e.self:GetID());
		--get get a target randomly
		current_target = e.self:GetHateRandom();
		--wipe the hate list
		ignore_reengage=true;
		ignore_disengage=true;
		e.self:WipeHateList();
		--add 3k new threat to the random target
		--e.self:AddToHateList(current_target,3000);
		eq.set_next_hp_event(75);
	elseif (e.hp_event <= 75 and phase == 4) then
		phase =5;
		e.self:Shout("YOU! WARDER! LIVE AGAIN AND SERVE ME!");
        SpawnWarder(e)
		eq.set_next_hp_event(50);
	elseif (e.hp_event <= 50 and phase ==5) then
		phase = 6;
		e.self:Shout("THIS IS NOT HOW I WILL BE REMEMBERED!");
		eq.set_timer("AE", math.random(1000,3000));
		eq.set_next_hp_event(25);
	elseif (e.hp_event <= 25 and phase == 6) then
		phase = 7;
		eq.stop_timer("AE");
		e.self:Shout("GUARDS! Assist me!");
		e.self:CameraEffect(2000,5);
		eq.zone_emote(MT.Emote,"Flapping of strong wings can be heard in the distance.");
		eq.set_timer("SpawnAdds",120000);
	end
end

function event_death_complete(e)
	e.self:Shout("So then... my fate is sealed... until we meet again.");
	eq.stop_timer("AE");
	eq.stop_timer("TankAEDMG");
end
