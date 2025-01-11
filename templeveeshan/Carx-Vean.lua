-- Carx`Vean (124094) NPCID: 124094
function event_combat(e)
	if e.joined then
		-- also aggro #Lord_Kreizenn (124074) and Kedrak (124093) if they are up
		local entity_list = eq.get_entity_list();
		local add_1	= entity_list:IsMobSpawnedByNpcTypeID(124074);
		local add_2	= entity_list:IsMobSpawnedByNpcTypeID(124093);

		if add_1 then
			entity_list:GetNPCByNPCTypeID(124074):CastToNPC():AddToHateList(e.other, 1);
		elseif add_2 then
			entity_list:GetNPCByNPCTypeID(124093):CastToNPC():AddToHateList(e.other, 1);
		end
	end
end
