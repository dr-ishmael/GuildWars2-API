#!perl

use Modern::Perl '2014';

use DateTime;
use DBI;
use Term::ProgressBar;

use threads;
use threads::shared;
use Thread::Queue;

use GuildWars2::API;
use GuildWars2::API::Utils;

my $VERBOSE = 0;

###
# Set up API interface
my $boss_api = GuildWars2::API->new( nocache => 1 );

# Read config info for database
# This file contains a single line, of the format:
#   <database_type>,<database_name>,<schema_name>,<schema_password>
#
# where <database_type> corresponds to the DBD module for your database.
#
my @db_keys = qw(type name schema pass);
my @db_vals;
open(DB,"database_info.conf") or die "Can't open db info file: $!";
while (<DB>) {
  chomp;
  @db_vals = split (/,/);
  last;
}
close(DB);
my %db :shared;
@db{@db_keys} = @db_vals;

# Connect to database
my $boss_dbh = DBI->connect('dbi:'.$db{'type'}.':'.$db{'name'}, $db{'schema'}, $db{'pass'},{mysql_enable_utf8 => 1})
  or die "Can't connect: $DBI::errstr\n";


# Get the last known build ID from database
print "Looking up last known build ID....." if $VERBOSE;
my $sth_get_build = $boss_dbh->prepare("select ifnull(max(build_id),-1) from build_tb where skins_processed = 'Y'")
  or die "Can't prepare statement: $DBI::errstr";

my $max_build_id = $boss_dbh->selectrow_array($sth_get_build)
  or die "Can't execute statement: $DBI::errstr";

say " $max_build_id" if $VERBOSE;

# Get the current build ID from API
print "Getting current build ID from API..." if $VERBOSE;
my $curr_build_id :shared = $boss_api->build();
say " $curr_build_id" if $VERBOSE;

# Update database if new build
my $new_build :shared = 0;

if ($curr_build_id > $max_build_id) {
  say "New build detected! All skins will be re-fecthed from the API.";
  $new_build = 1;
  # IGNORE in this statement is in case the items process has already done this for this build
  $boss_dbh->do('insert IGNORE into build_tb (build_id) values (?)', {}, $curr_build_id)
    or die "Can't execute statement: $DBI::errstr";
} else {
  say "Not a new build, existing skins will be skipped.";
}

# Get current MD5 and last build ID for all skins from database
my %skin_md5s :shared;

say "Retrieving local MD5 data..." if $VERBOSE;
my $sth_skin_md5 = $boss_dbh->prepare('select skin_id, skin_md5 from skin_index_tb')
  or die "Can't prepare statement: $DBI::errstr";

$sth_skin_md5->execute() or die "Can't execute statement: $DBI::errstr";

while (my $i = $sth_skin_md5->fetchrow_arrayref()) {
  $skin_md5s{$i->[0]} = $i->[1];
}
say scalar(keys %skin_md5s) . " total skins in database.";

# Get list of skins from API
say "Getting current list of skins..." if $VERBOSE;
my @api_skin_ids = $boss_api->list_skins();

my $tot_skins = scalar @api_skin_ids;
say $tot_skins . " total skins in API.";

my @proc_skin_ids;
my $proc_skins;
if ($new_build) {
  @proc_skin_ids = @api_skin_ids;
} else {
  # This computes the list disjunction of skins in the API against skins in our database.
  # We only need to spend time processing skins we don't already know.
  @proc_skin_ids  = grep {not $skin_md5s{$_}} @api_skin_ids;
}

$proc_skins = scalar @proc_skin_ids;

if ($proc_skins == 0) {
  # Short-circuit exit if nothing new to process
  say "No new skins to process; script will now exit";
  exit(0);
} elsif ($proc_skins == $tot_skins) {
  say "All skins will be re-processed.";
} else{
  say $proc_skins . " new skins to be processed.";
}

say "Redirecting STDERR to gw2api.err; please check this file for any warnings or errors generated during the process.";
open(my $olderr, ">&", \*STDERR) or die "Can't dup STDERR: $!";
open(STDERR, ">", ".\\gw2api.err") or die "Can't redirect STDERR: $!";
select STDERR; $| = 1;  # make unbuffered

select STDOUT;

say "Ready to begin processing.";

###
# THREADING! SCARY!
# boss/worker model copied from http://cpansearch.perl.org/src/JDHEDDEN/threads-1.92/examples/pool_reuse.pl

# Maximum working threads
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

# Create queues for threads to report new/changed skin_ids back to the boss
my $new_q = Thread::Queue->new();
my $updt_q = Thread::Queue->new();

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
my @new_skin_arr;
my @updt_skin_arr;

my $progress = Term::ProgressBar->new({name => 'Skins processed', count => $tot_skins, fh => \*STDOUT});
$progress->minor(0);
my $next_update = 0;

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
    last if (scalar @proc_skin_ids == 0);

    # Give the thread some work to do
    my @ids_to_process = splice @proc_skin_ids, 0, 10;
    $work_queues{$tid}->enqueue(@ids_to_process);

    $i += scalar @ids_to_process;
    $next_update = $progress->update($i)
      if $i >= $next_update;
}

# Take note of new/updated skin_ids passed back from threads
while ($new_q->pending() > 0) { push @new_skin_arr, $new_q->dequeue(); }
while ($updt_q->pending() > 0) { push @updt_skin_arr, $updt_q->dequeue(); }

$progress->update($tot_skins)
  if $tot_skins >= $next_update;
say "";

# Signal all threads that there is no more work
$work_queues{$_}->end() foreach keys(%work_queues);

# Wait for all the threads to finish
$_->join() foreach threads->list();

my $now = DateTime->now(time_zone  => 'America/Chicago');

my $rpt_filename = "gw2api_skins_report_".$now->ymd('').$now->hms('').".txt";

open(RPT, ">", $rpt_filename) or die "Can't open report file: $!";

say RPT "NEW";
say RPT "--------";
say RPT $_ foreach (sort { $a <=> $b } @new_skin_arr);
say RPT "";
say RPT "CHANGE";
say RPT "--------";
say RPT $_ foreach (sort { $a <=> $b } @updt_skin_arr);

close(RPT);

say "";
say "GW2API Skins Report";
say "";
say "Statistic  Count";
say "---------- --------";
say sprintf '%-10s %8s', 'TOTAL', $tot_skins;
say sprintf '%-10s %8s', 'PROCESSED', $proc_skins;
say sprintf '%-10s %8s', 'NEW', scalar @new_skin_arr;
say sprintf '%-10s %8s', 'CHANGES', scalar @updt_skin_arr;

say "";
say "For details see $rpt_filename";

#open(STDERR, ">&", $olderr)    or die "Can't dup OLDERR: $!";

# If this was the first time processing this build, update the processed flag
if ($new_build) {
  $boss_dbh->do("update build_tb set skins_processed = 'Y' where build_id = ?", {}, $curr_build_id)
    or die "Unable to updated skins_processed flag: $DBI::errstr";
}

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
  my $log;
  if ($VERBOSE) {
    $log = IO::File->new(">>gw2api_skins_t$tid.log");
    if (!defined($log)) {
      die "Can't open logfile: $!";
    }
    $log->autoflush;
  }

  say $log "This is thread $tid starting up!" if $VERBOSE;

  my $skin_id;

  # Signal the boss if this thread dies
  $SIG{__DIE__} =
    sub {
      my @loc = caller(1);
      print STDERR ">>> Thread $tid (fake) died on skin $skin_id! <<<\n";
      print STDERR "Kill happened at line $loc[2] in $loc[1]:\n", @_, "\n";
      # Add -$tid to head of idle queue to signal termination
      $IDLE_QUEUE->insert(0, -$tid);
      return 1;
    };

  # Create our very own API object
  my $api = GuildWars2::API->new( nocache => 1 );

  # Open a database connection
  say $log "Opening database connection." if $VERBOSE;
  my $dbh = DBI->connect('dbi:'.$db{'type'}.':'.$db{'name'}, $db{'schema'}, $db{'pass'},{mysql_enable_utf8 => 1})
    or die "Can't connect: $DBI::errstr\n";
  say $log "\tDatabase connection established." if $VERBOSE;

  # Prepare the SQL statements we will need
  say $log "Preparing SQL statements." if $VERBOSE;

  # Log the previous version of a changed skin
  my $sth_index_log = $dbh->prepare('
      insert into skin_index_log_tb
      select a.*, ? from skin_index_tb a where skin_id = ?
  ');


  # Upsert a new or changed skin to the index table
  my $sth_index_upsert = $dbh->prepare('
      insert into skin_index_tb (skin_id, skin_json, skin_md5, first_seen_build_id, last_seen_build_id, last_updt_build_id)
      values (?, ?, ?, ?, ?, ?)
      on duplicate key update
        skin_json=VALUES(skin_json)
       ,skin_md5=VALUES(skin_md5)
       ,last_seen_build_id=VALUES(last_seen_build_id)
       ,last_updt_build_id=VALUES(last_updt_build_id)
    ')
    or die "Can't prepare statement: $DBI::errstr";

  # Update the last_seen_dt for an unchanged skin
  my $sth_index_update = $dbh->prepare('update skin_index_tb set last_seen_build_id = ? where skin_id = ?')
    or die "Can't prepare statement: $DBI::errstr";

  # Upsert a new or changed skin to the data table
  my $sth_data_upsert = $dbh->prepare('
      insert into skin_tb (skin_id, skin_name, skin_type, skin_subtype, skin_description, flag_hideiflocked, flag_nocost, flag_showinwardrobe, skin_file_id, skin_file_signature, armor_race, armor_class, weapon_damage_type, skin_warnings)
      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      on duplicate key update
        skin_name=VALUES(skin_name)
       ,skin_type=VALUES(skin_type)
       ,skin_subtype=VALUES(skin_subtype)
       ,skin_description=VALUES(skin_description)
       ,flag_hideiflocked=VALUES(flag_hideiflocked)
       ,flag_nocost=VALUES(flag_nocost)
       ,flag_showinwardrobe=VALUES(flag_showinwardrobe)
       ,skin_file_id=VALUES(skin_file_id)
       ,skin_file_signature=VALUES(skin_file_signature)
       ,armor_race=VALUES(armor_race)
       ,armor_class=VALUES(armor_class)
       ,weapon_damage_type=VALUES(weapon_damage_type)
       ,skin_warnings=VALUES(skin_warnings)
    ')
    or die "Can't prepare statement: $DBI::errstr";

  # Upsert language data
  my $sth_lang_upsert = $dbh->prepare('
      insert into skin_lang_tb (skin_id, skin_name_de, skin_name_es, skin_name_fr)
      values (?, ?, ?, ?)
      on duplicate key update
        skin_name_de=VALUES(skin_name_de)
       ,skin_name_es=VALUES(skin_name_es)
       ,skin_name_fr=VALUES(skin_name_fr)
    ')
    or die "Can't prepare statement: $DBI::errstr";

  say $log "\tSQL statements prepared." if $VERBOSE;

  say $log "Beginning work loop." if $VERBOSE;

  # Work loop
  while (! $TERM) {
    # If the boss has closed the work queue, exit the work loop
    if (!defined($work_q->pending())) {
      say $log "Work queue is closed, exiting work loop." if $VERBOSE;
      last;
    }

    # If we have completed all work in the queue...
    if ($work_q->pending() == 0) {
      say $log "Work queue is empty, signaling ready state." if $VERBOSE;
      # ...indicate that were are ready to do more work
      $IDLE_QUEUE->enqueue($tid);
    }

    # Wait for work from the queue
    say $log "Getting work from the queue..." if $VERBOSE;
    $skin_id = $work_q->dequeue();
    if (!defined($skin_id)) {
      say $log "\tQueue returned undef! I quit." if $VERBOSE;
      last;
    }
    say $log "\tGot work: skin_id = $skin_id" if $VERBOSE;

    #################################
    # HERE'S ALL THE WORK

    my $change_flag = 0;

    say $log "Getting current data from API..." if $VERBOSE;
    my $skin = $api->get_skin($skin_id);
    say $log "\tAPI data retrieved." if $VERBOSE;

    say $log "Looking up existing MD5..." if $VERBOSE;
    my $old_md5 = $skin_md5s{$skin_id};
    if ($old_md5) {
      say $log "\tExisting MD5 is $old_md5." if $VERBOSE;

      if ($old_md5 eq $skin->raw_md5) {
        # No change
        say $log "MD5 unchanged, updating last_seen_dt." if $VERBOSE;
        $sth_index_update->execute($skin_id, $curr_build_id)
          or die "Can't execute statement: $DBI::errstr";
        say $log "\tlast_seen_dt updated." if $VERBOSE;
      } else {
        say $log "New MD5 is ".$skin->raw_md5.", skin data has changed." if $VERBOSE;

        $change_flag = 1;
        $updt_q->enqueue($skin_id);

        say $log "Archiving skin index..." if $VERBOSE;
        $sth_index_log->execute($curr_build_id, $skin_id)
          or die "Can't execute statement: $DBI::errstr";
        say $log "\tIndex archive complete." if $VERBOSE;
      }
    } else {
      say $log "\tSkin is new." if $VERBOSE;
      $change_flag = 1;
      $new_q->enqueue($skin_id);
    }

    if ($change_flag) {
      say $log "Updating skin index..." if $VERBOSE;
      $sth_index_upsert->execute($skin_id, $skin->raw_json, $skin->raw_md5, $curr_build_id, $curr_build_id, $curr_build_id)
        or die "Can't execute statement: $DBI::errstr";
      say $log "\tIndex update complete." if $VERBOSE;

      # New or change
      say $log "Updating skin data..." if $VERBOSE;

      $sth_data_upsert->execute(
         $skin->skin_id
        ,$skin->skin_name
        ,$skin->skin_type
        ,$skin->skin_subtype
        ,$skin->description
        ,$skin->skin_flags->{'HideIfLocked'}
        ,$skin->skin_flags->{'NoCost'}
        ,$skin->skin_flags->{'ShowInWardrobe'}
        ,$skin->icon_file_id
        ,$skin->icon_signature
        ,$skin->armor_race
        ,$skin->armor_weight
        ,$skin->damage_type
        ,$skin->skin_warnings
      )
        or die "Can't execute statement: $DBI::errstr";
      say $log "\tData update complete." if $VERBOSE;

    }

    # Process language data
    say $log "Getting de/es/fr language data" if $VERBOSE;
    my $skin_de = $api->get_skin($skin_id, 'de');
    my $skin_es = $api->get_skin($skin_id, 'es');
    my $skin_fr = $api->get_skin($skin_id, 'fr');

    say $log "Updating skin language data..." if $VERBOSE;
    $sth_lang_upsert->execute(
       $skin_id
      ,$skin_de->skin_name
      ,$skin_es->skin_name
      ,$skin_fr->skin_name
    )
      or die "Can't execute statement: $DBI::errstr";
    say $log "\tLanguage data update complete." if $VERBOSE;

    say $log "\tCompleted processing skin $skin_id." if $VERBOSE;
    # Continue looping until told to terminate
  }

  say $log "Boss signaled abnormal termination." if $TERM && $VERBOSE;

  # All done
  say $log "Terminating database connection..." if $VERBOSE;
  $dbh->disconnect;
  say $log "\tDatabase connection terminated." if $VERBOSE;

  say $log "This is thread $tid signing off." if $VERBOSE;
  $log->close if $VERBOSE;

}
