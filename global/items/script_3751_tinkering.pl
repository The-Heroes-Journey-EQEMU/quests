# Used by books for Tinkering Mastery AA ranks 1 - 3 rewarded by akanon/Rylin_Coil.lua 55027 for TaskID(272) completion
# items: 98471, 98472, 98473
# aaTinkeringMastery: 4672

sub EVENT_ITEM_CLICK {
    if($itemid == 98471) { # Mastering Tinkering Mastery I
        $client->GrantAlternateAdvancementAbility(4672,1,0);
        $client->Message(15,"You have learned the art of Tinkering Mastery.");
        $client->Message(15,"You have gained the ability Tinkering Mastery I at a cost of 3 ability points.");
        quest::ding();
    } 
    if($itemid == 98472) { # Mastering Tinkering Mastery II
        $client->GrantAlternateAdvancementAbility(4672,2,0);
        $client->Message(15,"You have gained the ability Tinkering Mastery II at a cost of 6 ability points.");
        quest::ding();
    }
    if($itemid == 98473) { # Mastering Tinkering Mastery III
        $client->GrantAlternateAdvancementAbility(4672,3,0);
        $client->Message(15,"You have gained the ability Tinkering Mastery III at a cost of 9 ability points.");
        quest::ding();
    }
}

# based on Turmoiltoad @ eqemu structure script_3751.pl
