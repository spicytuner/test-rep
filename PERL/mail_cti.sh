#!/bin/bash


uuencode /home/jsoria/SCRIPTS/PERL/cti.xls /tmp/cti.xls | mailx -s "CTI Report" jsoria@bresnan.com
