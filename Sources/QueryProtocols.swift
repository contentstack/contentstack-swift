//
//  ResourchQueryable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 19/03/20.
//

import Foundation

internal protocol QueryProtocol: class, CachePolicyAccessible {
    associatedtype ResourceType

    var stack: Stack { get set }

    var parameters: Parameters { get set }

    var queryParameter: [String: Any] { get set }

    var cachePolicy: CachePolicy { get set }
}

extension BaseQuery {
    public func find<ResourceType>(_ completion: @escaping ResultsHandler<ContentstackResponse<ResourceType>>)
        where ResourceType: Decodable & EndpointAccessible {
            if self.queryParameter.count > 0,
                let query = self.queryParameter.jsonString {
                self.parameters[QueryParameter.query] = query
            }
            self.stack.fetch(endpoint: ResourceType.endpoint,
                    cachePolicy: self.cachePolicy, parameters: parameters, then: completion)
    }
}

internal protocol BaseQuery: QueryProtocol, Queryable {}
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

internal protocol EntryQueryable: QueryProtocol {}

extension EntryQueryable {

    @discardableResult
    fileprivate func includeQuery(parameter: String, key: String, fields: [String]) -> Self {
        var baseDict = [key: fields]
        if let dict = self.parameters[parameter] as? [String: [String]] {
            for (keys, value) in dict {
                if keys != key {
                    baseDict[keys] = value
                } else {
                    baseDict[keys] = (value + fields.filter({ (string) -> Bool in
                        return value.contains(string) ? false : true
                    }))
                }
            }
        }
        self.parameters[parameter] = baseDict
        return self
    }

    @discardableResult
    public func locale(_ locale: String) -> Self {
        self.parameters["locale"] = locale
        return self
    }

    @discardableResult
    public func only(fields: [String]) -> Self {
        var fieldsToInclude = fields
        fieldsToInclude.append(contentsOf: ["locale", "title"])
        return self.includeQuery(parameter: QueryParameter.only, key: QueryParameter.base, fields: fieldsToInclude)
    }

    @discardableResult
    public func except(fields: [String]) -> Self {
        let fieldsToExclude = fields.filter { (string) -> Bool in
            return string != "locale"  && string != "title"
        }
        return self.includeQuery(parameter: QueryParameter.except, key: QueryParameter.base, fields: fieldsToExclude)
    }

    public func include(params: Query.Include) -> Self {
        if params.contains(Query.Include.count) {
            self.parameters[QueryParameter.includeCount] = true
        }
        if params.contains(Query.Include.contentType) {
            self.parameters[QueryParameter.includeContentType] = true
            self.parameters[QueryParameter.includeGloablField] = false
        }
        if params.contains(Query.Include.globalField) {
            self.parameters[QueryParameter.includeContentType] = true
            self.parameters[QueryParameter.includeGloablField] = true
        }
        if params.contains(Query.Include.refContentTypeUID) {
            self.parameters[QueryParameter.includeRefContentTypeUID] = true
        }
        return self
    }

    public func includeReference(with keys: [String]) -> Self {
        if let array = self.parameters[QueryParameter.include] as? [String] {
            self.parameters[QueryParameter.include] = (array + keys.filter({ (string) -> Bool in
                return array.contains(string) ? false : true
            }))
        } else {
            self.parameters[QueryParameter.include] = keys
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
