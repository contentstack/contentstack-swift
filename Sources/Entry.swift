//
//  Entry.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public class Entry: EntryQueryable, CachePolicyAccessible {
    typealias ResourceType = EntryModel

    var uid: String?

    public var cachePolicy: CachePolicy = .networkOnly

    internal var stack: Stack

    internal var contentType: ContentType

    internal var parameters: Parameters = [:]

    internal var queryParameter: [String: Any] = [:]

    internal required init(_ uid: String?, contentType: ContentType) {
        self.uid = uid
        self.contentType = contentType
        self.stack = contentType.stack
        self.parameters[QueryParameter.contentType] = contentType.uid
        self.parameters[QueryParameter.uid] = uid
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

extension Entry: ResourceQueryable {
    public func fetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void)
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide Entry uid") }
        self.stack.fetch(endpoint: ResourceType.endpoint,
                         cachePolicy: self.cachePolicy,
                         parameters: parameters + [QueryParameter.uid: uid,
                                                   QueryParameter.contentType: self.contentType.uid!],
                         then: { (result: Result<ContentstackResponse<ResourceType>, Error>, response: ResponseType) in
                            switch result {
                            case .success(let contentStackResponse):
                                if let resource = contentStackResponse.items.first {
                                    completion(.success(resource), response)
                                } else {
                                    completion(.failure(SDKError.invalidUID(string: uid)), response)
                                }
                            case .failure(let error):
                                completion(.failure(error), response)
                            }
        })
    }
}
