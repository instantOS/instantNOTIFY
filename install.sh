#!/bin/bash

# TODO: replace with makefile

installscript() {
    [ -e "$1.sh" ] || return 1
    cat "$1.sh" | sudo tee /usr/bin/"${2:-$1}"
    sudo chmod 755 /usr/bin/"${2:-$1}"
}

installscript instantnotifyctl
installscript instantnotify
installscript instantnotifytrigger
installscript instantnotifyoptions
installscript instantnotifytrigger dunsttrigger
