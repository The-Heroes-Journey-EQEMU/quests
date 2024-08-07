-- Heretic Heads - Rognarog's Head
function event_say(e)
	if(e.message:findi("Hail")) then
		e.self:Say("Shalom, " .. e.other:GetCleanName() .. "!  I welcome you to our humble village in these [" .. eq.say_link("trying times") .. "].");
	elseif(e.message:findi("trying times")) then
		e.self:Say("There are many threats currently facing this village. The kobolds of Clan Kolbok are becoming bolder in pushing the boundaries of the territory in which they usually hunt. A few of the kobolds now hunt recklessly, killing for pleasure instead of sustenance. [" .. eq.say_link("Rognarog") .. "] the Infuriated is the most murderous of such kobolds. Then there are the [" .. eq.say_link("heretics") .. "] that have been invading both Clan Kolbok and Kejek territories alike, practicing their dark sorceries as a show of devotion to their faceless god.");
	elseif(e.message:findi("heretics")) then
		e.self:Say("The heretics have not only corrupted their own spirits but they defile the spirits of the dead with their evil sorceries. Fill this satchel with the heads of invading heretics and I shall reward you for your allegiance to Kejek.");
		e.other:SummonItem(17883); -- Burlap Satchel
	elseif(e.message:findi("rognarog")) then
		e.self:Say("Rognarog the Infuriated was once a mighty warrior for Clan Kolbok until his devotion to the kobold god Rolfron Zek devoured his spirit and drove him mad with anguish. Now he wanders the mountains and valleys of Stonebrunt shedding the blood of whatever creatures cross his path. Should you face Rognarog and release him from this life I will reward you for his severed head.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 6969})) then -- Satchel of Heretic Heads
		e.self:Say("Less heretics to defile the lands and spirits. You have the gratitude of Kejek for your assistance in repelling the heretic threat.");
		e.other:QuestReward(e.self,8,0,7,3,eq.ChooseRandom(6955,6955,6953,0,0),200); -- 20% chance for Swiftclaw - 40% for Kejekan Tribal Headband and 40% for no items
		e.other:Faction(172, 8, 0); -- Kejek Village
		e.other:Faction(247, 1, 0); -- Peace Keepers
	elseif(item_lib.check_turn_in(e.trade, {item1 = 6968})) then -- Kobold Head (Head of Rognarog the Infuriated)
		e.self:Say("By slaying Rognarog you have spared the lives of those who would have crossed his path. I thank you for your assistance, the spirits have noticed your actions and are pleased.");
		e.other:QuestReward(e.self,0,9,6,0,eq.ChooseRandom(6982,6983,6984),200); -- 33.33% Titan Blessed Tanto or Titan Blessed Tachi or Titan Blessed Bokken
		e.other:Faction(172, 3, 0); -- Kejek Village
		e.other:Faction(247, 1, 0); -- Peace Keepers
	end
	item_lib.return_items(e.self, e.other, e.trade);
end