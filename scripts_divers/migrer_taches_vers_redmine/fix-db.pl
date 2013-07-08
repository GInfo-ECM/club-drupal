# In order to complete the migration to Redmine, we need to preserve date
# and username. To do this, we need to fix the database.

use strict;
use warnings;
use DBI;

my $db		= 'redmine_default';
my $server	= 'localhost'; # Il est possible de mettre une adresse IP
my $user        = 'root';      # identifiant
my $passwd	= 'tata';
my $port	= '';


##### Create DB connection
my $dbh = DBI->connect( "DBI:mysql:database=$db;host=$server;port=$port", $user, $passwd, { RaiseError => 1, } ) or die "Connection impossible à la base de données $db !\n $! \n $@\n$DBI::errstr";



###### Initialisation of hashes needed to fix URL
open(my $fix_url_issues_csv, '<', 'fix_url_issues.csv') or die "Couldn't open fix_url_issues.csv";
my %name2iid = ();
my %nid2iid = ();
my %cid2iid = ();
my %cid2post_nb = ();

while (my $line = <$fix_url_issues_csv>)
  {
    chomp $line;
    my ($nid, $name, $iid) = split ",", $line;
    $name2iid{$name} = $iid;
    $nid2iid{$nid} = $iid;
  }
close $fix_url_issues_csv;

open(my $fix_url_comments_csv, '<', 'fix_url_comments.csv') or die "Couldn't open fix_url_comments.csv";
while (my $line = <$fix_url_comments_csv>)
  {
    chomp $line;
    my ($cid, $iid, $post_nb) = split ",", $line;
    $cid2iid{$cid} = $iid;
    $cid2post_nb{$cid} = $post_nb;
  }
close $fix_url_comments_csv;



###### Definition of functions
sub fix_issues_link {
    my $text = $_[0];

    # Find all links in text
    my @links = ($text =~ m/:http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)(?:content\/t%C3%A2che|node)\/(.*)/g);

    if ( @links )
    {
	foreach (@links)
	{
	    print $_ ."\n";
	    $text =~ s/"http:\/\/assos\.centrale-marseille\.fr(\/|\/lessive\/)(content\/t%C3%A2che|node)\/.*":http:\/\/assos\.centrale-marseille\.fr(\/|\/lessive\/)(content\/t%C3%A2che|node)\/$_/#$cid2iid{$_}#note-$cid2post_nb{$_}/g;
	}
    }
    return $text;
}

sub fix_comments_link {
    my $text = $_[0];

    # Find all links in text
    my @links = $text =~ m/"http:\/\/assos\.centrale-marseille\.fr(\/|\/lessive\/)comment\/.*"/g;

     # Foreach link, get comment cid.
    my @cids = ();
    if (@links)
    {
	foreach (@links)
	{
	    my $cid =~ s/"http:\/\/assos\.centrale-marseille\.fr(\/|\/lessive\/)comment\/(.*)#.*"/$1/g;
	    push @cids, $cid;
	}

	foreach (@cids)
	{
	    $text =~ s/"http:\/\/assos\.centrale-marseille\.fr(\/|\/lessive\/)comment\/$_#$_":http:\/\/assos\.centrale-marseille\.fr\/comment\/$_#$_/#$name2iid{$_}/g;
	}
    }

    return $text;
}



###### Update issues
my $sql_update_issue =<<"SQL";
UPDATE issues
  SET author_id = ?, created_on = ?
  WHERE  id = ?
SQL

my $sql_fix_links_issue =<<"SQL";
UPDATE issues
    SET description = ?
    WHERE id = ?
SQL

my $req_update_issue = $dbh->prepare($sql_update_issue);
my $req_fix_links_issue = $dbh->prepare($sql_fix_links_issue);

# Reading file
open(my $issues, '<issues.csv') or die "Couldn't open issues.txt\n";

while (my $line = <$issues>)
  {
    # Update author and date of creation
    chomp $line;

    my ($iid, $author_id, $created_on, $nid, $name) = split ",", $line;

    $req_update_issue->execute($author_id, $created_on, $iid);

    ## Fix links
    # issues
    my $select_description = "SELECT description FROM issues WHERE id = 1569";

    my ($description) = $dbh->selectrow_array($select_description);

    $description = fix_issues_link($description);

    die "stop";

    print $description . "\n";
#    print $links[0];
#    print $name2iid{$links[0]};
    # Comments
#    $description = fix_comments_link($description);

#    $req_fix_links_issue->execute($description, $iid);
  }

$req_update_issue->finish;
$req_fix_links_issue->finish;


###### Update journals
my $sql_get_id =<<"SQL";
SELECT id FROM journals WHERE journalized_id = ?
ORDER BY created_on ASC
SQL

my $sql_update_journals =<<"SQL";
UPDATE journals
SET created_on = ?, user_id = ?
WHERE id = ?
SQL

my $sql_updated_on =<<"SQL";
UPDATE issues SET updated_on = ?
WHERE id = ?
SQL

my $sql_fix_links_comment =<<"SQL";
UPDATE journals
    SET notes = ?
    WHERE id = ?
SQL

my $req_get_id = $dbh->prepare($sql_get_id);
my $req_update_journals = $dbh->prepare($sql_update_journals);
my $req_updated_on = $dbh->prepare($sql_updated_on);
my $req_fix_links_comment = $dbh->prepare($sql_fix_links_comment);

# Reading file.
open(my $comments, '<comments.csv') or die "Couldn't open comments.txt\n";

# We must remember current iid in order to fetch result or execute query: req_get_id return
# more than one value
my $current_iid = -1;

while (my $line = <$comments>)
  {
    chomp $line;

    my ($iid, $user_id, $created_on) = split ",", $line;

    # We get the id of the comment.
    if ($current_iid != $iid)
    {
	$current_iid = $iid;
	$req_get_id->execute($iid);
    }

    my ($id) = $req_get_id->fetchrow_array;

    # We do the update.
    $req_update_journals->execute($created_on, $user_id, $id);
    $req_updated_on->execute($created_on, $iid);

    ## Fix links.
    # issues
    my $select_notes = "SELECT notes FROM journals WHERE id = $id";
    my ($notes) = $dbh->selectrow_array($select_notes);
#    $notes = fix_issues_link($notes);
    # Comments
#    $notes = fix_comments_link($notes);

#    $req_fix_links_comment->execute($notes, $id);
  }

$req_get_id->finish;
$req_update_journals->finish;
$req_updated_on->finish;

####### Close the db connection.
$dbh->disconnect;
