//
//  SyncResult.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 06/04/20.
//

import Foundation
/// A container for the synchronized state of a Stack
public final class SyncStack: Decodable {
    internal(set) public var syncToken = ""

    internal(set) public var paginationToken = ""

    internal(set) public var totalCount: Int = 0

    internal(set) public var items: [Any] = []

    internal var isInitialSync: Bool {
        if syncToken.isEmpty && paginationToken.isEmpty {
            return true
        }
        return false
    }

    internal var hasMorePages: Bool {
        if !paginationToken.isEmpty {
            return true
        }
        return false
    }

    internal var parameter: Parameters {
        if !syncToken.isEmpty {
            return ["sync_token": syncToken]
        } else if !paginationToken.isEmpty {
            return ["pagination_token": paginationToken]
        }
        return ["init": true]
    }

    public init(syncToken: String = "", paginationToken: String = "") {
        if !syncToken.isEmpty && !paginationToken.isEmpty {
            fatalError("Both Sync Token and Pagination Token can not be presnet.")
        }
        self.syncToken = syncToken
        self.paginationToken = paginationToken
    }

    private enum CodingKeys: String, CodingKey {
        case syncToken = "sync_token"
        case paginationToke = "pagination_token"
        case totalCount = "total_count"
        case items
    }

    public init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        self.syncToken     = try container.decodeIfPresent(String.self, forKey: .syncToken) ?? ""
        self.paginationToken = try container.decodeIfPresent(String.self, forKey: .paginationToke) ?? ""
        self.totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        if (!syncToken.isEmpty && !paginationToken.isEmpty) || (syncToken.isEmpty && paginationToken.isEmpty) {
            throw SDKError.syncError
        }

        self.items = try container.decode(Array<Any>.self, forKey: .items)
    }

    public enum SyncableTypes {
        /// Sync all `assets` and all `entries` of all content types.
        case all
        /// Enter `content type` UIDs. e.g., `products`.
        /// This retrieves published entries of specified content type.
        case contentType(String)
        /// Enter `locale` codes. e.g., `en-us`
        /// This retrieves published entries of specific locale.
        case locale(String)
        /// Enter the `start date`. e.g., `Date()`
        /// This retrieves published entries starting from a specific date.
        case startFrom(Date)
        /// If you do not specify any value from `PublishType`,
        /// it will bring all published entries and published assets.
        /// You can pass multiple types as comma-separated values,
        case publishType(PublishType)

        internal var parameters: Parameters {
            switch self {
            case .all:
                // Return empty dictionary to specify that all content should be sync'ed.
                return [:]
            case .contentType(let contentType):
                return ["content_type_uid": contentType]
            case .locale(let locale):
                return ["locale": locale]
            case .startFrom(let startFromDate):
                return ["start_from": startFromDate]
            case .publishType(let publishType):
                return ["type": publishType.rawValue]
            }
        }
    }

    public enum PublishType: String {
        case entryPublished = "entry_published"
        case assetPublished = "asset_published"
        case entryUnpublished = "entry_unpublished"
        case assetUnpublished = "asset_unpublished"
        case entryDeleted = "entry_deleted"
        case assetDeleted = "asset_deleted"
        case contentTypeDeleted = "content_type_deleted"
    }
}

extension SyncStack: EndpointAccessible {
    public static var endpoint: Endpoint = .sync
}
