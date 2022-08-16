//
//  SutBuilder.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation
import Contentstack

func makeEntrySut(contentTypeuid: String? = nil, entryUid: String? = nil) -> Entry {
    let stack = Contentstack.stack(apiKey: "api_key",
                              deliveryToken: "delivery_token",
                              environment: "environment")
    return stack.contentType(uid: contentTypeuid).entry(uid: entryUid)
}

func makeContentTypeSut(uid: String? = nil) -> ContentType {
    let stack = Contentstack.stack(apiKey: "api_key",
                              deliveryToken: "delivery_token",
                              environment: "environment")
    return stack.contentType(uid: uid)
}

func makeAssetSut(uid: String? = nil) -> Asset {
    let stack = Contentstack.stack(apiKey: "api_key",
                              deliveryToken: "delivery_token",
                              environment: "environment")
    return stack.asset(uid: uid)
}

func makeStackSut(apiKey: String = "",
                  deliveryToken: String = "",
                  environment: String = "",
                  region: ContentstackRegion = .us,
                  host: String? = nil,
                  apiVersion: String? = nil,
                  branch: String? = nil,
                  config: ContentstackConfig = .default) -> Stack {
    return Contentstack.stack(apiKey: apiKey,
                              deliveryToken: deliveryToken,
                              environment: environment,
                              region: region,
                              host: host ?? Host.delivery,
                              apiVersion: apiVersion ?? "v3",
                              branch: branch,
                              config: config)
}
