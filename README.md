# Darker

A minimal macOS menu-bar dimmer that works alongside f.lux. Requires macOS 13 or
later. Built with SwiftUI and AppKit, with no dependencies.

## Build and open

With Xcode command-line tools installed, run from this folder:

```sh
bash scripts/build-app.sh
mkdir -p "$HOME/Applications"
ditto build/Darker.app "$HOME/Applications/Darker.app"
open "$HOME/Applications/Darker.app"
```

The build creates a locally signed app; the commands install it in your user
Applications folder. Quit Darker before rebuilding and copying an update. It is
not notarized for distribution to other Macs.

## Use

Click the sleepy moon and move the slider. The left end turns dimming off; the
right end applies a 90% black overlay, so it cannot completely black out the
screen. There are no visible percentages. The slider controls all displays and
remembers its setting. Lower hardware brightness first for the best result.

The menu-bar icon is `moon.zzz` when off and `moon.zzz.fill` when dimming.
Option-click the icon to clear dimming without opening the menu. Quit removes
the overlays without changing hardware brightness or f.lux.

## Login startup

Darker enables **Open at Login** on its first launch and restores the saved dimming
level at login without opening its menu. You can turn startup off under
**System Settings → General → Login Items & Extensions**. Darker registers only
once, so it respects changes you make there.

## How it works

Each display gets a borderless, click-through black window that cannot take
keyboard focus. The windows follow Spaces and normal fullscreen apps, and update
on display changes and wake. Mirrored displays use their source's overlay.

Darker never calls gamma or color-temperature APIs, including on quit. No Screen
Recording or Accessibility permissions are needed. Percentages remain available
to VoiceOver even though they are not shown visually.

The hardware pointer can remain brighter than the image. Software dimming cannot
remove an LCD's underlying backlight glow. Login screens, exclusive fullscreen
content, and HDR output are not guaranteed to dim. Screen captures may include
the overlay, depending on the capture method.

## Development

```sh
swift test --disable-sandbox --cache-path .build/cache
```

The build also renders `build/icon-states.png` to preview the two menu-bar icons.
