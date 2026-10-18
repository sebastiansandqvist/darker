import AppKit

/// Owns only ordinary windows. Never reads, writes, or resets display gamma.
@MainActor final class OverlayController: NSObject {
    static let windowLevel = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
    private var windows: [CGDirectDisplayID: ShadeWindow] = [:]
    private var opacity = 0.0
    private var sessionActive = true

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self, selector: #selector(refresh),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification,
                     NSWorkspace.activeSpaceDidChangeNotification] {
            center.addObserver(self, selector: #selector(refresh), name: name, object: nil)
        }
        center.addObserver(self, selector: #selector(sessionResigned),
                           name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(sessionActivated),
                           name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
    }

    func setOpacity(_ value: Double) {
        opacity = value
        refresh()
    }

    func stop() {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        windows.values.forEach { $0.close() }
        windows.removeAll()
    }

    @objc private func refresh() {
        let screens = NSScreen.screens
        let connected = Set(screens.compactMap(\.displayID))
        for id in Array(windows.keys) where !connected.contains(id) {
            windows.removeValue(forKey: id)?.close()
        }
        for screen in screens {
            guard let id = screen.displayID else { continue }
            // Mirrored displays already show the source display's overlay.
            guard CGDisplayMirrorsDisplay(id) == kCGNullDirectDisplay else {
                windows.removeValue(forKey: id)?.close()
                continue
            }
            if opacity == 0 || !sessionActive {
                windows[id]?.orderOut(nil)
                continue
            }
            let window = windows[id] ?? ShadeWindow(screen: screen)
            windows[id] = window
            window.setFrame(screen.frame, display: true)
            window.alphaValue = opacity
            window.orderFrontRegardless()
        }
    }

    @objc private func sessionResigned() {
        sessionActive = false
        refresh()
    }

    @objc private func sessionActivated() {
        sessionActive = true
        refresh()
    }
}

private final class ShadeWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame, styleMask: .borderless,
                   backing: .buffered, defer: false)
        title = "Darker overlay"
        backgroundColor = .black
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        animationBehavior = .none
        level = OverlayController.windowLevel
        collectionBehavior = [.canJoinAllSpaces, .canJoinAllApplications, .stationary,
                              .ignoresCycle, .fullScreenAuxiliary]
        setAccessibilityElement(false)
    }

    // Borderless overlays must cover the menu bar as well as the usable area.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}

private extension NSScreen {
    var displayID: CGDirectDisplayID? {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }
}
