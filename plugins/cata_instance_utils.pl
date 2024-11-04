# Agent of Retribution Library

use POSIX qw(ceil);

sub OfferStandardInstance {
  my $client          = plugin::val('$client');
  my $npc             = plugin::val('$npc');
  my $text            = plugin::val('$text');
  my $zonesn          = plugin::val('$zonesn');
  my $dz_version      = 0;
  my $dz_duration     = 64800; # 18 hours
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
    if ($dz && ($dz->GetName() eq $expedition_name || $dz->GetName() eq ($expedition_name . " (Static)"))) {
      quest::say("When you are [" . quest::saylink("ready", 1) . "], proceed into the portal.");
    }
    else {
      quest::say("I offer you a Trial. $expedition_name lies before you, do you accept the challenge?");
      plugin::YellowText("You can select from [". quest::saylink('Respawning', 1). "] or [".quest::saylink('Non-Respawning',1). "] versions.");
    }
  }

  elsif ($text eq 'Respawning' || $text eq 'Non-Respawning') {
    if ($text eq 'Non-Respawning') {
      $dz_version = quest::get_rule("Custom:StaticInstanceVersion") || 100;
      $expedition_name = $expedition_name . " (Static)";
    }
    
    my $dz = $client->CreateExpedition($dz_zone, $dz_version, $dz_lifetime, $expedition_name, $min_players, $max_players);
    if ($dz) {
      $dz->SetCompass($zonesn, $npc->GetX(), $npc->GetY(), $npc->GetZ());
      $dz->SetSafeReturn($zonesn, $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());
      $dz->AddReplayLockout($dz_duration);      
      quest::say("Very well. When you are [" . quest::saylink("ready", 1) . "], proceed into the portal, and remember!");
    }
  }

  elsif ($text =~ /ready/i) {
    my $dz = $client->GetExpedition();
    if ($dz && ($dz->GetName() eq $expedition_name || $dz->GetName() eq ($expedition_name . " (Static)"))) {
      
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
  if (!IsTHJ()) {
    return;
  }

  my $npc = shift;
  my $player_count = shift;

  if (plugin::val('$instanceversion') != (quest::get_rule("Custom:StaticInstanceVersion") || 100)) {
    if (plugin::IsBlacklistedNPC($npc)) {
        $npc->Depop(0);
    }
    return;
  }

  if (!$npc || !$player_count || $player_count <= 2) {
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
  $npc->ModifyNPCStat("max_hp", $new_max_hp);

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

sub IsBlacklistedNPC {
  my $npc = shift;
  my @blacklist = (
      # Classic NPCs
	   'Lord Nagafen',
	   'Lady Vox',
	   'Phinigel Autropos',
	   'a dracoliche',
	   'Dread',
	   'Fright',
	   'Terror',
	   'Cazic Thule',
	   'Innoruuk',
	   'Overseer of Air',
	   'Master Yael',
	   'Thunder Spirit Princess',
	   'Noble Dojorn',
	   'a presence',
	   'Gwan',
	   'Protector of Sky',
	   'Gorgalosk',
	   'Keeper of Souls',
	   'The Spiroc Lord',
	   'a spiroc vanquisher',
	   'The Spiroc Guardian',
	   'Bzzazzt',
	   'Bazzzazzt',
	   'Bizazzt',
	   'Bzzzt',
	   'Sister of the Spire',
	   'Eye of Veeshan',
	   'The Hand of Veeshan',
    
    # Kunark NPCs
	   'Venril Sathir`s Remains',
	   'Severilous',
	   'Gorenaire',
	   'Venril Sathir',
	   'Talendor',
	   'Trakanon',
	   'Queen Velazul Di`zok',
	   'Prince Selrach Di`zok',
	   'Overking Bathezid',
	   'Hoshkar',
	   'Druushk',
	   'Xygoz',
	   'Silverwing',
	   'Nexona',
	   'Phara Dar',
	   'Faydedar',


      # Velious NPCs
      'Sontalak',
      'Zlandicar',
      'Klandicar',
      'Wuoshi',
      'Lord Yelinak',
      'Dain Frostreaver IV',
      'Velketor the Sorcerer',
      'Tunare',
      'Bristlebane',
      'The Mischievous Jester',
      'Master of the Guard',
      'The Progenitor',
      'Milas An`Rev',
      'The Final Arbiter',
      'Zeixshi`kar the Ancient',
      'Kildrukaun the Ancient',
      'Vyskudra the Ancient',
      'Tjudawos the Ancient',
      'Hraashna the Warder',
      'Nanzata the Warder',
      'Tukaarak the Warder',
      'Ventani the Warder',
      'Kerafyrm',
      'Derakor the Vindicator',
      'King Tormax',
      'The Statue of Rallos Zek',
      'The Idol of Rallos Zek',
      'Avatar of War',
      'Gozzrem',
      'Telkorenar',
      'Lediniara the Keeper',
      'Dozekar the Cursed',
      'Ikatiar the Venom',
      'Eashen of the Sky',
      'Aaryonar',
      'Lord Feshlak',
      'Dagarn the Destroyer',
      'Lord Kreizenn',
      'Lady Mirenilla',
      'Lord Koi`Doken',
      'Lord Vyemm',
      'Lady Nevederia',
      'Jorlleag',
      'Cekenar',
      'Sevalak',
      'Zlexak',
      'Vulak`Aerr',
      'VulakTrigger',

      # Luclin NPCs
      'an evolved burrower',
      'Khati Sha the Twisted',
      'Warder of Life',
      'Warder of Death',
      'The Va`Dyn',
      'The Itraer Vius',
      'The Insanity Crawler',
      'Shei Vinitras',
      'Servitor of Luclin',
      'Grieg Veneficus',
      'Lcea Katta',
      'Nathyn Illuminious',
      'Lord Inquisitor Seru',
      'Praesertum Rhugol',
      'Praesertum Vantorus',
      'Praesertum Matpa',
      'Praesertum Bikun',
      'Rhag`Zhezum',
      'Rhag`Mozdezh',
      'Arch Lich Rhag`Zadune',
      'High Priest Sssraeshza',
      'Xerkizh The Creator',
      'Rhozth Ssrakezh',
      'Rhozth Ssravizh',
      'a glyph covered serpent',
      'Vyzh`dra the Exiled',
      'Vyzh`dra the Cursed',
      'The Burrower Beast',
      'Though Horror Overfiend',
      'Doomshade',
      'Rumblecrush',
      'Zelnithak',
      'Akhevan Warder',
      'Va Dyn Khar',
      'Thall Va Xakra',
      'Kaas Thox Xi Ans Dyek',
      'Diabo Xi Va',
      'Diabo Xi Xin',
      'Diabo Xi Xin Thall',
      'Thall Va Kelun',
      'Diabo Xi Va Temariel',
      'Thall Xundraux Diabo',
      'Va Xi Aten Ha Ra',
      'Kaas Thox Xi Aten Ha Ra',
      'Kaas Thox Xi Aten Ha Ra',
      'Aten Ha Ra',

      # Planes of Power NPCs
      'Gryme the Crypt Guardian',
      'Aramin the Spider Guardian',
      'Grummus',
      'Xanamech Nezmirthafen',
      'Manaetic Behemoth',
      'Construct of Nightmare',
      'Terris Thule',
      'Aerin`Dar',
      'Carprin Deatharn',
      'Tarkil Adan',
      'Spectre of Corruption',
      'Darwol Adan',
      'Feig Adan',
      'Xhut Adan',
      'Kavilis Adan',
      'Raddi Adan',
      'Wavadozzik Adan',
      'Zandal Adan',
      'Meedo Adan',
      'Akkapan Adan',
      'Qezzin Adan',
      'Pzo Adan',
      'Bhaly Adan',
      'Bertoxxulous',
      'Salczek the Fleshgrinder',
      'The Acolyte of Affliction',
      'Ta`Grusch the Abomination',
      'The Keeper of Sorrows',
      'Maareq the Prophet',
      'Tylis Newleaf',
      'Saryrn',
      'Sorrowsong',
      'Auliffe Chaoswind',
      'Brynju Thunderclap',
      'Eindride Icestorm',
      'Kuanbyr Hailstorm',
      'Evynd Firestorm',
      'Emmerik Skyfury',
      'Agnarr the Storm Lord',
      'Karana',
      'Trydan Faye',
      'Rydda`Dar',
      'Rhaliq Trell',
      'Alekson Garn',
      'Halon of Marr',
      'Edium, Guardian of Marr',
      'Ralthazor, Champion of Marr',
      'Lord Mithaniel Marr',
      'Decorin Berik',
      'Decorin Grunhork',
      'Tallon Zek',
      'Vallon Zek',
      'Rallos Zek',
      'Rallos Zek the Warlord',
      'Xuzl',
      'Arlyxir',
      'Jiva',
      'Rizlona',
      'The Protector of Dresolik',
      'Solusek Ro',
      'Baltador the Cursed',
      'Pherlondien Clawpike',
      'Avatar of Wind',
      'The Elemental Masterpiece',
      'Avatar of Smoke',
      'Melernil Faal`Armanna',
      'Avatar of Mist',
      'Sigismond Windwalker',
      'Avatar of Dust',
      'High Councilman of the Queen',
      'Muzlakh the Chosen',
      'Rindaler Egulrtan',
      'Huridaf Vorgaasna',
      'an elemental arbitor',
      'Wesreh Galleantan',
      'Nuquernal Belegrodian',
      'Weruis Herfadban',
      'Xegony the Queen of Air',
      'Tantisala Jaggedtooth',
      'A Perfected warder of Earth',
      'A Monstrous Mudwalker',
      'Peregrin Rockskull',
      'Derugoak Bloodwalker',
      'A Mystical Arbitor of Earth',
      'War Chieftan Awisano',
      'War Chieftan Birak',
      'War Chieftan Galronar',
      'Warlord Gintolaken',
      'A Rathe Councilman',
      'Avatar of Earth',
      'General Druav Flamesinger',
      'Jaxoliz Dawneyes',
      'Criare Sunmane',
      'Quavonis Firetail',
      'Magmaton',
      'Babnoxis the Spider Queen',
      'Pyronis',
      'Blazzax the Omnifiend',
      'General Reparm',
      'Arch Mage Yozanni',
      'Guardian of Doomfire',
      'Hydrotha',
      'Fishlord Craiyk',
      'Fishlord Lezom',
      'Guardian of Coirnav',
      'Coirnav the Avatar of Water',

      #LoY NPCS
      'Overlord Ngrub',
      'Captain Varns',
      'Captain Krasnok',
      'Innoruuk',
      'The Luggald Broodmother',
      'Spiritseeker Nadox',
  );


    my $npc_name = normalize_name($npc->GetCleanName());  # Normalize NPC name

    # Check if the normalized NPC name is in the blacklist (also normalized)
    return grep { normalize_name($_) eq $npc_name } @blacklist;
}

sub normalize_name {
    my ($name) = @_;
    
    # Convert to lowercase, remove punctuation, numbers, symbols, and extra spaces
    $name = lc($name);                          # Normalize case
    $name =~ s/[^a-z\s]//g;                     # Remove all non-letter characters
    $name =~ s/\s+/ /g;                         # Replace multiple spaces with a single space
    $name =~ s/^\s+|\s+$//g;                    # Trim leading and trailing spaces

    return $name;
}
