//
//  Decodable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 05/08/19.
//

import Foundation
public extension Decoder {

    var timeZone: TimeZone? {
        return userInfo[.timeZoneContextKey] as? TimeZone
    }
}

internal extension CodingUserInfoKey {
    static let linkResolverContextKey = CodingUserInfoKey(rawValue: "linkResolverContext")!
    static let timeZoneContextKey = CodingUserInfoKey(rawValue: "timeZoneContext")!
    static let contentTypesContextKey = CodingUserInfoKey(rawValue: "contentTypesContext")!
    static let localizationContextKey = CodingUserInfoKey(rawValue: "localizationContext")!
}

extension JSONDecoder {

    public static func dateDecodingStrategy() -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom(Date.variableISO8601Strategy)
        return jsonDecoder
    }
}

// Inspired by https://gist.github.com/mbuchetics/c9bc6c22033014aa0c550d3b4324411a
internal struct JSONCodingKeys: CodingKey {
    internal var stringValue: String
    internal init?(stringValue: String) {
        self.stringValue = stringValue
    }
    internal var intValue: Int?
    internal init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

internal extension KeyedDecodingContainer {

    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> [String: Any]? {
        guard contains(key) else { return nil }
        guard try decodeNil(forKey: key) == false else { return nil }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> [Any]? {
        guard contains(key) else { return nil }
        guard try decodeNil(forKey: key) == false else { return nil }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> [String: Any] {
        var dictionary = [String: Any]()
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let asset = try? decode(AssetModel.self, forKey: key) {
                dictionary[key.stringValue] = asset
            } else if let entry = try? decode(EntryModel.self, forKey: key) {
                dictionary[key.stringValue] = entry
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

internal extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> [Any] {
        var array: [Any] = []
        while isAtEnd == false {
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let asset = try? decode(AssetModel.self) {
                array.append(asset)
            } else if let entry = try? decode(EntryModel.self) {
                array.append(entry)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}
