function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ah, greetings. I hope you are a student of the way of fear. Within this temple there are many who can teach you to harness your gifts. I am an instructor in the [rituals of fear].");
	elseif e.message:findi("rituals of fear") then
		e.self:Say("So you wish to learn, eh? I am working on a ritual to strike fear into the hearts of the other inhabitants of Odus. The reagents I require for this ritual are the doll of a Kerran priestess, the ichor of a giant wooly spider, your initiate symbol of Cazic-Thule, and a giant snake fang with which to carve my glyphs. Fetch me these components. We shall infect this land with fear, and I shall reward you with the station of disciple of this temple.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 13716, item2 = 16989, item3 = 1437, item4 = 7005}) then -- Items: Kerran Doll, Ichor, Initiate Symbol of Cazic Thule, Giant Snake Fang
		e.self:Say("Excellent work, " .. e.other:GetName() .. ". You are well on your way to proving yourself worthy to serve Cazic Thule.");
		e.other:QuestReward(e.self,{exp = 2000});
		e.other:SummonItem(1438);	-- Item: Disciple Symbol of Cazic Thule
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
