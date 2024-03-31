sub EVENT_SAY {
    my $classes = $client->GetClassesBitmask();
    my $player_class_id = $npc->GetClass() - 19;
    my $class_name = quest::getclassname($player_class_id);
    if ($npc->GetClass() >= 20 && $npc->GetClass() <= 35) {
        if ($text=~/hail/i) {
            my $select_string = quest::saylink("class_select", 1, "become a $class_name");
            my %class_greetings = (
                1 => "Ah, a courageous soul approaches. Are you here to embrace the discipline and strength required to [$select_string]?",
                2 => "Blessings upon you, child. The light guides you to me; is it your wish to [$select_string] and serve the divine?",
                3 => "Honor and valor shine from your eyes. Are you destined to [$select_string], a righteous defender of the light?",
                4 => "The winds whisper of a new guardian. Is your heart called to the wilds, to [$select_string], protector of nature?",
                5 => "A shadow looms near. Is it your fate to command the darkness and [$select_string]?",
                6 => "The essence of nature surrounds you. Are you ready to [$select_string], guardian of the balance?",
                7 => "Discipline and inner strength are your allies. Do you seek the path to [$select_string], master of martial arts?",
                8 => "A melody accompanies your steps. Do you feel the rhythm calling you to [$select_string], the voice of inspiration?",
                9 => "Cunning and silence are your markers. Are you prepared to [$select_string], master of stealth and treachery?",
                10 => "The spirits whisper of a new journey. Is it time for you to [$select_string], a conduit of the spirit world?",
                11 => "A chill of the grave precedes you. Will you embrace the dark arts and [$select_string]?",
                12 => "Arcane energies pulse around you. Is your destiny to [$select_string], master of the elements?",
                13 => "Creation's essence swirls around you. Are you called to [$select_string], summoner of the arcane?",
                14 => "Your presence bends reality. Are you ready to [$select_string], weaver of illusions and mind control?",
                15 => "The call of the wild strengthens. Will you heed the call and [$select_string], melding the power of beasts and combat?",
                16 => "Rage burns within your spirit. Do you wish to unleash this power and [$select_string], a warrior of frenzy?"
            );
            
            my $greeting = $class_greetings{$player_class_id} // "Greetings, traveler. Are you seeking guidance or knowledge?";
            if (!($classes & plugin::GetClassBitmask($player_class_id)) && plugin::GetClassesCount($client) < 3) {
                plugin::NPCTell($greeting);
            }
        }
    }

    if ($text eq "class_select") {
        my $class_name = quest::getclassname($npc->GetClass() - 19);
        my $confirm_link = quest::saylink("class_confirm", 1, "Are you ready to commit to the path of the $class_name?");

        my %class_specific_messages = (
            1 => "The path of the Warrior is arduous and demanding, requiring unwavering courage and strength. " . 
                "Once chosen, this path is your destiny, only to be reversed at the whims of the gods. [" . $confirm_link . "]",
            2 => "Embracing the Cleric's way means dedicating your life to the divine, serving as a beacon of light and healing. " .
                "This sacred commitment is binding, revered by the gods themselves. [" . $confirm_link . "]",
            3 => "The Paladin stands as a beacon of hope, blending the might of arms with the purity of faith. " .
                "Are you prepared to defend the light and uphold justice, knowing such a choice is guided by the gods? [" . $confirm_link . "]",
            4 => "Rangers protect the balance of nature, a path filled with peril and beauty. " .
                "If your heart is true to the wild, confirm your dedication to become one with nature and its guardians. [" . $confirm_link . "]",
            5 => "Shadow Knights wield the power of darkness and fear. " .
                "This path is fraught with danger and moral ambiguity. Only the most resolute may walk it, and once chosen, it is rarely abandoned. [" . $confirm_link . "]",
            6 => "Druids are the guardians of nature, harmonizing the forces of life and growth. " .
                "To walk this path is to become one with the earth itself. Are you ready to embrace this eternal bond? [" . $confirm_link . "]",
            7 => "The Monk's discipline is forged from inner strength and relentless training. " .
                "Embrace this path with the understanding that it demands complete devotion, a devotion that is recognized by the gods. [" . $confirm_link . "]",
            8 => "Bards are the heart of any fellowship, weaving magic and music into powerful symphonies. " .
                "If you feel the song within your soul, affirm your desire to live a life of melody and adventure. [" . $confirm_link . "]",
            9 => "Rogues thrive in the shadows, where cunning and agility are the keys to survival. " .
                "Is your spirit attuned to the silent whispers of the dark? Confirm your path and step into the world unseen. [" . $confirm_link . "]",
            10 => "Shamans act as intermediaries between the physical and spirit worlds. " .
                "If you are called to bridge these realms, affirm your commitment to the spiritual journey ahead. [" . $confirm_link . "]",
            11 => "Necromancers command the forces of death and decay. " .
                "This dark path is not chosen lightly, for its course is irrevocable, shadowed by the oversight of the gods themselves. [" . $confirm_link . "]",
            12 => "Wizards master the arcane, wielding the raw forces of magic. " .
                "If you seek to harness these elemental powers, confirm your resolve to tread a path fraught with danger and discovery. [" . $confirm_link . "]",
            13 => "Magicians shape reality, summoning creatures and objects from the ether. " .
                "Are you prepared to command the very fabric of existence, knowing such power is watched closely by the divine? [" . $confirm_link . "]",
            14 => "Enchanters twist the minds and reality itself, with wisdom and subtlety. " .
                "If you choose to weave the strands of fate, know that this path is as binding as the spells you will cast. [" . $confirm_link . "]",
            15 => "Beastlords bond with the spirits of animals, embodying their primal essence. " .
                "This sacred pact with nature is eternal, guided by the spirits and overseen by the gods. Are you ready to accept this union? [" . $confirm_link . "]",
            16 => "Berserkers unleash their inner fury, a force of pure, unbridled power. " .
                "This path of rage is relentless and all-consuming. Confirm if you are ready to embrace the storm within, under the gaze of the gods. [" . $confirm_link . "]"
        );

        my $class_message = $class_specific_messages{$player_class_id} // "The path before you is significant, a choice that once made, is not easily undone. The gods watch over your decision. " . $confirm_link;
        plugin::NPCTell($class_message);

        if ($player_class_id == 8) { # Special Handling for Bard
            $client->Message(13, "WARNING: You will be immediately disconnected so that your base class can be changed to Bard. " .
                                "All class combinations that include Bard must be base class Bard.");
        } elsif (plugin::IsMeleeClass($player_class_id) && !plugin::IsMeleeClass($client->GetClass())) { # Special handling for Melee Classes
            $client->Message(13, "WARNING: You will be immediately disconnected so that your base class can be changed to $class_name. " .
                                "All class combinations that include a melee or Hybrid must have a Melee or Hybrid as their base class.");
        }
    }

    if ($text eq "class_confirm") {
        if (plugin::GetClassesCount($client) < 3) {
            plugin::AddClass($player_class_id);
            plugin::NPCTell("Welcome, $class_name, and be known!");
        }
    }
}


sub EVENT_TICK {    
    CHECK_CHARM_STATUS();   
    if ($npc->IsPet() && $npc->GetOwner()->IsClient()) { 
        UPDATE_PET_BAG($npc);
    }
}

sub EVENT_COMBAT {
    CHECK_CHARM_STATUS();
}

sub EVENT_AGGRO {
    CHECK_CHARM_STATUS();
}

sub EVENT_SPELL_FADE {
    CHECK_CHARM_STATUS();
}

sub EVENT_SPAWN {
    if ($npc->IsPet() && $npc->GetOwner()->IsClient()) { 
        UPDATE_PET_BAG($npc);
        CHECK_CHARM_STATUS(); 
        plugin::CheckWorldWideBuffs($npc);       
    }
}

sub EVENT_ITEM
{
    if ($npc->IsPet() and $npc->GetOwner()->IsClient() and not $npc->Charmed()) {
        plugin::YellowText("You must use a Summoner's Syncrosatchel to equip your pet.");
        plugin::return_items(\%itemcount);
    }
}

sub EVENT_DAMAGE_GIVEN 
{
    # Special aggro events for player pets; if they are not taunting then add their owner to any
    # mob that they attack's aggro list. If they are taunting, then give them some bonus aggro.
    if ($npc->IsPet() && $npc->GetOwner()->IsClient()) {
        if ($npc->IsTaunting()) {
            $entity_list->GetMobByID($entity_id)->AddToHateList($npc->GetOwner());
        } else {
            $entity_list->GetMobByID($entity_id)->AddToHateList($npc, 100);
        }
    }
}

sub UPDATE_PET_BAG {    
    #quest::debug("--Syncronizing Pet Inventory--");
    my $owner = $npc->GetOwner()->CastToClient();
    my $bag_size = 200; # actual bag size limit in source
    my $bag_id = 199999; # Custom Item
    my $bag_slot = 0;

    if ($owner) {       
        my %new_pet_inventory;
        my %new_bag_inventory;
        my $updated = 0;

        my $inventory = $owner->GetInventory();
        #Determine if first instance of pet bag is in inventory or bank
        for (my $iter = quest::getinventoryslotid("general.begin"); $iter <= quest::getinventoryslotid("bank.end"); $iter++) {
            if ((($iter >= quest::getinventoryslotid("general.begin") && $iter <= quest::getinventoryslotid("general.end")) ||
                ($iter >= quest::getinventoryslotid("bank.begin") && $iter <= quest::getinventoryslotid("bank.end")))) {
                
                if ($owner->GetItemIDAt($iter) == $bag_id) {
                        $bag_slot = $iter;
                }
            }
        }
        if ($bag_slot) {
            # Determine contents
            if ($bag_slot >= quest::getinventoryslotid("general.begin") && $bag_slot <= quest::getinventoryslotid("general.end")) {
                %new_bag_inventory = GET_BAG_CONTENTS(\%new_bag_inventory, $owner, $bag_slot, quest::getinventoryslotid("general.begin"), quest::getinventoryslotid("generalbags.begin"), $bag_size);
            } elsif ($bag_slot >= quest::getinventoryslotid("bank.begin") && $bag_slot <= quest::getinventoryslotid("bank.end")) {
                %new_bag_inventory = GET_BAG_CONTENTS(\%new_bag_inventory, $owner, $bag_slot, quest::getinventoryslotid("bank.begin"), quest::getinventoryslotid("bankbags.begin"), $bag_size);
            } else {
                return;
            }

            # Fetching pet's inventory
            my @lootlist = $npc->GetLootList();

            # Sort the lootlist based on criteria
            @lootlist = sort {
                my $a_proceffect = $npc->GetItemStat($a, "proceffect") || 0;
                my $a_damage = $npc->GetItemStat($a, "damage") || 0;
                my $a_delay = $npc->GetItemStat($a, "delay") || 0;
                my $a_ratio = ($a_delay > 0 ? $a_damage / $a_delay : 0);
                my $a_ac = $npc->GetItemStat($a, "ac") || 0;
                my $a_hp = $npc->GetItemStat($a, "hp") || 0;

                my $b_proceffect = $npc->GetItemStat($b, "proceffect") || 0;
                my $b_damage = $npc->GetItemStat($b, "damage") || 0;
                my $b_delay = $npc->GetItemStat($b, "delay") || 0;
                my $b_ratio = ($b_delay > 0 ? $b_damage / $b_delay : 0);
                my $b_ac = $npc->GetItemStat($b, "ac") || 0;
                my $b_hp = $npc->GetItemStat($b, "hp") || 0;

                ($b_proceffect > 0 ? 1 : 0) <=> ($a_proceffect > 0 ? 1 : 0)
                || $b_ratio <=> $a_ratio
                || $b_ac <=> $a_ac
                || $b_hp <=> $a_hp
                || $b <=> $a  # using item IDs for final tiebreaker
            } @lootlist;

            foreach my $item_id (@lootlist) {
                my $quantity = $npc->CountItem($item_id);
                if ($quantity > 1) {
                    $updated = 1;
                    last;
                }
                $new_pet_inventory{$item_id} += $quantity;
            }
            
            foreach my $item_id (keys %new_pet_inventory) {
                # if the key doesn't exist in new_bag_inventory or the values don't match
                if (!exists $new_bag_inventory{$item_id}) {
                    $updated = 1; # set updated to true
                    #quest::debug("Inconsistency detected: $item_id not in bag or quantities differ.");
                    last; # exit the loop as we have found a difference
                }
            }

            # if $updated is still false, it could be because new_bag_inventory has more items, check for that
            if (!$updated) {
                foreach my $item_id (keys %new_bag_inventory) {
                    # if the key doesn't exist in new_pet_inventory
                    if (!exists $new_pet_inventory{$item_id}) {                    
                        $updated = 1; # set updated to true
                        last; # exit the loop as we have found a difference
                    }
                }
            }

            if ($updated) {
                #quest::debug("--Pet Inventory Reset Triggered--");
                my @lootlist = $npc->GetLootList();
                while (@lootlist) { # While lootlist has elements
                    foreach my $item_id (@lootlist) {
                        $npc->RemoveItem($item_id);
                    }
                    @lootlist = $npc->GetLootList(); # Update the lootlist after removing items
                }            

                while (grep { $_->{quantity} > 0 } values %new_bag_inventory) {
                    # Preprocess and sort item_ids by GetItemStat in ascending order
                    my @sorted_item_ids = sort {
                        my $count_a = () = unpack('B*', $owner->GetItemStat($a, "slots")) =~ /1/g;
                        my $count_b = () = unpack('B*', $owner->GetItemStat($b, "slots")) =~ /1/g;
                        $count_a <=> $count_b
                    } keys %new_bag_inventory;
                    
                    foreach my $item_id (@sorted_item_ids) {
                        #quest::debug("Processing item to add: $item_id");
                        if ($new_bag_inventory{$item_id}->{quantity} > 0) {
                            $npc->AddItem($item_id, 1, 1, @{$new_bag_inventory{$item_id}->{augments}});
                            $new_bag_inventory{$item_id}->{quantity}--;
                        }
                    }
                }

            }
        }
    } else {
        quest::debug("The owner is not defined");
        return;
    }
}

sub GET_BAG_CONTENTS {
    my %blacklist = map { $_ => 1 } (5532, 10099, 20488, 14383, 20490, 10651, 20544, 28034, 10650, 8495);
    my ($new_bag_inventory_ref, $owner, $bag_slot, $ref_general, $ref_bags, $bag_size) = @_;
    my %new_bag_inventory;

    my %occupied_slots; # To keep track of slots already taken
    my @items;

    my $rel_bag_slot = $bag_slot - $ref_general;
    my $bag_start = $ref_bags + ($rel_bag_slot * $bag_size);
    my $bag_end = $bag_start + $bag_size;

    for (my $iter = $bag_start; $iter < $bag_end; $iter++) {                
        my $item_id = $owner->GetItemIDAt($iter);
        if ($item_id > 0 && !exists($blacklist{$item_id})) {
            my @augments;
            for (my $aug_iter = 0; $aug_iter < 6; $aug_iter++) {
                if ($owner->GetAugmentAt($iter, $aug_iter)) {
                    push @augments, $owner->GetAugmentIDAt($iter, $aug_iter);
                } else {
                    push @augments, 0;
                }
            }
            if ($owner->GetItemStat($item_id, "itemtype") != 54) {
                push @items, {
                    slot => $iter,
                    id => $item_id,
                    proceffect => $owner->GetItemStat($item_id, "proceffect") || 0,
                    ratio => ($owner->GetItemStat($item_id, "delay") > 0 ? ($owner->GetItemStat($item_id, "damage") / $owner->GetItemStat($item_id, "delay")) : 0),
                    ac => $owner->GetItemStat($item_id, "ac") || 0,
                    hp => $owner->GetItemStat($item_id, "hp") || 0,
                    slots => $owner->GetItemStat($item_id, "slots"),
                    augments => \@augments
                };
            }
        }
    }

    # Sort items by proceffect in descending order
    @items = sort { ($b->{proceffect} > 0 ? 1 : 0) <=> ($a->{proceffect} > 0 ? 1 : 0) ||
                     $b->{ratio} <=> $a->{ratio} ||
                     $b->{ac} <=> $a->{ac} || $b->{hp} <=> $a->{hp} || 
                     $b->{id} <=> $a->{id} } @items;

    foreach my $item (@items) {
        for my $slot_bit (reverse 0..20) {
            if ($item->{slots} & (1 << $slot_bit) && !$occupied_slots{$slot_bit}) {
                $occupied_slots{$slot_bit} = 1;
                $new_bag_inventory{$item->{id}} = { quantity => 1, slot => $item->{slot}, augments => $item->{augments} };
                last;
            }
        }
    }

    return %new_bag_inventory;
}

sub CHECK_CHARM_STATUS
{
    if ($npc->Charmed() && !plugin::REV($npc, "is_charmed")) {     
        my @lootlist = $npc->GetLootList();
        my @inventory;
        foreach my $item_id (@lootlist) {
            my $quantity = $npc->CountItem($item_id);
            push @inventory, "$item_id:$quantity";
        }

        my $data = @inventory ? join(",", @inventory) : "EMPTY";
        plugin::SEV($npc, "is_charmed", $data);

    } elsif (!$npc->Charmed() && plugin::REV($npc, "is_charmed")) {
        
        my $data = plugin::REV($npc, "is_charmed");
        my @inventory = split(",", $data);

        my @lootlist = $npc->GetLootList();
        while (@lootlist) { # While lootlist has elements
            foreach my $item_id (@lootlist) {
                $npc->RemoveItem($item_id);
            }
            @lootlist = $npc->GetLootList(); # Update the lootlist after removing items
        }

        foreach my $item (@inventory) {
            my ($item_id, $quantity) = split(":", $item);
            #quest::debug("Adding: $item_id x $quantity");
            $npc->AddItem($item_id, $quantity);
        }

        plugin::SEV($npc, "is_charmed", "");
    }
    plugin::CheckWorldWideBuffs($npc);
}