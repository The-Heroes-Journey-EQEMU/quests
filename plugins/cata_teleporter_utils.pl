sub HandleTeleporterSay {
	my $text = plugin::val('text');
	my $client = plugin::val('client');
	my $npc = plugin::val('npc');

	my $group_flg = quest::get_data($client->AccountID() ."-group-ports-enabled") || "";
	my $eom_link = quest::varlink(46779);

	my $bind_loc = $client->GetBucket("baz_and_back_bind") || 'bazaar';
	my $revind_text = "";

	plugin::AddDefaultAttunement($client);
 
	my ($continent_pattern, $continent_map) = plugin::GetContinentCapturePattern(); 
	my ($waypoint_pattern, $eligible_waypoints) = plugin::GetWaypointCapturePattern(-1, $client);

	if ($text=~/hail/i) {
		my $name_string = $npc->GetCleanName() eq "Tearal" ? "Tearel, the Keeper of the Map" : "Timmy, Son of Tearel, the Keeper of the Other Map";

		my $attune_map_link = quest::silent_saylink("attune the map");
		my $expedition_link = quest::silent_saylink("an expedition");
		my $reagents_link = quest::silent_saylink("special reagents");

		if (!$group_flg) { 
			$group_flg = " However, that magic, like teleporting an entire group, will require [$reagents_link]." ;
		} else { 
			$group_flg = "";
		}
	
		if (!($bind_loc eq $zonesn)) {
			my $attune_link = quest::silent_saylink("attune your Bazaar and Back");
			$rebind_text = " I see that you are not personally attuned to this location, though! Would you like to [$attune_link] ability to return you here?";
		} else {
			$rebind_text = "";
		}

		plugin::NPCTell("Greetings, $name. I am $name_string . I can [$attune_map_link] to any rune circles you have previously discovered. If you are part of 
						[$expedition_link] I can also help you return to the heat of the battle.$group_flg$rebind_text");

		return;
	} elsif ($text =~ /attune your Bazaar and Back/i) {
		plugin::NPCTell("Excellent! You will now return to this vicinity whenever you use your Bazaar and Back ability!");
		$client->SetBucket("baz_and_back_bind", $zonesn);
	} elsif ($text =~ /attune the map/i) {
		# Get eligible continent names
		my @continent_names = GetEligibleContinentNames($client);

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
	} elsif ($text=~/special reagents/i) {
		if ($group_flg) {
			plugin::NPCTell("You already have performed this ritual, and have these abilities available to you.");
		} else {
			my $ritual_link = quest::silent_saylink("perform this ritual");
			plugin::NPCTell("If you can provide me with Five [$eom_link], I will [$ritual_link] for you.");
			plugin::YellowText("Once unlocked, the group transport and instance return abilities will be available to all characters on this account.");
		}
	} elsif ($text=~/perform this ritual/i) {
		if ($group_flg) {
			plugin::NPCTell("You already have performed this ritual, and have these abilities available to you.");
		} else {
			if (plugin::SpendEOM($client, 5)) {
				my $attuned_link = quest::silent_saylink("attuned", 1);
				quest::set_data($client->AccountID() ."-group-ports-enabled", 1);
				plugin::NPCTell("$name, forevermore you and yours can transport your entire group to anywhere you have [$attuned_link].");
			} else {
				plugin::NPCTell("I'm sorry, $name, you do not have enough [$eom_link] available to you right now. When you have more...");
			}
		}
	} elsif ($text=~/an expedition/i || $text=~/instance/i) {
		if ($group_flg) {
			my $dz = $client->GetExpedition();
			if ($dz) {
				my $dz_name = $dz->GetName();
				plugin::NPCTell("I can sense that you are attuned to a particular time and place. I have attuned the map to it!");
				plugin::YellowText("The Magic Map has been attuned to your instance: $dz_name");
				$client->SetEntityVariable("magic_map_attune", 'instance');
			} else {
				plugin::NPCTell("I do not sense any particular expedition affinity with you.");
			}
		} else {
			my $reagents_link = quest::silent_saylink("special reagents");
			plugin::NPCTell("Unfortunately, I will need some [$reagents_link] in order to transport you in this way.");
		}
	} elsif ($text =~ $continent_pattern) {
		my $matched_continent = $1;	# $1 contains the captured match
		
		if (exists $continent_map->{$matched_continent}) {
			my $continent_id = $continent_map->{$matched_continent};
			my %waypoints = plugin::GetWaypoints($continent_id, $client);

			# Collect the long names for the waypoints with quest::saylink
			my @waypoint_links;
			foreach my $key (sort {$a cmp $b} keys %waypoints) {
				if (plugin::is_eligible_for_zone($client, $key, 1) && $key ne $zonesn) {
					my $long_name = $waypoints{$key}->[0];	# Get the long name
					my $short_name = $key;	# The key is the short name
					my $zone_link = quest::silent_saylink($short_name, $long_name);
					push @waypoint_links, "[$zone_link]";	# Create a clickable link
				}
			}

			# Send each waypoint as a separate line
			plugin::NPCTell("$matched_continent... Let's see... I can send you to a number of places there...");
			foreach my $link (@waypoint_links) {
				plugin::PurpleText("---$link");
			}
		}
	} elsif ($text =~ $waypoint_pattern) {
		my $matched_waypoint_key = $1;	# $1 contains the captured waypoint key (shortname), e.g., 'rivervale'

		if ($matched_waypoint_key) {
			# Use the $eligible_waypoints hash to get the full waypoint data
			my $waypoint_name = $eligible_waypoints->{$matched_waypoint_key}->[0];	# Get the long name for the matched waypoint
			if (plugin::is_eligible_for_zone($client, $matched_waypoint_key, 1)) {
				plugin::NPCTell("Perfect. I will attune the map to $waypoint_name, immediately!");
				plugin::YellowText("The Magic Map has been attuned to $waypoint_name!");
				$client->SetEntityVariable("magic_map_attune", $matched_waypoint_key);
			}
		} 
	}
}

sub HandleTeleporterTick {
	return; # Disable this Feature

	my $entity_list = plugin::val('entity_list');
	quest::debug("How did we get here?");
	my @clientlist = $entity_list->GetClientList();
	my $clientcount = @clientlist;

	my $max_idle_seconds = 60 * 15; # Set your max idle threshold here (e.g., 60 seconds)
	my $idle_ticks = $max_idle_seconds / 6;

	my $warning_50_percent = int($idle_ticks * 0.5);
	my $warning_80_percent = int($idle_ticks * 0.8);


	foreach my $client (@clientlist) {
		if (!$client || $client->IsTrader() || $client->GetGM()) {
			next;
		}

		my $last_x = int($client->GetEntityVariable("last_x") || 0);
		my $last_y = int($client->GetEntityVariable("last_y") || 0);
		my $last_h = int($client->GetEntityVariable("last_h") || 0);


		my $cur_x = int($client->GetX());
		my $cur_y = int($client->GetY());
		my $cur_h = int($client->GetHeading());

		if (defined $last_x && defined $last_y && defined $last_h) {
			if ($last_x == $cur_x && $last_y == $cur_y && $last_h == $cur_h) {
				my $idle_counter = $client->GetEntityVariable("idle_counter") // 0;
				$idle_counter++;

				my $idle_seconds = $idle_counter * 6;
				my $idle_minutes = sprintf("%.1f", $idle_seconds / 60);
				my $max_idle_minutes = sprintf("%.1f", $max_idle_seconds / 60);

				if ($idle_counter == $warning_50_percent || $idle_counter == $warning_80_percent) {
					$client->Message(15, "Warning: You have been idle for $idle_minutes minutes. You will be returned to character select in ". sprintf("%.1f", (($max_idle_seconds - $idle_seconds) / 60) ) . " minutes,");
				}

				if ($idle_counter >= $idle_ticks) {
					$client->Kick();
				}

				$client->SetEntityVariable("idle_counter", $idle_counter);
			} else {
				$client->SetEntityVariable("idle_counter", 0);
			}
		}

		$client->SetEntityVariable("last_x", $cur_x);
		$client->SetEntityVariable("last_y", $cur_y);
		$client->SetEntityVariable("last_h", $cur_h);
	}
}

sub HasEligibleWaypoints {
	my ($continent_id, $client) = @_;
	my %waypoints = plugin::GetWaypoints($continent_id, $client);

	foreach my $key (keys %waypoints) {
		if (plugin::is_eligible_for_zone($client, $key, 1) && $key ne $zonesn) {
			return 1;	# Return true if at least one eligible waypoint is found
		}
	}

	return 0;	# Return false if no eligible waypoints are found
}

sub GetEligibleContinentNames {
	my ($client) = @_;
	my @eligible_continent_names;

	foreach my $continent_id (sort { $a <=> $b } plugin::GetContinents($client)) {
		if (HasEligibleWaypoints($continent_id, $client)) {
			my $continent_name = GetContinentName($continent_id);
			push @eligible_continent_names, "[$continent_name]";
		}
	}

	return @eligible_continent_names;
}