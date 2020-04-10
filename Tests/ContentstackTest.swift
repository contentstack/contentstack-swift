//
//  ContentstackTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import XCTest
@testable import Contentstack
import DVR
private var _stackSharedInstance: Stack?
#if !API_TEST
class TestContentstackClient {

    static func config() -> [String: Any] {
        #if API_TEST
        if let path = Bundle(for: TestContentstackClient.self).path(forResource: "config", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe),
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: Any] {
                return jsonDictionary
        }
        return [:]
        #else
        return [
            "api_key": "bltc94709340b84bdd2",
            "delivery_token": "csd2e69747f83e59e327d19962",
            "environment": "development"
        ]
        #endif
    }

    static func testStack(cassetteName: String) -> Stack {
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
}
#endif
