function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. "! I trust you are not afraid of heights. Kelethin is a grand city. but it is also a safe haven from predators and evil beings. About the only thing to fear are the [pixie tricksters].");
	elseif e.message:findi("pixie trickster") then
		e.self:Say("An irritating lot of fairy folk. They have been starting fires in our great forest. They may just burn our grand community down. We will have to [exterminate the pixies]. It is unfortunate. but it is for the good of the entire forest.");
	elseif e.message:findi("exterminate the pixie") then
		if e.other:GetFaction(e.self) < 6 then
			e.self:Say("Then I give you this pouch. Should you fill and combine it with pixie dust, I shall pay you greatly for your deeds. We may even find a use for the dust itself. Careful, small though they may be, many are quite strong. Search for the weak ones for now.");
			e.other:SummonItem(17957); -- Item: Empty Pouch
		else
			e.self:Say("Faydark's Champions cannot call you foe. but you have yet to earn our trust.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 12109 }) then -- Item: Pouch of Pixie Dust
		e.self:Say("Good work. scout!!  You have earned this reward.  It is all we have at the time.  I am certain you are satisfied.  If not, then do not let me hear of it.");
		e.other:QuestReward(e.self,{exp = 800, silver = math.random(9)});
		e.other:Faction(316, 10); -- Faction: Scouts of Tunare
		if math.random(100) < 20 then
			e.other:SummonItem(eq.ChooseRandom(2104, 2106, 2108, 2111, 2112)); -- Items: Patchwork Tunic, Patchwork Cloak, Patchwork Sleeves, Patchwork Pants, Patchwork Boots
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
