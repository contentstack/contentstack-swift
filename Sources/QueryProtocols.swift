//
//  ResourchQueryable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 19/03/20.
//

import Foundation
/// A base Query protocol which holds the essentials shared by all query types in the SDK which enable
/// querying against content types, entries and assets.
public protocol QueryProtocol: class, CachePolicyAccessible {
    associatedtype ResourceType
    /// The Stack instance to perform operation,
    var stack: Stack { get set }
    /// The parameters dictionary that are converted to `URLComponents`.
    var parameters: [String: Any] { get set }
    /// The Query parameters dictionary that are converted to `URLComponents`.
    var queryParameter: [String: Any] { get set }
    /// The cachePolicy that is use for fetching entity.
    var cachePolicy: CachePolicy { get set }
    
    var headers: [String: String] { get set }
}

extension BaseQuery {
    /// This is a generic find method which can be used to fetch collections of `ContentType`,
    /// `Entry`, and `Asset` instances.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query()
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query()
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible {
            if self.queryParameter.count > 0,
                let query = self.queryParameter.jsonString {
                self.parameters[QueryParameter.query] = query
            }
            self.stack.fetch(endpoint: ResourceType.endpoint,
                    cachePolicy: self.cachePolicy, parameters: parameters, headers: headers, then: completion)
    }
    
    public func asyncFind<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>) async
        where ResourceType: Decodable & EndpointAccessible {
            if self.queryParameter.count > 0,
                let query = self.queryParameter.jsonString {
                self.parameters[QueryParameter.query] = query
            }
            await self.stack.asyncFetch(endpoint: ResourceType.endpoint,
                    cachePolicy: self.cachePolicy, parameters: parameters, headers: headers, then: completion)
    }

    public func find<ResourceType>() async throws -> (Result<ContentstackResponse<ResourceType>, Error>, ResponseType)
        where ResourceType: Decodable & EndpointAccessible {
            if self.queryParameter.count > 0,
               let query = self.queryParameter.jsonString {
                self.parameters[QueryParameter.query] = query
            }
            do {
                let (data, response): (Result<ContentstackResponse<ResourceType>, Error>, ResponseType) = try await self.stack.asyncFetch(endpoint: ResourceType.endpoint,
                                                                                            cachePolicy: self.cachePolicy,
                                                                                                    parameters: parameters,
                                                                                                    headers: headers)
                switch data {
                case .success(let contentstackResponse):
                    return (.success(contentstackResponse), response)
                case .failure(let error):
                    return (.failure(error), response)
                }
            } catch {
                throw error
            }
    }
}
/// A concrete implementation of BaseQuery which serves as the base class for `Query`,
/// `ContentTypeQuery` and `AssetQuery`.
public protocol BaseQuery: QueryProtocol, Queryable {}
extension BaseQuery {
    /// Method to adding Query.Operation to a Query/
    /// - Parameters:
    ///   - keyPath:
    ///   - operation: The query operation used in the query.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .where(valueAtKeyPath: "fieldUid", .equals("Field condition"))
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query()
    /// .where(valueAtKeyPath: "fieldUid", .equals("Field condition"))
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query()
    /// .where(valueAtKeyPath: "fieldUid", .equals("Field condition"))
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func `where`(valueAtKeyPath keyPath: String, _ operation: Query.Operation) -> Self {
        self.queryParameter[keyPath] = operation.query
        return self
    }

    /// Instance method to mutuating query to skip the first `n` records.
    ///
    /// - Parameter numberOfResults: The number of results that will be skipped in the query.
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .skip(to: 20)
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().skip(to: 20)
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().skip(to: 20)
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    @discardableResult
    public func skip(theFirst numberOfResults: UInt) -> Self {
        self.parameters[QueryParameter.skip] = String(numberOfResults)
        return self
    }
    /// Instance method to mutuating query to limit response to contain `n` values.
    /// - Parameter numberOfResults: The number of results the response will be limited to.
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .limit(to: 20)
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().limit(to: 20)
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().limit(to: 20)
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```

    @discardableResult
    public func limit(to numberOfResults: UInt) -> Self {
        let limit = min(numberOfResults, QueryConstants.maxLimit)
        self.parameters[QueryParameter.limit] = String(limit)
        return self
    }
    /// Instance method to ordering the response in ascending for specific field.
    /// - Parameter keyPath: The key path for the property you are performing ordering.
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .orderByAscending(keyPath: "fieldUID")
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().orderByAscending(keyPath: "fieldUID")
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().orderByAscending(keyPath: "fieldUID")
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    @discardableResult
    public func orderByAscending(keyPath: String) -> Self {
        self.parameters[QueryParameter.asc] = keyPath
        return self
    }
    /// Instance method to ordering the response in descending for specific field.
    /// - Parameter keyPath: The key path for the property you are performing ordering.
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .orderByDecending(keyPath: "fieldUID")
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().orderByDecending(keyPath: "fieldUID")
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().orderByDecending(keyPath: "fieldUID")
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    @discardableResult
    public func orderByDecending(keyPath: String) -> Self {
        self.parameters[QueryParameter.desc] = keyPath
        return self
    }
    /// The parameters dictionary that are converted to `URLComponents`.
    /// - Parameter dictionary: The dictionary for URLComponents.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .addURIParam(dictionary: ["key": "value"])
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().addURIParam(dictionary: ["key": "value"])
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().addURIParam(dictionary: ["key": "value"])
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func addURIParam(dictionary: [String: String]) -> Self {
        for (key, value) in dictionary {
            _ = addURIParam(with: key, value: value)
        }
        return self
    }
    /// The parameters dictionary that are converted to `URLComponents`.
    /// - Parameters:
    ///   - key: The key for query parameter,
    ///   - value: The value for query parameter.
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .addURIParam(with: "key", value: "value")
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().addURIParam(with: "key", value: "value")
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().addURIParam(with: "key", value: "value")
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func addURIParam(with key: String, value: String) -> Self {
        self.parameters[key] = value
        return self
    }
    /// The Query parameters dictionary that are converted to `URLComponents`.
    /// - Parameter dictionary: The dictionary for URLComponents
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .addQuery(dictionary: ["key": "value"])
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().addQuery(dictionary: ["key": "value"])
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().addQuery(dictionary: ["key": "value"])
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```

    public func addQuery(dictionary: [String: Any]) -> Self {
        for (key, value) in dictionary {
            _ = addQuery(with: key, value: value)
        }
        return self
    }
    /// The Query parameters dictionary that are converted to `URLComponents`.
    /// - Parameters:
    ///   - key: The key for query parameter,
    ///   - value: The value for query parameter.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .addQuery(with: "key", value: "value")
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().addQuery(with: "key", value: "value")
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().addQuery(with: "key", value: "value")
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```

    public func addQuery(with key: String, value: Any) -> Self {
        self.queryParameter[key] = value
        return self
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
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .addValue("value", forHTTPHeaderField: "header")
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch allContentTypes
    /// stack.contentType().query().addValue("value", forHTTPHeaderField: "header")
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// // To fetch Assets
    /// stack.asset().query().addValue("value", forHTTPHeaderField: "header")
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func  addValue(_ value: String, forHTTPHeaderField field: String) -> Self {
        self.headers[field] = value
        return self
    }
}
/// The base Queryable protocol to fetch instance for `ContentType`, `Asset`, and `Entry`.
public protocol ResourceQueryable {
    /// This call fetches the latest version of a specific `ContentType`, `Asset`, and `Entry` of a particular stack.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    func fetch<ResourceType>(_ completion: @escaping ResultsHandler<ResourceType>)
        where ResourceType: Decodable & EndpointAccessible
}

/// The base Queryable protocol to find collections for content types, assets, and entries.
public protocol Queryable {
    /// This is a generic find method which can be used to fetch collections of `ContentType`,
    /// `Entry`, and `Asset` instances.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible
}
