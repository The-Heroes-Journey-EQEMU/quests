sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
    if (!plugin::IsTHJ()) {
        return;
    }
   
    my $remove_class_cost = 10;
    my $remove_class_lockout_scale = ($client->GetBucket("remove_class_lockout_scale") || 1);
    my $remove_class_lockout = 7 * $remove_class_lockout_scale;

    if ($text=~/hail/i) {   
        if (plugin::GetClassesCount($client) <= 1) {
            plugin::NPCTell("Mortal. Do you wish to throw yourself upon the [whims of blind fate]?");
        } else {
            plugin::NPCTell("Mortal. You are unsuitable, your fate has already been tainted by your pathetic free will. Begone, unless you would have me [reforge your path]");
        }

        my $free_class_remove = ($client->GetBucket("free_remove_class_used") || 0);
        if (!$free_class_remove) {
            plugin::YellowText("You have a free class removal available. You will be given the option to use it by proceeding with the menu.");
        }

        #my $free_aa_reset_used = ($client->GetBucket("free_aa_reset_used") || 0);
        #if (!$free_aa_reset_used) {
        #    plugin::YellowText("You have a free AA Reset available. Would you like to [".quest::saylink("reset_aa", 1, "use it")."]?");
        #}

        return;
    }

#    if ($text=~/reset_aa/i) {
#        my $free_aa_reset_used = ($client->GetBucket("free_aa_reset_used") || 0);
#        if (!$free_aa_reset_used) {
#            plugin::YellowText("All of your AA have been refunded.");
#            $client->SetBucket("free_aa_reset_used", 1);
#            $client->ResetAA();
#            $client->Save(1);
#            plugin::CommonCharacterUpdate($client);
#        }
#    }

    if ($text=~/blind fate/i) {
        if (plugin::GetClassesCount($client) == 1) {
            plugin::NPCTell("You will be put upon an irrevocable path, impossible to predict. Are you certain that you wish to do this?");
            plugin::YellowText("WARNING: If you [".quest::saylink('randomize_me_bitch', 1, 'continue')."], you will be assigned two random classes. This decision cannot be reversed.");
        } else {
            plugin::NPCTell("Mortal. You are unsuitable, your fate has already been tainted by your pathetic free will. Begone.");
        }
        return;
    }

    if ($text=~/randomize_me_bitch/i) {
       
        if (plugin::GetClassesCount($client) == 1) {
            my @all_classes = (1..16);

            # Continue until the client has 3 unique classes
            while (plugin::GetClassesCount($client) < 3) {
                my $random_class = $all_classes[int(rand(@all_classes))];
                
                # Check if the client already has this class
                if (!plugin::HasClass($client, $random_class)) {
                    plugin::AddClass($random_class, $client);
                }
            }

            my $full_class_name = plugin::GetPrettyClassString($client);

            plugin::WorldAnnounce("$name has cast themselves upon the whims of blind fate, choosing random classes ($full_class_name).");    
            plugin::NPCTell("Your fate is sealed, go and walk it.");
        } else {
            plugin::NPCTell("Mortal. You are unsuitable, your fate has already been tainted by your pathetic free will. Begone.");
        }
        return;
    }

    if ($text=~/reforge your path/i) {
        if (plugin::GetClassesCount > 1) {
            my $classes_string = GetClassLinkString();

            plugin::NPCTell("Which class would you have me strip from you; $classes_string? Be aware, you will lose all alternate advancement you have made down this path, permanently.");
        }
    }

    if ($text =~ /^del_class_(\d+)$/i) {
        my $class_id = $1;

        my $free_class_remove = ($client->GetBucket("free_remove_class_used") || 0);
        if (!$free_class_remove) {
            plugin::YellowText("You have a free class removal available. Would you like to [".quest::saylink("free_$class_id", 1, "use it")."]? This will bypass any lockouts or costs.");
        } else {
            if ($client->HasExpeditionLockout("Class Removal Lockout", "")) {
                plugin::YellowText("You cannot remove a class at this time, you still are under cooldown from a previous class removal.");
                return 0;
            }
        }

        if (plugin::HasClass($client, $class_id)) {
            if (plugin::GetEOM($client) >= $remove_class_cost) {
                 plugin::YellowText("It will cost $remove_class_cost Echo of Memory in order to remove a class. Additionally, 
                                    there is a $remove_class_lockout-day cooldown after removing a class before you can remove another.
                                    Each time you do this, your cooldown for this avatar will permanently increase. Would you like to ["
                                    .quest::saylink("proceed_$class_id", 1, "Proceed")."]?");
            
            } else {
                 plugin::YellowText("It costs $remove_class_cost Echo of Memory in order to remove a class. You can obtain
                                    Echo of Memory through contributions to the sever or purchase from other players in the Bazaar.");
            }           
        }
    }

    if ($text =~ /^proceed_(\d+)$/i) {
        my $class_id = $1; 

        if ($client->HasExpeditionLockout("Class Removal Lockout", "")) {
            plugin::YellowText("You cannot remove a class at this time, you still are under cooldown from a previous class removal.");
            return 0;
        }

        if (plugin::SpendEOM($client, $remove_class_cost) && plugin::HasClass($client, $class_id)) {
            plugin::RemoveClass($class_id, $client);
            $client->AddExpeditionLockout("Class Removal Lockout", "", $remove_class_lockout * 24 * 60 * 60);
            $client->SetBucket("remove_class_lockout_scale", $remove_class_lockout_scale + 1);
        }
    }

    if ($text =~ /^free_(\d+)$/i) {
        my $class_id = $1; 
        my $free_class_remove = ($client->GetBucket("free_remove_class_used") || 0);
        if (!$free_class_remove && plugin::HasClass($client, $class_id)) {
            $client->SetBucket("free_remove_class_used", 1);
            plugin::RemoveClass($class_id, $client);
        }
    }   

    if ($text =~ /unmem/i) {
        for ($i = 0; $i < 12; $i++) {
            $client->UnmemSpell($i, 1);
        }
    }
}

sub GetClassLinkString {
    my $client = shift || plugin::val('$client');  # Ensure $client is available
    my %class_map = plugin::GetClassMap();  # Get the full class map
    my $class_bits = $client->GetClassesBitmask();  # Retrieve the class bits for the client

    my @client_classes;

    # Iterate through class IDs to check which classes the client has
    foreach my $class_id (sort { $a <=> $b } keys %class_map) {
        if ($class_bits & (1 << ($class_id - 1))) {
            push @client_classes, "[".quest::saylink("del_class_$class_id", 1, $class_map{$class_id})."]";
        }
    }

    # Join the client's class names, using ", " and " or " appropriately
    my $pretty_class_string;
    if (@client_classes > 1) {
        $pretty_class_string = join(', ', @client_classes[0..$#client_classes-1]) . ' or ' . $client_classes[-1];
    } else {
        $pretty_class_string = $client_classes[0];  # Only one class
    }

    return $pretty_class_string;
}