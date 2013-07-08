### Ce script a été écrit afin de supprimer les préfixes des tables des bases données.
### Ces préfixes étaient indispensables quand tous les sites étaient dans une même base de données.

use strict;
use warnings;
use DBI;

my $bd		= $ARGV[0];
my $serveur	= 'localhost'; # Il est possible de mettre une adresse IP
my $identifiant = 'root';      # identifiant
my $motdepasse	= 'tata';
my $port	= '';

my ($prefix) = $ARGV[1];

my $dbh = DBI->connect( "DBI:mysql:database=$bd;host=$serveur;port=$port", $identifiant, $motdepasse, { RaiseError => 1, } ) or die "Connection impossible à la base de données $bd !\n $! \n $@\n$DBI::errstr";

my @table_names = $dbh->tables;
foreach my $table(@table_names)
{
    #print $table =~ m/$prefix/;
    #print $table . "\n";

    if( $table =~ m/^`$bd`\.`$prefix/ )
    {
	my ($new_name) = ( $table =~ m/$prefix(.*)`/ );
	my $new_table = "`$bd`.`$new_name`";
	print $new_name . "\n";
	print $new_table . "\n";
	$dbh->do('DROP TABLE IF EXISTS ' . $new_name);
	$dbh->do('RENAME TABLE ' . $table . ' TO ' . $new_name) or die 'Ne peut exécuter la requête';
    }
}

$dbh->disconnect();
