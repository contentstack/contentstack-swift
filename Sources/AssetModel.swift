//
//  AssetModel.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 08/04/20.
//

import Foundation

public final class AssetModel: AssetDecodable {
    public var title: String

    public var uid: String

    public var createdAt: Date

    public var updatedAt: Date

    public var createdBy: String

    public var updatedBy: String

    public var fileName: String

    public var fileSize: Double

    public var fileType: String

    public var url: String

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
    public var dimension: ImageDimension?

    /// A lightweight struct to hold the dimensions information for the this file, if it is an image type.
    public struct ImageDimension: Decodable {
        /// The width of the image.
        public let width: Double
        /// The height of the image.
        public let height: Double

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            width         = try container.decode(Double.self, forKey: .width)
            height        = try container.decode(Double.self, forKey: .height)
        }

        private enum CodingKeys: String, CodingKey {
            case width, height
        }
    }

    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: FieldKeys.self)
        title = try container.decode(String.self, forKey: .title)
        uid = try container.decode(String.self, forKey: .uid)
        url = try container.decode(String.self, forKey: .uid)
        fileName = try container.decode(String.self, forKey: .fileName)
        fileType = try container.decode(String.self, forKey: .fileType)
        dimension     = try container.decodeIfPresent(ImageDimension.self, forKey: .dimension)
        let filesize = try container.decode(String.self, forKey: .fileSize)
        fileSize = Double(filesize) ?? 0

        createdAt = try container.decode(Date.self, forKey: .createdAt)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        updatedBy = try container.decode(String.self, forKey: .updatedBy)
    }

    public enum QueryableCodingKey: String, CodingKey {
        case uid, title
        case fileName = "filename"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

}

extension AssetModel: EndpointAccessible {
    public static var endpoint: Endpoint {
        return .assets
    }
}
