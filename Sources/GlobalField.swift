//
//  GlobalField.swift
//  ContentstackSwift
//
//  Created by Reeshika Hosmani on 26/05/25.
//

import Foundation

public class GlobalField: CachePolicyAccessible{
    
    public var cachePolicy: CachePolicy = .networkOnly
    /// URI Parameters
    internal var parameters: Parameters = [:]
    internal var headers: [String: String] = [:]
    internal var stack: Stack
    /// Unique ID of the global_field of which you wish to retrieve the details.
    internal var uid: String?
    /// Query Parameters
    public var queryParameter: [String: Any] = [:]
    
    internal required init(stack: Stack) {
        self.stack = stack
    }
    internal required init(_ uid: String?, stack: Stack) {
        self.uid = uid
        self.stack = stack
    }
    
    public func includeBranch() -> GlobalField {
        self.parameters[QueryParameter.includeBranch] = true
        return self
    }
    
    public func includeGlobalFieldSchema() -> GlobalField {
        self.parameters[QueryParameter.includeGlobalFieldSchema] = true
        return self
    }
    
}

extension GlobalField: ResourceQueryable {
    /// This call fetches the latest version of a specific `Global Field` of a particular stack.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.globalField
    /// .fetch { (result: Result<GlobalFieldModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///         //Model retrive from API
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func fetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void)
        where ResourceType: EndpointAccessible & Decodable {
        guard let uid = self.uid else { fatalError("Please provide Global Field uid") }
        self.stack.fetch(endpoint: ResourceType.endpoint,
                         cachePolicy: self.cachePolicy,
                         parameters: parameters + [QueryParameter.uid: uid],
                         headers: headers,
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

extension GlobalField : Queryable{
    public func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>) where ResourceType :Decodable & EndpointAccessible {
        if self.queryParameter.count > 0,
            let query = self.queryParameter.jsonString {
            self.parameters[QueryParameter.query] = query
        }
        self.stack.fetch(endpoint: ResourceType.endpoint,
        cachePolicy: self.cachePolicy, parameters: parameters, headers: headers, then: completion)
    }
    
}
