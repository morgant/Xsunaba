PREFIX ?=	/usr/local
PROG =		Xsunaba
SECTION =	1
BIN =		bin
MAN =		man
BINDIR =	${PREFIX}/${BIN}
MANDIR =	${PREFIX}/${MAN}/man${SECTION}
XSUNABA_USER ?= xsunaba
DOAS_LINE =	"permit nopass ${USER} as ${XSUNABA_USER}"

build:
	@echo "Nothing to be built."

install: ${BIN}/${PROG} ${MAN}/${PROG}.${SECTION} install-user install-doas
	mkdir -p ${BINDIR}
	install -m755 ${BIN}/${PROG} ${BINDIR}
	mkdir -p ${MANDIR}
	install -m444 ${MAN}/${PROG}.${SECTION} ${MANDIR}

install-user:
	id ${XSUNABA_USER} || useradd -m ${XSUNABA_USER}

install-doas:
	! test -f /etc/doas.conf \
		&& touch /etc/doas.conf \
		&& chown root:wheel /etc/doas.conf \
		&& chmod 600 /etc/doas.conf
	grep -q "${DOAS_LINE}" /etc/doas.conf \
		|| echo "${DOAS_LINE}" >> /etc/doas.conf

install-sndio-cookie:
	@echo "Copying sndio cookie from '${USER}' to '${XSUNABA_USER}'..."
	mkdir -p ~${XSUNABA_USER}/.sndio
	cp ~${USER}/.sndio/cookie ~${XSUNABA_USER}/.sndio/
	chown ${XSUNABA_USER}:${XSUNABA_USER} ~${XSUNABA_USER}/.sndio/cookie
	chmod 600 ~${XSUNABA_USER}/.sndio/cookie

uninstall: uninstall-doas uninstall-user
	rm ${BINDIR}/${PROG}
	rm ${MANDIR}/${PROG}.${SECTION}

uninstall-user:
	rmuser ${XSUNABA_USER}

uninstall-doas:
	test -f /etc/doas.conf \
		&& grep -p "${DOAS_LINE}" /etc/doas.conf \
		&& sed -i "s/${DOAS_LINE}//g" /etc/doas.conf

uninstall-sndio-cookie:
	rm ~${XSUNABA_USER}/.sndio/cookie
