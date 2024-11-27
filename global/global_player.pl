sub EVENT_SIGNAL {
    # Signals;
    # 666 = EoM Dead Drop
    # 100 = Title Flags

    if ($signal == 666) {
        plugin::UpdateEoMAward($client);
        return;
    }

    if ($signal == 100) {
        my $semaphore_title = $client->GetBucket('flag-semaphore');
        if ($semaphore_title) {
            plugin::AddTitleFlag($semaphore_title, $client);
            $client->DeleteBucket('flag-semaphore');
        }
        plugin::EnableTitles($client);
    } 
}

#trivial change to test deploy

sub EVENT_ENTERZONE {
	plugin::CommonCharacterUpdate($client);

	if (!plugin::is_eligible_for_zone($client, $zonesn)) {
		$client->Message(4, "Your vision blurs. You lose conciousness and wake up in a familiar place.");
		$client->MovePC(151, 185, -835, 4, 390); # Bazaar Safe Location.
    }

    # Only THJ Stuff after this point
    if (!plugin::IsTHJ()) {
        return;
    }

    if (!$client->IsTaskCompleted(3) && !$client->IsTaskActive(3)) {
        $client->AssignTask(3);
    } elsif ($client->IsTaskCompleted(3) && (!$client->IsTaskCompleted(4) && !$client->IsTaskActive(4))) {
        $client->AssignTask(4);
    }

    my $entity_list = plugin::val('$entity_list');
    my @npcs = $entity_list->GetNPCList();
    if (plugin::IsTHJ() && $instanceid) {
        foreach my $npc (@npcs) {
            my $expedition = quest::get_expedition();
            if ($expedition) {
                plugin::ScaleInstanceNPC($npc, $expedition->GetMemberCount());
            }
        }
    }
}

sub EVENT_EQUIP_ITEM_CLIENT {
    if ($slot_id == 21) {
        # Simple Ring of the Hero, for Tutorial Quest 2
        if ($client->IsTaskActivityActive(4, 0) && $item_id == 150000) {
            $client->UpdateTaskActivity(4, 0, 1);
            return;
        }
        if ($client->IsTaskActivityActive(4, 1) && $item_id == 1150000) {
            $client->UpdateTaskActivity(4, 01, 1);
            return;
        }
        if ($client->IsTaskActivityActive(4, 2) && $item_id == 2150000) {
            $client->UpdateTaskActivity(4, 2, 1);
            return;
        }
        if ($item_id == 2150000) {
            plugin::dispatch_popup("symp_tutorial");
        } {
            plugin::dispatch_popup("power_source");
        }
    }

    symp_proc_tutorial_helper($item_id, $client);
}

sub EVENT_CONNECT {
    if (plugin::GetSoulmark($client)) {
        plugin::DisplayWarning($client);
    }
   
    plugin::CommonCharacterUpdate($client); 

    if (!$client->GetBucket("First-Login")) {
        $client->SetBucket("First-Login", 1);
		$client->SummonItem(18471); #A Faded Writ
        $client->Message(263, "You find a small note in your pocket.");
		$client->SetBucket('FirstLogin', 1);

        my $name = $client->GetCleanName();
        my $full_class_name = plugin::GetPrettyClassString($client);

        plugin::WorldAnnounce("$name ($full_class_name) has logged in for the first time.");        
        plugin::AwardSeasonalItems($client);
    }

    if (plugin::MultiClassingEnabled()) {
        if (!$client->IsTaskCompleted(3) && !$client->IsTaskActive(3)) {
            $client->AssignTask(3);
        } elsif ($client->IsTaskCompleted(3) && (!$client->IsTaskCompleted(4) && !$client->IsTaskActive(4))) {
            $client->AssignTask(4);
        }

        plugin::dispatch_popup("welcome");
    }

    if (!plugin::is_eligible_for_zone($client, $zonesn)) {
		$client->Message(4, "Your vision blurs. You lose conciousness and wake up in a familiar place.");
		$client->MovePC(151, 185, -835, 4, 390); # Bazaar Safe Location.
	}
}

sub EVENT_POPUPRESPONSE {
    plugin::check_tutorial_popup_response($popupid, $client);  
       
    if ($popupid == 58240) {        
        my $x = $client->GetEntityVariable("bazaar_x") + int(rand(11)) - 5;
        my $y = $client->GetEntityVariable("bazaar_y") + int(rand(11)) - 5;
        my $z = $client->GetEntityVariable("bazaar_z");
        my $h = $client->GetEntityVariable("bazaar_h");
        my $bind_loc = $client->GetEntityVariable("bazaar_zone");

        $client->SetBucket("Return-X", $client->GetX());
        $client->SetBucket("Return-Y", $client->GetY());
        $client->SetBucket("Return-Z", $client->GetZ());
        $client->SetBucket("Return-H", $client->GetHeading());
        $client->SetBucket("Return-Zone", $zoneid);
        $client->SetBucket("Return-Instance", $instanceid);

        $client->SpellEffect(218,1);
        $client->MovePC($bind_loc, $x, $y, $z, rand(512));
    }
}

sub EVENT_TASK_COMPLETE {
    if ($task_id == 3 && !$client->IsTaskCompleted(4)) {
        $client->AssignTask(4);
    }
}

sub EVENT_LEVEL_UP {
    plugin::CommonCharacterUpdate($client);

    my $new_level = $client->GetLevel();
    if (($new_level % 10 == 0) || $new_level == 5 || $new_level == $client->GetBucket("CharMaxLevel")) {
        my $name = $client->GetCleanName();
        my $full_class_name = plugin::GetPrettyClassString($client);

        my $capped = ($new_level == ($client->GetBucket("CharMaxLevel") || 0) ? " (Level Cap)" : "");

        plugin::WorldAnnounce("$name ($full_class_name) has reached Level $new_level$capped.");
    }
}

sub EVENT_CLICKDOOR {
	my $target_zone = plugin::get_target_door_zone($zonesn, $doorid, $version);

    if (!plugin::is_eligible_for_zone($client, $target_zone, 1)) {		
		return 1;
    }
}

sub EVENT_WARP {
    my $name = $client->GetCleanName();
    my $current_x = $client->GetX();
    my $current_y = $client->GetY();
    my $current_z = $client->GetZ();
    my $distance = sqrt(($current_x - $from_x) ** 2 + ($current_y - $from_y) ** 2 + ($current_z - $from_z) ** 2);
    my $account_key = $client->AccountID() . "-WarpCount";
    my $soulmark = quest::get_data($client->AccountID() . "-CheaterFlag");

    my @warp_events = plugin::DeserializeList(quest::get_data($account_key));

    # Enqueue the current warp event with timestamp
    push @warp_events, time();

    # Clean up array elements older than 30 days
    my $thirty_days_in_seconds = 30 * 24 * 60 * 60;
    @warp_events = grep { time() - $_ <= $thirty_days_in_seconds } @warp_events;

    # Count recent warp events
    my $recent_warp_count = scalar(@warp_events);

    my $enforcement = 0;

    quest::set_data($account_key, plugin::SerializeList(@warp_events));

    if ($distance > 100 || $soulmark) {
        my $admin_message = "Large Warp Detected. Character: $name Zone: $zonesn From: $from_x, $from_y, $from_z To: $current_x, $current_y, $current_z Distance: $distance";

        if ($soulmark) {
            $admin_message .= "\nAccount has Soulmark. Reason: $soulmark";            
        }

        if ($recent_warp_count) {
            $admin_message .= "\nPrevious 30-day Warp Count: $recent_warp_count";
        }

        if ($soulmark && $recent_warp_count > 10) {
            $admin_message .= "\nHigh 30-day Warp Count. Enforcement Engaged.";
            $enforcement = 1;
        }

        # Send the admin message
        quest::discordsend("admin", $admin_message);
        quest::debug($admin_message);

        if ($enforcement) {
            $client->WorldKick();
        }
    }
}

sub EVENT_DISCOVER_ITEM {
    my $name = $client->GetCleanName();
    
    # Only announce upgraded items
    if ($itemid > 999999) {        
        plugin::WorldAnnounceItem("$name has discovered: {item}.",$itemid);  
    }  
}

sub symp_proc_tutorial_helper {
    my $item_id = shift;
    my $client = shift;

    if ($item_id) {
        #pre-computed list of symp proc item ID bases
        my @sym_clicks = (
            6307, 6309, 6313, 7305, 900012, 900014, 1113, 1117, 1156, 1173, 
            1904, 2404, 5203, 5214, 5730, 5764, 6017, 6020, 6024, 6036, 
            6310, 6315, 6323, 6324, 6332, 6335, 6343, 6350, 6359, 6382, 
            6383, 6402, 6404, 6408, 6616, 6626, 7036, 7318, 7372, 7405, 
            10333, 10383, 10404, 10994, 11028, 11906, 11973, 12375, 13168, 
            13380, 13400, 13500, 13743, 13744, 13815, 13987, 13988, 13991, 
            14338, 14746, 14762, 20627, 21798, 21863, 21885, 21886, 21892, 
            22819, 22890, 23498, 24745, 24779, 24789, 24793, 25566, 25577, 
            25980, 25998, 26000, 26001, 26009, 26553, 27280, 27717, 28812, 
            28813, 28814, 28815, 28817, 28908, 29248, 29430, 29442, 30511, 
            31210, 31212, 31373, 62269, 68444, 68744, 68775, 68837, 69044, 
            69047, 69049, 69051, 69054, 69055, 69095, 69112, 69113, 69116, 
            69155
        );

        my $item_root = ($item_id % 1000000);

        if (grep { $_ == $item_root } @sym_clicks) {
            plugin::dispatch_popup("symp_tutorial", $client);
        }
    }
}

sub EVENT_COMBINE_VALIDATE {
	if ($recipe_id == 10344) {
		if ($validate_type =~/check_zone/i) {
			if ($zone_id != 289 && $zone_id != 290) {
				return 1;
			}
		}
	}
	
	return 0;
}

sub EVENT_COMBINE_SUCCESS {
    if ($recipe_id =~ /^1090[4-7]$/) {
        $client->Message(1,
            "The gem resonates with power as the shards placed within glow unlocking some of the stone's power. ".
            "You were successful in assembling most of the stone but there are four slots left to fill, ".
            "where could those four pieces be?"
        );
    }
    elsif ($recipe_id =~ /^10(903|346|334)$/) {
        my %reward = (
            melee  => {
                10903 => 67665,
                10346 => 67660,
                10334 => 67653
            },
            hybrid => {
                10903 => 67666,
                10346 => 67661,
                10334 => 67654
            },
            priest => {
                10903 => 67667,
                10346 => 67662,
                10334 => 67655
            },
            caster => {
                10903 => 67668,
                10346 => 67663,
                10334 => 67656
            }
        );
        my $type = plugin::ClassType($class);
        quest::summonfixeditem($reward{$type}{$recipe_id});
        quest::summonfixeditem(67704); # Item: Vaifan's Clockwork Gemcutter Tools
        $client->Message(1,"Success");
    }
}

sub EVENT_ITEM_CLICK_CAST_CLIENT {
    swap_vib_gaunt_and_hammer($client, $item_id);
    swap_epic($client, $item_id);
}  

sub swap_vib_gaunt_and_hammer {
    my ($client, $item_id) = @_;    
    my $src_item = 0;
    my $dst_item = 0;
    
    if ($item_id % 1000000 == 11668 || $item_id % 1000000 == 11669) {
        $src_item = $item_id;

        my $rank = int($item_id / 1000000);
        if ($item_id % 1000000 == 11668) {
            $dst_item = 11669 + ($rank * 1000000);
        }

        if ($item_id % 1000000 == 11669) {
            $dst_item = 11668 + ($rank * 1000000);
        }
    }

    if ($src_item && $dst_item) {
        $client->SummonFixedItem($dst_item);
    }
}

sub swap_epic {
    my ($client, $item_id) = @_;
    my $src_item = 0;
    my $dst_item = 0;

    if ($item_id == 2014383 || $item_id == 2800000) {
        $src_item = $item_id;
        if ($item_id == 2014383) {
            $dst_item = 2800000;
        }
        elsif ($item_id == 2800000) {
            $dst_item = 2014383;
        }
    }

    if ($item_id == 2010099 || $item_id == 2800001) {
        $src_item = $item_id;
        if ($item_id == 2010099) {
            $dst_item = 2800001;
        }
        elsif ($item_id == 2800001) {
            $dst_item = 2010099;
        }
    }

    if ($src_item && $dst_item) {
        my @augments = (
            $client->GetAugmentIDAt($slot_id, 0),
            $client->GetAugmentIDAt($slot_id, 1),
            $client->GetAugmentIDAt($slot_id, 2),
            $client->GetAugmentIDAt($slot_id, 3),
            $client->GetAugmentIDAt($slot_id, 4),
            $client->GetAugmentIDAt($slot_id, 5)
        );

        foreach my $augment (@augments) {
            $augment = 0 if $augment == -1;
        }

        my $charges = 1;
        my $is_attuned = 1;

        my $item_data = {
            item_id      => $dst_item,    
            charges      => 1,
            augment_one  => $augments[0],
            augment_two  => $augments[1],
            augment_three => $augments[2],
            augment_four  => $augments[3],
            augment_five  => $augments[4],
            augment_six   => $augments[5],
            attuned       => 1,
        };

        $client->AddItem($item_data);
    }
}

sub EVENT_CAST_ON {
    # Check for mutually-exclusive elemental form spells.
    my @spell_ids = (
        2789, 2790, 2791, 2792, 2793, 2794, 2795, 2796, 2797, 2798, 2799, 2800,
        38329, 38330, 38331, 38333, 38334, 38335, 38336, 38337, 38338, 38340, 38341, 38342
    );
    if (grep { $_ == $spell_id } @spell_ids) {
        foreach my $id (@spell_ids) {
            next if $id == $spell_id; # Skip the matched spell_id
            $client->BuffFadeBySpellID($id);
        }
    }

    if ($caster_id && $spell) {
        my @global_buffs = ( 43002, 43003, 43004, 43005, 43006, 43007, 43008, 17779 );
        # Check if spell_id IS in @global_buffs array
        if (grep { $_ == $spell_id } @global_buffs) {
            # no operation
        } elsif ($caster_id == $client->GetID() && $spell->GetBuffDuration() > 0) {
            plugin::dispatch_popup("self_buff", $client);
        }
    }
}

sub EVENT_SAY {
    if ($client->GetGM()) {
        if ($text=~/#awardtitle\s*(.*)/i) {
            $client->Message(13, "Disregard the command not recognized error.");
            my $arguments = $1; # Captures everything after #awardtitle
            
            my $tar_client = $client->GetTarget();
            if ($tar_client->IsClient()) {
                $tar_client = $tar_client->CastToClient();
            }
            if ($tar_client && $tar_client->IsClient()) {
                # Validate that there is exactly one argument which is a number
                if ($arguments =~ /^\s*(\d+)\s*$/) {
                    my $number = $1; # Captures the number
                    # Proceed with awarding the title using $number
                    
                    $client->Message(13, "Awarding TitleSet $number to " . $tar_client->GetName());
                    plugin::AddTitleFlag($number, $tar_client->CastToClient());
                    plugin::CommonCharacterUpdate($tar_client->CastToClient());
                    $tar_client->Signal(1);
                } else {
                    $client->Message(13, "Invalid input. Please provide a single numeric argument.");
                }
            } else {
                $client->Message(13, "You must target a client to issue this command.");
            }
        }
    }
}

