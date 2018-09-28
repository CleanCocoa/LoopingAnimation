# LoopingAnimation

![Swift 4.2](https://img.shields.io/badge/Swift-4.2-blue.svg?style=flat)
![Version](https://img.shields.io/github/tag/CleanCocoa/LoopingAnimation.svg?style=flat)
![License](https://img.shields.io/github/license/CleanCocoa/LoopingAnimation.svg?style=flat)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Convenience types to configure two `NSAnimation`s to loop infinitely.

## Types

- `SmoothAnimation` is an `NSAnimation` that reports progress continuously instead of only reporting progress marks that'd result in jagged animations.
- `AnimationLoop` handles `SmoothAnimation` callbacks to create a loop of two animations. You can configure the **increase** and **decrease** animation's durations and animation curves with `AnimationLoop.LoopConfiguration` or through the convenience initializer.
- `ValueAnimationLoop` wraps `AnimationLoop`, which progresses from 0.0 to 1.0, and instead forwards progress from 0.0 up to its `value`. You can use this to animate offsets from 0 to +100, or from 0 to -100, but not from -100 to +100. It always starts at 0.

## Installation

This repository is Carthage compatible.

But the overhead of compiling these few classes into a Swift module is not worth the effort. This repository setup was thrown together to separate the sample app from the library code; **I recommend to simply copy the relevant source code files into your project directly.**

## Example

See the sample app for a simple "breathing" animation.

```swift
func setupAnimation() -> ValueAnimationLoop {
    // Configure the animation to 
    // - start with an animation from 0...100 in 3 seconds,
    // - then loop back from 100...0 in 2 seconds.
    let loop = ValueAnimationLoop(
        value: 100,
        increaseDuration: 3.0,
        increaseCurve: .easeInOut,
        decreaseDuration: 2.0,
        decreaseCurve: .easeInOut,
        startWith: .increment)
    loop.progressHandler = { [weak self] in self?.animateValueChange($0) }
    return loop 
}

func animateValueChange(_ value: CGFloat) {
    // Change a view's position, size, color, whatever.
    print(value)
}
```

## Code License

Copyright (c) 2018 Christian Tietze. Distributed under the MIT License.
