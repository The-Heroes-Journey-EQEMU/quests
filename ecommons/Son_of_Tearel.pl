sub EVENT_SAY {
  my $group_flg       = quest::get_data($client->AccountID() ."-group-ports-enabled") || "";  
  my $eom_link        = quest::varlink(46779);

  my $bind_loc        = $client->GetBucket("baz_and_back_bind") || 'bazaar';
  my $revind_text     = "";

  plugin::AddDefaultAttunement($client);

  if ($text=~/hail/i) {        
    if (!$group_flg) { 
      $group_flg = " However, that magic, like teleporting an entire group, will require [special reagents]." 
    } else { 
      $group_flg = "" 
    };
    
    if (!($bind_loc eq $zonesn)) {
      $rebind_text = " I see that you are not personally attuned to this location, though! Would you like to [".quest::saylink("attune your Bazaar and Back", 1)."] ability to return you here?";
    } else {
      $rebind_text = "";
    }

    plugin::NPCTell("Greetings, $name. I am Timmy, Son of Tearel, the Keeper of the Other Map. I can [attune the map] to any rune circles you have previously discovered. If you are part of 
                    [an expedition] I can also help you return to the heat of the battle.". $group_flg . $rebind_text);

    return;
  }

  if ($text =~ /attune your Bazaar and Back/i) {
    plugin::NPCTell("Excellent! You will now return to this vicinity whenever you use your Bazaar and Back ability!");
    $client->SetBucket("baz_and_back_bind", $zonesn);
    return;
  }

  if ($text =~ /attune the map/i) {
      # Get eligible continent names
      my @continent_names = get_eligible_continent_names($client);

      # Formulate a grammatically correct list
      my $location_append = "";
      if (@continent_names == 1) {
          $location_append = $continent_names[0];
      } elsif (@continent_names == 2) {
          $location_append = $continent_names[0] . " or " . $continent_names[1];
      } elsif (@continent_names > 2) {
          $location_append = join(', ', @continent_names[0..$#continent_names-1]) . ", or " . $continent_names[-1];
      }

      # NPC dialogue response
      plugin::NPCTell("If you look closely, you'll see circles of rune-stones scattered throughout Norrath, and beyond. These serve as anchors for travel, and the map can be attuned to any of them. 
                      Let's narrow down where you want to go? $location_append?");

      return;
  }

  if ($text=~/special reagents/i) {
    if ($group_flg) {
      plugin::NPCTell("You already have performed this ritual, and have these abilities available to you.");
    } else {
      plugin::NPCTell("If you can provide me with Five [".$eom_link."], I will [perform this ritual] for you.");
      plugin::YellowText("Once unlocked, the group transport and instance return abilities will be available to all characters on this account.");
    }
    return;
  }

  if ($text=~/perform this ritual/i) {
    if ($group_flg) {
      plugin::NPCTell("You already have performed this ritual, and have these abilities available to you.");
    } else {
      if (plugin::SpendEOM($client, 5)) {
        quest::set_data($client->AccountID() ."-group-ports-enabled", 1);
        plugin::NPCTell("$name, forevermore you and yours can transport your entire group to anywhere you have [attuned].");
      } else {
        plugin::NPCTell("I'm sorry, $name, you do not have enough [".$eom_link."] available to you right now. When you have more...");
      }
    }
  }

  if ($text=~/an expedition/i || $text=~/instance/i) {
    if ($group_flg) {
      my $dz = $client->GetExpedition();
      if ($dz) {
        plugin::NPCTell("I can sense that you are attuned to a particular time and place. I have attuned the map to it!");
        plugin::YellowText("The Magic Map has been attuned to your instance: ". $dz->GetName());
        $client->SetEntityVariable("magic_map_attune", 'instance');
      } else {
        plugin::NPCTell("I do not sense any particular expedition affinity with you.");
      }
    } else {
      plugin::NPCTell("Unfortunately, I will need some [special reagents] in order to transport you in this way.");
    }
  }
 
  my ($continent_pattern, $continent_map) = plugin::GetContinentCapturePattern(); 

  if ($text =~ $continent_pattern) {
      my $matched_continent = $1;  # $1 contains the captured match
        
      if (exists $continent_map->{$matched_continent}) {
          my $continent_id = $continent_map->{$matched_continent};
          my %waypoints = plugin::GetWaypoints($continent_id, $client);

          # Collect the long names for the waypoints with quest::saylink
          my @waypoint_links;
          foreach my $key (sort {$a cmp $b} keys %waypoints) {
              if (plugin::is_eligible_for_zone($client, $key, 1) && $key ne $zonesn) {
                my $long_name = $waypoints{$key}->[0];  # Get the long name
                my $short_name = $key;  # The key is the short name
                push @waypoint_links, "[".quest::saylink($short_name, 0, $long_name)."]";  # Create a clickable link
              }
          }

          # Send each waypoint as a separate line
          plugin::NPCTell("$matched_continent... Let's see... I can send you to a number of places there...");
          foreach my $link (@waypoint_links) {
              plugin::PurpleText("---". $link);
          }
      }
  }

  my ($waypoint_pattern, $eligible_waypoints) = plugin::GetWaypointCapturePattern(-1, $client);
  if ($text =~ $waypoint_pattern) {
      my $matched_waypoint_key = $1;  # $1 contains the captured waypoint key (shortname), e.g., 'rivervale'

      if ($matched_waypoint_key) {
        # Use the $eligible_waypoints hash to get the full waypoint data
        my $waypoint_name = $eligible_waypoints->{$matched_waypoint_key}->[0];  # Get the long name for the matched waypoint
        if (plugin::is_eligible_for_zone($client, $matched_waypoint_key, 1)) {
            plugin::NPCTell("Perfect. I will attune the map to $waypoint_name, immediately!");
            plugin::YellowText("The Magic Map has been attuned to $waypoint_name!");
            $client->SetEntityVariable("magic_map_attune", $matched_waypoint_key);
          }
      } 
  }
}

sub has_eligible_waypoints {
    my ($continent_id, $client) = @_;
    my %waypoints = plugin::GetWaypoints($continent_id, $client);

    foreach my $key (keys %waypoints) {
        if (plugin::is_eligible_for_zone($client, $key, 1) && $key ne $zonesn) {
            return 1;  # Return true if at least one eligible waypoint is found
        }
    }

    return 0;  # Return false if no eligible waypoints are found
}

sub get_eligible_continent_names {
    my ($client) = @_;
    my @eligible_continent_names;

    foreach my $continent_id (sort { $a <=> $b } plugin::GetContinents($client)) {
        if (has_eligible_waypoints($continent_id, $client)) {
            push @eligible_continent_names, "[" . plugin::GetContinentName($continent_id) . "]";
        }
    }

    return @eligible_continent_names;
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
