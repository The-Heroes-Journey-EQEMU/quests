-- Wel`Wnas (124092) NPCID: 124092
function event_combat(e)
	if e.joined then
		-- grab the entity list
		local entity_list = eq.get_entity_list();

		-- also aggro #Lady_Mirenilla (124077) and  Gra`Vloren (124091) if they are up
		entity_list:GetNPCByNPCTypeID(124077):AddToHateList(e.other, 1);
		entity_list:GetNPCByNPCTypeID(124091):AddToHateList(e.other, 1);
	end
end