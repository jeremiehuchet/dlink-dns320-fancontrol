#!/ffp/bin/sh

set -e

TARGET_DISK_TEMP=38
TARGET_INTERNAL_TEMP=38
MAX_ACCEPTABLE_DISK_TEMP=42
MAX_ACCEPTABLE_INTERNAL_TEMP=45

disk_temp() {
  device=$1
  smartctl -d marvell --all $device | grep 194 | tail -c 3 | head -c 4
}

DISK_1_TEMP=$(disk_temp /dev/sda)
DISK_2_TEMP=$(disk_temp /dev/sdb)
INTERNAL_TEMP=$(fan_control -g 0 | cut -d' ' -f 4)

echo "sensor	temp	target"
echo "intern	$INTERNAL_TEMP	$TARGET_INTERNAL_TEMP"
echo "disk 1	$DISK_1_TEMP	$TARGET_DISK_TEMP"
echo "disk 2	$DISK_2_TEMP	$TARGET_DISK_TEMP"

if [ $DISK_1_TEMP -le $TARGET_DISK_TEMP ] \
    && [ $DISK_2_TEMP -le $TARGET_DISK_TEMP ] \
    && [ $INTERNAL_TEMP -le $TARGET_INTERNAL_TEMP ] ; then
  echo "> stopping fan"
  fan_control -f 0
elif [ $DISK_1_TEMP -ge $MAX_ACCEPTABLE_DISK_TEMP ] \
    || [ $DISK_2_TEMP -ge $MAX_ACCEPTABLE_DISK_TEMP ] \
    || [ $INTERNAL_TEMP -ge $MAX_ACCEPTABLE_INTERNAL_TEMP ] ; then
  echo "> setting fan to full speed"
  fan_control -f 2
else
  echo "> setting slow fan speed"
  fan_control -f 1
fi

exit 0
