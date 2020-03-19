//
//  CSURLCache.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 02/08/19.
//

import Foundation

internal class CSURLCache: URLCache {

    internal static let `default`: CSURLCache = CSURLCache(memoryCapacity: 1024 * 1024,
                                                           diskCapacity: (1024 * 1024 * 5),
                                                           diskPath: "csio_cache")

    override internal func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        var changeRequest = request
        if let url = request.url,
            let method = request.allHTTPHeaderFields?["_method"],
            method == "GET" {
            changeRequest = URLRequest(url: url,
                                       cachePolicy: request.cachePolicy,
                                       timeoutInterval: request.timeoutInterval)
            changeRequest.allHTTPHeaderFields  = request.allHTTPHeaderFields
            changeRequest.httpMethod = "GET"
            changeRequest.httpBody = request.httpBody
        }

        return super.cachedResponse(for: changeRequest)
    }

    override internal func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        var changeRequest = request
        if let url = request.url,
            let method = request.allHTTPHeaderFields?["_method"],
            method == "GET" {
            changeRequest = URLRequest(url: url,
                                       cachePolicy: request.cachePolicy,
                                       timeoutInterval: request.timeoutInterval)
            changeRequest.allHTTPHeaderFields  = request.allHTTPHeaderFields
            changeRequest.httpMethod = "GET"
            changeRequest.httpBody = request.httpBody
        }

        let response = CachedURLResponse(response: cachedResponse.response,
                                         data: cachedResponse.data,
                                         userInfo: cachedResponse.userInfo,
                                         storagePolicy: cachedResponse.storagePolicy)

        super.storeCachedResponse(response, for: request)
    }
}
