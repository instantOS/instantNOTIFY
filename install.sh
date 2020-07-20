#!/bin/bash

installscript() {
    [ -e "$1" ] || return 1
    cat "$1" | sudo tee /usr/bin/"${2:-$1}"
    sudo chmod 755 /usr/bin/"${2:-$1}"
}

installscript instantnotifyctl
installscript instantnotify
installscript instantnotifytrigger
installscript instantnotifyoptions
installscript instantnotifytrigger dunsttrigger
