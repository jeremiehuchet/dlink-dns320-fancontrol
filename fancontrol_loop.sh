#!/ffp/bin/sh

DELAY="5m"

while true ; do
  /ffp/opt/fancontrol/fancontrol_check.sh
  sleep $DELAY
done
