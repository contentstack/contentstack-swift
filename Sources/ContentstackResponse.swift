//
//  ContentstackResponse.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 18/03/20.
//

import Foundation

private protocol ResponseParams {
    var totalCount: UInt? { get }
}

private protocol HomogeneousResponse: ResponseParams {

    associatedtype ItemType

    var items: [ItemType] { get }
}

internal enum ResponseCodingKeys: String, CodingKey {
    case entries, entry, assets, asset, skip, limit, errors
    case contentTypes = "content_types", contentType = "content_type"
    case totalCount = "total_count"
}

public final class ContentstackResponse<ItemType>: HomogeneousResponse, Decodable
where ItemType: EndpointAccessible & Decodable {
    public var items: [ItemType] = []

    public var limit: UInt?

    public var skip: UInt?

    public var totalCount: UInt?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResponseCodingKeys.self)
        self.limit = try container.decodeIfPresent(UInt.self, forKey: ResponseCodingKeys.limit)
        self.totalCount = try container.decodeIfPresent(UInt.self, forKey: ResponseCodingKeys.totalCount)
        self.skip = try container.decodeIfPresent(UInt.self, forKey: ResponseCodingKeys.skip)

        self.items = []
        switch ItemType.endpoint {
        case .assets:
            if let assets =  try container.decodeIfPresent([ItemType].self, forKey: ResponseCodingKeys.assets) {
                self.items = assets
            } else if let asset =  try container.decodeIfPresent(ItemType.self, forKey: ResponseCodingKeys.asset) {
                self.items = [asset]
            }
        case .contenttype:
            if let contentTypes =  try container
                .decodeIfPresent([ItemType].self, forKey: ResponseCodingKeys.contentTypes) {
                self.items = contentTypes
            } else if let contentType =  try container
                .decodeIfPresent(ItemType.self, forKey: ResponseCodingKeys.contentType) {
                self.items = [contentType]
            }
        case  .entries:
            if let entries =  try container.decodeIfPresent([ItemType].self, forKey: ResponseCodingKeys.entries) {
                self.items = entries
            } else if let entry =  try container.decodeIfPresent(ItemType.self, forKey: ResponseCodingKeys.entry) {
                self.items = [entry]
            }
        default:
            print("sync")
        }
    }
}
