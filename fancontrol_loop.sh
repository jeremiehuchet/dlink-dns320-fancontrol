#!/ffp/bin/sh

DELAY="5m"

while true ; do
  fancontrol_custom_check
  sleep $DELAY
done
