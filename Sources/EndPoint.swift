//
//  Endpoints.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 01/08/19.
//

import Foundation

///  Endpoints that are available for the Content Delivery
public enum Endpoint: String {

    /// The stack endpoint.
    case stack
    /// The content type endpoint.
    case contenttype = "content_types"
    /// The entry endpoint.
    case entries
    /// The asset endpoint.
    case assets
    /// The synchronization endpoint.
    case sync = "stacks/sync"
    
    case taxnomies = "taxonomies"
    /// The path component string for the current endpoint.
    public var pathComponent: String {
        return rawValue
    }
}
