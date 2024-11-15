//
//  TFYSwiftChain.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/6.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa

public protocol TFYCompatible {}

extension NSObject: TFYCompatible {}

public protocol TFYSwiftPropertyCompatible {
    associatedtype T
    typealias SwiftCallBack = ((T?) -> ())
    var swiftCallBack: SwiftCallBack? { get set }
}

public struct Chain<Base> {
    public let base: Base
    public var build: Base {
        return base
    }
    public init(_ base: Base) {
        self.base = base
    }
}

extension TFYCompatible {
    static public var chain: Chain<Self>.Type {
        get { Chain<Self>.self }
        set {}
    }
    public var chain: Chain<Self> {
        get { Chain(self) }
        set {}
    }
}



