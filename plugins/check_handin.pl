sub get_base_id {
	my $item_id = shift;
	$item_id = $item_id % 1000000;
	return $item_id
}

# plugin::check_handin($item1 => #required_amount,...);
# autoreturns extra unused items on success
sub check_handin {
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

	# Make a copy of the original hashref
    my $original_hashref = { %$hashref };

    # Iterate over the hashref and replace each key with its get_base_id(key) version
    foreach my $item (keys %$hashref) {
        my $base_id = get_base_id($item);
        if ($base_id && $base_id ne $item) {
            $hashref->{$base_id} += $hashref->{$item} if exists $hashref->{$base_id};
            $hashref->{$base_id} = $hashref->{$item} unless exists $hashref->{$base_id};
            delete $hashref->{$item};  # Remove the original entry
        }
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
		if (!defined $hashref->{$req} || $hashref->{$req} != $required{$req}) {
			return;
		}
		if ($required{$req} < $hashref->{$req}) {
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
		if ($required{$req} < $hashref->{$req}) {
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
	my $hashref = shift;
	my $silent = shift || 0;
	my $client = plugin::val('$client');
	my $name = plugin::val('$name');
	my $items_returned = 0;

	my %item_data = (
		0 => [ plugin::val('$item1'), plugin::val('$item1_charges'), plugin::val('$item1_attuned'), plugin::val('$item1_inst') ],
		1 => [ plugin::val('$item2'), plugin::val('$item2_charges'), plugin::val('$item2_attuned'), plugin::val('$item2_inst') ],
		2 => [ plugin::val('$item3'), plugin::val('$item3_charges'), plugin::val('$item3_attuned'), plugin::val('$item3_inst') ],
		3 => [ plugin::val('$item4'), plugin::val('$item4_charges'), plugin::val('$item4_attuned'), plugin::val('$item4_inst') ],
	);

	my %return_data = ();	

	foreach my $k (keys(%{$hashref})) {
		next if ($k == 0);
		my $rcount = $hashref->{$k};
		my $r;
		for ($r = 0; $r < 4; $r++) {
			if ($rcount > 0 && $item_data{$r}[0] && $item_data{$r}[0] == $k) {
				if ($client) {
					my $inst = $item_data{$r}[3];
					my $return_count = $inst->RemoveTaskDeliveredItems();
					if ($return_count > 0) {						
						$client->SummonFixedItem($k, $inst->GetCharges(), $item_data{$r}[2]);
						$return_data{$r} = [$k, $item_data{$r}[1], $item_data{$r}[2]];
						$items_returned = 1;
						next;
					}
					$return_data{$r} = [$k, $item_data{$r}[1], $item_data{$r}[2]];					
					$client->SummonFixedItem($k, $item_data{$r}[1], $item_data{$r}[2]);
					$items_returned = 1;
				} else {
					$return_data{$r} = [$k, $item_data{$r}[1], $item_data{$r}[2]];					
					quest::summonfixeditem($k, 0);
					$items_returned = 1;
				}
				$rcount--;
			}
		}

		delete $hashref->{$k};
	}

	$client->SetEntityVariable("RETURN_ITEMS", plugin::GetHandinItemsSerialized("Return", %return_data));

	if ($items_returned && !$silent) {
		quest::say("I have no need for this $name, you can have it back.");
	}

	quest::send_player_handin_event();

	# Return true if items were returned
	return ($items_returned);
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
						quest::summonfixeditem($k);
						$items_returned = 1;
					}
				} else {
					quest::summonfixeditem($k);
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

sub GetHandinItemsSerialized {
	my $type = shift;
	my %hash = @_;
	my @variables = ();

	my %item_data = (
		0 => [ plugin::val('$item1'), plugin::val('$item1_charges'), plugin::val('$item1_attuned'), plugin::val('$item1_inst') ],
		1 => [ plugin::val('$item2'), plugin::val('$item2_charges'), plugin::val('$item2_attuned'), plugin::val('$item2_inst') ],
		2 => [ plugin::val('$item3'), plugin::val('$item3_charges'), plugin::val('$item3_attuned'), plugin::val('$item3_inst') ],
		3 => [ plugin::val('$item4'), plugin::val('$item4_charges'), plugin::val('$item4_attuned'), plugin::val('$item4_inst') ],
	);

	my $hashref = plugin::var('$itemcount'); 

	if ($type eq "Handin") {
		foreach my $k (keys(%{$hashref})) {
			next if ($k eq "copper" || $k eq "silver" || $k eq "gold" || $k eq "platinum" || $k == 0);
			my $rcount = $hashref->{$k};
			for (my $r = 0; $r < 4; $r++) {
				if ($rcount > 0 && $item_data{$r}[0] && $item_data{$r}[0] == $k) {
					my $item_id = $item_data{$r}[0];
					my $item_charges = $item_data{$r}[1];
					my $item_attuned = $item_data{$r}[2];
					push(@variables, $item_id . "|" . $item_charges . "|" . $item_attuned);
				}
			}
		}
	} else {
		foreach my $key (keys %hash) {
			push(@variables, $hash{$key}[0] . "|" . $hash{$key}[1] . "|" . $hash{$key}[2]);
		}
	}

	return join(",", @variables);
}

sub mq_process_items {
	my $hashref = shift;
	my $npc = plugin::val('$npc');
	my $trade = undef;
	
	if ($npc->EntityVariableExists("_mq_trade")) {
		$trade = decode_eqemu_item_hash($npc->GetEntityVariable("_mq_trade")); 
	} else {
		$trade = {};
	}
	
	foreach my $k (keys(%{$hashref})) {
		next if ($k == 0);
		
		if (defined $trade->{$k}) {
			$trade->{$k} = $trade->{$k} + $hashref->{$k};
		} else {
			$trade->{$k} = $hashref->{$k};
		}
	}
	
	my $str = encode_eqemu_item_hash($trade);
	$npc->SetEntityVariable("_mq_trade", $str);
}

sub check_mq_handin {
	my %required = @_;
	my $npc = plugin::val('$npc');
	my $trade = undef;
	
	if ($npc->EntityVariableExists("_mq_trade")) {
		$trade = decode_eqemu_item_hash($npc->GetEntityVariable("_mq_trade"));
	} else {
		return 0;
	}
	
	foreach my $req (keys %required) {
		if ((!defined $trade->{$req}) || ($trade->{$req} < $required{$req})) {
			return 0;
		}
	}
	
	foreach my $req (keys %required) {
		if ($required{$req} < $trade->{$req}) {
			$trade->{$req} -= $required{$req};
		} else {
			delete $trade->{$req};
		}
	}
	
	$npc->SetEntityVariable("_mq_trade", encode_eqemu_item_hash($trade));
	return 1;
}

sub clear_mq_handin {
	my $npc = plugin::val('$npc');
	$npc->SetEntityVariable("_mq_trade", "");
}

sub encode_eqemu_item_hash {
	my $hashref = shift;
	my $str = "";
	my $i = 0;
	
	foreach my $k (keys(%{$hashref})) {
		if ($i != 0) {
			$str .= ",";
		} else {
			$i = 1;
		}
		
		$str .= $k;
		$str .= "=";
		$str .= $hashref->{$k};
	}
	
	return $str;
}

sub decode_eqemu_item_hash {
	my $str = shift;
	my $hashref = { };
	
	my @vals = split(/,/, $str);
	my $val_len = @vals;
	for(my $i = 0; $i < $val_len; $i++) {
		my @subval = split(/=/, $vals[$i]);
		my $subval_len = @subval;
		if ($subval_len == 2) {
			my $key = $subval[0];
			my $value = $subval[1];
			
			$hashref->{$key} = $value;
		}
	}
	
	return $hashref;
}