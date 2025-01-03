-- #Aaryonar NPCID: 124010
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro Kal`Vunar (124016) and Nir`Tan (124012) if they are up
		entity_list:GetNPCByNPCTypeID(124016):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124012):AddToHateList(e.other, 1);
	end
end