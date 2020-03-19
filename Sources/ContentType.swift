//
//  ContentType.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public protocol ContentTypeDecodable: SystemFields, Decodable {
    var schema: [String: Any]? { get }
}

public class ContentType: FieldKeysQueryable {

    internal var stack: Stack
    var uid: String?

    internal required init(_ uid: String?, stack: Stack) {
       self.uid = uid
       self.stack = stack
    }

    public enum FieldKeys: String, CodingKey {
        case title, uid, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
    }

    public func entry(uid: String? = nil) -> Entry {
        if self.uid == nil {
            fatalError("Please provide ContentType uid")
        }
        return Entry(uid, contentType: self)
    }

    func query() -> ContentTypeQuery {
        let query = ContentTypeQuery(stack: self.stack)
        if let uid = self.uid {
           _ = query.where(queryableCodingKey: ContentType.FieldKeys.uid, Query.Operation.equals(uid))
        }
        return query
    }
}

extension ContentType: EndpointAccessible {
    public static var endPoint: Endpoint {
        return .contenttype
    }

    public func endPoint(components: inout URLComponents) {
        components.path = "\(components.path)/\(Endpoint.contenttype)"
        if let uid = uid {
            components.path = "\(components.path)/\(uid)"
        }
    }
}
