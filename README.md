# Darker

A minimal macOS menu-bar dimmer.

## Build and open

(Requires macOS 13 or later.)
With Xcode command-line tools installed, run from this folder:

```sh
bash scripts/build-app.sh
mkdir -p "$HOME/Applications"
ditto build/Darker.app "$HOME/Applications/Darker.app"
open "$HOME/Applications/Darker.app"
```

The build creates a locally signed app that launches automatically at login.


## How it works

This app overlays a click-through black window on every display. These windows follow Spaces, fullscreen apps, and extra displays.

## Development

```sh
swift test --disable-sandbox --cache-path .build/cache
```
