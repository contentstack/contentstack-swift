//
//  Taxonomy.swift
//  Contentstack
//
//  Created by Vikram Kalta on 01/06/2024.
//

import Foundation

public class Taxonomy: CachePolicyAccessible {

    var uid: String?
    public var stack: Stack
    public var parameters: [String : Any] = [:]
    public var headers: [String : String] = [:]
    public var cachePolicy: CachePolicy = .networkOnly
    
    public var queryParameter: [String : Any] = [:]
    
    internal required init(stack: Stack) {
        self.stack = stack
    }
    
    public func query() -> Query {
        let query = Query(contentType: nil, stack: stack, cachePolicy: cachePolicy)
        return query
    }
    
    public func addValue(_ value: String, forHTTPHeaderField field: String) -> Self {
        self.headers[field] = value
        return self
    }
}

extension Taxonomy: ResourceQueryable {
    public func fetch<ResourceType>() async throws -> ContentstackResponse<ResourceType> where ResourceType: EndpointAccessible, ResourceType: Decodable {
        do {
            let data: ContentstackResponse<ResourceType> = try await self.stack.asyncFetch(endpoint: ResourceType.endpoint, cachePolicy: self.cachePolicy)
            return data
        } catch {
            throw error
        }
    }
}
