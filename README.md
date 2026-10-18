# Darker

A minimal macOS menu-bar dimmer. Requires macOS 13 or later. Built with SwiftUI and AppKit, with no dependencies.

## Build and open

With Xcode command-line tools installed, run from this folder:

```sh
bash scripts/build-app.sh
mkdir -p "$HOME/Applications"
ditto build/Darker.app "$HOME/Applications/Darker.app"
open "$HOME/Applications/Darker.app"
```

The build creates a locally signed app that launches automatically at login.


## How it works

Each display gets a borderless, click-through black window that cannot take keyboard focus. These black windows follow Spaces, fullscreen apps, and extra displays.

## Development

```sh
swift test --disable-sandbox --cache-path .build/cache
```
