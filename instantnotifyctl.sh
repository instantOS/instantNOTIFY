#!/bin/bash

# command line interface for managing the database
# of recorded dunst notifications

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

echousage() {
    echo 'instantnotifyctl action [arguments]
    da [application]      delete notifications from one application
    dd                    delete notifications
    dk [keyword]          delete notifications containing keyword
    dr                    delete read notifications
    dc                    delete notifications older than the n newest ones
                          customizable through iconf notifyhistsize
    d [message] [title]   delete message with specific message and title
    l                     list all notifications
    la                    list all applications that have notifications
    r [message] [title]   mark message as read
    u [message] [title]   mark message as unread
    c                     get amount of unread notifications'
    exit
}

if [ -z "$1" ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    echousage
fi

if ! [ -e ~/.cache/instantos/notifications.db ]; then
    initdb
fi

case "$1" in
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
    MESSAGE="${3:-...}"
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
dl)
    if [ -n "$2" ] && [ "$2" -eq "$2" ]; then
        sq 'DELETE FROM notifications WHERE title IN (SELECT title FROM notifications LIMIT '"$2"') AND message IN (SELECT message FROM notifications LIMIT '"$2"') AND date IN (SELECT date FROM notifications LIMIT '"$2"');'
    else
        echo "delete last n notifications, please enter a number"
        exit 1
    fi
    ;;
dc)
    # clean old notifications
    NHISTSIZE="$(iconf notifyhistsize:1000)"
    NCOUNT="$(instantnotifyctl l | wc -l)"
    if [ -z "$NCOUNT" ] || [ -z "$NCOUNT" ]; then
        exit 1
    fi
    if [ "$NCOUNT" -gt "$NHISTSIZE" ] && [ "$NHISTSIZE" -gt 1 ]; then
        echo "cleaning old notifications"
        instantnotifyctl dl "$((NCOUNT - NHISTSIZE))"
    else
        echo "no notifications to clean"
    fi
    ;;
d*)
    sq 'DELETE FROM notifications WHERE message="'"$2"'" AND title="'"$3"'";'
    ;;
la*)
    sqlite3 -separator ";:;" ~/.cache/instantos/notifications.db 'SELECT application FROM notifications;'
    ;;
l*)
    # list notifications
    if [ -z "$2" ] || ! [ "$2" -eq "$2" ]; then
        sqlite3 -separator ";:;" ~/.cache/instantos/notifications.db 'SELECT * FROM notifications;'
    else

        LIMIT="$(($2 * 700))"
        sqlite3 -separator ";:;" \
            ~/.cache/instantos/notifications.db \
            'SELECT * FROM notifications'" LIMIT $LIMIT, 700;"
    fi
    ;;
r*)
    # mark as read
    sq 'UPDATE notifications SET read = 1 WHERE message="'"$2"'" AND title="'"$3"'";'
    ;;
u*)
    # mark as unread
    sq 'UPDATE notifications SET read = 0 WHERE message="'"$2"'" AND title="'"$3"'";'
    ;;
ca)
    # get count of unread notifications
    sq 'SELECT count(read) FROM notifications;'
    ;;
c*)
    # get count of unread notifications
    sq 'SELECT count(read) FROM notifications WHERE read=0;'
    ;;
esac
