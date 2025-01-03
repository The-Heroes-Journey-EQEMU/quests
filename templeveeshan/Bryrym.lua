-- Bryrym NPCID: 124005
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro #Lord_Feshlak (124008) and Vukuz (124015) if they are up
		entity_list:GetNPCByNPCTypeID(124008):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124015):AddToHateList(e.other, 1);
	end
end