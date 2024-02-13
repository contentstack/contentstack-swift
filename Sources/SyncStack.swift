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
    /// This is `seq_id`, a replacement for `syncToken` and `Pagination Token`
    internal(set) public var lastSeqId = ""
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
    
    internal var isInitialSeqSync: Bool {
        if lastSeqId.isEmpty {
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
    
    internal var hasMoreSeq: Bool {
        if !lastSeqId.isEmpty {
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
        /// Test case should check
    }
    
    internal var seqParameter: Parameters {
        if !lastSeqId.isEmpty {
            return ["seq_id": lastSeqId]
        }
        return ["init": true, "seq_id": true]
        /// Test case should check
    }

    /// Initialization
    /// - Parameters:
    ///   - syncToken: The syncToken from the previous syncronization.
    ///   - paginationToken: The paginationToken to fetch next batch of data.
    ///   - lastSeqId: The sequenceId to fetch next batch of data
    public init(syncToken: String = "", paginationToken: String = "", lastSeqId: String = "") {
        if !syncToken.isEmpty && !paginationToken.isEmpty {
            fatalError("Both Sync Token and Pagination Token can not be present.")
        }
        if (!syncToken.isEmpty || !paginationToken.isEmpty) && !lastSeqId.isEmpty {
            fatalError("Pagination Token or Sync Token cannot be present with sequenceId.")
        }
        self.syncToken = syncToken
        self.paginationToken = paginationToken
        self.lastSeqId = self.lastSeqId != lastSeqId ? lastSeqId : "";
    }

    private enum CodingKeys: String, CodingKey {
        case syncToken = "sync_token"
        case paginationToken = "pagination_token"
        case totalCount = "total_count"
        case lastSeqId = "last_seq_id"
        case items
    }

    public init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        self.syncToken     = try container.decodeIfPresent(String.self, forKey: .syncToken) ?? ""
        self.paginationToken = try container.decodeIfPresent(String.self, forKey: .paginationToken) ?? ""
        let lastSeqId = try container.decodeIfPresent(String.self, forKey: .lastSeqId) ?? ""
        self.lastSeqId = self.lastSeqId != lastSeqId ? lastSeqId : ""
        self.totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        if (!syncToken.isEmpty && !paginationToken.isEmpty) {
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
