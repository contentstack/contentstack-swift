//
//  Query.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

public class Query: ChainableQuery {
    internal typealias ResourceType = Entry

    internal var stack: Stack
    internal var contentTypeUid: String
    internal var parameters: [String: String] = [:]
    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(contentType: ContentType) {
        self.stack = contentType.stack
        self.contentTypeUid = contentType.uid!
        self.cachePolicy = contentType.cachePolicy
    }

    public func `where`(queryableCodingKey: Entry.FieldKeys, _ operation: Query.Operation) -> Query {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    @discardableResult
    public func only(fields: [String]) -> Self {
        return self.includeQuery(parameter: QueryParameter.only, key: QueryParameter.base, fields: fields)
    }

    @discardableResult
    public func exept(fields: [String]) -> Self {
        return self.includeQuery(parameter: QueryParameter.except, key: QueryParameter.base, fields: fields)
    }

    @discardableResult
    public func search(for text: String) -> Self {
        self.parameters[QueryParameter.typeahead] = text
        return self
    }

    @discardableResult
    fileprivate func includeQuery(parameter: String, key: String, fields: [String]) -> Self {
        var baseDict = [key: fields]
        if let dict = self.queryParameter[parameter] as? [String: [String]] {
            for (keys, value) in dict {
                if keys != key {
                    baseDict[keys] = value
                } else {
                    baseDict[keys] = value + fields
                }
            }
        }
        self.queryParameter[parameter] = baseDict
        return self
    }

    @discardableResult
    public func orderByAscending(propertyName: Entry.FieldKeys) -> Self {
        return self.orderByAscending(keyPath: propertyName.stringValue)
    }

    @discardableResult
    public func orderByDecending(propertyName: Entry.FieldKeys) -> Self {
        return self.orderByDecending(keyPath: propertyName.stringValue)
    }

    @discardableResult
    public func tags(for text: String) -> Self {
        self.parameters[QueryParameter.tags] = text
        return self
    }

    public func include(params: Include) -> Self {
        if params.contains(Query.Include.count) {
            self.parameters[QueryParameter.includeCount] = "true"
        }
        if params.contains(Query.Include.totalCount) {
            self.parameters[QueryParameter.count] = "true"
        }
        if params.contains(Query.Include.contentType) {
            self.parameters[QueryParameter.includeContentType] = "true"
            self.parameters[QueryParameter.includeGloablField] = "false"
        }
        if params.contains(Query.Include.globalField) {
            self.parameters[QueryParameter.includeContentType] = "true"
            self.parameters[QueryParameter.includeGloablField] = "true"
        }
        if params.contains(Query.Include.refContentTypeUID) {
            self.parameters[QueryParameter.includeRefContentTypeUID] = "true"
        }
        return self
    }

    public func includeReferenceField(with keys: [String]) -> Self {
        if let array = self.queryParameter[QueryParameter.include] as? [String] {
            self.queryParameter[QueryParameter.include] = array + keys
        } else {
            self.queryParameter[QueryParameter.include] = keys
        }
        return self
    }

    public func includeReferenceField(with key: String, only fields: [String]) -> Self {
        var query = self.includeReferenceField(with: [key])
        if fields.isEmpty {
            query = query.includeQuery(parameter: QueryParameter.only, key: key, fields: fields)
        }
        return query
    }

    public func includeReferenceField(with key: String, except fields: [String]) -> Self {
        var query = self.includeReferenceField(with: [key])
        if fields.isEmpty {
            query = query.includeQuery(parameter: QueryParameter.except, key: key, fields: fields)
        }
        return query
    }

    public func addParams(dictionary: [String: Any]) -> Self {
        for (key, value) in dictionary {
            _ = addQuery(with: key, value: value)
        }
        return self
    }

    public func addQuery(with key: String, value: Any) -> Self {
        self.queryParameter[key] = value
        return self
    }
}

public final class QueryOn<EntryType>: Query where EntryType: EntryDecodable {
    public func `where`(queryableCodingKey: EntryType.FieldKeys, _ operation: Query.Operation) -> Query {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    @discardableResult
    public func orderByAscending(propertyName: EntryType.FieldKeys) -> Self {
        return self.orderByAscending(keyPath: propertyName.stringValue)
    }

    @discardableResult
    public func orderByDecending(propertyName: EntryType.FieldKeys) -> Self {
        return self.orderByDecending(keyPath: propertyName.stringValue)
    }
}

public final class ContentTypeQuery: ChainableQuery {
    internal typealias ResourceType = ContentType

    internal var stack: Stack

    internal var parameters: [String: String] = [:]

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
            self.parameters[QueryParameter.includeCount] = "true"
        }
        if params.contains(.totalCount) {
            self.parameters[QueryParameter.count] = "true"
        }
        if params.contains(.globalFields) {
            self.parameters[QueryParameter.includeGloablField] = "true"
        }
        return self
    }
}

public final class AssetQuery: ChainableQuery {
    internal typealias ResourceType = Asset

    internal var stack: Stack

    internal var parameters: [String: String] = [:]

    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack) {
        self.stack = stack
        self.cachePolicy = stack.cachePolicy
    }

    public func `where`(queryableCodingKey: Asset.QueryableCodingKey, _ operation: Query.Operation) -> AssetQuery {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    public func include(params: Include) -> Self {
        if params.contains(.count) {
            self.parameters[QueryParameter.includeCount] = "true"
        }
        if params.contains(.totalCount) {
            self.parameters[QueryParameter.count] = "true"
        }

        if params.contains(.relativeURL) {
            self.parameters[QueryParameter.relativeUrls] = "true"
        }
        if params.contains(.dimention) {
            self.parameters[QueryParameter.includeDimension] = "true"
        }
        return self
    }

}
