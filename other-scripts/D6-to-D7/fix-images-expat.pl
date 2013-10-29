# In the expat website, when we try to migarte it, the images not found
# and the only solution we found is to use this script to patch its database
# and so repair the links

use strict;
use warnings;
use DBI;

my $db = 'expat';
my $server = 'localhost';
my $user = 'root';
my $password = 'tata';
my $port = '';

#### Create DB connection
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$server;port=$port", $user, $password, { RaiseError => 1, }) or die "Cannont connect to database $db";

# Update user's pictures

my $sql_select =<<"SQL";
SELECT uid, picture FROM expat_users
SQL

my $sql_update =<<"SQL";
UPDATE expat_users SET picture = ? WHERE uid = ?
SQL

my $req_select = $dbh->prepare($sql_select);
my $req_update = $dbh->prepare($sql_update);
$req_select->execute;

while (my ($uid, $picture) = $req_select->fetchrow_array)
{
    $picture =~ s#sites/assos.centrale-marseille.fr.expat/(.*)#sites/default/$1#;
    $req_update->execute($picture, $uid);
}

$req_update->finish;
$req_select->finish;

# Update other file
$sql_select = "SELECT fid, filepath FROM expat_files";
$sql_update = "UPDATE expat_files SET filepath = ? WHERE fid = ?";

$req_select = $dbh->prepare($sql_select);
$req_update = $dbh->prepare($sql_update);
$req_select->execute;

while (my ($fid, $file_path) = $req_select->fetchrow_array)
{
    $file_path =~ s#sites/assos.centrale-marseille.fr.expat/(.*)#sites/default/$1#;
    $req_update->execute($file_path, $fid);
}

$req_update->finish;
$req_select->finish;

$dbh->disconnect;
