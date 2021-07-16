#!/bin/bash

# Graphical options menu for managing the notification center

CHOICE="$(echo ':y ﮖDo not disturb
:b Delete all notifications from application
:b Delete notifications containing keyword
:r 﫨Delete al notifications
:b Delete read
:b History size
:b Back' | instantmenu -c -l 18 -h -1 -q 'notification options' -bw 4 -a 4)"

[ -z "$CHOICE" ] && exit

case "$CHOICE" in
*disturb)
    if imenu -c "Enable do not disturb mode? This will prevent all notifications"; then
        dunstctl set-paused true
        iconf -i donotdisturb 1
    else
        iconf -i donotdisturb 0
        if dunstctl is-paused | grep -q 'true'; then
            dunstctl set-paused false
            sleep 0.2
            notify-send 'notifications active'
        fi
    fi
    ;;

*application)
    read -r APPCHOICE < <(
        {
            instantnotifyctl la | sort -u
            echo ":b Back"
        } | instantmenu -l 10 -i -c -h -1 -bw 4
    )

    if grep -q ':b Back' <<<"$APPCHOICE"; then
        echo "back"
        instantnotifyoptions &
        exit
    fi

    [ -z "$APPCHOICE" ] && exit
    echo "deleting application notifications"
    instantnotifyctl da "$APPCHOICE"
    ;;
*keyword)
    KEYWORD="$(imenu -i 'keyword')"
    [ -z "$KEYWORD" ] && exit
    echo "deleting keyword notifications"
    instantnotifyctl dk "$KEYWORD"
    ;;
*notifications)
    imenu -c "delete all notifications?" || exit
    echo "deleting all notifications"
    instantnotifyctl dd
    ;;
*read)
    instantnotifyctl dr
    ;;
*size)
    HSIZE="$(imenu -i 'enter maximum amount of notifications to be kept')"
    [ -z "$HSIZE" ] && exit
    if ! [ "$HSIZE" -eq "$HSIZE" ] || ! [ "$HSIZE" -gt 1 ]; then
        imenu -m 'enter a number please'
        instantnotifyoptions
        exit
    fi
    iconf notifyhistsize "$HSIZE"
    ;;
*Back)
    instantnotify &
    exit
    ;;
esac
