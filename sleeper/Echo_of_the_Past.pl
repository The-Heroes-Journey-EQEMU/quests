my $expedition_name = "Sleeper's Tomb";
my $min_players     = 1;
my $max_players     = 72;
my $dz_zone         = "sleeper";
my $disable_respawn = "false";

sub EVENT_SAY {
  plugin::OfferStandardInstance($expedition_name, $min_players, $max_players, $dz_zone, $disable_respawn);
}

sub EVENT_SPAWN() {
  if ($instanceid > 0) {
    $npc->Kill();
  }
}