# When annales was migrated, informations about the cas usernames where lost
# resulting in the impossibility to log with cas. This script patch the database
# by copying uid and names from the users table to uid and cas_name in the cas_user table

use strict;
use warnings;
use DBI;

my $bd		= 'annales';
my $serveur	= 'localhost'; # Il est possible de mettre une adresse IP
my $identifiant = 'root';      # identifiant
my $motdepasse	= 'tata';
my $port	= '';


##### Create DB connection
my $dbh = DBI->connect( "DBI:mysql:database=$bd;host=$serveur;port=$port", $identifiant, $motdepasse, { RaiseError => 1, } ) or die "Connection impossible à la base de données $bd !\n $! \n $@\n$DBI::errstr";

my $sql_select =<<"SQL";
SELECT uid, name FROM users
SQL

my $sql_insert =<<"SQL";
INSERT INTO cas_user (aid, uid, cas_name)
VALUES (?, ?, ?)
SQL

my $req_select = $dbh->prepare($sql_select);
my $req_insert = $dbh->prepare($sql_insert);

$req_select->execute;

my $aid = 1;

while (my ($uid, $name) = $req_select->fetchrow_array)
{
    $req_insert->execute($aid, $uid, $name);
    $aid++;
}

$req_insert->finish;
$req_select->finish;

$dbh->disconnect;
