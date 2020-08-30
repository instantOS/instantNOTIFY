#!/bin/dash

# gets executed each time dunst receives a notification

# ignore some apps
if echo "$2" | grep -q 'instantASSIST'; then
    exit
fi

# some apps dont need/already have notification sounds
if ! echo "$1" | grep -Eiq '(discord|spotify|thunderbird|mailspring)' && ! iconf -i mutenotifications; then
    # play notification sound
    if ! [ -e ~/instantos/notifications/notification.ogg ]; then
        if checkinternet; then
            mkdir -p ~/instantos/notifications/
            wget -qO ~/instantos/notifications/notification.ogg \
                "https://notificationsounds.com/notification-sounds/me-too-603/download/ogg"
        else
            exit
        fi
    fi

    if ! iconf -i nonotify
    then
        if [ -e ~/instantos/notifications/customsound ]
        then
                mpv ~/instantos/notifications/customsound
        else
            mpv ~/instantos/notifications/notification.ogg
        fi
    fi

fi &

# instantmenu crashes when displaying messages that are too long
if echo "$3" | grep -E '.{500,}'; then
    CONTENTS="message too long to display"
else
    CONTENTS="$3"
fi

instantnotifyctl a "$1" "$2" "$CONTENTS"
