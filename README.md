# Xsunaba

## OVERVIEW

A utility to run X11 (or just X) applications in a rudimentary sandbox ('sunaba' from Japanese) to limit access to your files and X11 events (especially keyboard input.) The 'sandbox' consists of:

1. A separate local user account under which the X11 application will be run, restricting access to your user files (assuming appropriate permissions are in place)
2. A separate X session created and rendered into a window within your running X display using `Xephyr`, preventing the sandboxed X application from snooping on X11 events in the parent X session & display

_IMPORTANT:_ this _does not_ guarantee access is prevented outside the sandbox user & display, but should be at least marginally safer.

This is based on [a script by Milosz Galazka](https://blog.sleeplessbeastie.eu/2013/07/19/how-to-create-browser-sandbox/) (see [Internet Archive's Wayback Machine archive](https://web.archive.org/web/20210115000000*/https://blog.sleeplessbeastie.eu/2013/07/19/how-to-create-browser-sandbox/)) and ported to [OpenBSD](http://www.openbsd.org/).

For those using Xsunaba under OpenBSD, some X11 applications in ports utilize the [pledge(2)](https://man.openbsd.org/pledge) & [unveil(2)](https://man.openbsd.org/unveil) functions to further restrict access to the filesystem.

## PREREQUISITES

* OpenBSD
* X11 (preferably running [xenodm(1)](https://man.openbsd.org/xenodm))
* [doas(1)](https://man.openbsd.org/doas)
* [Xephyr(1)](https://man.openbsd.org/Xephyr)
* [xauth(1)](https://man.openbsd.org/xauth)
* [openssl(1)](https://man.openbsd.org/openssl)

## USAGE

1. Add an `xsunaba` user:

        doas useradd -m xsunaba

2. Add an entry to your `/etc/doas.conf` allowing your user passwordless access to the `xsunaba` user (replacing `<USER>` with your username):

        permit nopass <USER> as xsunaba

3. Prefix your X11 application command with `Xsunaba`, for example:

        Xsunaba chrome --incognito &

        Xsunaba firefox --private-window &

_Note:_ `Xsunaba` will automatically apply window geometry hacks to fit to the `Xephyr` display for the following X11 applications: `chrome`, and `firefox`.

### ADVANCED USAGE

The following environment variables may be set the change `Xsunaba`'s behavior:

* `VERBOSE`: Set to `true` to show verbose output. Default: `false`.
* `XSUNABA_DISPLAY`: Set a custom display number (incl. leading colon) to start `Xephyr` displays at. Default: `:32`.
* `XSUNABA_USER`: Set a username to run X11 application as. Default: `xsunaba`.
* `WIDTH`: Set a custom `Xephyr` display width in pixels. Default: `1024`.
* `HEIGHT`: Set a custom `Xephyr` display height in pixels. Default: `768`.

### Shared Files

If you want to share some files beween your user and the `xsunaba` user, it is suggested that you create a directory owned by the `xsunaba` user and grant group access to it to your user's group (generally the same as your user's name). It is best to only move specific files into and out of this shared directory as needed, not permanently store data in it, as any X11 application run using `Xsunaba` will have access to it.

*IMPORTANT:* This will weaken the security of your sandbox!

## LICENSE

Released under the [MIT License](LICENSE) by permission.
