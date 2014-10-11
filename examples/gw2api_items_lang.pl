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

### TEST ###
$db{'name'} = $db{'name'} . '_test';
### TEST ###

# Connect to database
my $boss_dbh = DBI->connect('dbi:'.$db{'type'}.':'.$db{'name'}, $db{'schema'}, $db{'pass'},{mysql_enable_utf8 => 1})
  or die "Can't connect: $DBI::errstr\n";

# Get list of items from API
say "Getting current list of items..." if $VERBOSE;
my @api_item_ids = $boss_api->list_items();

my $tot_items = scalar @api_item_ids;
say $tot_items . " total items in API.";

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

# Size of each work batch (how many items a thread processes at once)
my $WORK_SIZE :shared = 200;

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

#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
#say "Entering threaded mode at " . sprintf("%02d:%02d:%02d", $hour, $min, $sec);

my $progress = Term::ProgressBar->new({name => 'Items processed', count => $tot_items, fh => \*STDOUT});
$progress->minor(0);
my $next_update = 0;

# Manage the thread pool until signalled to terminate
while (! $TERM) {
    # Wait for an available thread
    my $tid = $IDLE_QUEUE->dequeue();

    # Update progress bar here because work has completed at this point
    $next_update = $progress->update($i)
      if $i >= $next_update;

    # Check for termination condition
    if ($tid < 0) {
      $tid = -$tid;
      # If we initiated the termination, break the loop
      last if $tid == 999;
      # If a worker terminated, clean it up
      #threads->object($tid)->join();
    }
    last if (scalar @api_item_ids == 0);

    # Give the thread some work to do
    my @ids_to_process = splice @api_item_ids, 0, $WORK_SIZE;
    $work_queues{$tid}->enqueue(@ids_to_process);

    $i += scalar @ids_to_process;
}

$progress->update($tot_items)
  if $tot_items >= $next_update;
say "";

# Signal all threads that there is no more work
$work_queues{$_}->end() foreach keys(%work_queues);

# Wait for all the threads to finish
$_->join() foreach threads->list();

open(STDERR, ">&", $olderr)    or die "Can't dup OLDERR: $!";

# Update the processed flag
my $curr_build_id = $boss_api->build();
$boss_dbh->do("update build_tb set items_lang_processed = 'Y' where build_id = ?", {}, $curr_build_id)
  or die "Unable to updated items_lang_processed flag: $DBI::errstr";

exit(0);





######################################
### Thread Entry Point Subroutines ###
######################################

# A worker thread
sub worker
{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
  # Hook into the work queue assigned to us
  my ($work_q) = @_;

  # This thread's ID
  my $tid = threads->tid();

  # Open a log file
  my $log;
  if ($VERBOSE) {
    $log = IO::File->new(">>gw2api_items_t$tid.log");
    if (!defined($log)) {
      die "Can't open logfile: $!";
    }
    $log->autoflush;
  }

  say $log "This is thread $tid starting up!" if $VERBOSE;

  my @item_ids;
  my $item_id;

  # Signal the boss if this thread dies
  $SIG{__DIE__} = sub {
      my @loc = caller(1);
      say STDERR ">>> Thread $tid (fake) died! <<<";
      if (defined($item_id)) { say STDERR ">>> Item id: $item_id <<<" }
      say STDERR "Kill happened at line $loc[2] in $loc[1]:\n", @_;
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
    @item_ids = $work_q->dequeue($WORK_SIZE);
    if (!defined($item_ids[0])) {
      say $log "\tQueue returned undef! I quit." if $VERBOSE;
      last;
    }
    say $log "\tGot work: " . scalar @item_ids . " items" if $VERBOSE;

    #################################
    # HERE'S ALL THE WORK
    # Loop over the item_ids we dequeued
    my %item_lang_data = ();

    foreach my $lang ('de', 'es', 'fr') {

      my @items = $api->get_items(\@item_ids, $lang);

      if ($items[0]->can('error')) {
        say STDERR "API returned an error! Aborting item...";
        next;
        ### might need more code here to "clean up" database on errors ###
      }

      foreach my $item (@items) {

        my $item_id = $item->{item_id};

        say $log "Preparing new/updated item data..." if $VERBOSE;

        $item_lang_data{$item_id}->{'name_'.$lang} = $item->item_name;
        $item_lang_data{$item_id}->{'desc_'.$lang} = $item->description;

        say $log "\tCompleted processing item $item_id." if $VERBOSE;

    }

    my @final_data = ();
    foreach my $item_id (keys %item_lang_data) {
      push (@final_data
        ,$item_id
        ,$item_lang_data{$item_id}->{'name_de'}
        ,$item_lang_data{$item_id}->{'desc_de'}
        ,$item_lang_data{$item_id}->{'name_es'}
        ,$item_lang_data{$item_id}->{'desc_es'}
        ,$item_lang_data{$item_id}->{'name_fr'}
        ,$item_lang_data{$item_id}->{'desc_fr'}
      );
    }

    # Upsert language data
    my $sth_replace_lang_data = $dbh->prepare('
        replace into item_lang_tb (item_id, item_name_de, item_name_es, item_name_fr, item_description_de, item_description_es, item_description_fr)
        values ' .
        join(',', ("(?, ?, ?, ?, ?, ?, ?)") x scalar @item_ids) # we will always process lang data for all items
      ) or die "Can't prepare statement: $DBI::errstr";
    $sth_replace_lang_data->execute(@final_data) or die "Can't execute statement: $DBI::errstr";

    %item_lang_data = ();

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
say "Thread $tid completed a batch at " . sprintf("%02d:%02d:%02d", $hour, $min, $sec);

    # Continue looping until told to terminate or queue is closed
  }

  say $log "Boss signaled abnormal termination." if $TERM && $VERBOSE;

  # All done
  say $log "Terminating database connection..." if $VERBOSE;
  $dbh->disconnect;
  say $log "\tDatabase connection terminated." if $VERBOSE;

  say $log "This is thread $tid signing off." if $VERBOSE;
  $log->close if $VERBOSE;

}
