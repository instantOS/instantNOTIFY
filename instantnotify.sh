#!/bin/bash

#######################################
## notification center for instantOS ##
#######################################

# show notification history in instantmenu
# enter to open a submenu for reading and deleting
# esc to exit

if ! [ -e /tmp/notifications/notif.txt ]; then
    echo "creating notification dir"
    mkdir /tmp/notifications
    cd /tmp/notifications
    echo "press enter to open submenu" >notif.txt
fi

cd /tmp/notifications

notifmenu() {
    #   sed 's/^/:b /g' | instantmenu -c -l 18 -h -1 -p "notifications" -q "search notifications" -bw 4 -a 4 | grep -o '\[.*'
    instantnotifyctl l | sed 's/\(.*\);:;\(.*\);:;\(.*\);:;\(.*\);:;\(.*\)/:b \5 [\1]  (\2) *\3* \4/g' | sed 's/^:b 0/:r /g' | sed 's/^:b 1/:b /g' | tac |
        instantmenu -c -l 18 -h -1 -p "notifications" -lc "instantnotfiyoptions" -q "search notifications" -bw 4 -a 4 | grep -o '\[.*'
}
refreshmenu() {
    NREAD=$(notifmenu)
    MESSAGE="$(echo "$NREAD" | grep -o '.*' | grep -o '[^]*')"
    TITLE="$(echo "$NREAD" | grep -o '.*' | grep -o '\*.*\*' | grep -o '[^*]*')"
    echo "title: $TITLE"
    READMESSAGE="$(echo "$MESSAGE" | sed -e 's/.\{50\}/&\n/g' | sed 's/^/>      /g')"
}

refreshmenu

while [ -n "$NREAD" ]; do
    # wrap lines and filter out lines that are not notifications
    read -r SELECTION < <({
        echo "$NREAD" | grep -o '\[.*' | sed -e "s/.\{150\}/&\n/g" |
            sed 's/\[\([0-9]*:[0-9]*\)\]  (\(.*\)) \*\(.*\)\* \(.*\)/:g Application :  \2\n>            \1\n>      \3/g'
        echo "$READMESSAGE
> "
        echo ':b Back
:b Mark as unread
:r Delete
:y Close'
    } | instantmenu -lc "instantnotfiyoptions" -c -l 18 -h -1 -q "notification" -bw 4 -a 4)

    [ "$SELECTION" = ":b Mark as unread" ] || instantnotifyctl r "$MESSAGE" "$TITLE"
    [ -z "$SELECTION" ] && exit

    case "$SELECTION" in
    *Delete)
        instantnotifyctl d "$MESSAGE" "$TITLE"
        ;;
    *Close)
        exit
        ;;
    *Back)
        echo "back"
        ;;
    *unread)
        echo "marking as unread"
        instantnotifyctl u "$MESSAGE" "$TITLE"
        ;;
    *)
        echo "app"
        SELECTION2="${SELECTION#:g Application :  }"
        echo "focussing $SELECTION2"
        wmctrl -x -a "$SELECTION2"
        exit
        ;;
    esac

    refreshmenu

done
