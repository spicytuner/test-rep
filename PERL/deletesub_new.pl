#!/usr/bin/perl 

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';
require('/opt/inventory/connect.info'); #holds all server unique data
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
if($ARGV[1] eq "mac")
{
	$is_mac = 1;
}
else
{
	$is_mac = 0;
}
if($ARGV[2] eq "delete")
{
	$delete = 1;
}
else
{
	$delete = 0;
}
if($ARGV[3] eq "full")
{
	$full = 1;
}
else
{
	$full = 0;
}
$contact='jsoria';
$domain='bresnan.com';
$test='1';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

	$invh = DBI->connect("dbi:mysql:database=Inventory:$db", $nms2username, $nms2password) or die "Can't connect to nms2!";

        $dbh = DBI->connect('dbi:Oracle:samprd',$usr,$passwd) || die "Cannot establish connection to the database";
        $dbh->{RaiseError}=1;
	if($is_mac eq "1")
	{
		$mac = $acctnum;
		my $sth2 = $invh->prepare("select mta_mac from mta inner join cm on mta.cm_id = cm.cm_id where cm_mac='$mac'");
        	$sth2->execute();
		if(@r2 = $sth2->fetchrow_array)
        	{
			$mta = $r2[0];
                	remove_from_cableprov($mac, $mta);
                }
                else
                {
                	remove_from_cableprov($mac, "");
               	}	
	}
	else
	{
		print "Starting search for account\n" if($full);
        	$sth=$dbh->prepare(q{select distinct parentref from pi where userid= ?});
        	$sth->execute($acctnum);
        	$sth->bind_columns({},\($parentref));

        	while ($sth->fetch)
                {
			print "found account\n" if($full);
			$sth3=$dbh->prepare(q{select macaddressofcm from hsd where parentref=?});
                	$sth3->execute($parentref);
			$sth3->bind_columns({},\($mac));
			while ($sth3->fetch)
                	{
				print "found mac\n" if($full);
				$sth4=$dbh->prepare(q{select macaddressofmta from voice where macaddressofcm=?});
                		$sth4->execute($mac);
                		$sth4->bind_columns({},\($mta));
                		if($sth4->fetch)
                		{
					print "found mta\n" if($full);
					remove_from_cableprov($mac, $mta);
				}
				else
				{
					remove_from_cableprov($mac, "");
				}
			}
			print "setting deletestatus=1 on table pi\n" if($full and $delete);
			$sth2=$dbh->prepare(q{update pi set deletestatus=1 where userid=?});
        		$sth2->execute($acctnum) if($delete);
	
			print "setting deletestatus=1 on table hsd\n" if($full and $delete);
			$sth3=$dbh->prepare(q{update hsd set deletestatus=1 where parentref=?});
	        	$sth3->execute($parentref) if($delete);
	
			print "setting deletestatus=1 on table voice\n" if($full and $delete);
			$sth4=$dbh->prepare(q{update voice set deletestatus=1 where parentref=?});
	        	$sth4->execute($parentref) if($delete);
	
			print "setting deletestatus=1 on table email\n" if($full and $delete);
			$sth5=$dbh->prepare(q{update email set deletestatus=1 where parentref=?});
	        	$sth5->execute($parentref) if($delete);

			print "setting deletestatus=1 on table subscriber\n" if($full and $delete);
			$sth6=$dbh->prepare(q{update subscriber set deletestatus=1 where recordnumber=?});
	        	$sth6->execute($parentref) if($delete);
	
			print "setting deletestatus=1 on table subscribertopackage\n" if($full and $delete);
			$sth7=$dbh->prepare(q{update subscribertopackage set deletestatus=1 where parentref=?});
	        	$sth7->execute($parentref) if($delete);
	
			print "setting deletestatus=1 on table subscriber_ref\n" if($full and $delete);
			$sth8=$dbh->prepare(q{update subs_service_to_device set deletestatus=1 where subscriber_ref=?});
	        	$sth8->execute($parentref) if($delete);
	
			print "deleteing from table pi\n" if($full and $delete);
			$sth9=$dbh->prepare(q{delete from pi where userid = ?});
	        	$sth9->execute($acctnum) if($delete);
			
			print "$acctnum Deleted from Alopa Database\n" if($delete);

                }
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
			foreach $zone_type (keys (%{$cableprov{$zone}}))
			{
				$cp = $cableprov{$zone}{$zone_type};
                        	open(MODEM, "> /home/cowen/deletemodem.txt") || die "unable to open file";
                        	$found = 0;
				print "checking $cp\n";
				print "csp.org -- $cp\n" if($full);
                        	@output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/csp.org" 2>/dev/null`; #grep csp.org for mac
                        	foreach $line (@output)
                        	{
                        	        $found = 1;
                        	        print "2|$line";
                        	        print MODEM "2|$line"; #attach 2| to lines with mac in it
                        	}
				print "deviceBinding.org -- $cp\n" if($full);
                        	@output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/deviceBinding.org" 2>/dev/null`; #grep devicebinding.org for mac
				foreach $line (@output)
                        	{
                        	        print "4|4|4|4|$line";
                        	        if($count == 1)
                        	        {
                        	                $found = 1;
                        	                print MODEM "4|$line"; #attach 4| to lines with mac in it
                        	        }
                        	}
				print "static.org -- $cp\n" if($full);
				@output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/static.org" 2>/dev/null`; #grep static for mac
                        	foreach $line (@output)
                        	{
                        	        $found = 1;
                        	        print "6|$line";
                        	        print MODEM "6|$line"; #attach 6| to lines with mac in it
                        	}
				print "mtaSpecific.org -- $cp\n" if($full);
                        	@output =`ssh cowen\@$cp "/usr/bin/grep $cm /opt/Alopa/MetaServ/CableProv/$zone/data/mtaSpecific.org" 2>/dev/null`; #grep mtaSpecific.org for mac
                        	foreach $line (@output)
                        	{
                        	        $found = 1;
                        	        print "8|$line";
                        	        print MODEM "8|$line"; #attach 8| to lines with mac in it
                        	}
                        	close(MODEM);   #close file
				if($found == 1)
				{
					print "removing files\n" if($delete);
					$remove_cableprov = "172.18.131.48";
					@output = `ssh cowen\@$remove_cableprov "rm -f deletemodem.txt"  2>/dev/null`;
					$line = `host $cp`;
                        		@output = split(' ', $line);
                        		$dhcp1 = $output[3];
					@output = `scp /home/cowen/deletemodem.txt cowen\@$remove_cableprov:deletemodem.txt  2>/dev/null`;
                        		print "on $remove_cableprov /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp1 /export/home/cowen/deletemodem.txt\n";
					if($delete)
					{
						#$output =`ssh cowen\@$remove_cableprov "/usr/local/bin/sudo /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp1 blah.txt"`;
                        			$output =`ssh cowen\@$remove_cableprov "/usr/local/bin/sudo /opt/Alopa/MetaServ/CableProv/bin/updClient.sh $dhcp1 /export/home/cowen/deletemodem.txt"`; #2>/dev/null`;
                        			print "$output\n";
                        		}
				}
				else
				{
					print "modem was not found on $cp\n";
				}
			}
		}
	}
}
