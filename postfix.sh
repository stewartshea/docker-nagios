#!/bin/bash
### In postfix.sh (make sure this file is chmod +x):
# `/sbin/setuser xxxxx` runs the given command as the user `xxxxx`.
# If you omit that part, the command will be run as root.

exec /usr/lib/postfix/master -d -c /etc/postfix  >>/var/log/postfix.log 2>&1
