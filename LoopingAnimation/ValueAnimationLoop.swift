//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

/// Animation loop that translates animation progress to `value`.
///
/// It animates incrementing from 0...`value` and back again from `value`...0.
public class ValueAnimationLoop {

    internal let loop: AnimationLoop
    public let value: CGFloat

    public var progressHandler: ((CGFloat) -> Void)?

    internal init(value: CGFloat, loop: AnimationLoop) {
        self.value = value
        self.loop = loop
    }

    public convenience init(value: CGFloat,
                            increaseDuration: TimeInterval = 1.0,
                            increaseCurve: NSAnimation.Curve = .easeInOut,
                            decreaseDuration: TimeInterval = 1.0,
                            decreaseCurve: NSAnimation.Curve = .easeInOut) {

        self.init(
            value: value,
            loop: AnimationLoop(
                increaseDuration: increaseDuration,
                increaseCurve: increaseCurve,
                decreaseDuration: decreaseDuration,
                decreaseCurve: decreaseCurve))

        self.loop.progressHandler = { [weak self] in self?.loopDidProgress(progress: $0, operation: $1) }
    }

    private func loopDidProgress(progress: AnimationLoop.Progress, operation: AnimationLoop.Operation) {

        guard let progressHandler = progressHandler else { return }

        let progressedValue: CGFloat = {
            switch operation {
            case .increment: return progress * value
            case .decrement: return value - (progress * value)
            }
        }()

        progressHandler(progressedValue)
    }

    public var isAnimating: Bool { return loop.isAnimating }

    public func start() {
        loop.start()
    }

    public func reset() {
        loop.reset()
    }
}
