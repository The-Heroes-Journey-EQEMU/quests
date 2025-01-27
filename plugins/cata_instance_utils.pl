# Agent of Retribution Library

use POSIX qw(ceil);

sub OfferStandardInstance {
  my $client          = plugin::val('$client');
  my $npc             = plugin::val('$npc');
  my $text            = plugin::val('$text');
  my $zonesn          = plugin::val('$zonesn');
  my $dz_version      = 254;
  my $dz_duration     = 14 * 60 * 60; # 18 hours
  my $dz_duration_sta = 2 * 60 * 60; # 18 hours
  my $dz_lifetime     = 604800;
  my ($expedition_name, $min_players, $max_players, $dz_zone, $x, $y, $z, $heading) = @_;

  if ($client->IsTaskActivityActive(4, 4)) {
    $client->UpdateTaskActivity(4, 4, 1);
  }

  if (plugin::IsSeasonal($client) || plugin::MultiClassingEnabled()) {
    $max_players = 6;
  }

  if ($text =~ /hail/i) {
    my $dz = $client->GetExpedition();
    if ($dz && ($dz->GetName() eq ($expedition_name . " (Respawning)") || $dz->GetName() eq ($expedition_name . " (Non-Respawning)"))) {
      quest::say("When you are [" . quest::saylink("ready", 1) . "], proceed into the portal.");
    }
    else {
      quest::say("I offer you a Trial. $expedition_name lies before you, do you accept the challenge?");      
      if (plugin::IsTHJ()) {
        plugin::YellowText("Notice: Instances will become more difficult for each player in your group beyond the second.");
        plugin::YellowText("[". quest::saylink('Non-Respawning',1). "] will not repopulate over time, and the most powerful enemies may be found within.");
        if ($disable_respawn eq "false") {
          plugin::YellowText("[". quest::saylink('Respawning', 1). "] will repopulate over time, but many rare enemies may not be found inside.");
        }
      } else {
        plugin::YellowText("You can select from [". quest::saylink('Respawning', 1). "] or [".quest::saylink('Non-Respawning',1). "] versions.");
      }
    }
  }

  elsif ($text eq 'Respawning' || $text eq 'Non-Respawning') {
    if ($text eq 'Non-Respawning') {
      $dz_version = quest::get_rule("Custom:StaticInstanceVersion") || 100;
      $expedition_name = $expedition_name . " (Non-Respawning)";
    } else {
      if ($disable_respawn eq "false") {
        $dz_version = quest::get_rule("Custom:FarmingInstanceVersion") || 100;
        $expedition_name = $expedition_name . " (Respawning)";
      } else {
        plugin::RedText("Notice: This zone is not approved for a respawning instance.");
        return;
      }
    }
    
    my $dz = $client->CreateExpedition($dz_zone, $dz_version, $dz_lifetime, $expedition_name, $min_players, $max_players);
    if ($dz) {
      $dz->SetCompass($zonesn, $npc->GetX(), $npc->GetY(), $npc->GetZ());
      $dz->SetSafeReturn($zonesn, $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());
      if ($text eq 'Respawning') {
        $dz->AddReplayLockout($dz_duration_sta);
      }
      if ($text eq 'Non-Respawning') {
        $dz->AddReplayLockout($dz_duration);
      } 
      quest::say("Very well. When you are [" . quest::saylink("ready", 1) . "], proceed into the portal, and remember!");
    } else {
      quest::say("I'm sorry, but I was not able to create this instance for you, mortal.");
    }
  }

  elsif ($text =~ /ready/i) {
    my $dz = $client->GetExpedition();
    if ($dz && ($dz->GetName() eq ($expedition_name . " (Respawning)") || $dz->GetName() eq ($expedition_name . " (Non-Respawning)"))) {
      
      # Fallback to safe zone coordinates if x, y, z, or heading are not defined
      my $final_x = defined $x ? $x : quest::GetZoneSafeX($dz->GetZoneID());
      my $final_y = defined $y ? $y : quest::GetZoneSafeY($dz->GetZoneID());
      my $final_z = defined $z ? $z : quest::GetZoneSafeZ($dz->GetZoneID());
      my $final_heading = defined $heading ? $heading : quest::GetZoneSafeHeading($dz->GetZoneID());

      $client->MovePCInstance($dz->GetZoneID(), $dz->GetInstanceID(), $final_x, $final_y, $final_z, $final_heading);
    }
  }  
}

sub ScaleInstanceNPC {
  if (!plugin::IsTHJ()) {
    return;
  }

  my $instanceversion = plugin::val('$instanceversion');

  if ($instanceversion != quest::get_rule("Custom:StaticInstanceVersion")) {
    return;
  }

  my $npc = shift;
  my $player_count = shift;

  if (!$npc || !$player_count || $player_count <= 2 || ($npc->GetOwner() && $npc->GetOwner()->IsClient())) {
    return;
  }

  $player_count -= 2;
  my $player_scale_factor = ($player_count * 0.25);

  # Ensure original stats are stored
  if (!$npc->GetEntityVariable("original_max_hp")) {
    $npc->SetEntityVariable("original_max_hp", $npc->GetMaxHP());
    $npc->SetEntityVariable("original_max_hit", $npc->GetNPCStat("max_hit"));
    $npc->SetEntityVariable("original_min_hit", $npc->GetNPCStat("min_hit"));
    $npc->SetEntityVariable("original_atk", $npc->GetNPCStat("atk"));
    $npc->SetEntityVariable("original_avoidance", $npc->GetNPCStat("avoidance"));
    $npc->SetEntityVariable("original_accuracy", $npc->GetNPCStat("accuracy"));
    $npc->SetEntityVariable("original_hp_regen", $npc->GetNPCStat("hp_regen"));
    $npc->SetEntityVariable("original_ac", $npc->GetNPCStat("ac"));
    
    # Resistances
    $npc->SetEntityVariable("original_mr", $npc->GetNPCStat("mr"));
    $npc->SetEntityVariable("original_fr", $npc->GetNPCStat("fr"));
    $npc->SetEntityVariable("original_cr", $npc->GetNPCStat("cr"));
    $npc->SetEntityVariable("original_dr", $npc->GetNPCStat("dr"));
    $npc->SetEntityVariable("original_pr", $npc->GetNPCStat("pr"));
  }

  # Calculate the new scaled values based on original stats
  my $scale_factor = 1 + $player_scale_factor;
  my $minor_scale_factor = 1 + ($player_scale_factor * 0.5);

  # Scale max_hp, max_hit, min_hit, and hp_regen by 1 + $scale_factor
  my $new_max_hp = ceil($npc->GetEntityVariable("original_max_hp") * $scale_factor);
  my $hp_ratio   = $npc->GetHPRatio();
  $npc->ModifyNPCStat("max_hp", $new_max_hp);

  $npc->SetHP($npc->GetMaxHP() * $hp_ratio);

  my $new_max_hit = ceil($npc->GetEntityVariable("original_max_hit") * $scale_factor);
  $npc->ModifyNPCStat("max_hit", $new_max_hit);

  my $new_min_hit = ceil($npc->GetEntityVariable("original_min_hit") * $scale_factor);
  $npc->ModifyNPCStat("min_hit", $new_min_hit);

  my $new_hp_regen = ceil($npc->GetEntityVariable("original_hp_regen") * $scale_factor);
  $npc->ModifyNPCStat("hp_regen", $new_hp_regen);

  # Scale all other stats by minor_scale_factor (50% of 1 + player_scale_factor)
  my $new_atk = ceil($npc->GetEntityVariable("original_atk") * $minor_scale_factor);
  $npc->ModifyNPCStat("atk", $new_atk);

  my $new_avoidance = ceil($npc->GetEntityVariable("original_avoidance") * $minor_scale_factor);
  $npc->ModifyNPCStat("avoidance", $new_avoidance);

  my $new_accuracy = ceil($npc->GetEntityVariable("original_accuracy") * $minor_scale_factor);
  $npc->ModifyNPCStat("accuracy", $new_accuracy);

  my $new_ac = ceil($npc->GetEntityVariable("original_ac") * $minor_scale_factor);
  $npc->ModifyNPCStat("ac", $new_ac);

  # Scale resistances by minor_scale_factor
  my $new_mr = ceil($npc->GetEntityVariable("original_mr") * $minor_scale_factor);
  $npc->ModifyNPCStat("mr", $new_mr);

  my $new_fr = ceil($npc->GetEntityVariable("original_fr") * $minor_scale_factor);
  $npc->ModifyNPCStat("fr", $new_fr);

  my $new_cr = ceil($npc->GetEntityVariable("original_cr") * $minor_scale_factor);
  $npc->ModifyNPCStat("cr", $new_cr);

  my $new_dr = ceil($npc->GetEntityVariable("original_dr") * $minor_scale_factor);
  $npc->ModifyNPCStat("dr", $new_dr);

  my $new_pr = ceil($npc->GetEntityVariable("original_pr") * $minor_scale_factor);
  $npc->ModifyNPCStat("pr", $new_pr);

  # These just use absolute values
  $npc->ModifyNPCStat("spellscale", $scale_factor * 100);
  $npc->ModifyNPCStat("healscale", $scale_factor * 100);
}