#!/bin/bash

# todo

CHOICE="$(echo ':b Delete all notification from application
:b Delete notifications containing keyword
:r 﫨Delete all notifications
:b Delete read
:b Back' | instantmenu -c -l 18 -h -1 -q 'notification options' -bw 4 -a 4)"

[ -z "$CHOICE" ] && exit

case "$CHOICE" in
*application)
    read -r APPCHOICE < <(
        {
            instantnotifyctl la | sort -u
            echo ":b Back"
        } | instantmenu -l 10 -c -h -1 -bw 4
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
*Back)
    instantnotify &
    exit
    ;;
esac
