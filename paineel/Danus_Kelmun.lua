function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Yes. yes.  Scrolls I have. scrolls you need.  Make up your mind quickly.  I don't have all day to stand here talking to you.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
