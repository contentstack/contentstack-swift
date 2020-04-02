//
//  Asset.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public protocol AssetProtocol: SystemFields {
    var fileName: String? { get }

    var fileSize: Double? { get }

    var fileType: String? { get }

    var url: String? { get }
}

public protocol AssetDecodable: AssetProtocol, Decodable {}

public class Asset: FieldKeysQueryable {

    internal var stack: Stack

    var uid: String?

    var endPoint: Endpoint = .assets

    public enum FieldKeys: String, CodingKey {
        case title, uid, url, dimension
        case fileName = "filename"
        case fileType = "content_type"
        case fileSize = "file_size"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case updatedAt = "updated_at"
        case updatedBy = "updated_by"
    }

    internal required init(_ uid: String?, stack: Stack) {
        self.uid = uid
        self.stack = stack
    }

    func query() -> AssetQuery {
        let query = AssetQuery(stack: self.stack)
        if let uid = self.uid {
           _ = query.where(queryableCodingKey: .uid, .equals(uid))
        }
        return query
    }
}

extension Asset: EndpointAccessible {
    public static var endPoint: Endpoint {
        return .assets
    }

    public func endPoint(components: inout URLComponents) {
        components.path = "\(components.path)/\(Endpoint.assets.pathComponent)"
        if let uid = uid {
            components.path = "\(components.path)/\(uid)"
        }
    }
}

//extension AssetProtocol {
//    internal 
//}
