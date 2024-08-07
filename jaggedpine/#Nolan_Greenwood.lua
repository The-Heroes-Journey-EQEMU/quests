---- Quest:Jaggedpine Druid Tunic
function event_say(e)
    local fac = e.other:GetFaction(e.self);
	
	if(fac <= 2) then			--requires warmly faction to Residents of Jaggedpine
		if(e.message:findi("hail")) then
			e.self:Emote("gives a gentle nod to " .. e.other:GetName() .. "");
			e.self:Say("Greetings. I am Nolan Greenwood, warder of the Jaggedpine and retainer of our [" .. eq.say_link("ancient ways") .. "]. The recent introduction of outsiders whose faith and loyalties mimic our own toward The Rainkeeper has led to the rebirth of a long lost excitement and use for my talents, thus my presence here today. Usually, I would not be so easily found for when presented with the choice, for I prefer the sanctuary of the open forest to the confining walls of my room here at Fort Jaggedpine.");
		elseif(e.message:findi("ancient ways")) then
			e.self:Say("As with any culture, my friend, there are countless established ways of life, worship, law, and order. It would be impossible for me to explain all of our ancient ways in a single conversation -- and even more impossible would it be for you to understand them. You must experience and [" .. eq.say_link("accept them as your own") .. "] to fully understand.");
		elseif(e.message:findi("accept them")) then
			e.self:Emote("raises a brow and gives a gentle, warm smile to " .. e.other:GetName() .. "'s declaration");
			e.self:Say("I see, and am very pleased to know that your interest has grown and your heart is opened to know the path of The Rainkeeper. As I retain the laws and order of nature that we of the Jaggedpine have sworn ourselves to, I will be more than willing to give you what words I can to guide you toward true discovery of what it means to be of The Rainkeeper's service and pledge. The rest shall be taught through your own experience in these [" .. eq.say_link("trials") .. "].");
		elseif(e.message:findi("trials")) then
			e.self:Say("To show your devotion to the natural world and strengthen your abilities to protect it, you must engage in a symbiotic relationship with nature. As you give your devotion and one day your life to the natural world, it will equally provide the [" .. eq.say_link("tools") .. "] that will aid you to execute the duties and protection you have pledged to uphold.");
		elseif(e.message:findi("tools")) then
			e.self:Say("Sustenance, shelter, and the necessities that we must have to survive are all provided by the world that we must protect. The wilderness will also lend its spiritual force to you, and it is the fullest potential of that spiritual force that I can see you and many other druids have yet to truly harness. Do not think that we reave these things from nature -- for as I said, our relationship must be mutual. If you invest the time and prayer to [" .. eq.say_link("ask of her") .. "], she shall provide the rest of these needs most willingly -- as a mother would her beloved child.");
		elseif(e.message:findi("ask of her")) then
			e.self:Say("These questions are not of the vocal expression, my friend. To request nature's aid, you must go in-search of that aid. In that search, you will provide unto her nothing less than a service equal to what it is you seek. My beloved daughter, Cheyloh, and I shall [" .. eq.say_link("guide me",false,"guide you") .. "] through this quest.");
		elseif(e.message:findi("guide me")) then
			e.self:Say("I will give you the guidance of words and my knowledge of the details pertaining to your tasks. My experience and talents in the ways of making proper and the most efficient use of that which nature will grant you in gratitude of your service to her shall be at your disposal as necessary and appropriate. The first of your tasks will be to acquire and return to me two items -- [" .. eq.say_link("Silver Griffon Feathers") .. "] and a [" .. eq.say_link("Jade Studded Rawhide Tunic") .. "].");
		elseif(e.message:findi("Silver Griffon Feathers")) then
			e.self:Say("There is a beast known as the Silver Griffon whom lurks in the darkest of shadows cast by Luclin's light. Although this creature was born of those that are natural, the Silver Griffon himself is not. Once a great and powerful creature of the Karana Plains, the beast known as the Silver Griffon was killed and its spirit corrupted by the priests of The Plaguebringer when their scourge was brought upon those plains not too long past. Put this creature to rest and from its ethereal wings, bring me its silver feathers.");
		elseif(e.message:findi("jade studded")) then
			e.self:Say("As the Qeynos faithful of The Rainkeeper have come to us, we have sent some of our most adept brothers and sisters to them as an act of good faith in hope that our ways would be exchanged. One such adept is Jhaya Wyndrunner. She, like myself, is a keeper of our ways -- a former apprentice of mine, in fact, and a master in the arts of weaving. Speak to her about the Jade Studded Rawhide Tunic and she will give you further guidance on how you may acquire it.");
		end
	elseif(e.message:findi("hail")) then
		e.self:Say("You need to prove your dedication to our cause before I can discuss such matters with you.");
	end
end

function event_trade(e)
    local item_lib = require("items");
    local fac = e.other:GetFaction(e.self);
	
	if(fac <= 2) then			--requires warmly faction to Residents of Jaggedpine	
		if(item_lib.check_turn_in(e.trade, {item1 = 8761, item2 = 8760})) then -- Silver Griffon Feathers & Jade Studded Rawhide Tunic
			e.self:Say("You have done well, " .. e.other:GetName() .. ". I am impressed and most pleased to know that you are adapting and accepting our ways so easily. Take this and may it protect you in these troubling times.");
			e.other:QuestReward(e.self,0,0,0,0,8400,5000); -- Tunic of the Pine
		end
	end
    item_lib.return_items(e.self, e.other, e.trade)
end