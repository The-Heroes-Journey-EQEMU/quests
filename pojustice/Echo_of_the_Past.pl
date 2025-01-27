my $expedition_name = "The Plane of Justice";
my $min_players     = 1;
my $max_players     = 72;
my $dz_zone         = "pojustice";
my $disable_respawn = "false";

sub EVENT_SAY {
  plugin::OfferStandardInstance($expedition_name, $min_players, $max_players, $dz_zone, $disable_respawn);
}