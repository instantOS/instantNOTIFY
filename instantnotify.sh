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
    cd /tmp/notifications || exit 1
    echo "press enter to open submenu" >notif.txt
fi

cd /tmp/notifications || exit 1

NOTIFCOUNT="$(instantnotifyctl ca)"
PAGECOUNT="$((NOTIFCOUNT / 700))"

NOTIFPAGE="$PAGECOUNT"

notifmenu() {

    NOTIFICATIONLIST="$(
        instantnotifyctl l "$NOTIFPAGE" | sed 's/\(.*\);:;\(.*\);:;\(.*\);:;\(.*\);:;\(.*\)/:b \5 [\1]  (\2) *\3* \4/g' | sed 's/^:b 0/:r /g' | sed 's/^:b 1/:b /g' | tac
    )"

    CHOICE="$(
        {
            if [ "$NOTIFPAGE" -lt "$PAGECOUNT" ]; then
                echo ':g Previous page'
            fi

            cut -c-500 <<<"$NOTIFICATIONLIST"

            if [ "$NOTIFPAGE" -gt 0 ]; then
                echo ':g Next page'
            fi

        } | instantmenu -i -c -l 18 -h -1 -p "notifications" -lc "instantnotifyoptions" -q "search notifications" -bw 4 -a 4

    )"

    if [ ':g Next page' = "$CHOICE" ]; then
        NOTIFPAGE="$((NOTIFPAGE - 1))"
        notifmenu
        return
    elif [ "$CHOICE" = ':g Previous page' ]; then
        NOTIFPAGE="$((NOTIFPAGE + 1))"
        notifmenu
        return
    elif [ -z "$CHOICE" ]; then
        exit
    else
        OUTCHOICE="$(grep -F "$CHOICE" <<<"$NOTIFICATIONLIST" | head -1 | grep -o '\[.*')"
        echo "$OUTCHOICE"
    fi

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
    } | instantmenu -lc "instantnotifyoptions" -c -l 18 -h -1 -q "notification" -bw 4 -a 4)

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
