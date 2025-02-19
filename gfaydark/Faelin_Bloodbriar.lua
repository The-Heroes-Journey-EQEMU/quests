function event_spawn(e)
	eq.set_timer("depop",20 * 60 * 1000);
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop_with_timer();
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 20472}) then -- Item: Worn Note
		e.self:Emote("reads the note carefully and growls to herself. 'Bad news, eh? Take this ring. There is one elf, dark elf even, whom we must go to in order to gather insight into Innoruuk's plans. Giz X'Tin, he goes by most commonly. Kithicor seems to be his favorite haunt and most likely you will find him there. Don't ask how I know him. Just take the ring as my sign to him and he will speak to you. We don't need to speak again, so don't seek me out. Just go to Telin. I must leave to investigate these events.'");
		e.other:SummonItem(20446); -- Item: Faelin`s Ring
		e.other:Ding();
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
