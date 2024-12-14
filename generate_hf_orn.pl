#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use POSIX;
use JSON;

# Elegant Azure
# Elegant Crimson
# Elegant Verdant
# Ornate Azure
# Ornate Crimson
# Ornate Verdant

# Resplendant

# Configuration Variables
my $original_name_prefix = '`Heroic Argent Plate'; # Prefix to match in the original Name
my $new_name_prefix = '`Resplendant Plate';       # Prefix for the new Name
my $new_model_id_base = 206;                          # New base for the herosforgemodel (numeric)

# Database Connection
sub LoadMysql {
    use DBI;
    use DBD::mysql;
    use JSON;

    my $json = JSON->new();

    #::: Load Config
    my $content;
    open(my $fh, '<', "../eqemu_config.json") or die "Cannot open config file: $!";
    {
        local $/;
        $content = <$fh>;
    }
    close($fh);

    #::: Decode
    my $config = $json->decode($content);

    #::: Set MySQL Connection vars
    my $db   = $config->{"server"}{"content_database"}{"db"};
    my $host = $config->{"server"}{"content_database"}{"host"};
    my $user = $config->{"server"}{"content_database"}{"username"};
    my $pass = $config->{"server"}{"content_database"}{"password"};

    #::: Map DSN
    my $dsn = "dbi:mysql:$db:$host:16033";

    #::: Connect and return
    my $connect = DBI->connect($dsn, $user, $pass, { RaiseError => 1, PrintError => 0 });

    return $connect;
}

# Use the LoadMysql function to get the database handle
my $dbh = LoadMysql();

# Check if successfully connected
unless ($dbh) {
    die "Failed to connect to database.";
}

# Step 1: Select rows matching the pattern (using the configurable original Name prefix)
my $select_query = $dbh->prepare(<<'SQL');
    SELECT *
    FROM items
    WHERE Name LIKE ?
SQL

$select_query->execute("$original_name_prefix%");

while (my $row = $select_query->fetchrow_hashref()) {
    # Step 2: Extract values from the original row
    my $old_name = $row->{Name};
    my $old_id = $row->{id};

    # Step 3: Calculate the new values
    my $slot_id = substr($old_id, -1); # Least significant digit of the ID
    my $new_name = $old_name =~ s/^\Q$original_name_prefix\E/$new_name_prefix/r;
    my $new_herosforgemodel = ($new_model_id_base * 100) + $slot_id;
    my $new_id = 700000 + ($new_model_id_base * 10) + $slot_id;

    # Step 4: Update values in the row hash
    $row->{Name} = $new_name;
    $row->{herosforgemodel} = $new_herosforgemodel;
    $row->{id} = $new_id;

    # Step 5: Construct dynamic SQL for insertion
    my $columns = join(", ", map { "`$_`" } keys %$row);       # Add backticks around column names
    my $placeholders = join(", ", map { "?" } keys %$row);
    my @values = values %$row;

    my $insert_sql = "INSERT INTO items ($columns) VALUES ($placeholders)";
    my $insert = $dbh->prepare($insert_sql);

    eval {
        $insert->execute(@values);
    };

    if ($@) {
        print "Failed to insert row for Name: $new_name. Error: $@\n";
    } else {
        print "Inserted new row: ID=$new_id, Name=$new_name, HerosForgeModel=$new_herosforgemodel\n";
    }

    $insert->finish();
}

# Clean up
$select_query->finish();
$dbh->disconnect();
