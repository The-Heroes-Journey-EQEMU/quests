sub EVENT_SPAWN {
  quest::modifynpcstat("runspeed", 0);
  quest::pause(2);
}

sub EVENT_SIGNAL {
  quest::debug("Priest received signal - " . $signal);
  if ($signal == 1){
    # Fall into formation
    quest::modifynpcstat("runspeed", 2.25);
  } elsif ($signal == 2){
    # Begin march to fort
    quest::modifynpcstat("runspeed", 1.25);
  } elsif ($signal == 3){
    # Charge into battle
    quest::modifynpcstat("runspeed", 2.25);
  }
}

sub EVENT_WAYPOINT_ARRIVE {
  if ($wp == 1){
    # Stop for Garadain's speech
    quest::modifynpcstat("runspeed", 0);
  } elsif ($wp == 2){
    # Stop briefly for the call to charge
    quest::modifynpcstat("runspeed", 0);
  } elsif ($wp==3) {
    # Arrived at final waypoint.  Stop navigation
    $npc->SetGrid(0);
    quest::settimer(9,300);
  }
}

sub EVENT_TIMER {
  if($timer == 9) {
    quest::stoptimer(9);
    quest::depopall(116541);
  }
}
