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
    internal var parameters: Parameters = [:]
    internal var stack: Stack

    var uid: String?

    internal required init(_ uid: String?, stack: Stack) {
        self.uid = uid
        self.stack = stack
    }

    func includeRelativeURL() -> Asset {
        self.parameters[QueryParameter.relativeUrls] = true
        return self
    }

    func includeDimension() -> Asset {
        self.parameters[QueryParameter.includeDimension] = true
        return self
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
                         parameters: parameters + [QueryParameter.uid: uid],
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
