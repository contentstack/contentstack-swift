//
//  SystemFields.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

/// Sysyem Fields are available fields for entities in Contentstack.
public protocol SystemFields: class {
    /// The unique identifier of the entity.
    var uid: String { get }
    /// The title of the entity.
    var title: String { get }
    /// Describes the date of the entity is created.
    var createdAt: Date? { get }
    /// Describes the date of the entity is last updated.
    var updatedAt: Date? { get }
}

/// The Protocol for creating Entry model.
public protocol EntryFields: SystemFields {
    /// The code for currently selected locale.
    var locale: String {get}
    /// Describes the unique identifier of user who created the entity.
    var createdBy: String? {get}
    /// Describes the unique identifier of user who last updated the entity.
    var updatedBy: String? {get}
}
/// The Protocol for creating Asset model.
public protocol AssetFields: SystemFields {
    /// Describes the unique identifier of user who created the entity
    var createdBy: String? {get}
    /// Describes the unique identifier of user who last updated the entity.
    var updatedBy: String? {get}
    /// The name of the Asset.
    var fileName: String { get }
    /// The size of the Asset.
    var fileSize: Double { get }
    /// The file tyoe  of the Asset.
    var fileType: String { get }
    /// The url for the Asset.
    var url: String { get }
}

/// The cache policy for while fetching entity.
public protocol CachePolicyAccessible {
    /// The cachePolicy that is use for fetching entity.
    var cachePolicy: CachePolicy { get }
}

/// A protocol enabling strongly typed queries to the Contentstack Delivery API via the SDK.
public protocol FieldKeysQueryable {
    /// The `CodingKey` representing the field identifiers/JSON keys for the corresponding content type.
    /// These coding keys should be the same as those used when implementing `Decodable`.
    associatedtype FieldKeys: CodingKey
}

/// Classes conforming to this protocol are accessible via an `Endpoint`.
public protocol EndpointAccessible {
    static var endpoint: Endpoint { get }
}
