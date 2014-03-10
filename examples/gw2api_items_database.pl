#!perl -w

use Modern::Perl '2012';

use DBI;
use IO::File;

use GuildWars2::API;


###
# Access the API and get the list of all current "discovered" items
my $api = GuildWars2::API->new;

my @item_ids = $api->list_items();

say scalar @item_ids . " total items to process.";

###
# THREADING! SCARY!
# boss/worker model copied from http://cpansearch.perl.org/src/JDHEDDEN/threads-1.92/examples/pool_reuse.pl
use threads;
use threads::shared;
use Thread::Queue;

# Maximum working threads
#my $MAX_THREADS = 10;
my $MAX_THREADS = 4;

# Flag to inform all threads that application is terminating
my $TERM :shared = 0;

# Threads add their ID to this queue when they are ready for work
# Also, when app terminates a -1 is added to this queue
my $IDLE_QUEUE = Thread::Queue->new();

# Gracefully terminate application on ^C or command line 'kill'
$SIG{'INT'} = $SIG{'TERM'} =
    sub {
        print(">>> Terminating <<<\n");
        $TERM = 1;
        # Add -999 to head of idle queue to signal boss-initiated termination
        $IDLE_QUEUE->insert(0, -999);
    };

# Thread work queues referenced by thread ID
my %work_queues;

# Read config info for database
# This file contains a single line, of the format:
#   <database_type>,<database_name>,<schema_name>,<schema_password>
#
# where <database_type> corresponds to the DBD module for your database.
#
my ($db_type, $db_name, $db_schema, $db_pass) :shared;
open(DB,"database_info.conf") or die "Can't open db info file: $!";
while (<DB>) {
  chomp;
  ($db_type, $db_name, $db_schema, $db_pass) = split (/,/);
  last;
}
close(DB);



# Create the thread pool
for (1..$MAX_THREADS) {
  # Create a work queue for a thread
  my $work_q = Thread::Queue->new();

  # Create the thread, and give it the work queue
  my $thr = threads->create('worker', $work_q);

  # Remember the thread's work queue
  $work_queues{$thr->tid()} = $work_q;
}

my $i = 0;

# Manage the thread pool until signalled to terminate
while (! $TERM) {
    # Wait for an available thread
    my $tid = $IDLE_QUEUE->dequeue();

    # Check for termination condition
    if ($tid < 0) {
      $tid = -$tid;
      # If we initiated the termination, break the loop
      last if $tid == 999;
      # If a worker terminated, clean it up
      #threads->object($tid)->join();
    }
    last if (scalar @item_ids == 0);

    # Give the thread some work to do
    my @ids_to_process = splice @item_ids, 0, 10;
    $work_queues{$tid}->enqueue(@ids_to_process);

    say ($i) if ($i % 1000) == 0;

    $i += scalar @ids_to_process;

    #last if $i >= 200;
}

say "$i items processed.";

# Signal all threads that there is no more work
$work_queues{$_}->end() foreach keys(%work_queues);

# Wait for all the threads to finish
$_->join() foreach threads->list();

print("Done\n");

exit(0);

######################################
### Thread Entry Point Subroutines ###
######################################

# A worker thread
sub worker
{
  # Hook into the work queue assigned to us
  my ($work_q) = @_;

  # This thread's ID
  my $tid = threads->tid();

  # Open a log file
  my $log = IO::File->new(">>gw2api_items_t$tid.log");
  if (!defined($log)) {
    die "Can't open logfile: $!";
  }
  $log->autoflush;

  say $log "This is thread $tid starting up!";

  my $item_id;

  # Signal the boss if this thread dies
  $SIG{__DIE__} =
    sub {
      my @loc = caller(1);
      print STDOUT ">>> Thread $tid died on item $item_id! <<<\n";
      print STDOUT "Kill happened at line $loc[2] in $loc[1]:\n", @_, "\n";
      # Add -$tid to head of idle queue to signal termination
      $IDLE_QUEUE->insert(0, -$tid);
      return 1;
    };

  # Open a database connection
  say $log "Opening database connection.";
  my $dbh = DBI->connect('dbi:'.$db_type.':'.$db_name, $db_schema, $db_pass)
    or die "Can't connect: $DBI::errstr\n";
  say $log "\tDatabase connection established.";

  # Prepare the SQL statements we will need
  say $log "Preparing SQL statements.";
  # Retreive the MD5 hash of existing item data
  my $sth_get_md5 = $dbh->prepare('select item_md5 from item_tb where item_id = ?')
    or die "Can't prepare statement: $DBI::errstr";

  # Upsert a new or changed item to the index table
  my $sth_index_upsert = $dbh->prepare('insert into item_index_tb (item_id) values (?) on duplicate key update last_updt_dt = CURRENT_TIMESTAMP')
    or die "Can't prepare statement: $DBI::errstr";

  # Update the last_seen_dt for an unchanged item
  my $sth_index_update = $dbh->prepare('update item_index_tb set last_seen_dt = CURRENT_TIMESTAMP where item_id = ?')
    or die "Can't prepare statement: $DBI::errstr";

  # Upsert a new or changed item to the data table
  my $sth_data_upsert = $dbh->prepare(
      'insert into item_tb (item_id, item_name, item_type, item_subtype, item_level, item_rarity, item_description, vendor_value, game_type_activity, game_type_dungeon, game_type_pve, game_type_pvp, game_type_pvplobby, game_type_wvw, flag_accountbound, flag_hidesuffix, flag_nomysticforge, flag_nosalvage, flag_nosell, flag_notupgradeable, flag_nounderwater, flag_soulbindonacquire, flag_soulbindonuse, flag_unique, item_file_id, item_file_signature, equip_prefix, equip_infusion_slot, suffix_item_id, buff_skill_id, buff_description, armor_class, armor_race, bag_size, bag_invisible, food_duration_sec, food_description, tool_charges, unlock_type, unlock_color_id, unlock_recipe_id, upgrade_applies_to, upgrade_suffix, upgrade_infusion_type, weapon_damage_type, item_json, item_md5)
       values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
       on duplicate key update
         item_name=VALUES(item_name)
        ,item_type=VALUES(item_type)
        ,item_subtype=VALUES(item_subtype)
        ,item_level=VALUES(item_level)
        ,item_rarity=VALUES(item_rarity)
        ,item_description=VALUES(item_description)
        ,vendor_value=VALUES(vendor_value)
        ,game_type_activity=VALUES(game_type_activity)
        ,game_type_dungeon=VALUES(game_type_dungeon)
        ,game_type_pve=VALUES(game_type_pve)
        ,game_type_pvp=VALUES(game_type_pvp)
        ,game_type_pvplobby=VALUES(game_type_pvplobby)
        ,game_type_wvw=VALUES(game_type_wvw)
        ,flag_accountbound=VALUES(flag_accountbound)
        ,flag_hidesuffix=VALUES(flag_hidesuffix)
        ,flag_nomysticforge=VALUES(flag_nomysticforge)
        ,flag_nosalvage=VALUES(flag_nosalvage)
        ,flag_nosell=VALUES(flag_nosell)
        ,flag_notupgradeable=VALUES(flag_notupgradeable)
        ,flag_nounderwater=VALUES(flag_nounderwater)
        ,flag_soulbindonacquire=VALUES(flag_soulbindonacquire)
        ,flag_soulbindonuse=VALUES(flag_soulbindonuse)
        ,flag_unique=VALUES(flag_unique)
        ,item_file_id=VALUES(item_file_id)
        ,item_file_signature=VALUES(item_file_signature)
        ,equip_prefix=VALUES(equip_prefix)
        ,equip_infusion_slot=VALUES(equip_infusion_slot)
        ,suffix_item_id=VALUES(suffix_item_id)
        ,buff_skill_id=VALUES(buff_skill_id)
        ,buff_description=VALUES(buff_description)
        ,armor_class=VALUES(armor_class)
        ,armor_race=VALUES(armor_race)
        ,bag_size=VALUES(bag_size)
        ,bag_invisible=VALUES(bag_invisible)
        ,food_duration_sec=VALUES(food_duration_sec)
        ,food_description=VALUES(food_description)
        ,tool_charges=VALUES(tool_charges)
        ,unlock_type=VALUES(unlock_type)
        ,unlock_color_id=VALUES(unlock_color_id)
        ,unlock_recipe_id=VALUES(unlock_recipe_id)
        ,upgrade_applies_to=VALUES(upgrade_applies_to)
        ,upgrade_suffix=VALUES(upgrade_suffix)
        ,upgrade_infusion_type=VALUES(upgrade_infusion_type)
        ,weapon_damage_type=VALUES(weapon_damage_type)
        ,item_json=VALUES(item_json)
        ,item_md5=VALUES(item_md5)
      '
    )
    or die "Can't prepare statement: $DBI::errstr";

  # Delete any existing entries on the rune table
  my $sth_delete_rune = $dbh->prepare('delete from item_rune_bonus_tb where item_id = ?')
    or die "Can't prepare statement: $DBI::errstr";

  # Insert rune entries
  my $sth_insert_rune = $dbh->prepare('insert into item_rune_bonus_tb values (?, ?, ?)')
    or die "Can't prepare statement: $DBI::errstr";

  say $log "\tSQL statements prepared.";

  say $log "Beginning work loop.";

  # Work loop
  WORK: { do {
    # If the boss has closed the work queue, exit the work loop
    if (!defined($work_q->pending())) {
      say $log "Work queue is closed, exiting work loop.";
      last;
    }

    # If we have completed all work in the queue...
    if ($work_q->pending() == 0) {
      say $log "Work queue is empty, signaling ready state.";
      # ...indicate that were are ready to do more work
      $IDLE_QUEUE->enqueue($tid);
    }

    # Wait for work from the queue
    say $log "Getting work from the queue...";
    $item_id = $work_q->dequeue();
    say $log "\tGot work: item_id = $item_id";

    #################################
    # HERE'S ALL THE WORK

    say $log "Looking up existing MD5...";
    my $old_md5 = $dbh->selectrow_array($sth_get_md5, undef, $item_id);
    if ($old_md5) {
      say $log "\tExisting MD5 is $old_md5.";
    } else {
      say $log "\tItem is new.";
    }

    say $log "Getting current data from API...";
    my $item = $api->get_item($item_id);
    say $log "\tAPI data retrieved.";

# For the future!
#  my $item_de = $api->get_item($item_id, 'de');
#  my $item_en = $api->get_item($item_id, 'en');
#  my $item_es = $api->get_item($item_id, 'es');
#  my $item_fr = $api->get_item($item_id, 'fr');

    if ($old_md5 && $old_md5 eq $item->raw_md5) {
      # No change
      say $log "MD5 unchanged, updating last_seen_dt.";
      $sth_index_update->execute($item_id)
        or die "Can't execute statement: $DBI::errstr";
      say $log "\tlast_seen_dt updated.";

    } else {
      say $log "New item or MD5 has changed, preparing new data.";
      $sth_index_upsert->execute($item_id);

      my $item_prefix;

      if ($item->item_type ~~ [ 'Armor', 'Back', 'Trinket', 'Weapon', ] ) {
        say $log "Item is equippable, determining prefix...";
        $item_prefix = $api->prefix_lookup($item);
        say $log "\tItem prefix is $item_prefix.";
      }

      # New or change
      say $log "Executing upsert statement...";
      $sth_data_upsert->execute(
         $item->item_id
        ,$item->item_name
        ,$item->item_type
        ,$item->item_subtype
        ,$item->level
        ,$item->rarity
        ,$item->description
        ,$item->vendor_value
        ,$item->game_type_flags->{'Activity'}
        ,$item->game_type_flags->{'Dungeon'}
        ,$item->game_type_flags->{'Pve'}
        ,$item->game_type_flags->{'Pvp'}
        ,$item->game_type_flags->{'PvpLobby'}
        ,$item->game_type_flags->{'Wvw'}
        ,$item->item_flags->{'AccountBound'}
        ,$item->item_flags->{'HideSuffix'}
        ,$item->item_flags->{'NoMysticForge'}
        ,$item->item_flags->{'NoSalvage'}
        ,$item->item_flags->{'NoSell'}
        ,$item->item_flags->{'NotUpgradeable'}
        ,$item->item_flags->{'NoUnderwater'}
        ,$item->item_flags->{'SoulBindOnAcquire'}
        ,$item->item_flags->{'SoulBindOnUse'}
        ,$item->item_flags->{'Unique'}
        ,$item->icon_file_id
        ,$item->icon_signature
        ,$item_prefix
        ,$item->infusion_slot
        ,$item->suffix_item_id
        ,$item->buff_skill_id
        ,$item->buff_desc
        ,$item->armor_class
        ,$item->armor_race
        ,$item->bag_size
        ,$item->invisible
        ,$item->food_duration_sec
        ,$item->food_description
        ,$item->charges
        ,$item->unlock_type
        ,$item->unlock_color_id
        ,$item->unlock_recipe_id
        ,$item->applies_to
        ,$item->suffix
        ,$item->infusion_type
        ,$item->damage_type
        ,$item->raw_json
        ,$item->raw_md5
      )
        or die "Can't execute statement: $DBI::errstr";
      say $log "\tUpsert statement complete.";

      if (ref($item->rune_bonuses) eq 'ARRAY') {
        say $log "Item is a rune. Deleting existing rune data.";
        $sth_delete_rune->execute($item_id)
          or die "Can't execute statement: $DBI::errstr";
        say $log "\tRune data deleted.";

        for my $b (0..$#{$item->rune_bonuses}) {
          say $log "Inserting rune bonus $b...";
          my $bonus = $item->rune_bonuses->[$b];
          $sth_insert_rune->execute($item_id, $b, $bonus)
            or die "Can't execute statement: $DBI::errstr";
          say $log "\tComplete.";
        }
        say $log "\tAll rune data inserted.";
      }
    }
    say $log "\tCompleted processing item $item_id.";
    # Continue looping until told to terminate
  } while (! $TERM); }

  say $log "Boss signaled abnormal termination." if $TERM;

  # All done
  say $log "Terminating database connection...";
  $dbh->disconnect;
  say $log "\tDatabase connection terminated.";

  say $log "This is thread $tid signing off.";
  $log->close;

}
