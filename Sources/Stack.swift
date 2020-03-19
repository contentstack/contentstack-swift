//
//  Stack.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public enum Host {
    /// The path for the Contentstack Delivery API.
    public static let delivery = "cdn.contentstack.io"
}

public typealias ResultsHandler<T> = (_ result: Result<T, Error>, ResponseType) -> Void

public class Stack: CachePolicyAccessible {
    internal var urlSession: URLSession

    private let config: ContentstackConfig

    /// `API Key` is a unique key assigned to each stack.
    public let apiKey: String
    /// `Delivery Token` is a read-only credential that you can create for different environments of your stack.
    public let deliveryToken: String
    /// `Environment` can be defined as one or more content delivery destinations
    public let environment: String
    /// The domain host to perform requests against. Defaults to `Host.delivery` i.e. `"cdn.contentstack.com"`.
    public let host: String
    /// `Region` refers to the location of the data centers where your organization's data resides.
    public let region: ContentstackRegion
    /// Stack api version point
    public let apiVersion: String
    /// `CachePolicy` allows you to cache request
    public var cachePolicy: CachePolicy = .networkOnly
    /// The JSONDecoder that the receiving client instance uses to deserialize JSON. The SDK will
    /// inject information about the locales to this decoder and use this information to normalize
    /// the fields dictionary of entries and assets.
    public private(set) var jsonDecoder: JSONDecoder

    init(apiKey: String,
         deliveryToken: String,
         environment: String,
         region: ContentstackRegion,
         host: String,
         apiVersion: String,
         config: ContentstackConfig) {

        self.apiKey = apiKey
        self.deliveryToken = deliveryToken
        self.environment = environment

        self.host = host
        self.region = region
        self.apiVersion = apiVersion

        self.config = config

        self.jsonDecoder = JSONDecoder.dateDecodingStrategy()
        if let dateDecodingStrategy = config.dateDecodingStrategy {
            jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
        }
        if let timeZone = config.timeZone {
            jsonDecoder.userInfo[.timeZoneContextKey] = timeZone
        }
        let contentstackHTTPHeaders = [
            "api_key": apiKey,
            "access_token": deliveryToken,
            "X-User-Agent": config.sdkVersionString(),
            "User-Agent": config.userAgentString()
        ]
        self.config.sessionConfiguration.httpAdditionalHeaders = contentstackHTTPHeaders
        self.urlSession = URLSession(configuration: config.sessionConfiguration)

        URLCache.shared = CSURLCache.default
    }

    public func contentType(uid: String? = nil) -> ContentType {
        return ContentType(uid, stack: self)
    }

    public func asset(uid: String? = nil) -> Asset {
        return Asset(uid, stack: self)
    }

    private func url(endpointAccessible: EndpointAccessible, parameters: [String: String] = [:]) -> URL {
        var components: URLComponents = URLComponents(string: "https://\(self.host)/\(self.apiVersion)")!
        endpointAccessible.endPoint(components: &components)

        var queryItems: [URLQueryItem] = [URLQueryItem]()

        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        components.queryItems = queryItems

        return components.url!
    }

}
