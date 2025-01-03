-- Gra`Vloren NPCID: 124091
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro #Lady_Mirenilla (124077) and Wel`Wnas (124092) if they are up
		entity_list:GetNPCByNPCTypeID(124077):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124092):AddToHateList(e.other, 1);
	end
end