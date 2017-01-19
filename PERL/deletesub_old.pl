#!/usr/bin/perl 

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

$cableprov{'billings'}{'primary'} = "cableprov1";
$cableprov{'billings'}{'secondary'} = "cableprov0";
$cableprov{'grandjunction'}{'primary'} = "cableprov3";
$cableprov{'grandjunction'}{'secondary'} = "cableprov2";
$cableprov{'cheyenne'}{'primary'} = "cableprov6";
$cableprov{'cheyenne'}{'secondary'} = "cableprov4";
$cableprov{'missoula'}{'primary'} = "cableprov7";
$cableprov{'missoula'}{'secondary'} = "cableprov5";

#Define your variables
my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$sth3,$sth4,$sth5,$sth6,$sth7,$sth8,$sth9,$dbname,$acctnum,$parentref);

$acctnum=$ARGV[0];
$is_mac=$ARGV[1];
$contact='jsoria';
$domain='bresnan.com';
$test='1';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);


        $dbh = DBI->connect('dbi:Oracle:samprd',$usr,$passwd) || die "Cannot establish connection to the database";
        $dbh->{RaiseError}=1;
		print "Starting search for account\n";
        	$sth=$dbh->prepare(q{select distinct parentref from pi where userid= ?});
        	$sth->execute($acctnum);
        	$sth->bind_columns({},\($parentref));

        	while ($sth->fetch)
                {


		$sth2=$dbh->prepare(q{update pi set deletestatus=1 where userid=?});
        	$sth2->execute($acctnum);

		$sth3=$dbh->prepare(q{update hsd set deletestatus=1 where parentref=?});
        	$sth3->execute($parentref);

		$sth4=$dbh->prepare(q{update voice set deletestatus=1 where parentref=?});
        	$sth4->execute($parentref);

		$sth5=$dbh->prepare(q{update email set deletestatus=1 where parentref=?});
        	$sth5->execute($parentref);

		$sth6=$dbh->prepare(q{update subscriber set deletestatus=1 where recordnumber=?});
        	$sth6->execute($parentref);

		$sth7=$dbh->prepare(q{update subscribertopackage set deletestatus=1 where parentref=?});
        	$sth7->execute($parentref);

		$sth8=$dbh->prepare(q{update subs_service_to_device set deletestatus=1 where subscriber_ref=?});
        	$sth8->execute($parentref);

		$sth9=$dbh->prepare(q{delete from pi where userid = ?});
        	$sth9->execute($acctnum);
		
		print "$acctnum Deleted from Alopa Database\n";

                }
	print "search finished\n";

sub remove_from_cableprov
{
	$mac = $_[0];
	$mta = $_[1];
	@macary = ( $mac, $mta );
        foreach $cm (@macary)
        {
		if($cm eq "")
		{
			print "device not found\n";
			next;
		}
		$found = 0;
		if($count == 0)
                {
                        print "Checking cm $cm on the cable provs\n";
                        $count++;
                }
                else
                {
                        print "Checking mta mac $cm on the cable provs\n";
                        $count++;
                }
        	foreach $zone (keys(%cableprov))        #goes though each cableprov group
        	{
                        open(MODEM, "> /home/cowen/deletemodem.txt") || die "unable to open file";
                        $found = 0;
                        $cp = $cableprov{$zone}{'primary'};     #primary cableprov address
                        $cp2nd = $cableprov{$zone}{'secondary'};        #secondary cableprov site
			print "csp.org -- $cp, $cp2nd\n";
                        @output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/csp.org" 2>/dev/null`; #grep csp.org for mac
                        foreach $line (@output)
                        {
                                $found = 1;
                                print "$line";
                                print MODEM "2|$line"; #attach 2| to lines with mac in it
                        }
			print "deviceBinding.org -- $cp, $cp2nd\n";
                        @output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/deviceBinding.org" 2>/dev/null`; #grep devicebinding.org for mac
			foreach $line (@output)
                        {
                                print "$line";
                                if($count == 1)
                                {
                                        $found = 1;
                                        print MODEM "4|$line"; #attach 4| to lines with mac in it
                                }
                        }
			print "static.org -- $cp, $cp2nd\n";
			@output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/static.org" 2>/dev/null`; #grep static for mac
                        foreach $line (@output)
                        {
                                $found = 1;
                                print "$line";
                                print MODEM "6|$line"; #attach 6| to lines with mac in it
                        }
			print "mtaSpecific.org -- $cp, $cp2nd\n";
                        @output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/mtaSpecific.org" 2>/dev/null`; #grep mtaSpecific.org for mac
                        foreach $line (@output)
                        {
                                $found = 1;
                                print "$line";
                                print MODEM "8|$line"; #attach 8| to lines with mac in it
                        }
                        close(MODEM);   #close file
			if($found == 1)
			{
			print "removing files\n";
			@output = `ssh cowen\@$cp "rm -f deletemodem.txt"  2>/dev/null`;
                        @output = `ssh cowen\@$cp2nd "rm -f deletemodem.txt" 2>/dev/null`;
			$line = `host $cp`;
                        @output = split(' ', $line);
                        $dhcp1 = $output[3];

                        $line = `host $cp2nd`;
                        @output = split(' ', $line);
                        $dhcp2 = $output[3];

			@output = `scp /home/cowen/deletemodem.txt cowen\@$cp:deletemodem.txt  2>/dev/null`;
                        @output = `scp /home/cowen/deletemodem.txt cowen\@$cp2nd:deletemodem.txt  2>/dev/null`;

                        print "on $cp /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp1 /export/home/cowen/deletemodem.txt\n";
                        $output =`ssh cowen\@$cp "/usr/local/bin/sudo /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp1 /export/home/cowen/deletemodem.txt"`; #2>/dev/null`;
                        print "$output\n";
                        print "on $cp2nd /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp2 /export/home/cowen/deletemodem.txt\n";
                        $output =`ssh cowen\@$cp2nd "/usr/local/bin/sudo /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp2 /export/home/cowen/deletemodem.txt"`; # 2>/dev/null`;
                        print "$output\n";
			}
			else
			{
				print "modem was not found on the cableprov\n";
			}

		}
	}
}
