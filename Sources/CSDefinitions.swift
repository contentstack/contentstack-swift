//
//  HTTPMethod.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 02/08/19.
//

import Foundation

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
internal enum HTTPMethod: String {
    /// `DELETE` method.
    case delete  = "DELETE"
    /// `GET` method.
    case get     = "GET"
    /// `POST` method.
    case post    = "POST"
    /// `PUT` method.
    case put     = "PUT"
    /// The httpMethod is string for the current http method.
    public var httpMethod: String {
        return rawValue
    }
}

/// Contentstack Regions.
///
/// - us: This region is for US Cloud
/// - eu: This region is for EU Cloud
public enum ContentstackRegion: String {
    /// This region is for US Cloud
    case us = "us"
    /// This region is for EU Cloud
    case eu = "eu"
    /// This region is for AZURE-NA Cloud
    case azure_na = "azure-na"
}
/// The cache policies allow you to define the source from where the SDK will retrieve the content.
public enum CachePolicy {
    ///The SDK retrieves data through a network call, and saves the retrieved data in the cache.
    ///This is set as the default policy.
    case networkOnly
    ///The SDK gets data from the cache.
    case cacheOnly
    ///The SDK gets data from the cache. However, if it fails to retrieve data from the cache, it makes a network call.
    case cacheElseNetwork
    ///The SDK gets data using a network call. However, if the call fails, it retrieves data from cache.
    case networkElseCache
    ///The SDK gets data from cache, and then makes a network call. (A success callback will be invoked twice.)
    case cacheThenNetwork
}

/// The response type define the source from where the SDK retrieve the content.
public enum ResponseType {
    ///This specifies response is from cache.
    case cache
    ///This specifies response is from network call.
    case network
}
