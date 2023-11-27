//
//  Asset.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

/// `Asset` refer to all the media files (images, videos, PDFs, audio files, and so on)
/// uploaded in your Contentstack repository for future use.
/// Learn more about [Asset](https://www.contentstack.com/docs/content-managers/work-with-assets).
public class Asset: CachePolicyAccessible {
    public var cachePolicy: CachePolicy = .networkOnly
    internal var parameters: Parameters = [:]
    internal var headers: [String: String] = [:]
    internal var stack: Stack

    /// Unique ID of the asset of which you wish to retrieve the details.
    internal var uid: String?

    internal required init(_ uid: String?, stack: Stack) {
        self.uid = uid
        self.stack = stack
    }

    /// Instance method to fetch `Asset` for specific locale.
    /// - Parameter locale: The code for fetching entry for locale.
    ///
    /// - Returns: A `Asset` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To retrive single asset with specific locale
    /// stack.asset(uid: assetUID).locale("en-us")
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
    
    /// To include the relative URLs of the assets in the response.
    /// - Returns: A `Asset` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To retrive single asset with relative URL
    /// let asset = stack.asset(uid: assetUID).includeRelativeURL()
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///          //Model retrive from API
    ///    case .failure(let error):
    ///          //Error Message
    ///    }
    /// }
    /// ```
    public func includeRelativeURL() -> Asset {
        self.parameters[QueryParameter.relativeUrls] = true
        return self
    }

    /// To include the fallback published content if specified locale content is not publish.
    /// - Returns: A `Asset` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To retrive single asset with relative URL
    /// let asset = stack.asset(uid: assetUID).includeFallback()
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///          //Model retrive from API
    ///    case .failure(let error):
    ///          //Error Message
    ///    }
    /// }
    /// ```
    public func includeFallback() -> Asset {
        self.parameters[QueryParameter.includeFallback] = true
        return self
    }
    
    /// To include the dimensions (height and width) of the image in the response.
    /// - Precondition: Supported image types: `JPG`, `GIF`, `PNG`, `WebP`, `BMP`, `TIFF`, `SVG`, and `PSD`.
    /// - Returns: A `Asset` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To retrive single asset with dimension
    /// stack.asset(uid: assetUID).includeDimension()
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///         //Model retrive from API
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    public func includeDimension() -> Asset {
        self.parameters[QueryParameter.includeDimension] = true
        return self
    }

    
    /// To include the metadata in the response.
    /// - Returns: A `Asset` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // To retrive single asset with dimension
    /// stack.asset(uid: assetUID).includeMetadata()
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///         //Model retrive from API
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    public func includeMetadata() -> Asset {
        self.parameters[QueryParameter.includeMetadata] = true
        return self
    }
    /// To fetch all or find  Assets `query` method is used.
    ///
    /// - Returns: A `AssetQuery` to enable chaining.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.asset().query()
    /// .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
    ///     switch result {
    ///     case .success(let contentstackResponse):
    ///         // Contentstack response with AssetModel array in items.
    ///     case .failure(let error):
    ///         //Error Message
    ///     }
    /// }
    public func query() -> AssetQuery {
        let query = AssetQuery(stack: self.stack)
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
    ///             environment: environment)
    ///
    /// // To fetch Assets
    /// stack.asset().addValue("value", forHTTPHeaderField: "header")
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///         //Model retrive from API
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func addValue(_ value: String, forHTTPHeaderField field: String) -> Self {
        self.headers[field] = value
        return self
    }
}

extension Asset: ResourceQueryable {
    /// This call fetches the latest version of a specific `Asset` of a particular stack.
    /// - Parameters:
    ///   - completion: A handler which will be called on completion of the operation.
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.asset(uid: assetUID)
    /// .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch result {
    ///    case .success(let model):
    ///         //Model retrive from API
    ///    case .failure(let error):
    ///         //Error Message
    ///    }
    /// }
    /// ```
    public func fetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void)
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide Asset uid") }
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
    
    public func asyncFetch<ResourceType>(_ completion: @escaping (Result<ResourceType, Error>, ResponseType) -> Void) async
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide Asset uid") }
        await self.stack.asyncFetch(endpoint: ResourceType.endpoint,
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

    public func fetch<ResourceType>() async throws -> (Result<ResourceType, Error>, ResponseType)
        where ResourceType: EndpointAccessible, ResourceType: Decodable {
        guard let uid = self.uid else { fatalError("Please provide Asset uid") }
        
        do {
            let (data, response) = try await self.stack.asyncFetch(endpoint: ResourceType.endpoint,
                                                                   cachePolicy: self.cachePolicy,
                                                                   parameters: parameters + [QueryParameter.uid: uid],
                                                                   headers: headers) as (ContentstackResponse<ResourceType>, ResponseType)
            if let resource = data.items.first {
                return (.success(resource), response)
            } else {
                throw SDKError.stackError
            }
        } catch {
            throw error
        }
    }
}
