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
}
