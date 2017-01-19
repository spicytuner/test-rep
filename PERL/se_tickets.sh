#!/bin/bash

/home/jsoria/SCRIPTS/PERL/se_tickets.pl

uuencode /home/jsoria/SCRIPTS/PERL/se_tickets.xls /tmp/se_tickets.xls | /bin/mail -s "SE Weekly Ticket Report" jsoria@cablevision.com bwilliams@cablevision.com

