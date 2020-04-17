//
//  QueryableRange.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 19/03/20.
//

import Foundation

/// Use types that conform to QueryableRange to perform queries with the four Range operators
public protocol QueryableRange {
    /// A string representation of a query value that can be used in an API query.
    var stringValue: String { get }
}

extension QueryableRange {
    func isEquals(to range: QueryableRange) -> Bool {
        if self is Int || self is Float || self is Double {
            if type(of: self) != type(of: range) { return false }
        }
        return self.stringValue == range.stringValue
    }
}

extension Int: QueryableRange {
    public var stringValue: String {
        return String(self)
    }
}

extension Bool: QueryableRange {
    public var stringValue: String {
        return self ? "true": "false"
    }
}

extension Double: QueryableRange {
    public var stringValue: String {
        return String(self)
    }
}

extension String: QueryableRange {
    public var stringValue: String {
        return self
    }
}

extension Date: QueryableRange {
    /// The ISO8601 string representation of the receiving Date object.
    public var stringValue: String {
        return self.iso8601String
    }
}
