sub EVENT_SPAWN {

quest::settimer(7,600);
quest::settimer("emote1",6);
quest::settimer("emote2",12);
quest::settimer("emote3",18);

}

sub EVENT_TIMER {

if($timer eq 7) {
quest::depop();
quest::stoptimer(7);
}
if($timer eq "emote1") {
quest::stoptimer("emote1");
quest::say("Terris, hear me now!  I have done as you asked.  My beloved dagger is whole once again!  Now keep up your part of the bargain.");
quest::signalwith(204065,1,0); # signal #Terris_Thule (204065) emotes
}
if($timer eq "emote2") {
quest::stoptimer("emote2");
quest::say("Vile wench, I knew in the end it would come to this.  You shall pay dearly for your injustice here.");
quest::signalwith(204065,2,0); # signal #Terris_Thule (204065) emotes
}
if($timer eq "emote3") {
quest::stoptimer("emote3");
quest::say("So then my hope is nearly lost.  Take my dagger with you and plunge it deep into her soulless heart.  If I cannot escape from this forsaken plane under her rules, I shall make my own!");
}

}

sub EVENT_SAY {

if($text=~/Hail/i)
       {
       $client->Message(0,"Thelin Poxbourne tells you, 'Please destroy her for subjecting me to her hideous visions.'  Thelin closes his eyes and is swept away from his nightmare.  The land of pure thought begins to vanish from around you.");
       $client->Message(15,"You receive a character flag!");
       quest::setglobal("pop_pon_construct", 1, 5, "F");
       $npc->CastSpell(1195, $userid); #cast Waking Moment on PC
       }

if($text=~/return/i)
       {
       #quest::movepc(204,-1520,1104,125); # Zone: ponightmare
       quest::MovePCInstance(204, $instanceid, -1520, 1104, 125); #zone: ponightmare within current instance
       }
{
$pop_pon_hedge_jezith=undef;
$pop_pon_construct=undef;
$pop_ponb_terris=undef;
$pop_ponb_poxbourne=undef;
$pop_poi_dragon=undef;
$pop_poi_behometh_preflag=undef;
$pop_poi_behometh_flag=undef;
$pop_pod_alder_fuirstel=undef;
$pop_pod_grimmus_planar_projection=undef;
$pop_pod_elder_fuirstel=undef;
$pop_poj_mavuin=undef;
$pop_poj_tribunal=undef;
$pop_poj_valor_storms=undef;
$pop_poj_execution=undef;
$pop_poj_flame=undef;
$pop_poj_hanging=undef;
$pop_poj_lashing=undef;
$pop_poj_stoning=undef;
$pop_poj_torture=undef;
$pop_pov_aerin_dar=undef;
$pop_pos_askr_the_lost=undef;
$pop_pos_askr_the_lost_final=undef;
$pop_cod_preflag =undef;
$pop_cod_bertox=undef;
$pop_cod_final=undef;
$pop_pot_shadyglade=undef;
$pop_pot_newleaf=undef;
$pop_pot_saryrn=undef;
$pop_pot_saryn_final=undef;
$pop_hoh_faye=undef;
$pop_hoh_trell=undef;
$pop_hoh_garn=undef;
$pop_hohb_marr=undef;
$pop_bot_agnarr=undef;
$pop_bot_karana=undef;
$pop_tactics_tallon =undef;
$pop_tactics_vallon=undef;
$pop_tactics_ralloz=undef;
$pop_elemental_grand_librarian=undef;
$pop_sol_ro_arlyxir=undef;
$pop_sol_ro_dresolik=undef;
$pop_sol_ro_jiva=undef;
$pop_sol_ro_rizlona=undef;
$pop_sol_ro_xuzl=undef;
$pop_sol_ro_solusk=undef;
$pop_fire_fennin_projection=undef;
$pop_wind_xegony_projection=undef;
$pop_water_coirnav_projection=undef;
$pop_eartha_arbitor_projection=undef;
$pop_earthb_rathe=undef;
$pop_time_maelin=undef;
}
}

