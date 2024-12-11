function event_death_complete(e)
	e.self:Say("All Iksar residents.. shall learn.. of my demise. Ungghh!!");
	eq.signal(87101,1); -- NPC: Atheling_Plague
end
