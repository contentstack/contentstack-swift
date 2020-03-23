//
//  Query.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

public class Query: BaseQuery, EntryQueryable {
    internal typealias ResourceType = Entry

    internal var stack: Stack
    internal var contentTypeUid: String
    internal var parameters: Parameters = [:]
    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(contentType: ContentType) {
        self.stack = contentType.stack
        self.contentTypeUid = contentType.uid!
        self.cachePolicy = contentType.cachePolicy
    }

    public func `where`(valueAtKey path: String, _ operation: Query.Operation) -> Query {
        return self.where(valueAtKeyPath: path, operation)
    }

    public func `where`(queryableCodingKey: Entry.FieldKeys, _ operation: Query.Operation) -> Query {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    public func `where`(referenceAtKeyPath keyPath: String, _ operation: Query.Reference) -> Query {
        if let query = operation.query {
            self.queryParameter[keyPath] = query
        }
        return self
    }

//    @discardableResult
//    public func orderByAscending(key path: String) -> Query {
//        return self.orderByAscending(keyPath: path)
//    }
//
//    @discardableResult
//    public func orderByDecending(key path: String) -> Query {
//        return self.orderByDecending(keyPath: path)
//    }

    @discardableResult
    public func orderByAscending(propertyName: Entry.FieldKeys) -> Query {
        return self.orderByAscending(keyPath: propertyName.stringValue)
    }

    @discardableResult
    public func orderByDecending(propertyName: Entry.FieldKeys) -> Query {
        return self.orderByDecending(keyPath: propertyName.stringValue)
    }

    @discardableResult
    public func search(for text: String) -> Query {
        self.parameters[QueryParameter.typeahead] = text
        return self
    }

    @discardableResult
    public func tags(for text: String) -> Query {
        self.parameters[QueryParameter.tags] = text
        return self
    }

    public func `operator`(_ operator: Query.Operator) -> Query {
        self.queryParameter[`operator`.string] = `operator`.value
        return self
    }
}

public final class QueryOn<EntryType>: Query where EntryType: EntryDecodable {
    public func `where`(queryableCodingKey: EntryType.FieldKeys, _ operation: Query.Operation) -> QueryOn<EntryType> {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    @discardableResult
    public func orderByAscending(propertyName: EntryType.FieldKeys) -> QueryOn<EntryType> {
        return self.orderByAscending(keyPath: propertyName.stringValue)
    }

    @discardableResult
    public func orderByDecending(propertyName: EntryType.FieldKeys) -> QueryOn<EntryType> {
        return self.orderByDecending(keyPath: propertyName.stringValue)
    }
}

public final class ContentTypeQuery: BaseQuery {
    internal typealias ResourceType = ContentType

    internal var stack: Stack

    internal var parameters: Parameters = [:]

    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack) {
        self.stack = stack
        self.cachePolicy = stack.cachePolicy
    }

    public func `where`(queryableCodingKey: ContentType.FieldKeys, _ operation: Query.Operation) -> ContentTypeQuery {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    public func include(params: Include) -> Self {
        if params.contains(.count) {
            self.parameters[QueryParameter.includeCount] = true
        }
        if params.contains(.totalCount) {
            self.parameters[QueryParameter.count] = true
        }
        if params.contains(.globalFields) {
            self.parameters[QueryParameter.includeGloablField] = true
        }
        return self
    }
}

public final class AssetQuery: BaseQuery {
    internal typealias ResourceType = Asset

    internal var stack: Stack

    internal var parameters: Parameters = [:]

    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack) {
        self.stack = stack
        self.cachePolicy = stack.cachePolicy
    }

    public func `where`(queryableCodingKey: Asset.FieldKeys, _ operation: Query.Operation) -> AssetQuery {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    public func include(params: Include) -> AssetQuery {
        if params.contains(.count) {
            self.parameters[QueryParameter.includeCount] = true
        }
        if params.contains(.totalCount) {
            self.parameters[QueryParameter.count] = true
        }

        if params.contains(.relativeURL) {
            self.parameters[QueryParameter.relativeUrls] = true
        }
        if params.contains(.dimention) {
            self.parameters[QueryParameter.includeDimension] = true
        }
        return self
    }

}
