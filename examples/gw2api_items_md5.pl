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


# Get the current build ID from API
print "Getting current build ID from API..." if $VERBOSE;
my $curr_build_id :shared = $boss_api->build();
say " $curr_build_id" if $VERBOSE;

# Get list of items from API
say "Getting current list of items..." if $VERBOSE;
my @api_item_ids = $boss_api->list_items();

my $tot_items = scalar @api_item_ids;

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

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
say "Entering threaded mode at " . sprintf("%02d:%02d:%02d", $hour, $min, $sec);

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

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
say "All threads complete at " . sprintf("%02d:%02d:%02d", $hour, $min, $sec);

# Set first_seen_build_id for all new items
my $sth_new_item_updt = $boss_dbh->prepare('
   update item_tb
   set first_seen_build_id = ?
   where first_seen_build_id is null
')
or die "Can't prepare statement: $DBI::errstr";

$sth_new_item_updt->execute($curr_build_id);

open(STDERR, ">&", $olderr)    or die "Can't dup OLDERR: $!";


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

  # Prepare the SQL statements we will need
  say $log "Preparing SQL statements." if $VERBOSE;

  # Log the previous version of changed items
  my $sth_log_item_data = $dbh->prepare("
      insert into item_log_tb
      select a.*, $curr_build_id, current_date from item_tb a where item_id in (?)
    ")
    or die "Can't prepare statement: $DBI::errstr";

  # Update the last_seen_dt for unchanged items
  my $sth_update_item_data = $dbh->prepare('update item_tb set last_seen_build_id = ? where item_id in (?)')
    or die "Can't prepare statement: $DBI::errstr";

  # Delete any existing entries on the rune table
  my $sth_delete_rune_data = $dbh->prepare('delete from item_rune_bonus_tb where item_id in (?)')
    or die "Can't prepare statement: $DBI::errstr";

  # Delete any existing entries on the attribute table
  my $sth_delete_attr_data = $dbh->prepare('delete from item_attribute_tb where item_id in (?)')
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
    @item_ids = $work_q->dequeue($WORK_SIZE);
    if (!defined($item_ids[0])) {
      say $log "\tQueue returned undef! I quit." if $VERBOSE;
      last;
    }
    say $log "\tGot work: " . scalar @item_ids . " items" if $VERBOSE;

    #################################
    # HERE'S ALL THE WORK
    # Loop over the item_ids we dequeued
    my @changed_item_md5 = ();

    my @items = $api->get_items(\@item_ids);

    if ($items[0]->can('error')) {
      say STDERR "API returned an error! Aborting item...";
      next;
      ### might need more code here to "clean up" database on errors ###
    }

    foreach my $item (@items) {

      my $change_flag = 0;
      my $item_id = $item->{item_id};

      push (@changed_item_md5, $item_id, $item->md5);

    }

    # We've processed a full batch of items, time to post everything to the database
      # Replace base item data
      my $sth_replace_item_data = $dbh->prepare('
          insert into item_tb (item_id, item_md5)
          values ' .
          join(',', ("(?, ?)") x ((scalar @changed_item_md5) / 2) )
          . ' on duplicate key update item_md5=VALUES(item_md5)'
        ) or die "Can't prepare statement: $DBI::errstr";
      $sth_replace_item_data->execute(@changed_item_md5) or die "Can't execute statement: $DBI::errstr";

    @changed_item_md5 = ();

#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
#say "Thread $tid completed a batch at " . sprintf("%02d:%02d:%02d", $hour, $min, $sec);

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
