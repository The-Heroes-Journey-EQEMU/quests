sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings $name, and welcome to the Bunker. Are you a [new warrior] or [veteran]?");
	}
	elsif ($text=~/new warrior/i) {
		#:: Match if faction with Steel Warriors is better than Indifferent
		if ($faction < 5) {
			quest::say("Good to know you chose the Bunker to train you. It is the home of The Steel Warriors. We find our inner strengths grow through battles and deeds to further our growth. Do you [seek deeds] or [crave battle]?");
		}
		#:: Match if faction with Steel Warriors is Indifferent
		elsif ($faction == 5) {
			quest::say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.");
		}
		#:: Match if faction with Steel Warriors worse than Indifferent
		else {
			quest::say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!");
		}
	}
	elsif ($text=~/veteran/i) {
		#:: Match if faction with Steel Warriors is better than Indifferent
		if ($faction < 5) {
			quest::say("I apologize for not knowing. I am new to the Bunker. I was a trainer at the Hall of Steel in Qeynos before this.  I left Qeynos in search of [Milea] and instead found myself joining the bunker's weaponmasters.");
		}
		#:: Match if faction with Steel Warriors is Indifferent
		elsif ($faction == 5) {
			quest::say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.");
		}
		#:: Match if faction with Steel Warriors worse than Indifferent
		else {
			quest::say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!");
		}
	}
	elsif ($text=~/seek deeds/i) {
		#:: Match if faction with Steel Warriors is better than Indifferent
		if ($faction < 5) {
			quest::say("It may not be a fray, but who ever said we Steel Warriors are nothing but brawn?  Recently, there has been reports of frequent visits by dark elves to the Hog Caller's Inn, here in Freeport. Go speak with Lady Shae. Tell her, the [Steel Warriors sent you]. We cannot rely on the Freeport Militia to look into such matters. They are probably involved. Bring me any clues you find.");
		}
		#:: Match if faction with Steel Warriors is Indifferent
		elsif ($faction == 5) {
			quest::say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.");
		}
		#:: Match if faction with Steel Warriors worse than Indifferent
		else {
			quest::say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!");
		}
	}
	elsif($text=~/crave battle/i) {
		#:: Match if faction with Steel Warriors is better than Indifferent
		if ($faction < 5) {
			quest::say("Aye!!  That is good.  Ask Cain Darkmoore about Clan Deathfist.  Also, when striking underhand, plant your feet at shoulder width and push with your legs on contact.  It does wonders and keeps your back and shoulders from aching.");
		}
		#:: Match if faction with Steel Warriors is Indifferent
		elsif ($faction == 5) {
			quest::say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.");
		}
		#:: Match if faction with Steel Warriors worse than Indifferent
		else {
			quest::say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!");
		}
	}
	elsif ($text=~/^milea$/i) {
		quest::say("Milea Clothspinner. She was my one true love. She, too, is a Steel Warrior. When she left Qeynos to find adventure, my heart left also. I never saw her again, but I decided to transfer my skills to Freeport. It is probably best that I did not find her. She was in love with adventure. <sigh> The women I am attracted to are always in love with another. Just like [Toala].");
	}
	elsif ($text=~/toala/i) {
		quest::say("Toala is supreme when it comes to the blade, but in the art of passion she chooses to leans toward Cain Darkmoore. I do not get it. She is a very beautiful and strong-hearted warrior. Why Cain does not like her is a mystery to me. Why does she waste her time when she could have me? After all, we men of Qeynos are known as the most romantic in all of Norrath.");
	}
	elsif ($text=~/milea is in east karana/i) {
		quest::say("You have seen Milea Clothspinner!! This is great news. I wish I could travel to see her, but Cain will not allow me to do so at this time. You must take her a note for me. Here, take this to her. As a master in this order, I command you to do so immediately. Go!!");
		#:: Give a 18934 - A Sealed Letter "LoveToMilea"
		quest::summonitem(18934);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
