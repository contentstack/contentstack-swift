//
//  ImageTransformError.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 30/03/20.
//

import Foundation
/// Information regarding an error received from Contentstack's Image Delivery API.
public struct ImageTransformError: Error, CustomDebugStringConvertible {
    /// Human redable error Message
    public let message: String

    public var debugDescription: String {
        return message
    }
}
