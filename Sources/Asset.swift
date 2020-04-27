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
    internal var stack: Stack

    /// Unique ID of the asset of which you wish to retrieve the details.
    internal var uid: String?

    internal required init(_ uid: String?, stack: Stack) {
        self.uid = uid
        self.stack = stack
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
    /// .fetch { (restult: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch restult {
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
    /// .fetch { (restult: Result<AssetModel, Error>, response: ResponseType) in
    ///    switch restult {
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
