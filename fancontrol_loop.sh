#!/ffp/bin/sh

DELAY="5m"

while true ; do
  /ffp/opt/fancontrol_check.sh
  sleep $DELAY
done
