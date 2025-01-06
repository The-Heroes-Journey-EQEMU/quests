function event_say(e)
	local qglobals = eq.get_qglobals(e.self,e.other);

	if e.message:findi("hail") then
		e.self:Say("Hmm... is there something I can help you with? I am far too [busy] to listen to your problems though so I take that back.");
	elseif e.message:findi("busy") then
		e.self:Say("It is none of your concern unless you are truly gifted in the dark art of necromancy. If so, you will have some form of proof to show me.");
	elseif e.message:findi("wish to hear") and tonumber(qglobals.necskullquest) == 9 then
		e.self:Say("I have recently found a volume on summoning a great minion from the Great Library of Charasis but I can't find all of the needed items. Being as I am one of the [sages of Cabilis], I request you go and [collect these items] for me.")
	elseif e.message:findi("sages of Cabilis") and tonumber(qglobals.necskullquest) == 9 then
		e.self:Say("Ah, they are all but a memory now. We used to be welcome within the city of Cabilis but our quest for greater power led to our exile. No matter now, go retrieve the items and you will be one of the chosen to walk beside greatness")
	elseif e.message:findi("collect these items") and tonumber(qglobals.necskullquest) == 9 then
		e.self:Say("As you should broodling. The the first is a brittle bone, which was once used for reincarnations. The second item is a poisoned soul, this is from an iksar that died a cruel and twisted death. The death was so awful, it's spirit still roams around angry. The third you will find in the burning heat. The final item is a gem of reflection. I have yet to find someone that knows how to create one. Even those fools in Cabilis probably wouldn't know. Maybe you can locate that one yourself. Bring all of these items back to me and I shall do the rest.")
		e.other:SummonItem(48041); -- Item: Ixpacan's Tome
	end
end

function event_trade(e)
	local item_lib = require("items");
	local qglobals = eq.get_qglobals(e.self,e.other);

	if item_lib.check_turn_in(e.trade, {item1 = 4267}) then -- Item: Necromancer Skullcap
		eq.set_global("necskullquest", "9", 5,"F"); -- Completed Skullcap Quest 9.1
		e.self:Say("Oh, I see you are truly gifted in the dark arts. Well I will explain my dilemma to you now if you [wish to hear].");
		e.other:SummonItem(4267); -- Item: Necromancer Skullcap
	elseif tonumber(qglobals.necskullquest) == 9 and item_lib.check_turn_in(e.trade, {item1 = 48042}) then -- Item: Ixpacan's Tome (Tome-Full)
		e.self:Say("Wonderful! You have brought all of the items I have asked for. Your future seems very bright with the rest of the Sages. Step back now as I conjure the child of Charasis.");
		eq.local_emote({e.self:GetX(), e.self:GetY(), e.self:GetZ()}, MT.LightGray, 150, "As Ixpacan starts his incantations, you can see an image begin to appear from the shadows.");
		e.self:Say("It's out of my control! Defeat it before it destroys us both!");
		eq.spawn2(93189,0,0,e.self:GetX() + 5,e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- NPC: child_of_Charasis
	elseif tonumber(qglobals.necskullquest) == 9 and item_lib.check_turn_in(e.trade, {item1 = 48044}) then -- Item: Child of Charasis Remains
		e.self:Say("I don't have the power to process these remains, aid me with your Necromancer Skullcap and provide me the remains and cap!")
		e.other:SummonItem(48044);	-- Item: Child of Charasis Remains
	elseif tonumber(qglobals.necskullquest) == 9 and item_lib.check_turn_in(e.trade, {item1 = 48044, item2 = 4267}) then -- Items: Child of Charasis Remains, Necromancer Skullcap
		e.self:Say("I see now that I lack the skill necessary to control the Dark Arts. Maybe it would be wiser to allow another such as yourself to continue forward. Please accept this token as a reward in your mastering of the Dark Arts.");
		eq.delete_global("necskullquest");	-- Removed 8th cap and global, must do quest again from cap 1
		e.other:SummonItem(48043);			-- Item: Demi Lich Skullcap
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
