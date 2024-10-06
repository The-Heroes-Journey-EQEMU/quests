sub EVENT_SPAWN {
  quest::settimer(1, 1200);
  quest::emote("rises from the corpse and stares around, as if waiting...");

  $npc->MoveTo($npc->GetX(), $npc->GetY(), $npc->FindGroundZ($npc->GetX(), $npc->GetY()));
}

sub EVENT_SAY {
    my $flag_stage = $npc->GetEntityVariable("Stage-Name");
    my $flag_name  = $npc->GetEntityVariable("Flag-Name");

    if ($text =~ /hail/i) {
        if (plugin::IsSeasonal($client) || plugin::MultiClassingEnabled()) {
            if (!plugin::ValidProgInstance($zoneid, $instanceid, $instanceversion)) {      
                plugin::YellowText("You may only advance your progression within an instance.");          
                return;
            }
        }  
        plugin::SetSubflag($client, $flag_stage, $flag_name);

        if ($flag_name eq "Lord Nagafen" && $client->IsTaskActivityActive(4, 5)) {
            $client->UpdateTaskActivity(4, 5, 1);
        }

        if ($flag_name eq "Lady Vox" && $client->IsTaskActivityActive(4, 6)) {
            $client->UpdateTaskActivity(4, 6, 1);
        }
    }
}

sub EVENT_TIMER {
    quest::emote("vanishes.");
    quest::depop();
}