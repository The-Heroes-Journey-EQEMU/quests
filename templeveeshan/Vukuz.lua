-- Vukuz NPCID: 124015
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro Bryrym (124005) and #Lord_Feshlak (124008) if they are up
		entity_list:GetNPCByNPCTypeID(124005):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124008):AddToHateList(e.other, 1);
	end
end