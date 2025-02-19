--oot/Gubblegrot_Smashfist.lua NPCID 69140
--SK Epic 1.5

local epic_disabled = true; -- Disabling for omens (epics) cannot reference perl expansion vars from lua.

function event_say(e)
	local qglobals = eq.get_qglobals(e.other);	

	if not epic_disabled then
		if(e.message:findi("hail")) then
			if qglobals["shadowknight_epic"] ~= nil and qglobals["shadowknight_epic"] == "8" then
				e.self:Say("I knew you would come. You will soon learn that evil does not pay!");
				e.self:SetSpecialAbility(19, 0);
				e.self:SetSpecialAbility(20, 0);
				e.self:SetSpecialAbility(24, 0);
				e.self:SetSpecialAbility(25, 0);
				e.self:SetSpecialAbility(35, 0);
				e.self:AddToHateList(e.other,1);
			end
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade);
end
