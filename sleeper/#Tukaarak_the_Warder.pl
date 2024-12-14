sub EVENT_DEATH_COMPLETE {
    if ($entity_list->GetMobByNpcTypeID(128090) || !$entity_list->GetMobByNpcTypeID(128094)) {
        return;
    }
    
    plugin::handle_death($npc, $x, $y, $z, $entity_list);
    
    my $nanzata = $entity_list->GetMobByNpcTypeID(128090);
    my $ventani = $entity_list->GetMobByNpcTypeID(128091);
    my $hraashna = $entity_list->GetMobByNpcTypeID(128093);

    if (!$nanzata && !$ventani && !$hraashna) {
        quest::shout("FOOLS! You have unleashed your doom!");
        quest::depop(128094);
        quest::spawn2(128089, 0, 0, -1481, -2373, -1034, 520);
    } else {
        quest::shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!");
    }

    my $killer = $entity_list->GetClientByID($killer_id);   

    if ($killer && plugin::IsSeasonal($killer)) {
        plugin::AddTitleFlag(200);
    }
}

sub EVENT_KILLED_MERIT {
    plugin::handle_killed_merit($npc, $client, $entity_list);
}