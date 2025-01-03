-- Lurian NPCID: 124013
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro Hsrek (124014) and #Lord_Vyemm (124017) if they are up
		entity_list:GetNPCByNPCTypeID(124014):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124017):AddToHateList(e.other, 1);
	end
end