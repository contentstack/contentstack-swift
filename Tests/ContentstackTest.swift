//
//  ContentstackTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import XCTest
@testable import Contentstack

private var _stackSharedInstance: Stack?
class TestContentstackClient {

    static func config() -> [String: Any] {
        if let path = Bundle(for: TestContentstackClient.self).path(forResource: "config", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe),
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: Any] {
                return jsonDictionary
        }
        return [:]
    }

    static var stack: Stack {
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
        return _stackSharedInstance!
    }
}

class ContentstackTest: XCTestCase {


}
