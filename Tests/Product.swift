//
//  Product.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 26/03/20.
//

import Foundation
import Contentstack

class Product: EntryDecodable, FieldKeysQueryable {
    public enum FieldKeys: String, CodingKey {
           case title, uid, locale
           case createdAt = "created_at"
           case updatedAt = "updated_at"
           case createdBy = "created_by"
           case updatedBy = "updated_by"
       }
    var locale: String
    var title: String
    var uid: String
    var createdAt: Date
    var updatedAt: Date
    var createdBy: String
    var updatedBy: String
}
