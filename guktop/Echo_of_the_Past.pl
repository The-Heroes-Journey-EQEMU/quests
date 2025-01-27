my $expedition_name = "Upper Guk";
my $min_players     = 1;
my $max_players     = 72;
my $dz_zone         = "guktop";
my $disable_respawn = "false";

sub EVENT_SAY {
  plugin::OfferStandardInstance($expedition_name, $min_players, $max_players, $dz_zone, $disable_respawn);
}