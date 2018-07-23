#!/bin/sh

echo "Starting FHEM collectord ..."
[ ! -s /data/collectord.conf ] && cp /collectord.conf /data/collectord.conf
rm -f /var/run/collectord.pid
/collectord -c /data/collectord.conf -v
