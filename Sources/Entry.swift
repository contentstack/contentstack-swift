//
//  Entry.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public class Entry: EntryQueryable, CachePolicyAccessible {
    public typealias ResourceType = EntryModel

    var uid: String?

    public var cachePolicy: CachePolicy = .networkOnly

    internal var contentType: ContentType
    /// Stack instance for Entry to be fetched
    public var stack: Stack
    /// URI Parameters
    public var parameters: [String: Any] = [:]
    /// Query Parameters
    public var queryParameter: [String: Any] = [:]

    internal required init(_ uid: String?, contentType: ContentType) {
        self.uid = uid
        self.contentType = contentType
        self.stack = contentType.stack
        self.parameters[QueryParameter.contentType] = contentType.uid
        self.parameters[QueryParameter.uid] = uid
    }

    /// To fetch all or find  Entries `query` method is used.
    ///
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query()
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
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

    /// To fetch all or find  Entries  to specific model `query` method is used.
    ///
    /// - Returns: A `QueryOn<EntryType>` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query(Product.self)
    /// .find { (result: Result<ContentstackResponse<Product>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with Product array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
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
    /// This call fetches the latest version of a specific `Entry` of a particular stack.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUID).entry(uid: UID)
    /// .fetch { (restult: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch restult {
    ///    case .success(let model):
    ///         //Model retrive from API
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
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
