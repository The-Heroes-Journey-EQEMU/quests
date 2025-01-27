my $expedition_name = "Tower of Frozen Shadow";
my $min_players     = 1;
my $max_players     = 72;
my $dz_zone         = "frozenshadow";
my $disable_respawn = "false";

sub EVENT_SAY {
  plugin::OfferStandardInstance($expedition_name, $min_players, $max_players, $dz_zone, $disable_respawn);
}