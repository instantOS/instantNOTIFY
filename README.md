# instantNOTIFY

Notification center for instantOS It uses dunst for popover notifications and
instantMENU as the interface. The functionality is inspired by the android
notification area, allowing to access and delete past notifications, searching
through notifications marking as read/unread.

## requirements

* instantMENU
* bash
* sqlite
* dunst
* dunst config that triggers ```instantnotifytrigger```
* mpv

## config

instantNOTIFY has two ignore files that allow ignoring or silencing
notifications from specific applications.

```sh
~/.config/instantos/notifysilent # contains applications that are not supposed to make a sound
~/.config/instantos/notifyignore # contains applications that are not supposed to have their notifications show up in the notification center
```
