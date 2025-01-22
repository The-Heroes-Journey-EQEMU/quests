sub GetAccountKey
{
    my $client = shift || plugin::val('$client');

    if ($client) {
        return "account-" . $client->AccountID() . "-";
    }
}

sub ClassType {
    my $client = plugin::val('$client');
    my $class  = $client->GetClass();

    my %melee_classes = map { $_ => 1 } (1, 7, 9, 16);
    my %caster_classes = map { $_ => 1 } (11, 12, 13, 14);
    my %priest_classes = map { $_ => 1 } (2, 6, 10);

    if (exists $melee_classes{$class}) {
        return "melee";
    }

    if (exists $caster_classes{$class}) {
        return "caster";
    }

    if (exists $priest_classes{$class}) {
        return "priest";
    }

    return "hybrid";
}

sub NPCTell {	
	my $npc = plugin::val('npc');
    my $client = plugin::val('client');
	my $message = shift;

	my $NPCName = $npc->GetCleanName();
    my $tellColor = 257;
	
    $client->Message($tellColor, "$NPCName tells you, '" . $message . "'");
}

sub YellowText {
	my $message     = shift;
    my $client      = shift || plugin::val('client');
    my $tellColor   = 335;
	
    $client->Message($tellColor, $message);
}

sub BlueText {
	my $message     = shift;
    my $client      = shift || plugin::val('client');
    my $tellColor   = 263;
	
    $client->Message($tellColor, $message);
}

sub RedText {
	my $message     = shift;
    my $client      = shift || plugin::val('client');
    my $tellColor   = 287;
	
    $client->Message($tellColor, $message);
}

sub PurpleText {
	my $message     = shift;
    my $client      = shift || plugin::val('client');
    my $tellColor   = 257;
	
    $client->Message($tellColor, $message);
}

sub WorldAnnounce {
	my $message = shift;
	quest::discordsend("ooc", $message);
	quest::we(335, $message);
}

sub convert_seconds {
    my ($seconds) = @_;

    my $hours = int($seconds / 3600);
    $seconds %= 3600;
    my $minutes = int($seconds / 60);
    $seconds %= 60;

    return ($hours, $minutes, $seconds);
}

# TODO - UPDATE THIS URL WHEN OUR ALLACLONE IS UP
sub WorldAnnounceItem {
    my ($message, $item_id) = @_;
    my $itemname = quest::getitemname($item_id);

    my $eqgitem_link = quest::varlink($item_id);
    my $discord_link = "[[$itemname](https://retributioneq.com/allaclone/?a=item&id=$item_id)]";

    # Replace a placeholder in the message with the EQ game link
    $message =~ s/\{item\}/$eqgitem_link/g;

    # Send the message with the game link to the EQ world
    quest::we(334, $message);

    # Replace the game link with the Discord link
    $message =~ s/\Q$eqgitem_link\E/$discord_link/g;

    # Send the message with the Discord link to Discord
    quest::discordsend("ooc", $message);
}

# Serializer
sub SerializeList {
    my @list = @_;
    return join(',', @list);
}

# Deserializer
sub DeserializeList {
    my $string = shift;
    return split(',', $string);
}

# Serializer
sub SerializeHash {
    my %hash = @_;
    return join(';', map { "$_=$hash{$_}" } keys %hash);
}

# Deserializer
sub DeserializeHash {
    my $string = shift;
    my %hash = map { split('=', $_, 2) } split(';', $string);
    return %hash;
}

sub num2en {
    my $number = shift;

    return "zero" if $number == 0; # Handle 0 explicitly
    return "one thousand" if $number == 1000; # Special case for 1000

    my %map = (
        1 => "one", 2 => "two", 3 => "three", 4 => "four", 5 => "five",
        6 => "six", 7 => "seven", 8 => "eight", 9 => "nine", 10 => "ten",
        11 => "eleven", 12 => "twelve", 13 => "thirteen", 14 => "fourteen",
        15 => "fifteen", 16 => "sixteen", 17 => "seventeen", 18 => "eighteen", 19 => "nineteen",
    );

    my %tens_map = (
        2 => "twenty", 3 => "thirty", 4 => "forty", 5 => "fifty",
        6 => "sixty", 7 => "seventy", 8 => "eighty", 9 => "ninety",
    );

    my $word = '';

    if ($number >= 100) {
        my $hundreds = int($number / 100);
        $word .= $map{$hundreds} . " hundred";
        $number %= 100; # Reduce number to remainder for further processing
        $word .= " and " if $number > 0; # Add 'and' if there's more to come
    }

    if ($number >= 20) {
        my $tens = int($number / 10);
        $word .= $tens_map{$tens};
        $number %= 10; # Reduce number to remainder for ones place
        $word .= "-" if $number > 0; # Add hyphen for numbers like "twenty-one"
    }

    $word .= $map{$number} if $number > 0 && exists $map{$number};

    return $word;
}

sub get_slot_by_item {
	my $client = shift;
	my $itemid = shift;

	my @slots = (0..30, 251..340, 2000..2023, 4010..6009, 6210..11009, 11010..11409, 9999);
	foreach $slot (@slots) {
		if ($client->GetItemIDAt($slot) % 1000000 == $itemid % 1000000) {
			return $slot;
		}
	}
	return 0;
}

sub swap_items {
    my ($client, $item_id, $slot_id) = @_;

    # Normalize item ID to its base form
    my $normalized_id = $item_id % 1000000;
    my $rank = int($item_id / 1000000);

    # Define the mapping of source to destination items for swaps
    my %item_swaps = (
        # Gauntlet and Hammer swaps
        11668 => 11669,
        11669 => 11668,

        # Epic swaps
        14383 => 800000,
        10099 => 800001,
        800000 => 14383,
        800001 => 10099,
    );

    # Bail out if the item is not in the swap list
    return unless exists $item_swaps{$normalized_id};

    # Determine the destination item
    my $dst_item = $item_swaps{$normalized_id} + ($rank * 1000000);

    # Retrieve augment data for the current item
    my @augments = (
        $client->GetAugmentIDAt($slot_id, 0),
        $client->GetAugmentIDAt($slot_id, 1),
        $client->GetAugmentIDAt($slot_id, 2),
        $client->GetAugmentIDAt($slot_id, 3),
        $client->GetAugmentIDAt($slot_id, 4),
        $client->GetAugmentIDAt($slot_id, 5),
    );

    # Replace invalid augment values (-1) with 0
    foreach my $augment (@augments) {
        $augment = 0 if $augment == -1;
    }

    # Construct item data with augments and attunement
    my $item_data = {
        item_id       => $dst_item,
        charges       => 1,
        augment_one   => $augments[0],
        augment_two   => $augments[1],
        augment_three => $augments[2],
        augment_four  => $augments[3],
        augment_five  => $augments[4],
        augment_six   => $augments[5],
        attuned       => 1,
    };

    # Add the swapped item with augments
    $client->AddItem($item_data);
}