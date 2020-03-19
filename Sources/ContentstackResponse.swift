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
    case entries, assets, skip, limit, errors
    case contentTypes = "content_types"
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

        switch ItemType.endPoint {
        case .assets:
            self.items = try container.decodeIfPresent([ItemType].self, forKey: ResponseCodingKeys.assets) ??  []
        case .contenttype:
            self.items = try container.decodeIfPresent([ItemType].self, forKey: ResponseCodingKeys.contentTypes) ??  []
        case  .entries:
            self.items = try container.decodeIfPresent([ItemType].self, forKey: ResponseCodingKeys.entries) ??  []
        default:
            print("sync")
        }
    }
}
