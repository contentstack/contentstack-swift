//
//  EntryQuaryable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 24/04/20.
//

import Foundation

public protocol EntryQueryable: QueryProtocol {}

extension EntryQueryable {
    @discardableResult
    fileprivate func includeQuery(parameter: String, key: String, fields: [String]) -> Self {
        var baseDict = [key: fields]
        if let dict = self.parameters[parameter] as? [String: [String]] {
            for (keys, value) in dict {
                if keys != key {
                    baseDict[keys] = value
                } else {
                    baseDict[keys] = (value + fields.filter({ (string) -> Bool in
                        return value.contains(string) ? false : true
                    }))
                }
            }
        }
        self.parameters[parameter] = baseDict
        return self
    }
    /// Instance method to fetch Entry for specific locale.
    /// - Parameter locale: The code for fetching entry for locale.
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
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
    /// ```
    @discardableResult
    public func locale(_ locale: String) -> Self {
        self.parameters["locale"] = locale
        return self
    }

    /// Specifies an array of `only` keys in BASE object that would be included in the response.
    /// - Parameter fields: Array of the `only` keys to be included in response.
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .only(["fieldUid"])
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    @discardableResult
    public func only(fields: [String]) -> Self {
        var fieldsToInclude = fields
        fieldsToInclude.append(contentsOf: ["locale", "title"])
        return self.includeQuery(parameter: QueryParameter.only, key: QueryParameter.base, fields: fieldsToInclude)
    }

    /// Specifies an array of `except` keys in BASE object that would be included in the response.
    /// - Parameter fields: Array of the `except` keys to be included in response.
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To fetch Entry from specific contentType
    /// stack.contentType(uid: contentTypeUID).entry().query()
    /// .except(["fieldUid"])
    /// .fetch { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
    ///    switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with EntryModel array in items.
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    @discardableResult
    public func except(fields: [String]) -> Self {
        let fieldsToExclude = fields.filter { (string) -> Bool in
            return string != "locale"  && string != "title"
        }
        return self.includeQuery(parameter: QueryParameter.except, key: QueryParameter.base, fields: fieldsToExclude)
    }
    /// Instance method for including `count`, `Unpublished`,
    /// `ContentType schema`, `Global Fields schema`, and `Reference ContentType Uid`
    /// in result.
    ///
    /// - Parameters:
    ///   - params: The member of your `Query.Include` that you want to include in response
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
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
    /// ```
    
    public func include(params: Query.Include) -> Self {
        if params.contains(Query.Include.count) {
            self.parameters[QueryParameter.includeCount] = true
        }
        if params.contains(Query.Include.contentType) {
            self.parameters[QueryParameter.includeContentType] = true
            self.parameters[QueryParameter.includeGloablField] = false
        }
        if params.contains(Query.Include.globalField) {
            self.parameters[QueryParameter.includeContentType] = true
            self.parameters[QueryParameter.includeGloablField] = true
        }
        if params.contains(Query.Include.refContentTypeUID) {
            self.parameters[QueryParameter.includeRefContentTypeUID] = true
        }
        return self
    }

    /// Instace method to include reference objects with given key in response.
    ///
    /// - Parameter keys: Array of reference keys to include in response.
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
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
    /// ```
    public func includeReference(with keys: [String]) -> Self {
        if let array = self.parameters[QueryParameter.include] as? [String] {
            self.parameters[QueryParameter.include] = (array + keys.filter({ (string) -> Bool in
                return array.contains(string) ? false : true
            }))
        } else {
            self.parameters[QueryParameter.include] = keys
        }
        return self
    }
    /// Specifies an array of `only` keys in reference object that would be included in the response.
    ///
    /// - Parameters:
    ///  -  key: The key who has reference to some other class object.
    ///  - fields: Array of the `only` keys to be included in response.
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
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
    /// ```
    public func includeReferenceField(with key: String, only fields: [String]) -> Self {
        var query = self.includeReference(with: [key])
        if !fields.isEmpty {
            query = query.includeQuery(parameter: QueryParameter.only, key: key, fields: fields)
        }
        return query
    }
    /// Specifies an array of `except` keys in reference object that would be included in the response.
    ///
    /// - Parameters:
    ///  -  key: The key who has reference to some other class object.
    ///  - fields: Array of the `except` keys to be included in response.
    ///
    /// - Returns: A reference to the receiving object to enable chaining.
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
    /// ```
    public func includeReferenceField(with key: String, except fields: [String]) -> Self {
        var query = self.includeReference(with: [key])
        if !fields.isEmpty {
            query = query.includeQuery(parameter: QueryParameter.except, key: key, fields: fields)
        }
        return query
    }
}
