sub EVENT_ITEM { 
	my $copper = plugin::val('copper');
	my $silver = plugin::val('silver');
	my $gold = plugin::val('gold');
	my $platinum = plugin::val('platinum');
	my $clientName = $client->GetCleanName();

	my $total_money = ($platinum * 1000) + ($gold * 100) + ($silver * 10) + $copper;
	my $dbh = plugin::LoadMysql();

	foreach my $item_id (keys %itemcount) {
	  if ($item_id != 0) {
		 quest::debug("I was handed: $item_id with a count of $itemcount{$item_id}");

		 my $item_name = quest::getitemname($item_id % 1000000);

		 quest::debug("looking for: '" . $item_name . "' Glamour-Stone");

		 # Use a prepared statement to prevent SQL injection
		 my $sth = $dbh->prepare('SELECT id FROM items WHERE name LIKE ?');
		 $sth->execute("'" . $item_name . "' Glamour-Stone");
		 if (my $row = $sth->fetchrow_hashref()) {                
			   if ($total_money >= (5000 * 1000)) {
				  $total_money -= (5000 * 1000);
				  plugin::Whisper("Perfect! Here, I had a Glamour-Stone almost ready. I'll just need to attune it to your $item_name! Enjoy!");
				  $client->SummonItem($row->{id});
				  
				  # Remove the $item_id from the hash %itemcount
				  delete $itemcount{$item_id};                  
			   } else {
				  plugin::Whisper("I must insist upon my fee $clientName for the $item_name. Please ensure you have enough for all your items.");
			   }
		 } else {
			   plugin::Whisper("I don't think that I can create a Glamour-Stone for that item, $clientName. It must be something that you hold in your hand, such as a weapon or shield.");
		 }
	  }
	}  
   
	# After processing all items, return any remaining money
	my $platinum_remainder = int($total_money / 1000);
	$total_money %= 1000;

	my $gold_remainder = int($total_money / 100);
	$total_money %= 100;

	my $silver_remainder = int($total_money / 10);
	$total_money %= 10;

	my $copper_remainder = $total_money;

	$client->AddMoneyToPP($copper_remainder, $silver_remainder, $gold_remainder, $platinum_remainder, 1);
	plugin::return_items(\%itemcount); 

}

sub EVENT_SAY {
	my $response = "";
	my $clientName = $client->GetCleanName();

	my $link_services 		= "[".quest::saylink("link_services", 1, "services")."]";
	my $link_services_2 		= "[".quest::saylink("link_services", 1, "do for you")."]";
	my $link_glamour_stone 	= "[".quest::saylink("link_glamour_stone", 1, "Glamour-Stone")."]";
	my $link_custom_work		= "[".quest::saylink("link_custom_work", 1, "custom enchantments")."]";
	my $link_echo_of_memory  = "[".quest::saylink("link_echo_of_memory", 1, "Echo of Memory")."]";
	my $link_random_ornament = "[".quest::saylink("link_random_ornament", 1, "random ornament")."]";
	my $link_random_armor	= "[".quest::saylink("link_random_armor", 1, "random armor ornament")."]";

	if($text=~/hail/i) {
		if (!$client->GetBucket("Tawnos")) {
			$response = "Hail, $clientName. You may refer to me as the Purveyor of Glamour, master artificer and enchanter! 
						I am still setting up my facilities here in the Bazaar, but I can already offer some $link_services to eager customers.";
		} else {
			$response = "Welcome back, $clientName. What can I $link_services_2 today? ";
		}    
	}

	elsif ($text eq "link_services") {
		$response = "Primarily, I can enchant a $link_glamour_stone for you. A speciality of my own invention, these augments can change the 
					appearance of your equipment to mimic another item that you posess. I do charge a nominal fee, a mere 5000 platinum coins, 
					for this service AND more importantly, the item you want to glamour WILL be sacrificed. 
					I aim to offer $link_custom_work for my most discerning customers soon, too.";
		$client->SetBucket("Tawnos", 1);
	}

	elsif ($text eq "link_glamour_stone") {
		$response = "If you are interested in a $link_glamour_stone, simply hand me the item which you'd like me to duplicate, along with my fee. PLEASE NOTE: Any item you hand me WILL be devoured in the glamour process.";
	}

	elsif ($text eq "link_custom_work") {
		$response = "I can produce a Glamour-Stone of a remarkable and unique nature, based upon whatever item my muse conjures. 
					There is no predicting what illusion may be produced! I will only embark upon this artistic work in exchange 
					for two $link_echo_of_memory, however. Would you like me to produce a $link_random_ornament, or a $link_random_armor for you?";
	}

	elsif ($text eq "link_echo_of_memory") {
		$response = "These are rare fragments of a previous age. Rumor is, only by great service to the realm can you obtain them.";
	}

	elsif ($text eq "link_random_armor") {
		my $eom_available = $client->GetAlternateCurrencyValue(6);

		if ($eom_available < 2) {
			$response = "I'm sorry, $clientName. You don't have enough Echo of Memory, please return when you have enough to pay me.";
		} else {
			my $random_result = get_random_armor();

			if ($random_result && plugin::SpendEOM($client, 2)) {
				$client->SummonItem($random_result);
			}
		}
	}

	elsif ($text eq "link_random_ornament") {
		my $eom_available = $client->GetAlternateCurrencyValue(6);

		if ($eom_available < 2) {
			$response = "I'm sorry, $clientName. You don't have enough Echo of Memory, please return when you have enough to pay me.";
		} else {
			my $random_result = get_random_glamour();

			if ($random_result && plugin::SpendEOM($client, 2)) {
				$client->SummonItem($random_result);
			}
		}
	}

	if ($response) {
		plugin::Whisper($response);
	}
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

sub get_random_glamour {
    my $dbh = plugin::LoadMysql();
    
    # Prepare the SQL statement
    my $sql = q{
				WITH limited_items AS (
					SELECT
						name,
						idfile,
						MIN(id) AS lowest_id
					FROM (
						SELECT
							name,
							idfile,
							id,
							ROW_NUMBER() OVER (PARTITION BY idfile ORDER BY id ASC) AS rn
						FROM
							items
						WHERE
							slots & (16384 | 8192 | 2048)
							AND races > 0
							AND classes > 0
							AND ((slots & 2048 AND itemtype = 5) OR (slots & (16384 | 8192)))
							AND itemtype != 54
							AND name NOT LIKE 'Summoned%'
							AND id < 1000000
					) sub
					WHERE
						rn <= 10
					GROUP BY
						idfile, name
				)
				SELECT
					i.id
				FROM
					items i
				JOIN
					limited_items li ON i.name = CONCAT("'", li.name, "' Glamour-Stone")
				ORDER BY RAND()
				LIMIT 1;
    };

    # Prepare the SQL statement
    my $sth = $dbh->prepare($sql);
    
    # Execute the statement
    $sth->execute();

    # Fetch the result (a random item id)
    my $id = $sth->fetchrow(); 
    if (defined $id) {
        quest::debug("Random Ornament: $id");
    } else {
        $client->Message(13, "ERROR: Unable to retrieve random ornament. Seek help on #bugs in Discord.");
    }

    # Return the fetched ID
    return $id;
}

sub get_random_armor {
    my $dbh = plugin::LoadMysql();
    
    # Prepare the SQL statement
    my $sql = q{
				SELECT id
					FROM (
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Heroic %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Elegant %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Elegant %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Elegant %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Elegant %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Ornate %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Ornate %` Glamour-Stone"
						UNION ALL
						SELECT i.id, i.Name FROM items i WHERE i.Name LIKE "`Resplendant %` Glamour-Stone"
					) weighted_items
					ORDER BY RAND()
					LIMIT 1;
    };

    # Prepare the SQL statement
    my $sth = $dbh->prepare($sql);
    
    # Execute the statement
    $sth->execute();

    # Fetch the result (a random item id)
    my $id = $sth->fetchrow(); 
    if (defined $id) {
        quest::debug("Random Ornament: $id");
    } else {
        $client->Message(13, "ERROR: Unable to retrieve random ornament. Seek help on #bugs in Discord.");
    }

    # Return the fetched ID
    return $id;
}



