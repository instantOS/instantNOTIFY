#!/bin/dash

# gets executed each time dunst receives a notification

[ -e ~/.config/instantos ] || mkdir -p ~/.config/instantos/

if ! [ -e ~/.config/instantos/notifyignore ]; then
    echo "creating notifyignore"
    cat /usr/share/instantnotify/notifyignore >~/.config/instantos/notifyignore
fi

if ! [ -e ~/.config/instantos/notifysilent ]; then
    echo "creating notifyignore"
    cat /usr/share/instantnotify/notifysilent >~/.config/instantos/notifysilent
fi

if grep -Fiq "$1" ~/.config/instantos/notifyignore || [ "$1" = "instantASSIST" ]
then
    echo "ignoring notification from $1"
    exit
fi

# some apps dont need/already have notification sounds
if ! grep -iqF "$1" ~/.config/instantos/notifysilent && ! iconf -i mutenotifications; then
    # play notification sound
    if ! [ -e ~/instantos/notifications/notification.ogg ]; then
        if checkinternet; then
            mkdir -p ~/instantos/notifications/
            wget -qO ~/instantos/notifications/notification.ogg \
                "http://notificationsound.surge.sh/notification.ogg"
        else
            exit
        fi
    fi

    if ! iconf -i nonotify; then
        if [ -e ~/instantos/notifications/customsound ]; then
            mpv --keep-open='no' ~/instantos/notifications/customsound
        else
            mpv --keep-open='no' ~/instantos/notifications/notification.ogg
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
