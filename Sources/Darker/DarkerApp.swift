import SwiftUI
import AppKit
import ServiceManagement

@main struct DarkerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    var body: some Scene { Settings { EmptyView() } }
}

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let settings = DimmingSettings()
    private let overlays = OverlayController()
    private let popover = NSPopover()
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.target = self
            button.action = #selector(togglePopover)
            button.setAccessibilityLabel("Darker")
        }
        statusItem = item
        popover.behavior = .transient
        popover.animates = false
        popover.delegate = self
        let host = NSHostingController(rootView: DimmingView(settings: settings))
        host.sizingOptions = [.preferredContentSize]
        popover.contentViewController = host
        settings.onChange = { [weak self] in self?.applyDimming() }
        applyDimming()
        configureLoginStartup()
        let loginLaunch = NSAppleEventManager.shared().currentAppleEvent?
            .paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
        if !loginLaunch { showPopover() }
    }

    private func configureLoginStartup() {
        // Register once, so disabling Darker in System Settings stays respected.
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: "didConfigureLoginStartup") else { return }
        do {
            let service = SMAppService.mainApp
            if service.status != .enabled && service.status != .requiresApproval {
                try service.register()
            }
            if service.status == .enabled || service.status == .requiresApproval {
                defaults.set(true, forKey: "didConfigureLoginStartup")
            }
            if service.status == .requiresApproval {
                SMAppService.openSystemSettingsLoginItems()
            }
        } catch {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert(error: error)
            alert.messageText = "Darker couldn’t enable login startup"
            alert.runModal()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showPopover()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlays.stop()
    }

    func popoverDidShow(_ notification: Notification) {
        // Keep the controls readable even when the desktop is heavily dimmed.
        popover.contentViewController?.view.window?.level = NSWindow.Level(
            rawValue: OverlayController.windowLevel.rawValue + 1
        )
    }

    @objc private func togglePopover() {
        if NSApp.currentEvent?.modifierFlags.contains(.option) == true {
            settings.clear()
        } else if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem?.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func applyDimming() {
        overlays.setOpacity(settings.opacity)
        let symbol = settings.opacity > 0 ? "moon.zzz.fill" : "moon.zzz"
        statusItem?.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Darker")?
            .withSymbolConfiguration(.init(pointSize: 15, weight: .medium))
        statusItem?.button?.image?.isTemplate = true
        statusItem?.button?.toolTip = "Darker\nOption-click to clear dimming"
        statusItem?.button?.setAccessibilityValue(settings.opacity > 0 ? "Dimming" : "Off")
    }
}

struct DimmingView: View {
    @ObservedObject var settings: DimmingSettings

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "moon.fill")
                        .accessibilityHidden(true)
                    Slider(value: Binding(
                        get: { DimmingSettings.maximum - settings.amount },
                        set: { settings.setAmount(DimmingSettings.maximum - $0) }
                    ), in: 0...DimmingSettings.maximum)
                        .accessibilityLabel("Brightness")
                        .accessibilityValue("\(Int(settings.amount.rounded())) percent dimming")
                        .accessibilityIdentifier("dimmingSlider")
                    Image(systemName: "sun.max")
                        .accessibilityHidden(true)
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                HStack {
                    Text("Darker")
                    Spacer()
                    Text("Brighter")
                }
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 25)
            }
            .padding(14)
            Divider()
            HStack {
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
                    .buttonStyle(.borderless)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
        }
        .frame(width: 240)
        .fixedSize(horizontal: false, vertical: true)
    }
}
