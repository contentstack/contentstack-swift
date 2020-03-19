//
//  SystemFields.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public protocol SystemFields: class {

    var title: String? { get }

    var uid: String { get }

    var createdAt: Date? { get }

    var updatedAt: Date? { get }

    var createdBy: String? {get}

    var updatedBy: String? {get}
}

public protocol AssetFields: SystemFields {
    var fileName: String? { get }

    var fileSize: Double? { get }

    var fileType: String? { get }

    var url: String? { get }
}

// Classes conforming to this protocol are accessible via an `Endpoint`.
public protocol CachePolicyAccessible {
    /// The endpoint that `EndpointAccessible` types are accessible from.
    var cachePolicy: CachePolicy { get }
}

/// A protocol enabling strongly typed queries to the Contentstack Delivery API via the SDK.
public protocol FieldKeysQueryable {
    /// The `CodingKey` representing the field identifiers/JSON keys for the corresponding content type.
    /// These coding keys should be the same as those used when implementing `Decodable`.
    associatedtype FieldKeys: CodingKey
}

// Classes conforming to this protocol are accessible via an `Endpoint`.
public protocol EndpointAccessible {
    static var endPoint: Endpoint { get }
    /// The endpoint component that `EndpointAccessible` types are accessible from.
    func endPoint(components: inout URLComponents)
}
