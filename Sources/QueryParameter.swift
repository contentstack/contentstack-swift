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
    internal static let limit            = "limit"
    /// `skip` parameter will skip a specific number of items.
    internal static let skip             = "skip"
    /// `locale` in the query to get entry/entries of a particular locale
    internal static let locale           = "locale"
    /// `asc`can sort them in the ascending order
    internal static let asc              = "asc"
    /// `desc` can sort them in the descending orde
    internal static let desc             = "desc"
    /// `query` to search accross all text and symbol fields in your space
    internal static let query            = "query"

    internal static let typeahead        = "typeahead"

    internal static let tags             = "tags"

    internal static let contentType      = "content_type"

    internal static let uid              = "uid"

    /// `only` parameter will include the data of only the specified fields for each entry
    internal static let only             = "only"
    /// `BASE` is the default value and refers to the top-level fields of the schema
    internal static let base             = "BASE"

    /// `except` parameter will exclude the data of the specified fields
    internal static let except           = "except"

    /// `include` parameter wish to fetch the content
    /// of the entry that is included in the reference field
    internal static let include          = "include"

    /// `include_count` retrieves entries details and their count
    internal static let includeCount     = "include_count"

    internal static let relativeUrls = "relative_urls"

    internal static let includeDimension = "include_dimension"

    internal static let includeGloablField    = "include_global_field_schema"

    internal static let includeUnpublished        = "include_unpublished"

    internal static let includeContentType        = "include_content_type"

    internal static let includeRefContentTypeUID  = "include_reference_content_type_uid"
}

extension Query {
    public struct Include: OptionSet {
        public init(rawValue: Int) { self.rawValue = rawValue }

        public let rawValue: Int

        public static let count: Include = Include(rawValue: 1 << 0)
        public static let unpublished: Include = Include(rawValue: 1 << 1)
        public static let contentType: Include = Include(rawValue: 1 << 2)
        public static let globalField: Include = Include(rawValue: 1 << 3)
        public static let refContentTypeUID: Include = Include(rawValue: 1 << 4)

        public static let all: Include = [.count,
                                          .unpublished,
                                          .contentType,
                                          .globalField,
                                          .refContentTypeUID]
    }
}

extension ContentTypeQuery {
    public struct Include: OptionSet {
        public init(rawValue: Int) { self.rawValue = rawValue }

        public let rawValue: Int

        public static let count: Include = Include(rawValue: 1 << 0)
        public static let globalFields: Include = Include(rawValue: 1 << 1)

        public static let all: Include = [.count,
                                          .globalFields]
    }
}

extension AssetQuery {
    public struct Include: OptionSet {
        public init(rawValue: Int) { self.rawValue = rawValue }

        public let rawValue: Int

        public static let count: Include = Include(rawValue: 1 << 0)
        public static let relativeURL: Include = Include(rawValue: 1 << 1)
        public static let dimension: Include = Include(rawValue: 1 << 2)

        public static let all: Include = [.count,
                                          .relativeURL,
                                          .dimension]
    }
}
