//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

public class AnimationLoop: NSObject, NSAnimationDelegate {

    public let configuration: LoopConfiguration

    private var runningAnimation: DirectedAnimation!
    public var currentOperation: Operation { return runningAnimation.operation }
    public var isAnimating: Bool { return runningAnimation.isAnimating }

    /// Value betweem 0.0 and 1.0
    public typealias Progress = CGFloat
    public var progressHandler: ((Progress, Operation) -> Void)?

    /// Sets up an animation loop.
    ///
    /// - parameter configuration: Configuration of the looping animation parts.
    /// - parameter initialOperation: Which animation loop operation to start with. Defaults to `.increment`.
    public required init(
        configuration: LoopConfiguration,
        startWith initialOperation: Operation = .increment) {

        self.configuration = configuration

        super.init()

        self.runningAnimation = createAnimation(operation: initialOperation)
    }

    /// Sets up a loop with a `LoopConfiguration` of the parameters from this initializer.
    ///
    /// - parameter increaseDuration: Time the increase animations will take.
    /// - parameter increaseCurve: Animation curve of increase animations.
    /// - parameter decreaseDuration: Time the decreaste animations will take.
    /// - parameter decreaseCurve: Animation curve of decrease animations.
    public convenience init(
        increaseDuration: TimeInterval,
        increaseCurve: NSAnimation.Curve,
        decreaseDuration: TimeInterval,
        decreaseCurve: NSAnimation.Curve) {

        self.init(configuration: LoopConfiguration(
            increase: .init(duration: increaseDuration, animationCurve: increaseCurve),
            decrease: .init(duration: decreaseDuration, animationCurve: decreaseCurve)))
    }

    /// Sets up a loop of 2 animations with increase and decrease both
    /// configured the same way.
    ///
    /// - parameter duration: Duration of both the increase and decrease animation.
    /// - parameter animationCurve: Animation curve of both the increase and decrease animation.
    public convenience init(duration: TimeInterval, animationCurve: NSAnimation.Curve) {
        self.init(increaseDuration: duration, increaseCurve: animationCurve,
                  decreaseDuration: duration, decreaseCurve: animationCurve)
    }

    /// Sets up a loop of 2 animations with a default duration of 1 second
    /// and `.easeInOut` animation curve.
    public convenience override init() {
        self.init(duration: 1, animationCurve: .easeInOut)
    }

    private func createAnimation(operation: Operation) -> DirectedAnimation {

        let animation = configuration.step(operation: operation).smoothAnimation()
        animation.animationBlockingMode = .nonblocking
        animation.delegate = self
        animation.progressHandler = { [weak self] in self?.animationDidProgress($0) }
        return DirectedAnimation(
            animation: animation,
            operation: operation)
    }

    private func animationDidProgress(_ progress: NSAnimation.Progress) {
        progressHandler?(CGFloat(progress), currentOperation)
    }

    public func animationDidEnd(_ animation: NSAnimation) {
        guard animation === self.runningAnimation.animation else { return }
        startNextAnimation()
    }

    private func startNextAnimation() {
        let nextOperation = !self.currentOperation
        let nextAnimation = createAnimation(operation: nextOperation)
        self.runningAnimation = nextAnimation
        nextAnimation.start()
    }

    public func start() {

        guard !isAnimating else { preconditionFailure("Cannot start while running") }

        runningAnimation.start()
    }

    public func reset() {

        self.runningAnimation.cancel()
        self.runningAnimation = createAnimation(operation: .increment)
    }

    public struct DirectedAnimation {

        public let animation: SmoothAnimation
        public var isAnimating: Bool { return animation.isAnimating }

        public let operation: Operation

        public init(animation: SmoothAnimation, operation: Operation) {
            self.animation = animation
            self.operation = operation
        }

        public func start() {
            animation.start()
        }

        public func cancel() {
            // Do not forward the last frame event that `stop()` will emit.
            animation.progressHandler = { _ in }
            animation.stop()
        }
    }

    public enum Operation {
        case increment
        case decrement

        public static prefix func !(_ operation: Operation) -> Operation {
            if operation ~= .increment { return .decrement }
            return .increment
        }
    }

    public struct LoopConfiguration {
        public let increase: AnimationStep
        public let decrease: AnimationStep

        public init(increase: AnimationStep, decrease: AnimationStep) {
            self.increase = increase
            self.decrease = decrease
        }

        public func step(operation: Operation) -> AnimationStep {
            switch operation {
            case .increment: return increase
            case .decrement: return decrease
            }
        }

        public struct AnimationStep {
            public let duration: TimeInterval
            public let animationCurve: NSAnimation.Curve

            public init(duration: TimeInterval, animationCurve: NSAnimation.Curve) {
                self.duration = duration
                self.animationCurve = animationCurve
            }

            public func smoothAnimation() -> SmoothAnimation {
                return SmoothAnimation(duration: duration, animationCurve: animationCurve)
            }
        }
    }
}
