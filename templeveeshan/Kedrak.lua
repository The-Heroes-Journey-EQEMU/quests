-- Kedrak NPCID: 124093
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro #Lord_Kreizenn (124074) and Carx`Vean (124094) if they are up
		entity_list:GetNPCByNPCTypeID(124074):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124094):AddToHateList(e.other, 1);
	end
end