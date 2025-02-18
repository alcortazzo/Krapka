import AppKit
import Combine
import SwiftUI

@main
struct KrapkaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            Text("Settings Placeholder")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    @ObservedObject private var pingManager = PingManager()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_: Notification) {
        setupStatusItem()
        setupPopover()
        setupPingManager()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Connection Status")
            let greenImage = image?.withSymbolConfiguration(.init(paletteColors: [.systemGreen]))
            button.image = greenImage
            button.action = #selector(togglePopover)
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.delegate = self
    }

    private func setupPingManager() {
        pingManager.startPinging()
        pingManager.$color.sink { [weak self] color in
            self?.updateButtonAppearance(color: color)
        }.store(in: &cancellables)
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.contentViewController = NSHostingController(rootView: PingGraphView(pingManager: pingManager))
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    private func updateButtonAppearance(color: Color) {
        let image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Connection Status")

        if let button = statusItem.button {
            switch color {
            case .green:
                let greenImage = image?.withSymbolConfiguration(.init(paletteColors: [.systemGreen]))
                button.image = greenImage
            case .yellow:
                let yellowImage = image?.withSymbolConfiguration(.init(paletteColors: [.systemYellow]))
                button.image = yellowImage
            case .red:
                let redImage = image?.withSymbolConfiguration(.init(paletteColors: [.systemRed]))
                button.image = redImage
            default:
                button.image = image
            }
        }
    }
}

extension AppDelegate: NSPopoverDelegate {
    func popoverDidClose(_: Notification) {
        popover.contentViewController = nil
    }
}
