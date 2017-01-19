#!/usr/bin/perl

# Author: Joe Soria
# Date: July 23, 2007
#
# This script will alert when the freespace threashold is met.

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,$sth3,
$dbname,$job,$what,$EXIT);
 # Exit 0 = good 1 = critical
$EXIT = 0;
@database=qw(remrep);
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

foreach $database(@database) 
	{

	$dbh = DBI->connect("dbi:Oracle:$database",$usr,$passwd) || die "Cannot establish connection to the database";
	$dbh->{RaiseError}=1;

	$sth=$dbh->prepare(q{insert into hsd_license_count
SELECT 'Residential HSD Subscribers' ,
       COUNT(sub_id) , 
       NVL(SUM (CASE WHEN ctr <= 3 THEN 1 
                 WHEN ctr > 3 THEN ctr - 2 END),0) , 
       NVL(SUM (CASE WHEN ctr = 1 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 2 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 3 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr <= 3 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr > 3 THEN 1 END),0) , trunc(sysdate)
  FROM (SELECT   /*+ index(s sub_pk) use_nl(s,ss1) */
                 s.sub_id, 
                 COUNT (*) ctr
            FROM sub s, sub_svc ss1,
            (SELECT sub_typ_id FROM REF_SUB_TYP WHERE SUB_TYP_NM = 'residential') x
           WHERE s.sub_id = ss1.sub_id
            AND s.sub_typ_id = x.sub_typ_id
            AND ss1.SUB_SVC_STATUS_ID in (SELECT status_id
                                          FROM ref_status rs
                                         WHERE EXISTS (
                                                  SELECT 1
                                                    FROM ref_class rc
                                                   WHERE class_nm = 'SubSvcSpec'
                                                     AND rc.class_id = rs.class_id)
                                          AND status not in ('deleted','delete_in_progress')) 
            AND EXISTS (
                    SELECT 1
                      FROM svc sv1
                     WHERE sv1.svc_id = ss1.svc_id
                       AND sv1.svc_nm = 'internet_access')
            AND NOT EXISTS (
                    SELECT 1
                      FROM sub_svc ss2, svc sv2
                     WHERE sv2.svc_id = ss2.svc_id
                       AND ss1.sub_id = ss2.sub_id
                       AND sv2.svc_nm = 'smp_switch_dial_tone_access')
            AND s.sub_status_id NOT IN (
                    SELECT status_id
                      FROM ref_status rs
                     WHERE EXISTS (
                              SELECT 1
                                FROM ref_class rc
                               WHERE class_nm = 'SubSpec'
                                 AND rc.class_id = rs.class_id)
                       AND status IN ('deleted', 'delete_in_progress'))
        GROUP BY s.sub_id) 
UNION
SELECT 'Commercial HSD Subscribers' ,
       COUNT(sub_id) ,
       NVL(SUM (CASE WHEN ctr <= 3 THEN 1 
                 WHEN ctr > 3 THEN ctr - 2 END),0) , 
       NVL(SUM (CASE WHEN ctr = 1 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 2 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 3 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr <= 3 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr > 3 THEN 1 END),0) , trunc(sysdate)
    FROM (SELECT   /*+ index(s sub_pk) use_nl(s,ss1) */
                 s.sub_id, COUNT (*) ctr
            FROM sub s, sub_svc ss1,
            (SELECT sub_typ_id FROM REF_SUB_TYP WHERE SUB_TYP_NM = 'commercial') x
           WHERE s.sub_id = ss1.sub_id
            AND s.sub_typ_id = x.sub_typ_id
            AND ss1.SUB_SVC_STATUS_ID in (SELECT status_id
                                          FROM ref_status rs
                                         WHERE EXISTS (
                                                  SELECT 1
                                                    FROM ref_class rc
                                                   WHERE class_nm = 'SubSvcSpec'
                                                     AND rc.class_id = rs.class_id)
                                          AND status not in ('deleted','delete_in_progress'))
            AND EXISTS (
                    SELECT 1
                      FROM svc sv1
                     WHERE sv1.svc_id = ss1.svc_id
                       AND sv1.svc_nm = 'internet_access')
            AND NOT EXISTS (
                    SELECT 1
                      FROM sub_svc ss2, svc sv2
                     WHERE sv2.svc_id = ss2.svc_id
                       AND ss1.sub_id = ss2.sub_id
                       AND sv2.svc_nm = 'smp_switch_dial_tone_access')
            AND s.sub_status_id NOT IN (
                    SELECT status_id
                      FROM ref_status rs
                     WHERE EXISTS (
                              SELECT 1
                                FROM ref_class rc
                               WHERE class_nm = 'SubSpec'
                                 AND rc.class_id = rs.class_id)
                       AND status IN ('deleted', 'delete_in_progress'))
        GROUP BY s.sub_id )
	});
	$sth->execute();
	
	$sth2=$dbh->prepare(q{insert into voice_license_count
SELECT 'Residential VOICE Subscribers' ,
       COUNT(sub_id) , 
       NVL(SUM (CASE WHEN ctr <= 4 THEN 1  
                 WHEN ctr > 4 THEN 
                 1+(floor((ctr-4)/2)) + (mod(ctr,2)) 
       END),0) , 
       NVL(SUM (CASE WHEN ctr = 1 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 2 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 3 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 4 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr <= 4 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr > 4 THEN 1 END),0) , trunc(sysdate)
  FROM (SELECT   /*+ index(s sub_pk) use_nl(s,ss1) */
                 s.sub_id, COUNT (*) ctr
            FROM sub s, sub_svc ss1,
            (SELECT sub_typ_id FROM REF_SUB_TYP WHERE SUB_TYP_NM = 'residential') x
           WHERE s.sub_id = ss1.sub_id
            AND s.sub_typ_id = x.sub_typ_id
            AND ss1.sub_svc_status_id IN (SELECT status_id
                                          FROM ref_status rs
                                         WHERE EXISTS (
                                                  SELECT 1
                                                    FROM ref_class rc
                                                   WHERE class_nm = 'SubSvcSpec'
                                                     AND rc.class_id = rs.class_id)
                                          AND status not in ('deleted','delete_in_progress'))
            AND EXISTS (
                    SELECT 1
                      FROM svc sv1
                     WHERE sv1.svc_id = ss1.svc_id
                       AND sv1.svc_nm = 'smp_switch_dial_tone_access')
            AND NOT EXISTS (
                    SELECT 1
                      FROM sub_svc ss2, svc sv2
                     WHERE sv2.svc_id = ss2.svc_id
                       AND ss1.sub_id = ss2.sub_id
                       AND sv2.svc_nm = 'internet_access')
            AND s.sub_status_id NOT IN (
                    SELECT status_id
                      FROM ref_status rs
                     WHERE EXISTS (
                              SELECT 1
                                FROM ref_class rc
                               WHERE class_nm = 'SubSpec'
                                 AND rc.class_id = rs.class_id)
                       AND status IN ('deleted', 'delete_in_progress'))
        GROUP BY s.sub_id )
UNION
SELECT 'Commercial VOICE Subscribers' ,
       COUNT(sub_id) , 
       NVL(SUM (CASE WHEN ctr <= 4 THEN 1  
                 WHEN ctr > 4 THEN 
                 1+(floor((ctr-4)/2)) + (mod(ctr,2)) 
       END),0) , 
       NVL(SUM (CASE WHEN ctr = 1 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 2 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr = 3 THEN 1 END),0),
       NVL(SUM (CASE WHEN ctr = 4 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr <= 4 THEN 1 END),0) ,
       NVL(SUM (CASE WHEN ctr > 4 THEN 1 END),0) , trunc(sysdate)
  FROM (SELECT   /*+ index(s sub_pk) use_nl(s,ss1) */
                 s.sub_id, COUNT (*) ctr
            FROM sub s, sub_svc ss1,
            (SELECT sub_typ_id FROM REF_SUB_TYP WHERE SUB_TYP_NM = 'commercial') x
           WHERE s.sub_id = ss1.sub_id
            AND s.sub_typ_id = x.sub_typ_id
            AND ss1.sub_svc_status_id IN (SELECT status_id
                                          FROM ref_status rs
                                         WHERE EXISTS (
                                                  SELECT 1
                                                    FROM ref_class rc
                                                   WHERE class_nm = 'SubSvcSpec'
                                                     AND rc.class_id = rs.class_id)
                                          AND status not in ('deleted','delete_in_progress'))
            AND EXISTS (
                    SELECT 1
                      FROM svc sv1
                     WHERE sv1.svc_id = ss1.svc_id
                       AND sv1.svc_nm = 'smp_switch_dial_tone_access')
            AND NOT EXISTS (
                    SELECT 1
                      FROM sub_svc ss2, svc sv2
                     WHERE sv2.svc_id = ss2.svc_id
                       AND ss1.sub_id = ss2.sub_id
                       AND sv2.svc_nm = 'internet_access')
            AND s.sub_status_id NOT IN (
                    SELECT status_id
                      FROM ref_status rs
                     WHERE EXISTS (
                              SELECT 1
                                FROM ref_class rc
                               WHERE class_nm = 'SubSpec'
                                 AND rc.class_id = rs.class_id)
                       AND status IN ('deleted', 'delete_in_progress'))
        GROUP BY s.sub_id)
	});
	$sth2->execute();

	$sth3=$dbh->prepare(q{insert into hsd_and_voice_license_count
SELECT 'Residential HSD & VL Subscribers',
       COUNT (sub_id) , 
       NVL (SUM (ctr), 0) , trunc(sysdate)
  FROM (SELECT   ssx.sub_id, 
                 COUNT (*) ctr
            FROM sub_svc ssx
           WHERE EXISTS (
                    SELECT 1
                      FROM (SELECT /*+ index(s sub_pk) use_nl(s,ss1) */
                                   DISTINCT s.sub_id
                                       FROM sub s,
                                            sub_svc ss1,
                                            (SELECT status_id
                                               FROM ref_status rs
                                              WHERE EXISTS (
                                                       SELECT 1
                                                         FROM ref_class rc
                                                        WHERE class_nm = 'SubSvcSpec'
                                                          AND rc.class_id = rs.class_id)
                                                AND status NOT IN ('deleted', 'delete_in_progress')) z,
                                            (SELECT sub_typ_id
                                               FROM ref_sub_typ
                                              WHERE sub_typ_nm = 'residential') x
                                      WHERE s.sub_id = ss1.sub_id
                                        AND s.sub_typ_id = x.sub_typ_id
                                        AND ss1.sub_svc_status_id = z.status_id
                                        AND EXISTS (
                                               SELECT 1
                                                 FROM svc sv1
                                                WHERE sv1.svc_id = ss1.svc_id
                                                  AND sv1.svc_nm = 'internet_access')
                                        AND EXISTS (
                                               SELECT 1
                                                 FROM sub_svc ss2, svc sv2
                                                WHERE sv2.svc_id = ss2.svc_id
                                                  AND ss2.sub_svc_status_id = z.status_id
                                                  AND ss1.sub_id = ss2.sub_id
                                                  AND sv2.svc_nm = 'smp_switch_dial_tone_access')
                                        AND s.sub_status_id NOT IN (
                                               SELECT status_id
                                                 FROM ref_status rs
                                                WHERE EXISTS (
                                                         SELECT 1
                                                           FROM ref_class rc
                                                          WHERE class_nm = 'SubSpec'
                                                            AND rc.class_id = rs.class_id)
                                                  AND status IN ('deleted', 'delete_in_progress'))) sx
                     WHERE ssx.sub_id = sx.sub_id
                       AND ssx.svc_id IN (
                              SELECT svc_id
                                FROM svc
                               WHERE svc_nm IN ('internet_access', 'smp_switch_dial_tone_access')))
        GROUP BY ssx.sub_id)
UNION
SELECT 'Commercial HSD & VL Subscribers' ,
       COUNT (sub_id) , 
       NVL (SUM (ctr), 0) , trunc(sysdate)
  FROM (SELECT   ssx.sub_id, 
                 COUNT (*) ctr
            FROM sub_svc ssx
           WHERE EXISTS (
                    SELECT 1
                      FROM (SELECT /*+ index(s sub_pk) use_nl(s,ss1) */
                                   DISTINCT s.sub_id
                                       FROM sub s,
                                            sub_svc ss1,
                                            (SELECT status_id
                                               FROM ref_status rs
                                              WHERE EXISTS (
                                                       SELECT 1
                                                         FROM ref_class rc
                                                        WHERE class_nm = 'SubSvcSpec'
                                                          AND rc.class_id = rs.class_id)
                                                AND status NOT IN ('deleted', 'delete_in_progress')) z,
                                            (SELECT sub_typ_id
                                               FROM ref_sub_typ
                                              WHERE sub_typ_nm = 'commercial') x
                                      WHERE s.sub_id = ss1.sub_id
                                        AND s.sub_typ_id = x.sub_typ_id
                                        AND ss1.sub_svc_status_id = z.status_id
                                        AND EXISTS (
                                               SELECT 1
                                                 FROM svc sv1
                                                WHERE sv1.svc_id = ss1.svc_id
                                                  AND sv1.svc_nm = 'internet_access')
                                        AND EXISTS (
                                               SELECT 1
                                                 FROM sub_svc ss2, svc sv2
                                                WHERE sv2.svc_id = ss2.svc_id
                                                  AND ss2.sub_svc_status_id = z.status_id
                                                  AND ss1.sub_id = ss2.sub_id
                                                  AND sv2.svc_nm = 'smp_switch_dial_tone_access')
                                        AND s.sub_status_id NOT IN (
                                               SELECT status_id
                                                 FROM ref_status rs
                                                WHERE EXISTS (
                                                         SELECT 1
                                                           FROM ref_class rc
                                                          WHERE class_nm = 'SubSpec'
                                                            AND rc.class_id = rs.class_id)
                                                  AND status IN ('deleted','delete_in_progress'))) sx
                     WHERE ssx.sub_id = sx.sub_id
                       AND ssx.svc_id IN (
                              SELECT svc_id
                                FROM svc
                               WHERE svc_nm IN ('internet_access','smp_switch_dial_tone_access')))
        GROUP BY ssx.sub_id)});
	$sth3->execute();

		}
exit($EXIT)

