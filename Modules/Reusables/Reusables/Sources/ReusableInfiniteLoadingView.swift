//
//  ReusableInfiniteLoadingView.swift
//  Fullback
//
//  Created by Muiz on 02/07/21.
//  Copyright © 2021 Fullback. All rights reserved.
//

import UIKit
import ThirdPartyLibraries

public final class ReusableInfiniteLoadingView: UIView {
    let progress = IndefiniteAnimatedView()
    
    public var strokeColor = UIColor.red {
        didSet {
            progress.setIndefinite(strokeColor: strokeColor)
        }
    }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        addSubview(progress)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        progress.frame.size = .init(width: 20, height: 20)
        progress.center = center
        progress.setIndefinite(radius: 10)
        progress.setIndefinite(strokeColor: strokeColor)
        progress.setIndefinite(strokeThickness: 1)
    }
}
