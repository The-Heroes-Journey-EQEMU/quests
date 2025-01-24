sub EVENT_SAY {
	plugin::HandleTeleporterSay();
}

sub EVENT_ITEM {
	plugin::return_items(\%itemcount);
}

sub EVENT_TICK {
	plugin::HandleTeleporterTick();
}