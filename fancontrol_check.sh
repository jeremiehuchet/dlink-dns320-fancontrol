#!/ffp/bin/sh

set -e

NO_FAN_DISK_TEMP=34
NO_FAN_INTERNAL_TEMP=34
TARGET_DISK_TEMP=38
TARGET_INTERNAL_TEMP=38
MAX_ACCEPTABLE_DISK_TEMP=42
MAX_ACCEPTABLE_INTERNAL_TEMP=45

disk_temp() {
  device=$1
  smartctl -d marvell --all $device | grep 194 | tail -c 3 | head -c 4
}

log() {
  logger -p user.notice -t FAN $*
}

DISK_1_TEMP=$(disk_temp /dev/sda)
DISK_2_TEMP=$(disk_temp /dev/sdb)
INTERNAL_TEMP=$(fan_control -g 0 | cut -d' ' -f 4)
CURRENT_FAN_STATE=$(fan_control -g 3 | cut -d' ' -f 4)

echo "system health status
| sensor	temp	target
| intern	$INTERNAL_TEMP	$TARGET_INTERNAL_TEMP
| disk 1	$DISK_1_TEMP	$TARGET_DISK_TEMP
| disk 2	$DISK_2_TEMP	$TARGET_DISK_TEMP"
log "case: $INTERNAL_TEMP, disk1: $DISK_1_TEMP, disk2: $DISK_2_TEMP"

if [ $DISK_1_TEMP -le $NO_FAN_DISK_TEMP ] \
    && [ $DISK_2_TEMP -le $NO_FAN_DISK_TEMP ] \
    && [ $INTERNAL_TEMP -le $NO_FAN_INTERNAL_TEMP ] ; then
  FAN_ACTION="> stopping fan"
  fan_control -f 0
elif [ $DISK_1_TEMP -ge $MAX_ACCEPTABLE_DISK_TEMP ] \
    || [ $DISK_2_TEMP -ge $MAX_ACCEPTABLE_DISK_TEMP ] \
    || [ $INTERNAL_TEMP -ge $MAX_ACCEPTABLE_INTERNAL_TEMP ] ; then
  FAN_ACTION="> setting fan to full speed"
  fan_control -f 2
elif [ $DISK_1_TEMP -gt $TARGET_DISK_TEMP ] \
    && [ $DISK_2_TEMP -gt $TARGET_DISK_TEMP ] \
    && [ $INTERNAL_TEMP -gt $TARGET_INTERNAL_TEMP ] ; then
  FAN_ACTION="> setting slow fan speed"
  fan_control -f 1
elif [ $DISK_1_TEMP -le $NO_FAN_DISK_TEMP ] \
    && [ $DISK_2_TEMP -le $NO_FAN_DISK_TEMP ] \
    && [ $INTERNAL_TEMP -le $NO_FAN_INTERNAL_TEMP ] \
    && [ $CURRENT_FAN_STATE -gt 0 ] ; then
  FAN_ACTION="> setting slow fan speed"
  fan_control -f 1
else
  FAN_ACTION="> keeping current fan speed"
fi

echo "$FAN_ACTION"
log $FAN_ACTION

exit 0
