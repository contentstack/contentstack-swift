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

/// Decodable is a powerful Swift standard library feature that developers can use to decode custom types from external representation, such as JSON.
///
/// `EntryDecodable` is an extension of the decodable protocol that you can use to decode the response to a specific model. By using this protocol, you can define types that will be mapped from your entries of the content type.
///
/// In this guide, we will discuss how we can use the EntryDecodable Protocol in your Swift SDK.
///
/// EntryDecodable Example Usage
///
/// Let's understand how to use this protocol with the help of a few examples.
///
/// Standard Usage
///
/// We have a content type named `Session` and to fetch entries of our `Session` content type from the Swift SDK, we need to create a class named `Session` that implements the `EntryDecodable` protocol as follows:
///
/// Example usage:
/// ```
/// class Session: EntryDecodable {
///    public enum FieldKeys: String, CodingKey {
///        case title, uid, locale, type, speakers
///        case createdAt = "created_at"
///        case updatedAt = "updated_at"
///        case createdBy = "created_by"
///        case updatedBy = "updated_by"
///        case sessionId = "session_id"
///        case desc = "description"
///        case sessionTime = "session_time"
///    }
///
///    var locale: String
///    var title: String
///    var uid: String
///    var createdAt: Date?
///    var updatedAt: Date?
///    var createdBy: String?
///    var updatedBy: String?
///    var sessionId: Int
///    var desc: String
///    var type: String
///    var sessionTime: SessionTime
///    var speakers: [Speaker]?
///    public required init(from decoder: Decoder) throws {
///        let container   = try decoder.container(keyedBy: FieldKeys.self)
///        uid = try container.decode(String.self, forKey: .uid)
///        title = try container.decode(String.self, forKey: .title)
///        createdBy = try? container.decode(String.self, forKey: .createdBy)
///        updatedBy = try? container.decode(String.self, forKey: .updatedBy)
///        createdAt = try? container.decode(Date.self, forKey: .createdAt)
///        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
///        locale = try container.decode(String.self, forKey: .locale)
///        sessionId = try container.decode(Int.self, forKey: .sessionId)
///        desc = try container.decode(String.self, forKey: .desc)
///        type = try container.decode(String.self, forKey: .type)
///        sessionTime = try container.decode(DateTime.self, forKey: .sessionTime)
///        speakers = try container.decode([Speaker].self, forKey: .speakers)
///    }
/// }
/// ```
/// Usage in Referencing
///
/// Let's say there is another content type in our Stack named `Speaker` that is referenced in our `Session` Content Type.
///
/// For this case, we will create a class named `Speaker` that implements the `EntryDecodable` protocol as follows:
/// Example usage:
/// ```
/// class Speaker: EntryDecodable {
///    public enum FieldKeys: String, CodingKey {
///        case title, uid, name, locale
///        case createdAt = "created_at"
///        case updatedAt = "updated_at"
///        case createdBy = "created_by"
///        case updatedBy = "updated_by"
///        case desc = "description"
///    }
///
///    var locale: String
///    var title: String
///    var uid: String
///    var createdAt: Date?
///    var updatedAt: Date?
///    var createdBy: String?
///    var updatedBy: String?
///    var sessionId: Int
///    var desc: String
///    var name: String
///    public required init(from decoder: Decoder) throws {
///        let container   = try decoder.container(keyedBy: FieldKeys.self)
///        uid = try container.decode(String.self, forKey: .uid)
///        title = try container.decode(String.self, forKey: .title)
///        createdBy = try? container.decode(String.self, forKey: .createdBy)
///        updatedBy = try? container.decode(String.self, forKey: .updatedBy)
///        createdAt = try? container.decode(Date.self, forKey: .createdAt)
///        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
///        locale = try container.decode(String.self, forKey: .locale)
///        name = try container.decode(String.self, forKey: .name)
///        desc = try container.decode(String.self, forKey: .desc)
///    }
/// }
///```
///
/// In the `Session` class, we have a ‘session_time’ `Global Field`. To parse it, we need to create a class named `SessionTime` that implements the `Decodable` protocol as follows.
/// Example:
/// ```
/// class SessionTime: Decodable {
///    var startTime: Date?
///    var endTime: Date?
///
///    public enum CodingKeys: String, CodingKey {
///        case startTime = "start_time"
///        case endTime = "end_time"
///    }
///    public required init(from decoder: Decoder) throws {
///        let container   = try decoder.container(keyedBy: CodingKeys.self)
///        startTime = try? container.decode(Date.self, forKey: .startTime)
///        endTime = try? container.decode(Date.self, forKey: .endTime)
///    }
/// }
/// ```
/// `Note`: If we have fields with `Modular block`, `JSON`, or an `array of JSON` in our content type, we can create a class that implements `Decodable`.
public protocol EntryDecodable: EntryFields, FieldKeysQueryable, EndpointAccessible, Decodable {}
