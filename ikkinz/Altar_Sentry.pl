#Ikkinz Raid #4: Chambers of Destruction 
sub EVENT_SPAWN {
  quest::setnexthpevent(80);
  if(!defined($qglobals{$instanceid.asentkill2})) {
    $altarkill2 = int(rand(4)) + 1;
    quest::setglobal($instanceid.asentkill2,$altarkill2,3,"H6");
  }
  else {
    $altarkill2 = $qglobals{$instanceid.asentkill2};
  }
}

sub EVENT_DEATH_COMPLETE {
  if ( $status >= 80 ) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
    }
  elsif($client->HasClass("Bard") && ($qglobals{$instanceid.asentkill2} == 2)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Beastlord")  && ($qglobals{$instanceid.asentkill2} == 2)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Berserker")  && ($qglobals{$instanceid.asentkill2} == 3)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Cleric")  && ($qglobals{$instanceid.asentkill2} == 4)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Druid")  && ($qglobals{$instanceid.asentkill2} == 4)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Enchanter")  && ($qglobals{$instanceid.asentkill2} == 1)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Magician") && ($qglobals{$instanceid.asentkill2} == 1)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Monk")  && ($qglobals{$instanceid.asentkill2} == 3)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Necromancer") && ($qglobals{$instanceid.asentkill2} == 1)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Paladin")  && ($qglobals{$instanceid.asentkill2} == 2)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Ranger")  && ($qglobals{$instanceid.asentkill2} == 2)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Rogue") && ($qglobals{$instanceid.asentkill2} == 3)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Shadowknight")  && ($qglobals{$instanceid.asentkilll2} == 2)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Shaman")  && ($qglobals{$instanceid.asentkill2} == 4)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Warrior")  && ($qglobals{$instanceid.asentkill2} == 3)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  elsif($client->HasClass("Wizard")  && ($qglobals{$instanceid.asentkill2} == 1)) {
    quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  }
  else {
    quest::spawn2(294603,0,0,$x,$y,$z,$h); # NPC: Altar_Sentry
	quest::ze(0,"Your energy didn't match that required to kill the stone worker.");
    if($altarkill2 == 1) {
      quest::emote("The creature will perish under the strength of intelligent magic");
    }
    if($altarkill2 == 2) {
      quest::emote("The creature appears weak to the combined effort of might and magic!");
    }
    if($altarkill2 == 3) {
      quest::emote("The creature appears weak to the combined effort of strength and cunning!");
    }
    if($altarkill2 == 4) {
      quest::emote("The creature cannot stand up to the power of healers");
    }
	quest::ze(0,"It reforms instantly!");
  }
  quest::signalwith(294614, 1, 0); # NPC: #Trigger_Ikkinz_4
}

sub EVENT_HP {
  if($hpevent == 80) {
    $npc->WipeHateList();
    quest::setnexthpevent(60);
    quest::emote("changes target");
  }
  if($hpevent == 60) {
    $npc->WipeHateList();
    quest::setnexthpevent(40);
    quest::emote("changes target");
  }
  if($hpevent == 40) {
    $npc->WipeHateList();
    quest::setnexthpevent(20);
    quest::emote("changes target");
  }
  if($hpevent == 20) {
    $npc->WipeHateList();
  }
}
#future lua
#function event_combat(e)
#	if (e.joined == true) then
#		eq.set_timer("OOBcheck", 3 * 1000);
#		eq.set_timer("strike",   math.random(5,20) * 1000);
#	else
#		eq.stop_timer("OOBcheck");
#		eq.stop_timer("strike");
#	end
#end
#
#
#function event_timer(e)
#if(e.timer=="OOBcheck") then
#eq.stop_timer("OOBcheck");
#	if (e.self:GetX() > 115 or e.self:GetX() < -180 or e.self:GetY() > -360 or e.self:GetY() < -470) then
#		e.self:CastSpell(3791,e.self:GetID()); -- Spell: Ocean's Cleansing
#		e.self:GotoBind();
#		e.self:WipeHateList();
#		e.self:SetHP(e.self:GetMaxHP());
#	else
#		eq.set_timer("OOBcheck", 3 * 1000);
#	end
#elseif(e.timer=="strike") then
#e.self:Emote("focuses its attention on someone new!");
#e.self:CastedSpellFinished(5010, e.self:GetHateTop()); -- Spell: Strike of glory
#end
#end
