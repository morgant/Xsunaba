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

## LICENSE

Released under the [MIT License](LICENSE) by permission.
