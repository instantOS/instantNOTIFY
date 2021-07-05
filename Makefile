PREFIX = /usr/

all: install

install:
	install -Dm 755 instantnotifyctl.sh ${DESTDIR}${PREFIX}bin/instantnotifyctl
	install -Dm 755 instantnotify.sh ${DESTDIR}${PREFIX}bin/instantnotify
	install -Dm 755 instantnotifytrigger.sh ${DESTDIR}${PREFIX}bin/instantnotifytrigger
	install -Dm 755 instantnotifyoptions.sh ${DESTDIR}${PREFIX}bin/instantnotifyoptions
	install -Dm 755 instantnotifytrigger.sh ${DESTDIR}${PREFIX}bin/dunsttrigger
	install -Dm 644 defaults/notifyignore ${DESTDIR}${PREFIX}share/instantnotify/notifyignore
	install -Dm 644 defaults/notifysilent ${DESTDIR}${PREFIX}share/instantnotify/notifysilent

uninstall:
	rm ${DESTDIR}${PREFIX}bin/instantnotifyctl
	rm ${DESTDIR}${PREFIX}bin/instantnotify
	rm ${DESTDIR}${PREFIX}bin/instantnotifytrigger
	rm ${DESTDIR}${PREFIX}bin/instantnotifyoptions
	rm ${DESTDIR}${PREFIX}bin/dunsttrigger
	rm -rf ${DESTDIR}${PREFIX}share/instantnotify
