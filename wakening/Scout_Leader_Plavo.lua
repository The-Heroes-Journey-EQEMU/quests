	-- Cleric 1.5 Epic Quest // Harmony of the Soul // --Drogerin	
-- items: 9591, 9945, 9948, 9597

local epic_disabled = true;

function event_say(e)
	if not epic_disabled then
		local qglobals = eq.get_qglobals(e.other);
		if qglobals["cleric_epic"] ~= nil and qglobals["cleric_epic"] >= "5" and e.message:findi("aid") then
			e.self:Say("They will research and learn about the greatest mortal beings in this realm. Learning about the creatures that may prove to be friend or foe, so they prepare for either. Our scouts have gathered most of the information that they need, but there are a few creatures that we still need to harvest brains from. Currently scouts are attempting to find the brain of the Shissar, a dragon, and an Akhevan. I am sure any of the scouts would welcome your assistance. I will send runners ahead to notify them you may be arriving.");
		end
	else
		e.self:Say("I am busy, go away!");
	end
end
						
function event_trade(e)
	local item_lib = require("items");
	local qglobals = eq.get_qglobals(e.other);

	if not epic_disabled then
		if qglobals["cleric_epic"] ~= nil and qglobals["cleric_epic"] >= "4" and item_lib.check_turn_in(e.trade, {item1 = 9591}) then  --Dark Disciples Notice of Service
			e.self:Say("You are from the Faydwer camp are you? I'm not terribly familiar with the faces from there. Anyway, the scouts have been sent out, and are gathering the \"parts\" that we believe the Legion will need to prepare for the incursion into our realm. If we are to find their good graces, we must prove that we will stop at nothing to [aid] them.");
			eq.set_global("cleric_epic","5",5,"F");
		elseif qglobals["cleric_epic"] ~= nil and qglobals["cleric_epic"] >= "5" and item_lib.check_turn_in(e.trade, {item1 = 9945, item2 = 9948, item3 = 9597}) then -- Shissar Cerebral Cortex // Dragon Cerebrum // Akhevan Brain Stem
			e.self:Say("Excellent work! The leader will be pleased. He should be here any moment to collect them.");
			eq.spawn2(119176,0,0,861.99,-3016.40,20,0); --Dark Disciple Master
			eq.depop_with_timer();
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
