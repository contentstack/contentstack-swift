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

public class ContentType: CachePolicyAccessible {

    var uid: String?
    internal var stack: Stack

    public var cachePolicy: CachePolicy = .networkOnly

    internal required init(_ uid: String?, stack: Stack) {
       self.uid = uid
       self.stack = stack
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
           _ = query.where(queryableCodingKey: .uid, Query.Operation.equals(uid))
        }
        return query
    }
}

extension ContentType: ResourceQueryable {
    public func fetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void)
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide ContentType uid") }
        self.stack.fetch(endpoint: ResourceType.endpoint,
                         cachePolicy: self.cachePolicy,
                         parameters: [QueryParameter.uid: uid],
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
