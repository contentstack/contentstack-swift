//
//  Query.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation
/// To fetch all or find  Entries  use `Query`.
public class Query: BaseQuery, EntryQueryable {
    public var headers: [String: String] = [:]
    
    public typealias ResourceType = EntryModel

    internal var contentTypeUid: String
    /// Stack instance for Entry to be fetched
    public var stack: Stack
    /// URI Parameters
    public var parameters: [String: Any] = [:]
    /// Query Parameters
    public var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy
    

    internal required init(contentType: ContentType) {
        self.stack = contentType.stack
        self.contentTypeUid = contentType.uid!
        self.cachePolicy = contentType.cachePolicy
        self.parameters[QueryParameter.contentType] = contentTypeUid
    }

    /// Use this method to do a search on `Entries` which enables
    /// searching for entries based on value's for field key Path.
    ///
    /// - Parameters:
    ///   - path: The field key path that  you are performing your select operation against.
    ///   - operation: The query operation used in the query.
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
    /// .where(valueAtKey: .title, .equals("Entry Title"))
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func `where`(valueAtKey path: String, _ operation: Query.Operation) -> Query {
        return self.where(valueAtKeyPath: path, operation)
    }

    /// Use this method to do a search on `Entries` which enables
    /// searching for entries based on value's queryable coding from `EntryModel.FieldKeys`.
    ///
    /// - Parameters:
    ///   - queryableCodingKey: The member of your `EntryModel.FieldKeys`
    ///   that  you are performing your select operation against.
    ///   - operation: The query operation used in the query.
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
    /// .where(queryableCodingKey: .title, .equals("Entry Title"))
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func `where`(queryableCodingKey: EntryModel.FieldKeys, _ operation: Query.Operation) -> Query {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    /// Use this method to do a search on `Entries` which enables
    /// searching for entries based on value's for members of referenced entries.
    ///
    /// - Parameters:
    ///   - keyPath: The reference field key path that  you
    ///   are performing your select operation against.
    ///   - operation: The query operation used in the query.
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
    /// .where(referenceAtKeyPath: .title, .equals("Entry Title"))
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func `where`(referenceAtKeyPath keyPath: String, _ operation: Query.Reference) -> Query {
        if let query = operation.query {
            self.queryParameter[keyPath] = query
        }
        return self
    }

    /// When fetching entries, you can sort them in the ascending order
    /// with respect to the value of a specific field in the response body.
    /// - Parameter propertyName: The member of your `EntryModel.FieldKeys` that you are performing order by ascending.
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query()
    /// .orderByAscending(propertyName: .title)
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    @discardableResult
    public func orderByAscending(propertyName: EntryModel.FieldKeys) -> Query {
        return self.orderByAscending(keyPath: propertyName.stringValue)
    }

    /// When fetching entries, you can sort them in the decending order
    /// with respect to the value of a specific field in the response body.
    /// - Parameter propertyName: The member of your `EntryModel.FieldKeys` that you are performing order by decending.
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query()
    /// .orderByDecending(propertyName: .title)
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    @discardableResult
    public func orderByDecending(propertyName: EntryModel.FieldKeys) -> Query {
        return self.orderByDecending(keyPath: propertyName.stringValue)
    }

    /// Use this method to do a search on `Entries`.
    /// - Parameter text: The text string to match against.
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query()
    /// .search(for: "searchString")
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    @discardableResult
    public func search(for text: String) -> Query {
        self.parameters[QueryParameter.typeahead] = text
        return self
    }

    /// Use this method to do a search on tags for `Entries`.
    /// - Parameter text: The text string to match against.
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query()
    /// .tags(for: "tagSearchString")
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    @discardableResult
    public func tags(for text: String) -> Query {
        self.parameters[QueryParameter.tags] = text
        return self
    }

    /// Use this method to do a search on `Entries` which enables
    /// searching for entries based on `Query.Operator`.
    /// - Parameter operator: The member of `Query.Operator` that you are performing
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query()
    /// .tags(for: "tagSearchString")
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func `operator`(_ operator: Query.Operator) -> Query {
        self.queryParameter[`operator`.string] = `operator`.value
        return self
    }
}

/// To fetch all or find  Entries and Quering for Specific Model  use `QueryOn`.
public final class QueryOn<EntryType>: Query where EntryType: EntryDecodable {
    internal typealias ResourceType = EntryType
    /// Use this method to do a search on `Entries` which enables
    /// searching for entries based on value's queryable coding from`EntryType.FieldKeys`.
    ///
    /// - Parameters:
    ///   - queryableCodingKey: The member of your `EntryType.FieldKeys`
    ///   that  you are performing your select operation against.
    ///   - operation: The query operation used in the query.
    ///
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query(Product.Self)
    /// .where(queryableCodingKey: .title, .equals("Entry Title"))
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func `where`(queryableCodingKey: EntryType.FieldKeys, _ operation: Query.Operation) -> QueryOn<EntryType> {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    /// When fetching entries, you can sort them in the ascending order
    /// with respect to the value of a specific field in the response body.
    /// - Parameter propertyName: The member of your `EntryType.FieldKeys` that you are performing order by ascending.
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query(Product.Self)
    /// .orderByAscending(propertyName: .title)
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    @discardableResult
    public func orderByAscending(propertyName: EntryType.FieldKeys) -> QueryOn<EntryType> {
        return self.orderByAscending(keyPath: propertyName.stringValue)
    }

    /// When fetching entries, you can sort them in the decending order
    /// with respect to the value of a specific field in the response body.
    /// - Parameter propertyName: The member of your `EntryType.FieldKeys` that you are performing order by decending.
    /// - Returns: A `Query` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.contentType(uid: contentTypeUid).entry().query(Product.Self)
    /// .orderByDecending(propertyName: .title)
    /// .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    @discardableResult
    public func orderByDecending(propertyName: EntryType.FieldKeys) -> QueryOn<EntryType> {
        return self.orderByDecending(keyPath: propertyName.stringValue)
    }
}
/// To fetch all or find  `ContentType`  use `ContentTypeQuery`.
public final class ContentTypeQuery: BaseQuery {
    public var headers: [String: String] = [:]
    
    public typealias ResourceType = ContentTypeModel

    /// Stack instance for Entry to be fetched
    public var stack: Stack
    /// URI Parameters
    public var parameters: [String: Any] = [:]
    /// Query Parameters
    public var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack) {
        self.stack = stack
        self.cachePolicy = stack.cachePolicy
    }

    /// Use this method to do a search on `ContentType` which enables
    /// searching for entries based on value's for members of referenced entries.
    ///
    /// - Parameters:
    ///   - queryableCodingKey: The member of your `QueryableCodingKey`
    ///   that  you are performing your select operation against.
    ///   - operation: The query operation used in the query.
    /// - Returns: A `ContentTypeQuery` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.asset().query().where(queryableCodingKey: .title, .equals("ContentType Title"))
    /// .find { (result: Result<ContentstackResponse<ContentType>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentType array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```

    public func `where`(queryableCodingKey: ContentTypeModel.QueryableCodingKey, _
        operation: Query.Operation) -> ContentTypeQuery {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    /// Include URI paramertes to fetch ContentType with Global Fields and Count.
    /// - Parameters:
    ///   - params: The member of your `ContentTypeQuery.Include` that you want to include in response
    /// - Returns: A AssetQuery to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.asset().query().include(params: [.all])
    /// .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with ContentTypeModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func include(params: Include) -> Self {
        if params.contains(.count) {
            self.parameters[QueryParameter.includeCount] = true
        }
        if params.contains(.globalFields) {
            self.parameters[QueryParameter.includeGloablField] = true
        }
        return self
    }
}

/// To fetch all or find  `Assets` use `AssetQuery`.
public final class AssetQuery: BaseQuery {
    public var headers: [String : String] = [:]
    
    public typealias ResourceType = AssetModel

    /// Stack instance for Entry to be fetched
    public var stack: Stack
    /// URI Parameters
    public var parameters: [String: Any] = [:]
    /// Query Parameters
    public var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack) {
        self.stack = stack
        self.cachePolicy = stack.cachePolicy
    }

    /// Instance method to fetch `Assets` for specific locale.
    /// - Parameter locale: The code for fetching entry for locale.
    ///
    /// - Returns: A `AssetQuery` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To retrive single asset with specific locale
    /// stack.asset().query().locale("en-us")
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///          //Model retrive from API
    ///    case .failure(let error):
    ///          //Error Message
    ///    }
    /// }
    /// ```
    public func locale(_ locale: String) -> Self {
        self.parameters["locale"] = locale
        return self
    }

    /// Use this method to do a search on `Assets` which enables
    /// searching for entries based on value's for members of referenced entries.
    ///
    /// - Parameters:
    ///   - queryableCodingKey: The member of your `QueryableCodingKey`
    ///   that  you are performing your select operation against.
    ///   - operation: The query operation used in the query.
    ///
    /// - Returns: A AssetQuery to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.asset().query().where(queryableCodingKey: .title, .equals("Asset Title"))
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func `where`(queryableCodingKey: AssetModel.QueryableCodingKey, _ operation: Query.Operation) -> AssetQuery {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    /// Include URI paramertes to fetch Asset with relative url and dimansion
    /// - Parameters:
    ///   - params: The member of your `AssetQuery.Include` that you want to include in response
    /// - Returns: A AssetQuery to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.asset().query().include(params: [.all])
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    /// ```
    public func include(params: Include) -> AssetQuery {
        if params.contains(.count) {
            self.parameters[QueryParameter.includeCount] = true
        }
        if params.contains(.relativeURL) {
            self.parameters[QueryParameter.relativeUrls] = true
        }
        if params.contains(.dimension) {
            self.parameters[QueryParameter.includeDimension] = true
        }
        if params.contains(.fallback) {
            self.parameters[QueryParameter.includeFallback] = true
        }
        if params.contains(.metadata) {
            self.parameters[QueryParameter.includeMetadata] = true
        }
        return self
    }
}
