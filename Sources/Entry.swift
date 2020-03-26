//
//  Entry.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public protocol EntryDecodable: SystemFields, Decodable, FieldKeysQueryable {
    var locale: String? {get}
}

public class Entry: EntryQueryable, CachePolicyAccessible {
    typealias ResourceType = Entry

    public var cachePolicy: CachePolicy = .networkOnly

    var contentType: ContentType

    var uid: String?

    internal var stack: Stack

    internal var parameters: Parameters = [:]

    internal var queryParameter: [String: Any] = [:]

    public enum FieldKeys: String, CodingKey {
        case title, uid, locale
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
    }

    internal required init(_ uid: String?, contentType: ContentType) {
        self.uid = uid
        self.contentType = contentType
        self.stack = contentType.stack
    }

    public func query() -> Query {
        if self.contentType.uid == nil {
            fatalError("Please provide ContentType uid")
        }
        let query = Query(contentType: self.contentType)
        if let uid = self.uid {
           _ = query.where(queryableCodingKey: .uid, .equals(uid))
        }
        return query
    }

    public func query<EntryType>(_ entry: EntryType.Type) -> QueryOn<EntryType>
        where EntryType: EntryDecodable & FieldKeysQueryable {
            if self.contentType.uid == nil {
                fatalError("Please provide ContentType uid")
            }
            let query = QueryOn<EntryType>(contentType: self.contentType)
            if let uid = self.uid {
              _ =  query.where(queryableCodingKey: .uid, Query.Operation.equals(uid))
            }
            return query
    }
}

extension Entry: EndpointAccessible {
    public static var endPoint: Endpoint {
        return .entries
    }

    public func endPoint( components: inout URLComponents) {
        guard let contentTypeUID = contentType.uid else {return}
        components.path = "\(components.path)/\(Endpoint.contenttype.pathComponent)"
        components.path = "\(components.path)/\(contentTypeUID)/\(Endpoint.entries.pathComponent)"
        if let uid = uid {
            components.path = "\(components.path)/\(uid)"
        }
    }
}
