-- Osborne for Red drogmor sellback in Gunthak

-- say block
function event_say(e)
    if(e.message:findi("Hail")) then
        e.self:Emote("'s eyes dart around the lighthouse crazily. 'WHAT! I didn't do anything, leave me alone! Oh . . . You're here about a drogmor . . . very sorry I didn't realize. The red ones are very . . . energetic? But I've been trained to handle them. If you've got a wild one you want to get rid of, show me your drum and I'll see what I can do with it.'");
	end
end

--trade block
function event_trade(e)
    local item_lib = require("items");
    
	if(item_lib.check_turn_in(e.trade, {item1 = 59515})) then -- Small Red Drum
		e.other:SummonItem(21820); -- Bag of Platinum Pieces
	elseif(item_lib.check_turn_in(e.trade, {item1 = 59516})) then -- Red Drum
		e.other:SummonItem(21821); -- Heavy Bag of Platinum
	elseif(item_lib.check_turn_in(e.trade, {item1 = 59517})) then -- Large Red Drum
		e.other:SummonItem(21822); -- Big Bag of Platinum
	elseif(item_lib.check_turn_in(e.trade, {item1 = 59518})) then -- Giant Red Drum
		e.other:SummonItem(21823); -- Huge Bag of Platinum
    end
    
	item_lib.return_items(e.self, e.other, e.trade)
end
