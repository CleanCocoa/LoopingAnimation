//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit

/// `NSAnimation` that reports smooth, un-marked animation progress directly through `progressHandler`.
public class SmoothAnimation: NSAnimation {
    public var progressHandler: ((NSAnimation.Progress) -> Void)?
    public override var currentProgress: NSAnimation.Progress {
        didSet {
            progressHandler?(currentProgress)
        }
    }
}
