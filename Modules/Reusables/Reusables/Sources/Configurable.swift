//
//  Configurable.swift
//  PrivyPass
//
//  Created by Muiz on 23/08/21.
//

import Foundation

public protocol Configurable {}
public extension Configurable {
    @discardableResult
    func configure(completion: (Self) -> Void) -> Self {
        completion(self)
        return self
    }
}

extension NSObject: Configurable {}
