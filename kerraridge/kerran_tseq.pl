sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Errr. You smell funny. You bring us [toy]?");
	}
	if ($text=~/toy/i) {
		quest::say("You go, bring us gnome toy. You not come back or we eat you and then you die like short one. Gnome toy! You bring. You good person.");
	}
}

sub EVENT_ITEM {
	#:: Match a 6344 - Gnome Tinkered Toy
	if (plugin::check_handin(\%itemcount, 6344 => 1)) {
		quest::say("Rreeee! Great toy. Shiny. We not need this old toy anymore. You take. Now go way, this our toy, we play.");
		#:: Give a 13748 - Kerran Toy
		quest::summonitem(113748);
		quest::faction( 382, 20);	# + Kerra Isle
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
