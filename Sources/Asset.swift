//
//  Asset.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public protocol AssetDecodable: AssetFields, FieldKeysQueryable, Decodable {}

public class Asset: CachePolicyAccessible {
    public var cachePolicy: CachePolicy = .networkOnly

    internal var stack: Stack

    var uid: String?

    internal required init(_ uid: String?, stack: Stack) {
        self.uid = uid
        self.stack = stack
    }

    func query() -> AssetQuery {
        let query = AssetQuery(stack: self.stack)
        if let uid = self.uid {
           _ = query.where(queryableCodingKey: .uid, .equals(uid))
        }
        return query
    }
}

extension Asset: ResourceQueryable {
    public func fetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void)
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide Asset uid") }
        self.stack.fetch(endpoint: ResourceType.endpoint,
                         cachePolicy: self.cachePolicy,
                         parameters: [QueryParameter.uid: uid],
                         then: completion)
    }
}
