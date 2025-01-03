-- If you found this, please don't spoil it for everyone else. This will be EPIC.
-- If I catch you spoiling this before velious release, you WILL be banned.

local ignore_reengage	= false;
local ignore_disengage	= false;
local event_npcs		= {128020, 128090, 128091, 128092, 128093}
local next_event_hp		= 90;
local hate_to_add		= 3000;

function event_spawn(e)
	e.self:Shout("Insolent lesser races, in thanks for freeing me from centuries of slumber, I shall grant you a quick death!");
    eq.get_entity_list():FindDoor(46):ForceOpen(e.self);
	eq.set_next_hp_event(90);
end

function event_combat(e)
	if e.joined then
		if ignore_reengage then -- check to see if we purposefully wiped the hate list, if so ignore this
			ignore_reengage = false;
			return;
		end
		e.self:Emote(" ROARS!");

		--lets get some pressure on the tank, and anyone who is stupid enough
		--be in front of the mob :)
		eq.depop_all(128020);
		eq.set_timer("TankAEDMG", math.random(1000,3000));
		eq.stop_timer("reset");
	else
		if ignore_disengage then -- check to see if we purposefully wiped the hate list, if so ignore this
			ignore_disengage = false;
			return;
		end
		eq.stop_timer("TankAEDMG");
		eq.stop_timer("AE");
		eq.set_timer("reset",10 * 1000);
	end
end

function event_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "TankAEDMG" then
		eq.set_timer("TankAEDMG",30 * 1000);

		--Prismatic beam, 1.5k to 2.5k -100 Prismatic resist. 75% resist max
		--AOE dmg around the tank
		e.self:CastSpell(42231,e.self:GetTarget():GetID());
	
	elseif e.timer == "AE" then
		--big bada boom time, once every 60 sec
		eq.zone_emote(MT.Emote, "The dragon unleashes a wave of prismatic energy!");
		e.self:CameraEffect(1000,5);
		e.self:CastSpell(23150,e.self:GetID())
		eq.stop_timer("TankAEDMG"); --lets not overlap our tank buster AE with the 60 sec AE
		eq.set_timer("TankAEDMG",30 * 1000); --lets go again in 30 sec!

		if phase == 7 then
			eq.set_timer("AE", 20 * 1000); --if under 25% change to every 20 seconds
		else
			eq.set_timer("AE", 30 * 1000); --if above 25% every 30 sec
		end
	elseif e.timer == "SpawnAdds" then
		SpawnAdds(e);
	elseif e.timer == "reset" then
		reset_event(e);
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

	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
end

function SpawnWarder(e)
    local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
    local npc = eq.spawn2(eq.ChooseRandom(128090, 128091, 128092, 128093), 0, 0, x + 75, y + 25, z, h):AddToHateList(e.self:GetHateTop(),2000);
	if npc.valid then
        npc:Shout("I LIVE AGAIN! Master, your wish is my command!")
	end
end

function event_hp(e)
	if e.hp_event == 90 or e.hp_event == 85 or e.hp_event == 80 then
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		e.self:CastSpell(6790,e.self:GetID()); --Spell: terrifying roar, -1k resist poison, 300 range
		ignore_reengage		= true;
		ignore_disengage	= true;
		-- e.self:WipeHateList();
		-- e.self:AddToHateList(current_target,2000); -- add 3k new threat to the random target
		next_event_hp = next_event_hp - 5;
		eq.set_next_hp_event(next_event_hp);
	elseif e.hp_event == 75 then
		e.self:Shout("YOU! WARDER! LIVE AGAIN AND SERVE ME!");
        SpawnWarder(e)
		eq.set_next_hp_event(50);
	elseif e.hp_event == 50 then
		e.self:Shout("THIS IS NOT HOW I WILL BE REMEMBERED!");
		eq.set_timer("AE", math.random(1000,3000));
		eq.set_next_hp_event(25);
	elseif e.hp_event == 25 then
		eq.stop_timer("AE");
		e.self:Shout("GUARDS! Assist me!");
		e.self:CameraEffect(2000,5);
		eq.zone_emote(MT.Emote,"Flapping of strong wings can be heard in the distance.");
		eq.set_timer("SpawnAdds",60 * 1000);
	end
end

function reset_event(e)
	e.self:WipeHateList();
	e.self:GotoBind();
	e.self:BuffFadeAll();
	e.self:SetHP(e.self:GetMaxHP());
	ignore_reengage		= false;
	ignore_disengage	= false;
	next_event_hp		= 90;
	phase				= 1;
	eq.set_next_hp_event(90);

	for i = 1, #event_npcs do
		eq.depop_all(event_npcs[i])
	end
end

function event_death_complete(e)
	e.self:Shout("So then... my fate is sealed... until we meet again.");
end
