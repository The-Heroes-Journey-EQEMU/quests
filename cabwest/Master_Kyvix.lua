function event_say(e)
	if e.message:findi("hail") and e.other:HasItem(4264) then -- Item: Occultist Skullcap
		e.self:Say("So you are expecting to earn your way to rank of revenant, eh? You shall when I have the base and stem of the candle your occultist skullcap.");
	elseif e.message:findi("hail") then
		e.self:Say("Quite busy!! Quite busy!! Things must be done. [New components] to be collected!!");
	elseif e.message:findi("New components") then
		e.self:Say("Yes, yes!! I will need components from beyond the gates. I must find an [apprentice of the third rank].");
	elseif e.message:findi("apprentice of the third rank") then
		e.self:Say("If you truly be an apprentice of the third circle, then there is a Dark Binder skullcap to be earned. Take this sack and fill it with a creeper cabbage, a heartsting telson with venom, brutling choppers and a scalebone femur. When they are combined within the sack, you may return it to me with your third rank skullcap and and we shall bid farewell to the title, apprentice.");
		e.other:SummonItem(17024); -- Item: Brood Sack
	elseif e.message:findi("true mission") then
		e.self:Say("I have been waiting for a Nihilist to return. His name was Ryx and I fear his love of ale and the high seas has kept him from his mission. All I want you to do is find him. He should be disguised as a worker and he will give you a tome to bring to me. Return it with your Dark Binder Cap. I am sure that is simple enough for one as simple as you. Be sure to give him this.");
		e.other:SummonItem(12848); -- Item: A Spectacle
	elseif e.message:findi("Kor Sha Candlestick") then
		e.self:Say("I need the foot and stem of my candlestick. The Stem comes from Sarnaks. The foot has been stolen by Gripe, in East Cabilis.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 12420, item2 = 4262}) then -- Items: full component sack, apprentice skullcap
		e.self:Say("Well done, here's your fourth rank skull cap. You can now start your [true mission].");
		e.other:QuestReward(e.self,{exp = 200, gold = 15});
		e.other:SummonItem(4263);	-- Item: Dark Binder Skullcap
		e.other:Faction(441,2);		-- Faction: Legion of Cabilis
		e.other:Faction(443,10);	-- Faction: Brood of Kotiz
	elseif item_lib.check_turn_in(e.trade, {item1 = 18065, item2 = 4263}) then -- Items: a journal and dark binder skullcap
		e.self:Say("Well done, here's your fifth rank skull cap. You can now track down the [Kor Sha Candlestick].");
		e.other:QuestReward(e.self,{exp = 200, gold = 20});
		e.other:SummonItem(4264);	-- Item: Occultist Skullcap
		e.other:Faction(441,2);		-- Faction: Legion of Cabilis
		e.other:Faction(443,10);	-- Faction: Brood of Kotiz
	elseif item_lib.check_turn_in(e.trade, {item1 = 12853, item2 = 12852, item3 = 4264}) then -- Items: Stem of Candlestick, Foot of Candlestick, occultist skullcap
		e.self:Emote("grabs the candle parts and puts them in an odd pouch, then takes your cap which disintegrates in his palm. He hands you another cap.");
		e.self:Say("Welcome, Revenant " .. e.other:GetName() .. ". You have done well. The Harbinger awaits you. He seeks a [new revenant].");
		e.other:QuestReward(e.self,{exp = 200, gold = 6});
		e.other:SummonItem(4265);	-- Item: Revenant Skullcap
		e.other:Faction(441,2);		-- Faction: Legion of Cabilis
		e.other:Faction(443,10);	-- Faction: Brood of Kotiz
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
