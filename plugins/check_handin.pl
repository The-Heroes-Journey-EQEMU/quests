# plugin::check_handin($item1 => #required_amount,...);
# autoreturns extra unused items on success
sub check_handin {
    use Scalar::Util qw(looks_like_number);
    my $client  = plugin::val('client');
    my $hashref = shift;

    # Remove empty IDs
    if ($hashref->{0}) {
        delete $hashref->{0};
    }

    if (!$client->EntityVariableExists("HANDIN_ITEMS")) {
        $client->SetEntityVariable("HANDIN_ITEMS", plugin::GetHandinItemsSerialized("Handin", %$hashref));
    }

    # Make a copy of the original hashref
    my $original_hashref = { %$hashref };

    # Normalize item IDs
    foreach my $item (keys %$hashref) {
        my $base_id = get_base_id($item);
        if ($base_id && $base_id ne $item) {
            $hashref->{$base_id} += $hashref->{$item} if exists $hashref->{$base_id};
            $hashref->{$base_id} = $hashref->{$item} unless exists $hashref->{$base_id};
            delete $hashref->{$item};
        }
    }

    # Validate the hand-in
    my %required = @_;
    my $retval = 1;
    foreach my $req (keys %required) {
        if (!defined $hashref->{$req} || $hashref->{$req} < $required{$req}) {
            $retval = 0;
        }
    }

    # Adjust the counts in $hashref
    foreach my $req (keys %required) {
        if ($hashref->{$req} && $hashref->{$req} >= $required{$req}) {
            $hashref->{$req} -= $required{$req};
        } else {
            delete $hashref->{$req};
        }
    }

    if (!$retval) {
        %$hashref = %$original_hashref;
        return 0;
    }

    return $retval;
}

sub check_handin_fixed {
    use Scalar::Util qw(looks_like_number);
    my $client     = plugin::val('client');
    my $hashref    = shift;

	# These are the empty IDs
	if ($hashref->{0}) {
		delete $hashref->{0};
	}

	if (!$client->EntityVariableExists("HANDIN_ITEMS")) {
		$client->SetEntityVariable("HANDIN_ITEMS", plugin::GetHandinItemsSerialized("Handin", %$hashref));
	}	

	# -----------------------------
	# handin formatting examples
	# -----------------------------
	# item_id    => required_count eg (1001 => 1)
	# -----------------------------
	my %required = @_;
	my $retval = 1;
	foreach my $req (keys %required) {
		if (!defined $hashref->{$req} || $hashref->{$req} != $required{$req}) {
			$retval = 0;
		}
	}

	foreach my $req (keys %required) {
		if ($hashref->{$req} && $required{$req} < $hashref->{$req}) {
			$hashref->{$req} -= $required{$req};
		} else {
			delete $hashref->{$req};
		}
	}
	    
    if (!$retval) {       
        return 0;
    }

	return $retval;
}

sub return_items {
}

sub return_bot_items {
	my $bot = plugin::val('bot');
	if (!$bot->GetOwner() || !$bot->GetOwner()->IsClient()) {
		return;
	}

	my $client = $bot->GetOwner()->CastToClient();
	my $hashref = plugin::var('itemcount');
	my $name = plugin::val('name');
	my $items_returned = 0;

	my %item_data = (
		0 => [ plugin::val('item1'), plugin::val('item1_charges'), plugin::val('item1_attuned'), plugin::val('item1_inst') ],
		1 => [ plugin::val('item2'), plugin::val('item2_charges'), plugin::val('item2_attuned'), plugin::val('item2_inst') ],
		2 => [ plugin::val('item3'), plugin::val('item3_charges'), plugin::val('item3_attuned'), plugin::val('item3_inst') ],
		3 => [ plugin::val('item4'), plugin::val('item4_charges'), plugin::val('item4_attuned'), plugin::val('item4_inst') ],
		4 => [ plugin::val('item5'), plugin::val('item5_charges'), plugin::val('item5_attuned'), plugin::val('item5_inst') ],
		5 => [ plugin::val('item6'), plugin::val('item6_charges'), plugin::val('item6_attuned'), plugin::val('item6_inst') ],
		6 => [ plugin::val('item7'), plugin::val('item7_charges'), plugin::val('item7_attuned'), plugin::val('item7_inst') ],
		7 => [ plugin::val('item8'), plugin::val('item8_charges'), plugin::val('item8_attuned'), plugin::val('item8_inst') ],
	);

	foreach my $k (keys(%{$hashref})) {
		next if ($k == 0);
		my $rcount = $hashref->{$k};
		my $r;
		for ($r = 0; $r < 8; $r++) {
			if ($rcount > 0 && $item_data{$r}[0] && $item_data{$r}[0] == $k) {
				if ($client) {
					# remove delivered task items from return for this slot
					my $inst = $item_data{$r}[3];
					my $return_count = $inst->RemoveTaskDeliveredItems();

					if ($return_count > 0) {
						$client->SummonItem($k, $inst->GetCharges(), $item_data{$r}[2]);
						$items_returned = 1;
					}
				} else {
					quest::summonitem($k, 0);
					$items_returned = 1;
				}
				$rcount--;
			}
		}

		delete $hashref->{$k};
	}

	if ($items_returned) {
		$bot->OwnerMessage("I have no need for this $name, you can have it back.");
	}

	return $items_returned;
}