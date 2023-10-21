//
//  AsyncTestContentstackClient.swift
//  Contentstack
//
//  Created by Jigar Kanani on 09/10/23.
//

import XCTest
@testable import Contentstack
import DVR
private var _stackSharedInstance: Stack?

class AsyncTestContentstackClient {

    static func config() -> [String: Any] {
        #if API_TEST
        if let path = Bundle(for: AsyncTestContentstackClient.self).path(forResource: "config", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe),
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: Any] {
                return jsonDictionary
        }
        return [:]
        #else
        return [
            "api_key": "api_key",
            "delivery_token": "delivery_token",
            "environment": "environment"
        ]
        #endif
    }

    static func asyncTestStack(cassetteName: String) -> Stack {
        if _stackSharedInstance == nil {
            let stackConfig = config()
            if let apiKey = stackConfig["api_key"] as? String,
                let deliveryToken = stackConfig["delivery_token"] as? String,
                let environment = stackConfig["environment"]  as? String {
                _stackSharedInstance = Contentstack.stack(apiKey: apiKey,
                                                          deliveryToken: deliveryToken,
                                                          environment: environment,
                                                          host: stackConfig["host"] as? String ??  Host.delivery)
            }
        }
        #if !API_TEST
        let dvrSession = DVR.Session(cassetteName: cassetteName, backingSession: _stackSharedInstance!.urlSession)
        _stackSharedInstance?.urlSession = dvrSession
        #endif
        return _stackSharedInstance!
    }

    static func asyncTestCacheStack() -> Stack {
        let stackConfig = config()
        if let apiKey = stackConfig["api_key"] as? String,
            let deliveryToken = stackConfig["delivery_token"] as? String,
            let environment = stackConfig["environment"]  as? String {
            _stackSharedInstance = Contentstack.stack(apiKey: apiKey,
                                                      deliveryToken: deliveryToken,
                                                      environment: environment,
                                                      host: stackConfig["host"] as? String ??  Host.delivery)
        }
        return _stackSharedInstance!
    }
}
