#!/ffp/bin/sh

#
#  description: Script to get fan control working with DNS-320
#  Written by Johny Mnemonic
# 
#  Modified on 20130812 by Jeremie Huchet
#

# PROVIDE: fancontrol
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="fancontrol"
start_cmd="fancontrol_start"
stop_cmd="fancontrol_stop"
status_cmd="fancontrol_status"

ORIGINAL_FAN_CONTROL=/usr/sbin/fan_control
CUSTOM_FAN_CONTROL_LOOP=/ffp/opt/fancontrol/fancontrol_loop.sh
CUSTOM_FAN_CONTROL_CHECK=/ffp/opt/fancontrol/fancontrol_check.sh

logcommand() {
 logger -t user $1
}

fancontrol_start() {
  if [ ! -e /var/run/fancontrol.pid ] ; then
    logcommand "Starting Fancontrol daemon"
    killall fan_control >/dev/null 2>/dev/null &
    chmod -x $ORIGINAL_FAN_CONTROL
    cp $CUSTOM_FAN_CONTROL_LOOP /usr/sbin/fancontrol_custom
    cp $CUSTOM_FAN_CONTROL_CHECK /usr/sbin/fancontrol_custom_check
    chmod u+x $CUSTOM_FAN_CONTROL_LOOP $CUSTOM_FAN_CONTROL_CHECK
    fancontrol_custom >/dev/null 2>/dev/null & 
    echo $! >> /var/run/fancontrol.pid
  else
    logcommand "Fancontrol daemon already running"
  fi
}

fancontrol_stop() {
	logcommand "Stopping Fancontrol daemon"
	kill -9 `cat /var/run/fancontrol.pid`
	rm /var/run/fancontrol.pid
	rm $CUSTOM_FAN_CONTROL_LOOP $CUSTOM_FAN_CONTROL_CHECK
	chmod +x $ORIGINAL_FAN_CONTROL
	fan_control >/dev/null 2>/dev/null &
}
	
fancontrol_restart() {
	fancontrol_stop
	sleep 2
	fancontrol_start
}

fancontrol_status() {
	if [ -e /var/run/fancontrol.pid ]; then
		echo " Fancontrol daemon is running"
	else
		echo " Fancontrol daemon is not running"
	fi
}

run_rc_command "$1"
