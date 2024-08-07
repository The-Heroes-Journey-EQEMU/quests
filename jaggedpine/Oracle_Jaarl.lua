---- Quest:Paying Oracle Jaarl Respect
function event_say(e)
	local fac = e.other:GetFaction(e.self);
	
    if(e.message:findi("hail")) then
        e.self:Emote("shakes his body and his countless necklaces cause a loud rattle to echo off the stone walls. 'Hello Frostpipes. Have you come to [" .. eq.say_link("worship") .. "] or have you just come for a visit to view our wonderful architecture and to [" .. eq.say_link("pay your respects") .. "].");
    elseif(e.message:findi("worship")) then
        e.self:Say("Very well. You worship quietly then. May Brell Serilis bless you.");
    elseif(e.message:findi("respects")) then
        e.self:Say("You have, well then! You can pay your respects by bringing me a [" .. eq.say_link("present") .. "].");
    elseif(e.message:findi("present")) then
        e.self:Say("I like necklaces. I wear necklaces made from every kind of beast. The power of the beast is contained within each necklace. The more necklaces I wear, the greater my power! Bring me a Bear Fang Necklace, a Wolf Fang Necklace and a Panther Fang Necklace. This will show your devotion to the temple. Then perhaps I can do you a [" .. eq.say_link("favor") .. "]");
    elseif(e.message:findi("favor")) then
        if(fac <= 4) then
            e.self:Say("I see that you truly respect our temple and more importantly, myself. Since I have great power and you have given me many gifts, I am willing to give you a gift if you are skilled in the ways of the [" .. eq.say_link("mystic") .. "] or the [" .. eq.say_link("heretic") .. "].");
        else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
    elseif(e.message:findi("heretic")) then
		if(fac <= 4) then
			e.self:Say("I can make a weapon for you, one that you may use to curse your enemies with terrible illness. I require several items. The shaft of the weapon will be made from a Treant Finger. I shall cover the shaft in Griffon Down and affix a Griffon Skull to the top. Finally, I shall need a Diseased Bear Liver with which to imbue the staff with its terrible magic.");
		else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
	elseif(e.message:findi("mystic")) then
		if(fac <= 4) then
			e.self:Say("I can make a weapon for you, one that you may use to curse your enemies with terrible illness. I require several items. The shaft of the weapon will be made from a Treant Finger. I shall cover the shaft in Griffon Down and affix a Griffon Skull to the top. Finally, I shall need a Diseased Bear Liver with which to imbue the staff with its terrible magic.");
		else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
    elseif(e.message:findi("liver")) then
		if(fac <= 4) then
			e.self:Say("The best person to talk to about that would be that human. I believe he calls himself Farkus Grime. He passes through here now and then and he seems to be fascinated with disease. Perhaps he could help you with that.");
		else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
    elseif(e.message:findi("down")) then
		if(fac <= 4) then
			e.self:Say("I imagine you could find one of those from a Griffon.");
		else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
    elseif(e.message:findi("skull")) then
		if(fac <= 4) then
			e.self:Say("I imagine you could find one of those from a Griffon.");
		else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
    elseif(e.message:findi("finger")) then
		if(fac <= 4) then
			e.self:Say("I doubt a treant would willingly hand over his finger. Remember, the older the treant the stronger the shaft of the weapon will be."); -- Possible continuance of the quest, but unknown.
		else
           dialogue_reject(e.self);		--NPC will not advance quest without proper faction
        end
	end
end

function event_trade(e)
    local item_lib = require("items");
	local fac = e.other:GetFaction(e.self);
	
    if((fac <= 4) and (item_lib.check_turn_in(e.trade, {item1 = 8265, item2 = 8266, item3 = 8267, item4 = 8268}))) then -- Diseased Bear Liver, Griffon Down, Griffon Skull & Treant Finger
        e.self:Say("Grr, Bark. Here is your item");
        e.other:QuestReward(e.self,0,0,0,0,8071,1000); -- Rod of Ulceration
    elseif(item_lib.check_turn_in(e.trade, {item1 = 8258,item2 = 8261,item3 = 8257})) then -- Wolf Fang Necklace, Bear Fang Necklace, Panther Fang Necklace
        e.self:Emote("puts the necklaces around his neck as his body shakes, causing the various bits and pieces of bone and tooth to clatter loudly. 'Ah yes! I feel the power flowing through me, I am ever closer to the spirit world! I thank you for your devotion to the temple!'");
        e.other:Faction(6,100); -- Anchorites of Brell Serilis
        e.other:QuestReward(e.self,0,0,0,0,0,0);
    end
    item_lib.return_items(e.self, e.other, e.trade)
end

function dialogue_reject(npc)
	local phrase = math.random(1,4);
	if (phrase == 1) then
		npc:Say("I wonder how much I could get for the tongue of a blithering fool?  Leave before I decide to find out for myself.");
	elseif (phrase == 2) then
		npc:Say("Oh look, a talking lump of refuse. How novel!");
	elseif (phrase == 3) then
		npc:Say("Is that your BREATH , or did something die in here? Now go away!");
	elseif (phrase == 4) then
		npc:Say("I didn't know Slime could speak common.  Go back to the sewer before I lose my temper.");
	end
end