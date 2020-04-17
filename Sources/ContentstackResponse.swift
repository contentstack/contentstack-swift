//
//  ContentstackResponse.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 18/03/20.
//

import Foundation

private protocol ResponseParams {
    var count: UInt? { get }
}

private protocol HomogeneousResponse: ResponseParams {

    associatedtype ItemType

    var items: [ItemType] { get }
}

internal enum ResponseCodingKeys: String, CodingKey {
    case entries, entry, assets, asset, skip, limit, errors, count
    case contentTypes = "content_types", contentType = "content_type"
}

public final class ContentstackResponse<ItemType>: HomogeneousResponse, Decodable
where ItemType: EndpointAccessible & Decodable {
    public var items: [ItemType] = []

    public var limit: UInt?

    public var skip: UInt?

    public var count: UInt?

    public var fields: [String: Any]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResponseCodingKeys.self)
        self.limit = try container.decodeIfPresent(UInt.self, forKey: .limit)
        self.skip = try container.decodeIfPresent(UInt.self, forKey: .skip)
        self.count = try container.decodeIfPresent(UInt.self, forKey: .count)

        self.items = []
        switch ItemType.endpoint {
        case .assets:
            if let assets =  try container.decodeIfPresent([ItemType].self, forKey: .assets) {
                self.items = assets
            } else if let asset =  try container.decodeIfPresent(ItemType.self, forKey: .asset) {
                self.items = [asset]
            }
        case .contenttype:
            if let contentTypes =  try container
                .decodeIfPresent([ItemType].self, forKey: .contentTypes) {
                self.items = contentTypes
            } else if let contentType =  try container
                .decodeIfPresent(ItemType.self, forKey: .contentType) {
                self.items = [contentType]
            }
        case  .entries:
            if let entries =  try container.decodeIfPresent([ItemType].self, forKey: .entries) {
                let containerFields   = try decoder.container(keyedBy: JSONCodingKeys.self)
                let response = try containerFields.decode(Dictionary<String, Any>.self)
                if let contentType = response["content_type"] as? ContentTypeModel {
                    fields = ["content_type": contentType]
                }
                self.items = entries
            } else if let entry =  try container.decodeIfPresent(ItemType.self, forKey: .entry) {
                if var contentTypeIncludable = entry as? ContentTypeIncludable {
                    let containerFields   = try decoder.container(keyedBy: JSONCodingKeys.self)
                    let response = try containerFields.decode(Dictionary<String, Any>.self)
                    if let contentType = response["content_type"] as? ContentTypeModel {
                        contentTypeIncludable.contentType = contentType
                    }
                }
                self.items = [entry]
            }
        default:
            print("sync")
        }
    }
}
