function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade);
	item_lib.return_items(e.self, e.other, e.trade);
end