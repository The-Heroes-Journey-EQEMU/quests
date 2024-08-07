-- Researcher Alvarik for High Level Research quest in Gunthak

-- helper functions for say events
function liar(speaker)
    speaker:Say("Do you take me for a fool? It is obvious that you are not what you state. Begone from my sight, your false statements disgust me and insult the realms of the arcane.");
end

function newbie(speaker)
    speaker:Say("You seem to be keeping up on your studies. Without true knowledge of research, the original research notes will be too complicated for you to understand. Please come back whne you are more knowledgeable of these things.");
end

-- say block
function event_say(e)
    if(e.message:findi("Hail")) then
        e.self:Say("Hello there. Are you too a student of the [" .. eq.say_link("I am a student of the arcane.", false, "arcane") .. "]");

    elseif(e.message:findi("arcane")) then
        e.self:Say("Excellent. I hold myself as a master of researching the arcane. Even though I study mostly in the art of wizardry, I still carry tomes of the other realms. If you are a master of research and would like to borrow a copy of the research tome, let me know what school of magic you belong to and I may be able to help you out. I also carry with me hand copied works of the masters. If you like you can buy one from me for a small fee.");

    elseif(e.message:findi("Enchanter")) then
        if(e.other:HasClass(Class.ENCHANTER)) then -- Enchanter
            if (e.other:GetSkill(58) > 100) then 
                e.self:Say("So you fancy yourself an enchanter? I dabble a bit in it myself, though I am more interested in the art of explosions! Nevertheless, here is the Phantasmist's Tome. Good luck to you in your studies!");
                e.other:SummonItem(17652); -- Phantasmal Tome
            else
                newbie(e.self);
            end
        else
            liar(e.self);
        end

    elseif(e.message:findi("Wizard")) then
        if(e.other:HasClass(Class.WIZARD)) then -- Wizard
            if(e.other:GetSkill(58) > 100) then 
                e.self:Say("So you too study wizardry! Isn't it the most fascinating of the four realms of magic? Well I won't keep you, here is the Sorcerer's Lexicon. Good luck to you in your studies.");
                e.other:SummonItem(17655); -- Sorcerer's Lexicon
            else
                newbie(e.self);
            end
        else
            liar(e.self);
        end

    elseif(e.message:findi("Magician")) then
        if(e.other:HasClass(Class.MAGICIAN)) then -- Magician
            if(e.other:GetSkill(58) > 100) then 
                e.self:Say("So you too study summoning! Isn't it the most fascinating of the four realms of magic? Well I won't keep you, here is the Arch Magus Grimoire. Good luck to you in your studies.");
                e.other:SummonItem(17653); -- Arch Magus Grimoire
            else
                newbie(e.self);
            end
        else
            liar(e.self);
        end
    
    elseif(e.message:findi("Necromancer")) then
        if(e.other:HasClass(Class.NECROMANCER)) then -- Necromancer
            if(e.other:GetSkill(58) > 100) then 
                e.self:Say("So you study necromancy! Isn't it the most fascinating of the four realms of magic? Well I won't keep you, here is the Warlock's Book of Binding. Good luck to you in your studies.");
                e.other:SummonItem(17654); -- Warlock's Book of Binding
            else
                newbie(e.self);
            end
        else
            liar(e.self);
        end
    end
end

-- returns items
function event_trade(e)
    local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
