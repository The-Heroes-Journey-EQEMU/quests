-- The Insanity Crawler (179180) in Akheva

function event_spawn(e)
	eq.zone_emote(MT.DimGray, "You hear squealing voices of Centi echo through the dark hallways. Something must have them frightened. You find yourself wondering what could possibly scare the servants of the Akheva. Do you really want to know?")
	eq.set_timer('depop', 30 * 60 * 1000)
end

function event_slay(e)
	if e.other:IsClient() or e.other:IsPet() then
		local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
		eq.spawn2(179136,0,0, x - 10, y, z, h);
		eq.spawn2(179136,0,0, x + 10, y, z, h);
		eq.spawn2(179136,0,0, x, y - 10, z, h);
		eq.spawn2(179136,0,0, x, y + 10, z, h);
	end
end

function event_timer(e)
	if e.timer == 'depop' then
		eq.stop_timer(e.timer);
		eq.depop();
	end
end
