-- Skyshrine Velious Armor - Paladin
local quest_helper		= require('velious_quest_helper');
local SKYSHRINE_ARMOR	= quest_helper.SKYSHRINE_ARMOR;

local QUEST_ITEMS = {
	quest_helper:melee_helmet(SKYSHRINE_ARMOR.Plate_Helmet,		31119),	-- Items: Scaled Knight's Helm
	quest_helper:melee_chest(SKYSHRINE_ARMOR.Breastplate,		31120),	-- Items: Scaled Knight's Breastplate
	quest_helper:melee_arms(SKYSHRINE_ARMOR.Plate_Vambraces,	31121),	-- Items: Scaled Knight's Vambraces
	quest_helper:melee_bracer(SKYSHRINE_ARMOR.Plate_Bracer,		31122),	-- Items: Scaled Knight's Bracer
	quest_helper:melee_gloves(SKYSHRINE_ARMOR.Plate_Gauntlets,	31123),	-- Items: Scaled Knight's Gauntlets
	quest_helper:melee_legs(SKYSHRINE_ARMOR.Plate_Greaves,		31124),	-- Items: Scaled Knight's Greaves
	quest_helper:melee_boots(SKYSHRINE_ARMOR.Plate_Boots,		31125)	-- Items: Scaled Knight's Boots
};

function event_say(e)
	if e.other:GetFaction(e.self) == 1 then -- Ally
		if e.message:findi("hail") then
			e.self:Say("I wish to speak only to the knights called paladins. If you are what I seek do you [" .. eq.say_link("i wish to partake of your quests",false,"wish to partake of my quests") .. "]?");
		elseif e.message:findi("i wish to partake of your quests") then
			e.self:Say("Excellent. By serving my cause, you, in turn, will further your own. I require certain components to aid me and if you bring them to me, I shall reward you for your honorable service. You may choose from among these items: a [helm], a [breastplate], [armplates], [bracers], [gauntlets], [greaves], and [boots].");
		elseif e.message:findi("helm") then
			e.self:Say("All I require are an unadorned plate helmet and three pieces of crushed coral. This should be a small task for one such as you. Go now and I shall await your return.");
		elseif e.message:findi("breastplate") then
			e.self:Say("As the resolve of your faith protects you, so shall this breastplate. All that is required are three flawless diamonds and an unadorned breastplate. Do this quickly so that you may return to the field of battle.");
		elseif e.message:findi("armplates") then
			e.self:Say("So, a pair of armplates is what you require? Well, I require unadorned plate vambraces and three flawed emeralds before you may receive it.");
		elseif e.message:findi("bracers") then
			e.self:Say("Bracers for the mighty? Retrieve these components and I shall forge the item for you. Bring me three crushed flame emeralds and an unadorned plate bracer.");
		elseif e.message:findi("gauntlets") then
			e.self:Say("Mighty gauntlets to smite your foes for the glory of the greater good! It is no easy task but I shall require a pair of unadorned plate gauntlets as well as three crushed topaz.");
		elseif e.message:findi("greaves") then
			e.self:Say("Sturdy are the pillars that support the temple. I shall make you just as strong with these leggings. Gather unadorned plate greaves and three flawed sea sapphires.");
		elseif e.message:findi("boots") then
			e.self:Say("A pair of boots you shall have once you have brought me a pair of unadorned plate boots, and three pieces of crushed black marble.");
		end
	else
		e.self:Say("You must prove your dedication to the Claws of Veeshan before I will speak to you.");
	end
end

function event_trade(e)
	quest_helper:quest_turn_in(e, 1, QUEST_ITEMS, quest_helper.skyshrine_armor_success);
end
