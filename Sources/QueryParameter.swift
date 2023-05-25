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
    
    internal static let includeMetadata = "include_metadata"

    internal static let includeGloablField    = "include_global_field_schema"

    internal static let includeUnpublished        = "include_unpublished"

    internal static let includeContentType        = "include_content_type"

    internal static let includeRefContentTypeUID  = "include_reference_content_type_uid"
    
    internal static let includeFallback  = "include_fallback"
    
    internal static let includeEmbeddedItems  = "include_embedded_items"
}

extension Query {
    /// The `Query.Include` is parameter for including `count`, `Unpublished`,
    /// `ContentType schema`, `Global Fields schema`, and `Reference ContentType Uid`
    /// in result.
    public struct Include: OptionSet {
        /// Creates a new option set from the given raw value.
        ///
        /// - Parameter rawValue: The raw value of the option set to create. Each bit
        ///   of `rawValue` potentially represents an element of the `Query.Include`,
        ///   though raw values may include bits that are not defined as distinct
        ///   values of the `Query.Include` type.
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Each bit of `rawValue` potentially represents an element of the option set
        public let rawValue: Int

        /// To include `count` in the response.
        public static let count: Include = Include(rawValue: 1 << 0)
        /// To include Unpublished Entries in response,
        public static let unpublished: Include = Include(rawValue: 1 << 1)
        /// To include ContentType schema in Entry response,
        public static let contentType: Include = Include(rawValue: 1 << 2)
        /// To include Global Fields schema in Entry response,
        public static let globalField: Include = Include(rawValue: 1 << 3)
        /// To include Reference ContentType Uid in reference field in Entry response,
        public static let refContentTypeUID: Include = Include(rawValue: 1 << 4)
        /// Retrieve the published content of the fallback locale if an entry is not localized in specified locale.
        public static let fallback: Include = Include(rawValue: 1 << 5)
        /// Include Embedded Objects (Entries and Assets) along with entry/entries details.
        public static let embeddedItems: Include = Include(rawValue: 1 << 6)
        
        /// Include Embedded Objects (Entries and Assets) along with entry/entries details.
        public static let metadata: Include = Include(rawValue: 1 << 7)
        
        /// To inclide all `Query.Include` values.
        public static let all: Include = [.count,
                                          .unpublished,
                                          .contentType,
                                          .globalField,
                                          .refContentTypeUID,
                                          .fallback,
                                          .embeddedItems,
                                          .metadata]
    }
}

extension ContentTypeQuery {
    /// The `ContentTypeQuery.Include` is parameter for including `count`, `Global Fields schema` in result.
    public struct Include: OptionSet {
        /// Creates a new option set from the given raw value.
        ///
        /// - Parameter rawValue: The raw value of the option set to create. Each bit
        ///   of `rawValue` potentially represents an element of the `ContentTypeQuery.Include`,
        ///   though raw values may include bits that are not defined as distinct
        ///   values of the `ContentTypeQuery.Include` type.
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Each bit of `rawValue` potentially represents an element of the option set
        public let rawValue: Int

        /// To include count in the response.
        public static let count: Include = Include(rawValue: 1 << 0)
        /// To include Global Fields schema in ContentType response,
        public static let globalFields: Include = Include(rawValue: 1 << 1)
        /// To include all `ContentTypeQuery.Include` values.
        public static let all: Include = [.count,
                                          .globalFields]
    }
}

extension AssetQuery {
    /// The `AssetQuery.Include` is parameter for including `count`, `relative URLs`,
    /// and `dimensions` in result.
    public struct Include: OptionSet {
        /// Creates a new option set from the given raw value.
        ///
        /// - Parameter rawValue: The raw value of the option set to create. Each bit
        ///   of `rawValue` potentially represents an element of the `AssetQuery.Include`,
        ///   though raw values may include bits that are not defined as distinct
        ///   values of the `AssetQuery.Include` type.
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Each bit of `rawValue` potentially represents an element of the option set
        public let rawValue: Int

        /// To include count in the response.
        public static let count: Include = Include(rawValue: 1 << 0)
        /// To include the relative URLs of the assets in the response.
        public static let relativeURL: Include = Include(rawValue: 1 << 1)
        /// To include the dimensions (height and width) of the image in the response.
        /// Supported image types: JPG, GIF, PNG, WebP, BMP, TIFF, SVG, and PSD.
        public static let dimension: Include = Include(rawValue: 1 << 2)
        /// Retrieve the published content of the fallback locale if an entry is not localized in specified locale.
        public static let fallback: Include = Include(rawValue: 1 << 3)
        /// Retrieve the published content of the fallback locale if an entry is not localized in specified locale.
        public static let metadata: Include = Include(rawValue: 1 << 4)
        /// To inclide all `AssetQuery.Include` values.
        public static let all: Include = [.count,
                                          .relativeURL,
                                          .dimension,
                                          .fallback,.metadata]
    }
}
