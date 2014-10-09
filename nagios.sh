#!/bin/bash
### In nagios.sh (make sure this file is chmod +x):
# `/sbin/setuser xxxxx` runs the given command as the user `xxxxx`.
# If you omit that part, the command will be run as root.

exec /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg  >>/var/log/nagios.log 2>&1
