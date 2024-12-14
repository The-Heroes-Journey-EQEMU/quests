sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::say("Well looky there! Feeling lucky? Come win a prize! Mounts, Petamorph Wands, Illusions, Clockwork friends... 
                    delicious foods and potions to boot! If you want to try your luck at a game of chance, simply hand me 5,000 
                    platinum pieces, or consider donating to wager two [Echo of Memory], I'll accept those, too!");
    }
    if ($text =~ /Echo of Memory/i) {
        if (plugin::SpendEOM($client, 2)) {
            GetRandomResult();
        } else {
            quest::say("You don't have enough Echoes of Memory, dear friend. Come back when you do!");
        }
    }
}

sub EVENT_ITEM {
    foreach my $key (keys %itemcount) {
        my $value = $itemcount{$key};
        #quest::debug("Key: $key, Value: $value");
    }

    if (plugin::CheckCashPayment(5000000, $copper, $silver, $gold, $platinum)) { # 5000 Platinum
        GetRandomResult();    
    } else {
        quest::say("You'll need to give me enough money for the casino ticket!");
    }
    plugin::return_items(\%itemcount);
}

sub GetRandomResult {
    my $client = plugin::val('$client');
    my $name   = $client->GetCleanName();
    # Format here is chance => weight for reward entry to be chosen (if weights sum to 100, this is a percentage), 
    # $items => potential items to be rewarded for this option, $message => flavor text for winning
    my @rewards = (
        # { chance => 25, items => [56064], message => "Happy Thanksgiving!" }, #Thanksgiving
        { chance => 25, items => [36995, 57825, 64489, 57819, 57818, 37538, 32557], message => "Better luck next time! Here, have some food. A loss is better on a full stomach!" },
        # { chance => 25, items => [36013], message => "Cheers!" }, #Thanksgiving
        { chance => 25, items => [56942, 56940, 56938, 56934, 56935, 56944, 56937, 32557], message => "Better luck next time! Here, drink this down, it should cheer you up!" },
        { chance => 20, items => [41961, 48083], message => "Let the experience flow!" },
        { chance => 10, items => [67923, 56052, 61036, 62774, 66783, 64711, 66431, 66449, 67953, 67883, 
                                  52193, 66598, 61979, 67145, 66564, 907290, 907291, 907292, 907293, 907294,
                                  907295, 907296], message => "Nicely done! Pets love a facelift every now and then $name!" },
        { chance => 5, items => [37954, 67008, 43993, 37999, 40638, 40714, 40686, 50854, 40656, 31861], message => "An illusion?! In case I don't recognize you next time, congratulations $name!" },
        { chance => 3, items => [59508, 59513, 43970, 57798, 54983, 60437, 52098, 64560, 54934, 60945, 62787, 57191], message => "Wow! Looks like $name will be traveling in style now!" },
        { chance => 2, items => [52024], message => "Urthron's... what?! How'd that get in there?! Congratulations $name!" },
        { chance => 2, items => [976008], message => "Oooo! Your very own Clockwork Banker $name!" },
        { chance => 2, items => [976009], message => "Your friends will be SO jealous! Congratulations on your Clockwork Merchant $name!" },
        # { chance => 2, items => [56051], message => "TURKEYS $name! TURKEYS ALL THE TIME!" }, #Thanksgiving
        { chance => 2, items => [36995, 57825, 64489, 57819, 57818, 37538], message => "Better luck next time! Here, have some food. A loss is better on a full stomach!" }
    );

    quest::say("Okay, here we go! Rolling the dice!");   

    my $total_weight = 0;
    foreach my $reward (@rewards) {
        $total_weight += $reward->{chance};
    }
    
    my $random_weight = rand($total_weight);
    
    my $cumulative_weight = 0;
    foreach my $reward (@rewards) {
        $cumulative_weight += $reward->{chance};
        if ($random_weight < $cumulative_weight) {
            my $item = quest::ChooseRandom(@{$reward->{items}});
            if ($item == 32557) {
                $client->SummonItem($item, 5);
            } else {
                $client->SummonItem($item);  # Choose a random item from the current reward
            }
            quest::say($reward->{message});  # Output the message associated with the current reward
            return;
        }
    }
}