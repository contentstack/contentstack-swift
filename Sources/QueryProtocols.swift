//
//  ResourchQueryable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 19/03/20.
//

import Foundation

internal protocol QueryProtocol: class, Queryable, CachePolicyAccessible {
    associatedtype ResourceType

    var stack: Stack { get set }

    var parameters: [String: String] { get set }

    var queryParameter: [String: Any] { get set }

    var cachePolicy: CachePolicy { get set }
}

extension QueryProtocol {
    public func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible {
        if let query = self.queryParameter.jsonString {
            self.parameters[QueryParameter.query] = query
        }
    }
}

internal protocol ChainableQuery: QueryProtocol {}
extension ChainableQuery {

    public func `where`(valueAtKeyPath keyPath: String, _ operation: Query.Operation) -> Self {
           // Create parameter for this query operation.
        let parameter = keyPath + operation.string
        self.queryParameter[parameter] = operation.value
        return self
    }

    @discardableResult
    public func skip(theFirst numberOfResults: UInt) -> Self {
        self.parameters[QueryParameter.skip] = String(numberOfResults)
        return self
    }

    @discardableResult
    public func limit(to numberOfResults: UInt) -> Self {
        let limit = min(numberOfResults, QueryConstants.maxLimit)
        self.parameters[QueryParameter.limit] = String(limit)
        return self
    }

    @discardableResult
    public func orderByAscending(keyPath: String) -> Self {
        self.parameters[QueryParameter.asc] = keyPath
        return self
    }

    @discardableResult
    public func orderByDecending(keyPath: String) -> Self {
        self.parameters[QueryParameter.desc] = keyPath
        return self
    }
}

public protocol ResourceQueryable {
    func fetch<ResourceType>(_ completion: @escaping ResultsHandler<ResourceType>)
        where ResourceType: Decodable & EndpointAccessible
}

public protocol Queryable {
    func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible
}
