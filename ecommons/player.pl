sub EVENT_CLICKDOOR {
    if ($doorid == 146) { # Magic Map
        my $attuned_shortname   = $client->GetEntityVariable("magic_map_attune");
        my $waypoint_data = plugin::GetWaypoint($attuned_shortname, $client);
        if ($waypoint_data || ($attuned_shortname eq 'instance' && $client->GetExpedition())) {
            my $long_name = $waypoint_data->[0];  # Access the long name (first element in the array)
            my $continent = $waypoint_data->[1];  # Access the continent ID
            my $x = $waypoint_data->[2];          # X coordinate
            my $y = $waypoint_data->[3];          # Y coordinate
            my $z = $waypoint_data->[4];          # Z coordinate
            my $heading = $waypoint_data->[5];    # Heading

            if ($attuned_shortname eq 'instance') {
                $dz = $client->GetExpedition();
                $long_name = $dz->GetName();
            }

            my $popup_title = "Travel with the Magic Map";
            my $popup_text  = "Would you like to travel to $long_name?";
            my $popup_self  = 1460;
            my $popup_group = 1461;
            my $popup_btns  = 2;
            my $popup_btn_1 = "Self";
            my $popup_btn_2 = "Group";
            my $popup_dur   = 30;

            $client->Popup2($popup_title, $popup_text, $popup_self, $popup_group, $popup_btns, $popup_dur, $popup_btn_1, $popup_btn_2);
        } else {
            plugin::YellowText("The Magic Map has not been attuned to you. Talk to Tearel to continue.");
        }
    }    
}

sub EVENT_POPUPRESPONSE {
    if ($popupid == 1460 || $popupid == 1461) {
        my $group_flg           = quest::get_data($client->AccountID() ."-group-ports-enabled") || "";
        my $attuned_shortname   = $client->GetEntityVariable("magic_map_attune");
        my $waypoint_data       = plugin::GetWaypoint($attuned_shortname, $client);
        my $group               = $client->GetGroup();
        my $dz                  = $client->GetExpedition();

        # Group option locked behind EoM
        if ($popupid == 1461 && !$group_flg) {
            plugin::YellowText("Your account does not have the ability to transport your group this way unlocked.");
            return;
        }

        if ($attuned_shortname eq 'instance') {
            if (!$group_flg) {
                plugin::YellowText("Your account does not have the ability to transport your group this way unlocked.");
                return;
            }

            if (!$dz) {
                plugin::YellowText("You are not a member of an expedition.");
                return;
            }

            if (!plugin::is_eligible_for_zone($client, quest::GetZoneShortName($dz->GetZoneID()))) {
                plugin::YellowText("You are not eligible to enter that zone.");
                return;
            }
            
            if ($popupid == 1461 && $group) {
                my $expedition_members_ref = $dz->GetMembers();
                my %expedition_members = %{$expedition_members_ref};
                for (my $count = 0; $count < $group->GroupCount(); $count++) {
                    my $player = $group->GetMember($count);
                    if ($player) {
                        # Check if the player is a member of the expedition
                        # TODO - Collect all failure modes and output at once instead of breaking on first one
                        my $player_name = $player->GetName();
                        if (!exists $expedition_members{$player_name}) {
                            plugin::YellowText("$player_name is not a member of this expedition.");
                            return;
                        }

                        if (!plugin::is_eligible_for_zone($player, quest::GetZoneShortName($dz->GetZoneID()))) {
                            plugin::YellowText("$player_name is not eligible to enter that zone.");
                            return;
                        }
                    }
                }

                for (my $count = 0; $count < $group->GroupCount(); $count++) {
                    my $player = $group->GetMember($count);
                    if ($player) {
                        $player->SpellEffect(218,1);
                        $player->MovePCDynamicZone($dz->GetZoneID());
                    }
                }
            }

            $client->SpellEffect(218,1);
            $client->MovePCDynamicZone($dz->GetZoneID());
        } else {
            # Not moving to a DZ
            if (!$waypoint_data) {
                plugin::YellowText("You have selected an invalid destination.");
                return;
            }

            my $long_name = $waypoint_data->[0];  # Access the long name (first element in the array)
            my $continent = $waypoint_data->[1];  # Access the continent ID
            my $x         = $waypoint_data->[2];  # X coordinate
            my $y         = $waypoint_data->[3];  # Y coordinate
            my $z         = $waypoint_data->[4];  # Z coordinate
            my $heading   = $waypoint_data->[5];  # Heading

            if (!plugin::is_eligible_for_zone($client, $attuned_shortname)) {
                plugin::YellowText("You are not eligible to enter that zone.");
                return;
            }

            if ($popupid == 1461 && $group) {
                for (my $count = 0; $count < $group->GroupCount(); $count++) {
                    my $player = $group->GetMember($count);
                    if ($player) {
                        # TODO - Collect all failure modes and output at once instead of breaking on first one
                        my $player_name = $player->GetName();
                        if (!plugin::is_eligible_for_zone($player, $attuned_shortname)) {
                            plugin::YellowText("$player_name is not eligible to enter that zone.");
                            return;
                        }
                    }
                }

                for (my $count = 0; $count < $group->GroupCount(); $count++) {
                    my $player = $group->GetMember($count);
                    if ($player) {
                        $player->SpellEffect(218,1);
                        $player->MovePC(quest::GetZoneID($attuned_shortname), $x, $y, $z, $heading);
                    }
                }
            }

            $client->SpellEffect(218,1);
            $client->MovePC(quest::GetZoneID($attuned_shortname), $x, $y, $z, $heading);
        }
    }
}