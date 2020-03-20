//
//  ParameterEncoding.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 20/03/20.
//

import Foundation
internal typealias Parameters = [String: String]

extension Parameters {
    internal func query() -> String {
        var components: [(String, String)] = []
        for key in self.keys.sorted(by: <) {
            if let value = self[key] {
                components += queryComponents(with: key, value: value)
            }
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    private func queryComponents(with key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
         if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(with: "\(key)[\(nestedKey)]", value: value)
            }
         } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(with: encode(key: key), value: value)
            }
         } else if let value = value as? NSNumber {
            if let boolvalue = value as? Bool {
                components.append((escape(key), escape(boolvalue.encode())))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
         } else if let bool = value as? Bool {
            components.append((escape(key), escape(bool.encode())))
         } else {
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }

    private func escape(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }

    private func encode(key: String) -> String {
        return "\(key)[]"
    }
}

extension Bool {
    internal func encode() -> String {
        return self ? "true" : "false"
    }
}
