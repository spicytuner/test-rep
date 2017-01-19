#!/usr/bin/perl

sub mysql_cmts
{
	my($mtaip,$cnt,$dbh, $dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass);

	$dbh = DBI->connect('dbi:Oracle:remrep','masterm','mMmMbeeR') || die "Cannot establish connection to the database";
	$dbh->{RaiseError}=1;

	$test='3';
	($usr,$passwd,$sid)=&serv_info($test);
	$nmsuser=$usr;
	$nmspass=$passwd;

	print "connecting to mysql\n";

	$dbh2 = DBI->connect("dbi:mysql:database=Inventory:$sid", $nmsuser, $nmspass) ||  die "Can't connect to nms2!";
	$sth9=$dbh2->prepare(q{ select cm_mac, cmts_name, mta_ip from cm inner join cmts on cm.cmts_id = cmts.cmts_id left join mta on cm.cm_id = mta.cm_id });
	$sth9->execute();
	$sth9->bind_columns({}, \($cmmac,$cmts,$mtaip));

	print "truncating cmmac_to_cmts table\n";
	
	$sth11=$dbh->prepare(q{truncate table cmmac_to_cmts reuse storage });
	$sth11->execute();
	
	print "fetching data from mysql\n";
	
	while ($sth9->fetch)
		{
		$sth10=$dbh->prepare(q{ insert into cmmac_to_cmts values ( ?,?,?) });
		$sth10->execute($cmmac,$cmts,$mtaip);
		}

}
1;
