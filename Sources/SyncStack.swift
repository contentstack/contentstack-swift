//
//  SyncResult.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 06/04/20.
//

import Foundation
/// A container for the synchronized state of a Stack
public final class SyncStack: Decodable {
    /// You can use the `sync_token` later to perform subsequent sync,
    /// which fetches only new changes through delta updates.
    internal(set) public var syncToken = ""
    /// If there are more than 100 records, you get a `pagination_token` in response.
    /// This token can be used to fetch the next batch of data.
    internal(set) public var paginationToken = ""
    /// The total number of resources which matched the original request.
    internal(set) public var totalCount: Int = 0
    /// The resources which are part of the array response.
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

    /// Initialization
    /// - Parameters:
    ///   - syncToken: The syncToken from the previous syncronization.
    ///   - paginationToken: The paginationToken to fetch next batch of data.
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

    /// This enable to sync entity with condition.
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

    /// This enable to sync entity with Published type.
    public enum PublishType: String {
        /// To sync only Published Entries.
        case entryPublished = "entry_published"
        /// To sync only Published Assets.
        case assetPublished = "asset_published"
        /// To sync only Unpublished Entries.
        case entryUnpublished = "entry_unpublished"
        /// To sync only Unpublished Assets.
        case assetUnpublished = "asset_unpublished"
        /// To sync only Deleted Entries.
        case entryDeleted = "entry_deleted"
        /// To sync only Deleted Assets.
        case assetDeleted = "asset_deleted"
        /// To sync only only deleted content type Entries.
        case contentTypeDeleted = "content_type_deleted"
    }
}

extension SyncStack: EndpointAccessible {
    public static var endpoint: Endpoint = .sync
}
