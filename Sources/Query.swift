//
//  Query.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

internal enum QueryConstants {
    internal static let maxLimit: UInt               = 1000
}

/// Use types that conform to QueryableRange to perform queries with the four Range operators
public protocol QueryableRange {
    /// A string representation of a query value that can be used in an API query.
    var stringValue: String { get }
}

extension Int: QueryableRange {

    public var stringValue: String {
        return String(self)
    }
}

extension Double: QueryableRange {

    public var stringValue: String {
        return String(self)
    }
}

extension String: QueryableRange {

    public var stringValue: String {
        return self
    }
}

extension Date: QueryableRange {

    /// The ISO8601 string representation of the receiving Date object.
    public var stringValue: String {
        return self.iso8601String
    }
}

internal protocol QueryProtocol: class, CachePolicyAccessible {
    associatedtype ResourceType

    var stack: Stack { get set }

    var parameters: [String: String] { get set }

    var queryParameter: [String: Any] { get set }

    var cachePolicy: CachePolicy { get set }
}

extension QueryProtocol {
    public func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible {
            if let query = self.queryParameter.jsonString {
                self.parameters[QueryParameter.query] = query
            }
//            stack!.fetch(endpoint: ResourceType.endpoint, c
            //achePolicy: self.cachePolicy, parameters: self.parameters, then: completion)
    }
}

internal protocol ChainableQuery: QueryProtocol {}
extension ChainableQuery {

    public func `where`(valueAtKeyPath keyPath: String, _ operation: Query.Operation) -> Self {
           // Create parameter for this query operation.
        let parameter = keyPath + operation.string
        self.queryParameter[parameter] = operation.value
        return self
    }

    @discardableResult
    public func skip(theFirst numberOfResults: UInt) -> Self {
        self.parameters[QueryParameter.skip] = String(numberOfResults)
        return self
    }

    @discardableResult
    public func limit(to numberOfResults: UInt) -> Self {
        let limit = min(numberOfResults, QueryConstants.maxLimit)
        self.parameters[QueryParameter.limit] = String(limit)
        return self
    }

    @discardableResult
    public func orderByAscending(keyPath: String) -> Self {
        self.parameters[QueryParameter.asc] = keyPath
        return self
    }

    @discardableResult
    public func orderByDecending(keyPath: String) -> Self {
        self.parameters[QueryParameter.desc] = keyPath
        return self
    }
}

public class Query: ChainableQuery {

    internal typealias ResourceType = Entry

    internal required init(stack: Stack, parameters: [String: String] = [:]) {
        self.stack = stack
        self.parameters = parameters
        self.cachePolicy = stack.cachePolicy
    }
    internal var stack: Stack

    internal var parameters: [String: String]

    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

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
    
    public func include(params: Query.Include) -> Self {
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

//    public func includeReferenceField(with keys: [String]) -> Self {
//        if let array = self.queryParams [QueryParameter.include] as? [String] {
//            self.query[QueryParameter.include] = array + keys
//        } else {
//            self.query[QueryParameter.include] = keys
//        }
//        return self
//    }

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
        self.query[key] = value
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

    internal var parameters: [String: String]

    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack, parameters: [String: String] = [:]) {
        self.stack = stack
        self.parameters = parameters
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

    internal var parameters: [String: String]

    internal var queryParameter: [String: Any] = [:]

    public var cachePolicy: CachePolicy

    internal required init(stack: Stack, parameters: [String: String] = [:]) {
        self.stack = stack
        self.parameters = parameters
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
