#!/bin/bash

/home/jsoria/SCRIPTS/PERL/ne_se_opentickets.pl

#uuencode /home/jsoria/SCRIPTS/PERL/open_tickets.xls /tmp/open_tickets.xls | /bin/mail -s "open tickets" jsoria@bresnan.com dandrews@bresnan.com jboelter@bresnan.com tmartinson@bresnan.com bwilliams@bresnan.com bwiley@bresnan.com ajackson@bresnan.com mmckenzie@bresnan.com dhelms@bresnan.com gchimos@bresnan.com vburkhardt@bresnan.com sysadmins@bresnan.net bcroberts@bresnan.com


uuencode /home/jsoria/SCRIPTS/PERL/open_tickets.xls /tmp/open_tickets.xls | /bin/mail -s "NE Open Tickets" jsoria@bresnan.com vburkhardt@bresnan.com

uuencode /home/jsoria/SCRIPTS/PERL/seopen_tickets.xls /tmp/seopen_tickets.xls | /bin/mail -s "SE Open Tickets" jsoria@bresnan.com bwilliams@bresnan.com

#uuencode /home/jsoria/SCRIPTS/PERL/seopen_tickets.xls /tmp/seopen_tickets.xls | /bin/mail -s "SE Open Tickets" bwilliams@bresnan.com

#uuencode /home/jsoria/SCRIPTS/PERL/open_tickets.xls /tmp/open_tickets.xls | /bin/mail -s "NE Open Tickets" jsoria@bresnan.com
#uuencode /home/jsoria/SCRIPTS/PERL/seopen_tickets.xls /tmp/seopen_tickets.xls | /bin/mail -s "SE Open Tickets" jsoria@bresnan.com 
