function event_spawn(e)
	eq.set_timer("follow", 1);
end

function event_timer(e)
	if e.timer == "follow" then
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(115101) then
			e.self:follow(115101);
			eq.stop_timer("follow");
		end
	end
end
