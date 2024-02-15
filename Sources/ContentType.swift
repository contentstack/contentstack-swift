//
//  ContentType.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation
/// The decodable to get schema of ContentType.
public protocol ContentTypeDecodable: SystemFields, Decodable {
    /// The  schema for ContentType.
    var schema: [String: Any]? { get }
}
/// Content type defines the structure or schema of a page or a section of your web or mobile property.
/// Read more about [Content Types](https://www.contentstack.com/docs/developers/create-content-types).
public class ContentType: CachePolicyAccessible {

    var uid: String?
    internal var stack: Stack
    internal var parameters: Parameters = [:]
    internal var headers: [String: String] = [:]
    public var cachePolicy: CachePolicy = .networkOnly

    internal required init(_ uid: String?, stack: Stack) {
       self.uid = uid
       self.stack = stack
    }

    /// Get instance of `Entry` to fetch `Entry` or fetch specific `Entry`.
    ///
    /// - Parameters:
    ///   - uid: The UId of `Entry` you want to fetch data,
    /// - Returns: `Entry` instance
    ///
    /// Example usage:
    ///```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To perform `Entry` query:
    /// let query = stack.Entry().query()
    /// // To get specific `Entry` instance from uid:
    /// let entry = stack.Entry(uid: entryUid)
    ///```
    public func entry(uid: String? = nil) -> Entry {
        if self.uid == nil {
            fatalError("Please provide ContentType uid")
        }
        return Entry(uid, contentType: self)
    }

    /// To include Global Fields schema in ContentType response.
    /// - Returns: A `ContentType` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType().query().includeGlobalFields()
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }

    public func includeGlobalFields() -> ContentType {
        self.parameters[QueryParameter.includeGloablField] = true
        return self
    }
    /// To fetch all or find  ContentTypes `query` method is used.
    ///
    /// - Returns: A `ContentTypeQuery` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType().query()
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    public func query() -> ContentTypeQuery {
        let query = ContentTypeQuery(stack: self.stack)
        if let uid = self.uid {
           _ = query.where(queryableCodingKey: .uid, .equals(uid))
        }
        return query
    }
    
    /// The Query parameters dictionary that are converted to `URLComponents`.
    /// - Parameters:
    ///   - key: The key for header parameter,
    ///   - value: The value for header  parameter.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///
    /// // To fetch allContentTypes
    /// stack.contentType().addValue("value", forHTTPHeaderField: "header")
    /// .fetch { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().addValue("value", forHTTPHeaderField: "header")
    /// .fetch { (result: Result<ContentTypeModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///          //Model retrive from API
    ///    case .failure(let error):
    ///          //Error Message
    ///    }
    /// }
    /// ```
    public func  addValue(_ value: String, forHTTPHeaderField field: String) -> Self {
        self.headers[field] = value
        return self
    }
}

extension ContentType: ResourceQueryable {
    /// This call fetches the latest version of a specific `ContentType` of a particular stack.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: assetUID)
    /// .fetch { (result: Result<ContentTypeModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///          //Model retrive from API
    ///    case .failure(let error):
    ///          //Error Message
    ///    }
    /// }
    /// ```
    public func fetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void)
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide ContentType uid") }
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

    public func fetch<ResourceType>() async throws -> ContentstackResponse<ResourceType> where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide ContentType uid") }

        do {
            let data: ContentstackResponse<ResourceType> = try await self.stack.asyncFetch(endpoint: ResourceType.endpoint, cachePolicy: self.cachePolicy, parameters: parameters + [QueryParameter.uid: uid], headers: headers)
            return data
        } catch {
            throw error
        }
    }
}
