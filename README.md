# Xsunaba

## OVERVIEW

`Xsunaba` is a utility to run X (or X11, if you prefer) applications in a
rudimentary sandbox to limit access to your files and XEvents (especially
keyboard input.) 'Sunaba' is romaji for the Japanese word '砂場', which
translates as 'sandbox' or 'sandpit'.

The 'sandbox' consists of:

1. A separate, less privileged, local user account under which the X
    application will be executed, restricting access to your user files
    (assuming appropriate permissions are set)
2. A separate X session created and rendered into a window within your running
    X display by `Xephyr`, preventing the sandboxed X application from
    snooping on XEvents in the parent X session & display

**IMPORTANT:** _This **DOES NOT** guarantee access is prevented outside the
sandbox user and X display, but should be at least marginally safer._

For those using `Xsunaba` under OpenBSD, some X applications in ports utilize
the [pledge(2)](https://man.openbsd.org/pledge) & [unveil(2)](https://man.openbsd.org/unveil)
functions to further restrict uneccessary operations and access to the
filesystem, network, etc.

Limitations due to implementation via `Xephyr`:

* Hardware acceleration is not supported for X applications using OpenGL, so
    the sandbox only provides software rasterization via the
    [LLVMpipe](https://docs.mesa3d.org/drivers/llvmpipe.html) driver. This
    _may_ be performant enough for some 2D rendering, but 3D rendering
    performance will be abysmal.
* The sandbox does not provide a display manager (DM), so will not execute
    the sandbox user's `~/.xsession`, `~/.xinitrc`, nor initialize a window
    manager (WM). If specific environment configuration is necessary for an X
    application to run correctly in the sandbox, it is suggested to create a
    wrapper script to configure & execute the application, then execute the
    wrapper script with `Xsunaba`.

## PREREQUISITES

* OpenBSD
* [X(7)](https://man.openbsd.org/X) and [Xorg(1)](https://man.openbsd.org/Xorg)
    (preferably with the [xenodm(1)](https://man.openbsd.org/xenodm) display
    manager)
* [doas(1)](https://man.openbsd.org/doas)
* [Xephyr(1)](https://man.openbsd.org/Xephyr)
* [xauth(1)](https://man.openbsd.org/xauth)
* [openssl(1)](https://man.openbsd.org/openssl)

### Optional

* [xclip(1)](https://github.com/astrand/xclip)
* [sndio(7)](https://man.openbsd.org/sndio)

## INSTALLATION

To install `Xsunaba`, the manual page, create the `xsunaba` user, and update
your `/etc/doas.conf` to allow your user to run applications in the sandbox
without a password:

```
$ doas make install USER="$USER"
```

If you don't yet have an `/etc/doas.conf`, one will be created for you, but
you will need explicitly specify your username when running `make install` as
`root` (replacing `<username>` with your username):

```
# make install USER=<username>
```

## USAGE

Prefix your X application command with `Xsunaba`, for example:

```
Xsunaba chrome --incognito &

Xsunaba firefox --private-window &
```

**NOTE:** `Xsunaba` will automatically apply window geometry hacks to fit to
the `Xephyr` display for the following X applications: `chrome` and `firefox`.

### ADVANCED USAGE

The following environment variables may be set to override `Xsunaba`'s default
behavior:

* `VERBOSE`: Set to `true` to show verbose output. Default: `false`.
* `XSUNABA_DISPLAY`: Set a custom display number (incl. leading colon) to
    start `Xephyr` displays at. Default: `:32`.
* `XSUNABA_USER`: Set a username to run X application as. Default: `xsunaba`.
* `WIDTH`: Set a custom `Xephyr` display width in pixels. Default: `1024`.
* `HEIGHT`: Set a custom `Xephyr` display height in pixels. Default: `768`.

#### Alternate and/or Multiple Sandbox Users

If you would like your sandbox user to have a different username than
`xsunaba` or would like to create multiple sandbox users, you can create them 
as follows (replacing `<sandbox_user>` with your preferred sandbox username):

```
doas make install-user XSUNABA_USER=<sandbox_user>
doas make install-doas XSUNABA_USER=<sandbox_user> USER=$USER
```

You can then execute `Xsunaba` with your custom sandbox user, for example
(replacing `<sandbox_user>`):

```
XSUNABA_USER=<sandbox_user> Xsunaba firefox --private-window &
```

#### Shared Selection and/or Clipboard

If you want to copy the sandbox user's X selection and/or clipboard to your
user's selection and/or clipboard, this can be done with `xclip`. After
starting an application in your `Xsunaba` sandbox, do the following:

##### Selection

```
doas -u "$XSUNABA_USER" xclip -display "$XSUNABA_DISPLAY" -out | xclip -in
```

##### Clipboard

```
doas -u "$XSUNABA_USER" xclip -display "$XSUNABA_DISPLAY" -selection clipboard -out | xclip -selection clipboard -in
```

#### Shared Files

If you want to share some files beween your user and the `xsunaba` user, it is
suggested that you create a directory owned by the `xsunaba` user and grant
group access to it to your user's group (generally the same as your user's
name). It is best to only move specific files into and out of this shared
directory as needed, not permanently store data in it, as any X application
run using `Xsunaba` will have access to it.

*IMPORTANT:* This will weaken the security of your sandbox!

#### Audio

By default, X applications executed in the sandbox will not have access to
play or record audio for privacy reasons. Per the ['Authentication' section
in sndio(7)](https://man.openbsd.org/sndio#Authentication), one can copy their
`~/.sndio/cookie` file to the `xsunaba` user to allow it to access
[sndiod(8)](https://man.openbsd.org/sndiod) simultaneously:

```
doas -u xsunaba mkdir -p ~xsunaba/.sndio
doas install -o xsunaba -g xsunaba -m 600 ~${USER}/.sndio/cookie ~xsunaba/.sndio/
```

The Makefile also provides an `install-sndio-cookie` target to automate this:

```
doas make install-sndio-cookie USER=$USER
```

*IMPORTANT:* If you have enabled audio recording in the OpenBSD kernel using
[sysctl(8)](https://man.openbsd.org/sysctl) or [sysctl.conf(5)](https://man.openbsd.org/sysctl.conf)
(`kern.audio.record=1`), applications run in the sandbox will be able to
access your microphone.

If audio is failing to play from applications within the Xsunaba sandbox,
first confirm the following:

1. You have played _any_ audio as your primary user, which will have created
    the sndio(7) cookie
2. You have copied, _not_ symlinked, your user's `~/.sndio/cookie` to the
    Xsunaba user
3. The Xsunaba user's `~/.sndio/cookie` is owned by the correct user (e.g.
    `xsunaba:xsunaba`) and _only_ the owner has read & write permissions (i.e.
    `600`)
4. That there contents of your user's and the Xsunaba user's `~/.sndio/cookie`
    files are identical

## HISTORY

`Xsunaba` is based on [a script by Milosz Galazka](https://blog.sleeplessbeastie.eu/2013/07/19/how-to-create-browser-sandbox/)
(see [Internet Archive's Wayback Machine archive](https://web.archive.org/web/20210115000000*/https://blog.sleeplessbeastie.eu/2013/07/19/how-to-create-browser-sandbox/))
and ported to [OpenBSD](http://www.openbsd.org/) and `doas` by Morgan
Aldridge. Milosz granted permission for this implementation to be released
under the MIT license.

## LICENSE

Released under the [MIT License](LICENSE) by permission.
