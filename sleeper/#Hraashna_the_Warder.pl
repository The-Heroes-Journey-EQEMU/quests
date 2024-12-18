sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);

    my $nanzata = $entity_list->GetMobByNpcTypeID(128090);
    my $ventani = $entity_list->GetMobByNpcTypeID(128091);
    my $tukaarak = $entity_list->GetMobByNpcTypeID(128092);

    if (!$nanzata && !$ventani && !$tukaarak) {
        quest::shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!");
    } else { 
        quest::shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!");
    }

    my $killer = $entity_list->GetClientByID($killer_id);   

    if ($killer && int(rand(500)) == 0) {
        plugin::AddTitleFlag(200);
    }
}

sub EVENT_KILLED_MERIT {
    plugin::handle_killed_merit($npc, $client, $entity_list);
}