//
//  ResourchQueryable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 19/03/20.
//

import Foundation

internal protocol QueryProtocol: class, Queryable, CachePolicyAccessible {
    associatedtype ResourceType

    var stack: Stack { get set }

    var parameters: Parameters { get set }

    var queryParameter: [String: Any] { get set }

    var cachePolicy: CachePolicy { get set }
}

extension QueryProtocol {
    public func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible {
        if let query = self.queryParameter.jsonString {
            self.parameters[QueryParameter.query] = query
        }
    }
}

internal protocol BaseQuery: QueryProtocol {}
extension BaseQuery {

    public func `where`(valueAtKeyPath keyPath: String, _ operation: Query.Operation) -> Self {
        self.queryParameter[keyPath] = operation.query
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

    public func addURIParam(dictionary: [String: String]) -> Self {
        for (key, value) in dictionary {
            _ = addURIParam(with: key, value: value)
        }
        return self
    }

    public func addURIParam(with key: String, value: String) -> Self {
        self.parameters[key] = value
        return self
    }

    public func addQuery(dictionary: [String: Any]) -> Self {
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

internal protocol EntryQueryable: BaseQuery {}

extension EntryQueryable {

    public func `where`(queryableCodingKey: Entry.FieldKeys, _ operation: Query.Operation) -> Self {
        return self.where(valueAtKeyPath: "\(queryableCodingKey.stringValue)", operation)
    }

    public func `where`(referenceAtKeyPath keyPath: String, _ operation: Query.Reference) -> Self {
        if let query = operation.query {
           self.queryParameter[keyPath] = query
        }
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
    public func only(fields: [String]) -> Self {
        return self.includeQuery(parameter: QueryParameter.only, key: QueryParameter.base, fields: fields)
    }

    @discardableResult
    public func except(fields: [String]) -> Self {
        return self.includeQuery(parameter: QueryParameter.except, key: QueryParameter.base, fields: fields)
    }

    @discardableResult
    public func search(for text: String) -> Self {
        self.parameters[QueryParameter.typeahead] = text
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

    public func includeReference(with keys: [String]) -> Self {
        if let array = self.queryParameter[QueryParameter.include] as? [String] {
            self.queryParameter[QueryParameter.include] = array + keys
        } else {
            self.queryParameter[QueryParameter.include] = keys
        }
        return self
    }

    public func includeReferenceField(with key: String, only fields: [String]) -> Self {
        var query = self.includeReference(with: [key])
        if !fields.isEmpty {
            query = query.includeQuery(parameter: QueryParameter.only, key: key, fields: fields)
        }
        return query
    }

    public func includeReferenceField(with key: String, except fields: [String]) -> Self {
        var query = self.includeReference(with: [key])
        if !fields.isEmpty {
            query = query.includeQuery(parameter: QueryParameter.except, key: key, fields: fields)
        }
        return query
    }
}

public protocol ResourceQueryable {
    func fetch<ResourceType>(_ completion: @escaping ResultsHandler<ResourceType>)
        where ResourceType: Decodable & EndpointAccessible
}

public protocol Queryable {
    func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible
}
