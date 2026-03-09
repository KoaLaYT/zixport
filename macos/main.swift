import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var renderView: RenderView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let game = game_init()
        let width = Int(game.display_width)
        let height = Int(game.display_height)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "zixport"
        window.center()

        renderView = RenderView(
            frame: NSRect(x: 0, y: 0, width: width, height: height),
            game: game
        )
        window.contentView = renderView
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(renderView)
        NSApplication.shared.activate(ignoringOtherApps: true)

        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            if !game_update() {
                timer.invalidate()
                NSApplication.shared.terminate(nil)
                return
            }
            self?.renderView.needsDisplay = true
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

class RenderView: NSView {
    let game: Game

    init(frame: NSRect, game: Game) {
        self.game = game
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let width = Int(game.display_width)
        let height = Int(game.display_height)
        let buffer = game.display!

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let dataProvider = CGDataProvider(dataInfo: nil,
                                                 data: buffer,
                                                 size: width * height * 4,
                                                 releaseData: { _, _, _ in }) else { return }

        guard let image = CGImage(width: width,
                                   height: height,
                                   bitsPerComponent: 8,
                                   bitsPerPixel: 32,
                                   bytesPerRow: width * 4,
                                   space: colorSpace,
                                   bitmapInfo: bitmapInfo,
                                   provider: dataProvider,
                                   decode: nil,
                                   shouldInterpolate: false,
                                   intent: .defaultIntent) else { return }

        context.saveGState()
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        context.restoreGState()
    }

    override func keyDown(with event: NSEvent) {
        game_key_down(event.keyCode)
    }

    override func keyUp(with event: NSEvent) {
        game_key_up(event.keyCode)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
