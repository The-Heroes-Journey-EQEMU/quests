my $expedition_name = "The Ruins of Ka Vethan";
my $min_players     = 1;
my $max_players     = 72;
my $dz_zone         = "akheva";
my $disable_respawn = "false";

sub EVENT_SAY {
  plugin::OfferStandardInstance($expedition_name, $min_players, $max_players, $dz_zone, $disable_respawn);
}