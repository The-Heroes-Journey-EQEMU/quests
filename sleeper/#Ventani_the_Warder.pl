sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);
    
    my $nanzata = $entity_list->GetMobByNpcTypeID(128090);
    my $tukaarak = $entity_list->GetMobByNpcTypeID(128092);
    my $hraashna = $entity_list->GetMobByNpcTypeID(128093);

    if (!$nanzata && !$tukaarak && !$hraashna) {
        quest::shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!");
    } else { 
        quest::shout("FOOLS! You have unleashed your doom!");

        quest::depop(128094);
        quest::spawn(128089, 0, 0, -1481, -2373, -1034, 520);
        quest::forcedooropen(46);
    }

    my $killer = $entity_list->GetClientByID($killer_id);   

    if ($killer && int(rand(100)) == 0) {
        plugin::AddTitleFlag(200);
    }
}

sub EVENT_KILLED_MERIT {
    plugin::handle_killed_merit($npc, $client, $entity_list);
}