//
//  QueryParameter.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

internal enum QueryConstants {
    internal static let maxLimit: UInt               = 1000
}

internal enum QueryParameter {

    /// `limit` parameter will return a specific number of items.
    public static let limit            = "limit"
    /// `skip` parameter will skip a specific number of items.
    public static let skip             = "skip"
    /// `locale` in the query to get entry/entries of a particular locale
    public static let locale           = "locale"
    /// `asc`can sort them in the ascending order
    public static let asc              = "asc"
    /// `desc` can sort them in the descending orde
    public static let desc             = "desc"
    /// `query` to search accross all text and symbol fields in your space
    public static let query            = "query"

    public static let typeahead        = "typeahead"

    public static let tags             = "tags"

    /// `only` parameter will include the data of only the specified fields for each entry
    public static let only             = "only"
    /// `BASE` is the default value and refers to the top-level fields of the schema
    public static let base             = "BASE"

    /// `except` parameter will exclude the data of the specified fields
    public static let except           = "except"

    /// `include` parameter wish to fetch the content
    /// of the entry that is included in the reference field
    public static let include          = "include"

    /// `count` retrieves entries details and total count
    public static let count     = "count"

    /// `include_count` retrieves entries details and their count
    public static let includeCount     = "include_count"

    public static let relativeUrls = "relative_urls"

    public static let includeDimension = "include_dimension"
    /// `include_global_field_schema` 
    public static let includeGloablField    = "include_global_field_schema"

    public static let includeUnpublished        = "include_unpublished"

    public static let includeContentType        = "include_content_type"

    public static let includeRefContentTypeUID  = "include_reference_content_type_uid"
}

extension Query {
    public struct Include: OptionSet {
        public init(rawValue: Include.RawValue) { self.rawValue = rawValue }

        public let rawValue: Int

        public static let count: Include = Include(rawValue: 1 << 0)
        public static let totalCount: Include = Include(rawValue: 1 << 1)
        public static let unpublished: Include = Include(rawValue: 1 << 3)
        public static let contentType: Include = Include(rawValue: 1 << 4)
        public static let globalField: Include = Include(rawValue: 1 << 5)
        public static let refContentTypeUID: Include = Include(rawValue: 1 << 6)

        public static let all: Include = [.count,
                                          .totalCount,
                                          .unpublished,
                                          .contentType,
                                          .globalField,
                                          .refContentTypeUID]
    }
}

extension ContentTypeQuery {
    public struct Include: OptionSet {
        public init(rawValue: Include.RawValue) { self.rawValue = rawValue }

        public let rawValue: Int

        public static let count: Include = Include(rawValue: 1 << 0)
        public static let totalCount: Include = Include(rawValue: 1 << 1)
        public static let globalFields: Include = Include(rawValue: 1 << 2)

        public static let all: Include = [.count,
                                          .totalCount,
                                          .globalFields]
    }
}

extension AssetQuery {
    public struct Include: OptionSet {
        public init(rawValue: Include.RawValue) { self.rawValue = rawValue }

        public let rawValue: Int

        public static let count: Include = Include(rawValue: 1 << 0)
        public static let totalCount: Include = Include(rawValue: 1 << 1)
        public static let relativeURL: Include = Include(rawValue: 1 << 2)
        public static let dimention: Include = Include(rawValue: 1 << 3)

        public static let all: Include = [.count,
                                          .totalCount,
                                          .relativeURL,
                                          .dimention]
    }
}
