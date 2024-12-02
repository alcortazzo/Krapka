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

    func applicationDidFinishLaunching(_: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Connection Status")
            let greenImage = image?.withSymbolConfiguration(.init(paletteColors: [.systemGreen]))

            button.image = greenImage
            button.action = #selector(togglePopover)
        }

        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: PingGraphView(pingManager: pingManager))
        popover.behavior = .transient

        pingManager.startPinging()

        // Observe changes to pingManager.color
        pingManager.$color.sink { [weak self] color in
            self?.updateButtonAppearance(color: color)
        }.store(in: &cancellables)
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

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
