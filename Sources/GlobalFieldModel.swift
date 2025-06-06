//
//  GlobalFieldModel.swift
//  ContentstackSwift
//
//  Created by Reeshika Hosmani on 27/05/25.
//

import Foundation

// Helper for decoding [String: Any] and other nested unknown types
public struct AnyDecodable: Decodable {
    public let value: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyDecodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyDecodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
}

public protocol GlobalFieldDecodable: GlobalFields, FieldKeysQueryable, EndpointAccessible, Decodable {}

public final class GlobalFieldModel : GlobalFieldDecodable {
    public var title: String
    
    public var uid: String
    
    public var createdAt: Date?
    
    public var updatedAt: Date?
    
    public var schema: [[String: Any]] = []
    
    public var description: String?
    
    public var maintainRevisions: Bool?
    
    public var inbuiltClass: Bool?
    
    public var version: Int?
    
    public var branch: String?
    
    public var lastActivity: [String: Any] = [:]
    
    public enum FieldKeys: String, CodingKey {
        case title, uid, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case maintainRevisions = "maintain_revisions"
        case version = "_version"
        case branch = "_branch"
        case lastActivity = "last_activity"
        case inbuiltClass = "inbuilt_class"
        case schema
    }
    
    public enum QueryableCodingKey: String, CodingKey {
        case uid, title, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

//    public required init(from decoder: Decoder) throws {
//        let container   = try decoder.container(keyedBy: FieldKeys.self)
//        uid = try container.decode(String.self, forKey: .uid)
//        title = try container.decode(String.self, forKey: .title)
//        description = try? container.decodeIfPresent(String.self, forKey: .description)
//        createdAt = try? container.decode(Date.self, forKey: .createdAt)
//        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
//        maintainRevisions = try? container.decode(Bool.self, forKey: .maintainRevisions)
//        version = try? container.decode(Int.self, forKey: .version)
//        branch = try? container.decode(String.self, forKey: .branch)
//        inbuiltClass = try? container.decode(Bool.self, forKey: .inbuiltClass)
//        let containerFields   = try? decoder.container(keyedBy: JSONCodingKeys.self)
//        let globalFieldSchema = try containerFields?.decode(Dictionary<String, Any>.self)
//        if let schema = globalFieldSchema?["schema"] as? [[String: Any]] {
//            self.schema = schema
//        }
////        if let decodedSchema = try? container.decodeIfPresent([ [String: AnyDecodable] ].self, forKey: .schema) {
////                 self.schema = decodedSchema.map { $0.mapValues { $0.value } }
////        }
//        if let decodedLastActivity = try? container.decodeIfPresent([String: AnyDecodable].self, forKey: .lastActivity) {
//                    lastActivity = decodedLastActivity.mapValues { $0.value }
//                }
//    }
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FieldKeys.self)

        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        maintainRevisions = try? container.decode(Bool.self, forKey: .maintainRevisions)
        version = try? container.decode(Int.self, forKey: .version)
        branch = try? container.decode(String.self, forKey: .branch)
        inbuiltClass = try? container.decode(Bool.self, forKey: .inbuiltClass)

        // ✅ Decode schema directly and safely
        if let decodedSchema = try? container.decodeIfPresent([[String: AnyDecodable]].self, forKey: .schema) {
            self.schema = decodedSchema.map { $0.mapValues { $0.value } }
        }

        if let decodedLastActivity = try? container.decodeIfPresent([String: AnyDecodable].self, forKey: .lastActivity) {
            lastActivity = decodedLastActivity.mapValues { $0.value }
        }
    }
}

extension GlobalFieldModel : EndpointAccessible {
    public static var endpoint: Endpoint {
        return .globalfields
    }
}
