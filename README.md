# Darker

A minimal macOS menu-bar dimmer.

<img width="312" height="185" alt="Screenshot 2026-10-18 at 9 42 30 AM" src="https://github.com/user-attachments/assets/2ecf4c03-45b7-4121-94a4-c5f4fbde2a75" />


## Build and run

(Requires macOS 13 or later.)
With Xcode command-line tools installed, run from this folder:

```sh
bash scripts/build-app.sh
mkdir -p "$HOME/Applications"
ditto build/Darker.app "$HOME/Applications/Darker.app"
open "$HOME/Applications/Darker.app"
```

This creates a locally signed app that launches automatically at login.


## How it works

This app overlays a click-through black window on every display. These windows follow Spaces, fullscreen apps, and extra displays.

## Development

```sh
swift test --disable-sandbox --cache-path .build/cache
```
