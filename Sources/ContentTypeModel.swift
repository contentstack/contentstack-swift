//
//  ContentTypeModel.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 08/04/20.
//

import Foundation

public final class ContentTypeModel: SystemFields, Decodable {

    public var title: String

    public var uid: String

    public var createdAt: Date

    public var updatedAt: Date

    public var description: String?

    public var schema: [[String: Any]] = []

    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: FieldKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        let containerFields   = try decoder.container(keyedBy: JSONCodingKeys.self)
        let contentSchema = try containerFields.decode(Dictionary<String, Any>.self)
        if let schema = contentSchema["schema"] as? [[String: Any]] {
            self.schema = schema
        }
    }

    public enum FieldKeys: String, CodingKey {
        case title, uid, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case schema
    }

    public enum QueryableCodingKey: String, CodingKey {
        case uid, title, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

}

extension ContentTypeModel: EndpointAccessible {
    public static var endpoint: Endpoint {
        return .contenttype
    }
}
