#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $mode = ">>";
my @prior_ids = ();

if (defined($ARGV[0]) && $ARGV[0] eq "clean") {
  $mode = ">";
} else {
  # Read in item IDs that have already been processed.

  open (IMAIN, "items_t.csv") or die "unable to open file: $!";

  while (<IMAIN>) {
    my ($id) = split(/\|/, $_);
    push @prior_ids, $id;
  }

  close (IMAIN);
}

###
# Open all output files
open(OMAIN, $mode, "items_t.csv") or die "unable to open file: $!\n";

open(OARMOR, $mode, "item_armor_t.csv") or die "unable to open file: $!\n";
open(OBACKX, $mode, "item_back_t.csv") or die "unable to open file: $!\n";
open(OBAGSX, $mode, "item_bags_t.csv") or die "unable to open file: $!\n";
open(OCONSM, $mode, "item_consumables_t.csv") or die "unable to open file: $!\n";
open(OTOOLX, $mode, "item_tools_t.csv") or die "unable to open file: $!\n";
open(OTRNKT, $mode, "item_trinkets_t.csv") or die "unable to open file: $!\n";
open(OUPGRD, $mode, "item_upgrade_components_t.csv") or die "unable to open file: $!\n";
open(OWEAPN, $mode, "item_weapons_t.csv") or die "unable to open file: $!\n";

open(OATTRB, $mode, "item_attributes_t.csv") or die "unable to open file: $!\n";
open(ORNBNS, $mode, "item_rune_bonuses_t.csv") or die "unable to open file: $!\n";

###
# If this is a clean run, initialize the files with header records
if ($mode eq ">") {
  say OMAIN "item_id|game_link|item_name|item_type|item_subtype|level|rarity|description|vendor_value"
          . "|Activity|Dungeon|Pve|Pvp|PvpLobby|Wvw" # game_type_flags
          . "|AccountBound|HideSuffix|NoMysticForge|NoSalvage|NoSell|NotUpgradeable|NoUnderwater|SoulbindOnAcquire|SoulBindOnUse|Unique" #item_flags
          . "|icon_file_id|icon_signature"
          ;

  say OARMOR "item_id|armor_type|armor_class|defense|race|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";
  say OBACKX "item_id|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";
  say OBAGSX "item_id|bag_size|invisible";
  say OCONSM "item_id|consumable_type|food_duration_ms|food_description|unlock_type|unlock_color_id|unlock_recipe_id";
  say OTOOLX "item_id|tool_type|charges";
  say OTRNKT "item_id|trinket_type|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";
  say OUPGRD "item_id|upgrade_type|applies_to|suffix|infusion_type|buff_skill_id|buff_desc";
  say OWEAPN "item_id|weapon_type|damage_type|min_strength|max_strength|defense|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";

  say OATTRB "item_id|attribute|modifier";
  say ORNBNS "item_id|bonus_1|bonus_2|bonus_3|bonus_4|bonus_5|bonus_6";
}

###
# Access the API and get the list of all items
my $api = GuildWars2::API->new;

my @item_ids = $api->list_items();


###
# THREADING! SCARY!
# boss/worker model copied from http://cpansearch.perl.org/src/JDHEDDEN/threads-1.92/examples/pool_reuse.pl
use threads;
use threads::shared;
use Thread::Queue;

# Maximum working threads
my $MAX_THREADS = 10;

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
        # Add -1 to head of idle queue to signal termination
        $IDLE_QUEUE->insert(0, -1);
    };

# Thread work queues referenced by thread ID
my %work_queues;

# Setup a shared hash containing the fileno's of all the filehandles we've opened
# This allows the threads to access the filehandles through their fileno
# from http://www.perlmonks.org/?node_id=494239
my %fhash;

share ($fhash{'main'});
share ($fhash{'armr'});
share ($fhash{'back'});
share ($fhash{'bags'});
share ($fhash{'cons'});
share ($fhash{'tool'});
share ($fhash{'trnk'});
share ($fhash{'upgr'});
share ($fhash{'wepn'});
share ($fhash{'attr'});
share ($fhash{'rune'});

$fhash{'main'} = fileno(OMAIN);
$fhash{'armr'} = fileno(OARMOR);
$fhash{'back'} = fileno(OBACKX);
$fhash{'bags'} = fileno(OBAGSX);
$fhash{'cons'} = fileno(OCONSM);
$fhash{'tool'} = fileno(OTOOLX);
$fhash{'trnk'} = fileno(OTRNKT);
$fhash{'upgr'} = fileno(OUPGRD);
$fhash{'wepn'} = fileno(OWEAPN);
$fhash{'attr'} = fileno(OATTRB);
$fhash{'rune'} = fileno(ORNBNS);

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
    last if ($tid < 0);
    last if (scalar @item_ids == 0);

    # Give the thread some work to do
    my @ids_to_process = splice @item_ids, 0, 10;
    $work_queues{$tid}->enqueue(@ids_to_process);

    say ($i-1) if ($i++ % 1000) == 0;
}

say "$i items processed.";

# Signal all threads that there is no more work
$work_queues{$_}->enqueue(-1) foreach keys(%work_queues);

# Wait for all the threads to finish
$_->join() foreach threads->list();

close(OMAIN);
close(OARMOR);
close(OBACKX);
close(OBAGSX);
close(OCONSM);
close(OTOOLX);
close(OTRNKT);
close(OUPGRD);
close(OWEAPN);
close(OATTRB);
close(ORNBNS);

print("Done\n");

exit(0);


#
#for my $item_id (@item_list) {
#  next if ($item_id ~~ @prior_ids);
#
#
#
#}




### Thread Entry Point Subroutines ###

# A worker thread
sub worker
{
    my ($work_q) = @_;

    # This thread's ID
    my $tid = threads->tid();

    # Open local copies of filehandles
    open (OMAIN, ">>&=$fhash{'main'}") or warn "$!\n";
    open (OARMOR, ">>&=$fhash{'armr'}") or warn "$!\n";
    open (OBACKX, ">>&=$fhash{'back'}") or warn "$!\n";
    open (OBAGSX, ">>&=$fhash{'bags'}") or warn "$!\n";
    open (OCONSM, ">>&=$fhash{'cons'}") or warn "$!\n";
    open (OTOOLX, ">>&=$fhash{'tool'}") or warn "$!\n";
    open (OTRNKT, ">>&=$fhash{'trnk'}") or warn "$!\n";
    open (OUPGRD, ">>&=$fhash{'upgr'}") or warn "$!\n";
    open (OWEAPN, ">>&=$fhash{'wepn'}") or warn "$!\n";
    open (OATTRB, ">>&=$fhash{'attr'}") or warn "$!\n";
    open (ORNBNS, ">>&=$fhash{'rune'}") or warn "$!\n";

    # Work loop
    do {
        # Indicate that were are ready to do work
        #printf("Idle     -> %2d\n", $tid);
        $IDLE_QUEUE->enqueue($tid);

        # Wait for work from the queue
        my $work = $work_q->dequeue();

        # If no more work, exit
        last if ($work < 0);

        # Do some work
        #printf("Working  -> %2d -> %5d\n", $tid, $work);
        process_item($work);

        # Loop back to idle state if not told to terminate
    } while (! $TERM);

    # All done
    #printf("Finished -> %2d\n", $tid);

    close(OMAIN);
    close(OARMOR);
    close(OBACKX);
    close(OBAGSX);
    close(OCONSM);
    close(OTOOLX);
    close(OTRNKT);
    close(OUPGRD);
    close(OWEAPN);
    close(OATTRB);
    close(ORNBNS);

}


sub process_item {
  my ($item_id) = @_;

  my $item = $api->get_item($item_id);

  my $game_link       = $item->game_link;
  (my $item_name      = $item->item_name) =~ s/\n//g;
  my $item_type       = $item->item_type;
  my $item_subtype    = $item->item_subtype || "";
  my $level           = $item->level;
  my $rarity          = $item->rarity;
  (my $description    = $item->description) =~ s/\n/<br>/g;
  my $vendor_value    = $item->vendor_value;
  my $game_type_flags = $item->game_type_flags;
  my $item_flags      = $item->item_flags;
  my $icon_file_id    = $item->icon_file_id;
  my $icon_signature  = $item->icon_signature;

  say OMAIN "$item_id|$game_link|$item_name|$item_type|$item_subtype|$level|$rarity|$description|$vendor_value"
            . '|' . join('|', map { $game_type_flags->{$_} } sort keys %$game_type_flags )
            . '|' . join('|', map { $item_flags->{$_} } sort keys %$item_flags )
            . "|$icon_file_id|$icon_signature"
  ;

  #
  # Armor type data
  #
  if ($item_type eq "Armor") {
    my $armor_type      = $item->armor_type;
    my $armor_class     = $item->armor_class;
    my $defense         = $item->defense || "";
    my $race            = $item->race || "";
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc      = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OARMOR "$item_id|$armor_type|$armor_class|$defense|$race|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";
  }

  #
  # Back type data
  #
  elsif ($item_type eq "Back") {
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc      = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OBACKX "$item_id|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";
  }

  #
  # Bag type data
  #
  elsif ($item_type eq "Bag") {
    my $bag_size            = $item->bag_size;
    my $invisible           = $item->invisible;

    say OBAGSX "$item_id|$bag_size|$invisible";
  }

  #
  # Consumable type data
  #
  elsif ($item_type eq "Consumable") {
    my $consumable_type     = $item->consumable_type;
    my $food_duration_ms    = $item->food_duration_ms || "";
    (my $food_description   = $item->food_description || "") =~ s/\n/<br>/g;
    my $unlock_type         = $item->unlock_type || "";
    my $unlock_color_id     = $item->unlock_color_id || "";
    my $unlock_recipe_id    = $item->unlock_recipe_id || "";

    say OCONSM "$item_id|$consumable_type|$food_duration_ms|$food_description|$unlock_type|$unlock_color_id|$unlock_recipe_id";
  }

  #
  # Tool type data
  #
  elsif ($item_type eq "Tool") {
    my $tool_type       = $item->tool_type;
    my $charges         = $item->charges;

    say OTOOLX "$item_id|$tool_type|$charges";
  }

  #
  # Trinket type data
  #
  elsif ($item_type eq "Trinket") {
    my $trinket_type    = $item->trinket_type;
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc      = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OTRNKT "$item_id|$trinket_type|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";
  }

  #
  # UpgradeComponent type data
  #
  elsif ($item_type eq "UpgradeComponent") {
    my $upgrade_type    = $item->upgrade_type;
    my $applies_to      = $item->applies_to;
    my $suffix          = $item->suffix || "";
    my $infusion_type   = $item->infusion_type || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc      = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OUPGRD "$item_id|$upgrade_type|$applies_to|$suffix|$infusion_type|$buff_skill_id|$buff_desc";

    # Rune subtype data
    if ($item->can('rune_bonuses')) {
      my $rune_bonuses = $item->rune_bonuses;
      s/\n/<br>/g for @$rune_bonuses;
      say ORNBNS "$item_id|" . join('|', @$rune_bonuses);
    }
  }

  #
  # Weapon type data
  #
  elsif ($item_type eq "Weapon") {
    my $weapon_type     = $item->weapon_type;
    my $damage_type     = $item->damage_type;
    my $min_strength    = $item->min_strength || "";
    my $max_strength    = $item->max_strength || "";
    my $defense         = $item->defense || "";
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc      = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OWEAPN "$item_id|$weapon_type|$damage_type|$min_strength|$max_strength|$defense|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";
  }

  #
  # Attributes
  #
  if($item->can('item_attributes')) {
    my $item_attributes = $item->item_attributes;
    foreach my $a (keys %$item_attributes) {
      my $m = $item_attributes->{$a};
      say OATTRB "$item_id|$a|$m";
    }
  }

  return 0;
}
