//
//  ImageTransformError.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 30/03/20.
//

import Foundation

public struct ImageTransformError: Error, CustomDebugStringConvertible {

    internal let message: String

    public var debugDescription: String {
        return message
    }
}
