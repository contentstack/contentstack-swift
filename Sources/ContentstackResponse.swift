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
    case entries, entry, assets, asset, skip, limit, errors, count, globalFields, globalField
    case contentTypes = "content_types", contentType = "content_type"
}

/// This is the result of any request of collection from Contentstack.
public final class ContentstackResponse<ItemType>: HomogeneousResponse, Decodable
where ItemType: EndpointAccessible & Decodable {
    /// The resources which are part of the array response.
    public var items: [ItemType] = []

    /// The maximum number of resources originally requested.
    public var limit: UInt?

    /// The number of elements skipped when performing the request.
    public var skip: UInt?

    /// The total number of resources which matched the original request.
    public var count: UInt?

    /// The dictionary of fields from the response that are included in API request.
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
        case .taxnomies:
            if let taxonomies = try container.decodeIfPresent([ItemType].self, forKey: .entries) {
                let containerFields = try decoder.container(keyedBy: JSONCodingKeys.self)
                let response = try containerFields.decode(Dictionary<String, Any>.self)
                if let contentType = response["content_type"] as? ContentTypeModel {
                    fields = ["content_type": contentType]
                }
                self.items = taxonomies
            }
        case .globalfields:
            // Decode entire response as [String: AnyDecodable] using singleValueContainer
            let fullResponseContainer = try decoder.singleValueContainer()
            let fullResponse = try fullResponseContainer.decode([String: AnyDecodable].self)

            if let globalFieldsArray = fullResponse["global_fields"]?.value as? [[String: Any]] {
                for item in globalFieldsArray {
                    let data = try JSONSerialization.data(withJSONObject: item, options: [])
                    let model = try JSONDecoder().decode(ItemType.self, from: data)
                    self.items.append(model)
                }
            } else if let globalField = fullResponse["global_field"]?.value as? [String: Any] {
                let data = try JSONSerialization.data(withJSONObject: globalField, options: [])
                let model = try JSONDecoder().decode(ItemType.self, from: data)
                self.items = [model]
            }

        default:
            ContentstackLogger.log(.error, message: ContentstackMessages.unsupportedEndpointType)
        }
    }
}
