-- Necromancer 5th Rank - Skullcap

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Insert Metal Key *whirrrr*.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 12849}) then -- Item: A Metal Key
		e.self:Say("*Whirrrr*");
		e.other:QuestReward(e.self,0,0,0,0,18065); -- Item: Journal
	end
end
