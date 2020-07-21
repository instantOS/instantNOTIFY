#!/bin/bash

sq() {
    sqlite3 ~/.cache/instantos/notifications.db "$1"
}

initdb() {
    mkdir -p ~/.cache/instantos
    sq 'CREATE TABLE "notifications" ("date" TEXT, "application" TEXT, "title" TEXT, "message" TEXT, "read" INTEGER);'
}

cleanstring() {
    sed 's/"/q/g' | sed 's/;:;/;;;/g'
}

addnotification() {
    sq 'INSERT INTO notifications (date, application, title, message, read) VALUES ("'$1'", "'$2'", "'"$(echo $3 | sed 's/"//g')"'", "'"$(echo $4 | sed 's/"//g')"'", '$5');'
}

if ! [ -e ~/.cache/instantos/notifications.db ]; then
    initdb
fi

case $1 in
a*)
    # add notification
    shift 1

    if [ -z "$1" ]; then
        echo "usage: instantnotifyctl a application title message"
        exit
    fi

    DATE=$(date +%H:%M)
    APPLICATION="${1:-application}"
    TITLE="${2:-title}"
    MESSAGE="${3:-helloworld}"
    addnotification "$DATE" "$APPLICATION" "$TITLE" "$MESSAGE" "0"
    ;;
da)
    # delete all notifications from a specific application
    sq 'DELETE FROM notifications WHERE application="'"$2"'";'
    ;;
dd)
    # delete all notifications
    sq 'DELETE FROM notifications;'
    ;;
dk)
    # delete notification containing
    sq 'DELETE FROM notifications WHERE message LIKE "%'"$2"'%" OR title LIKE "%'"$2"'%";'
    ;;
dr)
    # delete notification containing
    sq 'DELETE FROM notifications WHERE read = 1;'
    ;;
d*)
    sq 'DELETE FROM notifications WHERE message="'"$2"'" AND title="'"$3"'";'
    ;;
la*)
    sqlite3 -separator ";:;" ~/.cache/instantos/notifications.db 'SELECT application FROM notifications;'
    ;;
l*)
    # list notifications
    sqlite3 -separator ";:;" ~/.cache/instantos/notifications.db 'SELECT * FROM notifications;'
    ;;
r*)
    # mark as read
    sq 'UPDATE notifications SET read = 1 WHERE message="'"$2"'" AND title="'"$3"'";'
    ;;
u*)
    # mark as unread
    sq 'UPDATE notifications SET read = 0 WHERE message="'"$2"'" AND title="'"$3"'";'
    ;;
c*)
    # get count of unread notifications
    sq 'SELECT count(read) FROM notifications WHERE read=0;'
    ;;
esac
