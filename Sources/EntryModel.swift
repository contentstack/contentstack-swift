//
//  EntryModel.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 08/04/20.
//

import Foundation

public protocol ContentTypeIncludable {
    var contentType: ContentTypeModel? { get set}
}

public extension EndpointAccessible where Self: EntryDecodable {
    static var endpoint: Endpoint {
        return Endpoint.entries
    }
}

public class EntryModel: EntryDecodable, ContentTypeIncludable {

    public var title: String

    public var uid: String

    public var locale: String

    public var createdAt: Date?

    public var updatedAt: Date?

    public var createdBy: String?

    public var updatedBy: String?

    public var fields: [String: Any]?

    public var contentType: ContentTypeModel?

    public enum FieldKeys: String, CodingKey {
        case title, uid, locale
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
    }

    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: FieldKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        createdBy = try? container.decode(String.self, forKey: .createdBy)
        updatedBy = try? container.decode(String.self, forKey: .updatedBy)
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        locale = try container.decode(String.self, forKey: .locale)

        let containerFields   = try decoder.container(keyedBy: JSONCodingKeys.self)
        fields = try containerFields.decode(Dictionary<String, Any>.self)
    }

    /// Returns a JSON-serializable `[String: Any]` dictionary suitable for use with
    /// `JSONSerialization`. When `include_all` or reference includes are used, the SDK
    /// stores nested `EntryModel`/`AssetModel`/`ContentTypeModel` objects inside the
    /// `fields` dictionary. Those Swift objects are not accepted by `JSONSerialization`,
    /// so this method recursively converts them to plain dictionaries before returning.
    public func toJSON() -> [String: Any] {
        return EntryModel.normalizeForJSON(fields ?? [:]) as? [String: Any] ?? [:]
    }

    static func normalizeForJSON(_ value: Any) -> Any {
        switch value {
        case let entry as EntryModel:
            return entry.toJSON()
        case let asset as AssetModel:
            return asset.toJSON()
        case let contentType as ContentTypeModel:
            return contentType.toJSON()
        case let array as [Any]:
            return array.map { normalizeForJSON($0) }
        case let dict as [String: Any]:
            return dict.mapValues { normalizeForJSON($0) }
        default:
            // Reached for JSON-native scalars (String/NSNumber/Bool/NSNull). The SDK decoder
            // only ever stores these or the three model types above inside `fields`. If a new
            // decodable model type is ever added to Decodable.swift, add a case for it here.
            return value
        }
    }
}
