//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import LoopingAnimation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var breathingView: BreathingView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        guard let contentView = window.contentView else { fatalError() }

        self.breathingView = BreathingView()
        breathingView.translatesAutoresizingMaskIntoConstraints = false
        breathingView.shadow = {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 2
            shadow.shadowOffset = NSSize(width: 0, height: -2)
            shadow.shadowColor = NSColor(white: 0, alpha: 0.3)
            return shadow
        }()
        contentView.addSubview(breathingView)
        contentView.addConstraints([
            NSLayoutConstraint(item: breathingView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: breathingView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            ])
    }
}

class BreathingView: NSView {

    override var intrinsicContentSize: NSSize { return NSSize(width: 300, height: 300) }

    override func viewDidMoveToSuperview() {

        switch superview {
        case .some: animationLoop.start()
        case .none: animationLoop.reset()
        }
    }

    private let maxPadding: CGFloat = 40
    lazy var animationLoop: ValueAnimationLoop = {
        let loop = ValueAnimationLoop(
            value: maxPadding,
            increaseDuration: 3.0,
            increaseCurve: .easeInOut,
            decreaseDuration: 2.0,
            decreaseCurve: .easeInOut)
        loop.progressHandler = { [weak self] in self?.breathingValue = $0 }
        return loop
    }()

    private(set) var breathingValue: CGFloat = 0 {
        didSet {
            self.needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        let padding = maxPadding - breathingValue
        let circleRect = NSRect(
            x: bounds.origin.x + padding,
            y: bounds.origin.y + padding,
            width: bounds.size.width - 2 * padding,
            height: bounds.size.height - 2 * padding)
        #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).setFill()
        NSBezierPath(ovalIn: circleRect).fill()
    }
}
