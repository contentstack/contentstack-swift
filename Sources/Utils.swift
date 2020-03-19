//
//  Utils.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

public extension Dictionary {
    internal var jsonString: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self,
                                                  options: JSONSerialization.WritingOptions.prettyPrinted),
            let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        }
        return nil
    }
}
