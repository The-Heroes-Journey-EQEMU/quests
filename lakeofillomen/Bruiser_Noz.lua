--Shaman Skull Quest 6

function event_spawn(e)
	e.self:Emote("is a battle-scared lizard with arms the size of tree trunks. He approaches and speaks. You feel the lager-tinged breeze blast your skin. 'Stay out of this, Klok!! I didn't spend 30 seasons in the legion to be pestered by the likes of you!! Here I am, you little croak!! You want my skull? Come and get it!!'");
	make_attackable(e.self, false);
	eq.signal(85140, 50); -- NPC: Klok_Sargin
end

function event_signal(e)
	e.self:Say("Ha!! Who dares to take what is Bruiser's!! I will make swamp mush out of them!!");
	make_attackable(e.self, true);
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade)
end

function make_attackable(mob, attackable)
	mob:SetSpecialAbility(SpecialAbility.immune_melee, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.immune_magic, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.immune_aggro, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.immune_aggro_on, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.no_harm_from_client, attackable and 0 or 1)
end
