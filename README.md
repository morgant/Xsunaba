# Xsunaba

## OVERVIEW

A utility to run X11 applications in a sandbox (sunaba). The sandbox consists of a sandbox user and a `Xephyr` display.

_Note:_ this _does not_ guarantee access is prevented outside the sandbox user & display, but does  limit access to your primary user & display.

This is based on [a script by Milosz Galazka](https://blog.sleeplessbeastie.eu/2013/07/19/how-to-create-browser-sandbox/) and ported to [OpenBSD](http://www.openbsd.org/).

## PREREQUISITES

* OpenBSD
* `doas`
* `Xephyr`
* `xauth`
* `openssl`

## USAGE

1. Add a `xsunaba` user:

        doas useradd -m xsunaba

2. Add an entry to your `/etc/doas.conf` allowing your user passwordless access to the `xsunaba` user (replacing `<USER>` with your username):

        permit nopass setenv {DISPLAY} <USER> as xsunaba

3. Prefix your X11 application command with `Xsunaba`, for example:

        Xsunaba chrome --window-size=1024,768 --window-position=0,0 --incognito &

        Xsunaba firefox -width 1024 -height 768 --private-window &

## LICENSE

Copyright (c) 2020 Morgan T. Aldridge  
Copyright (c) 2013 Milosz Galazka
