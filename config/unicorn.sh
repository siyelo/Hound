#! /bin/bash

### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the unicorn web server
# Description:       starts unicorn
### END INIT INFO

USER="ubuntu"
DAEMON=unicorn
DAEMON_OPTS="-c /home/ubuntu/app/config/unicorn.rb -E production -D"
NAME=unicorn
DESC="Unicorn app for $USER"
PID=/home/ubuntu/app/tmp/pids/unicorn.pid

case "$1" in
  start)
        CD_TO_APP_DIR="cd /home/ubuntu/app"
        START_DAEMON_PROCESS="bundle exec $DAEMON $DAEMON_OPTS"

        echo -n "Starting $DESC: "
        if [ `whoami` = root ]; then
          su - $USER -c "$CD_TO_APP_DIR > /dev/null 2>&1 && $START_DAEMON_PROCESS"
        else
          $CD_TO_APP_DIR > /dev/null 2>&1 && $START_DAEMON_PROCESS
        fi
        echo "$NAME."
        ;;
  stop)
        echo -n "Stopping $DESC: "
        kill -QUIT `cat $PID`
        echo "$NAME."
        ;;
  restart)
        echo -n "Restarting $DESC: "
        kill -USR2 `cat $PID`
        echo "$NAME."
        ;;
  reload)
        echo -n "Reloading $DESC configuration: "
        kill -HUP `cat $PID`
        echo "$NAME."
        ;;
  *)
        echo "Usage: $NAME {start|stop|restart|reload}" >&2
        exit 1
        ;;
esac

exit 0
