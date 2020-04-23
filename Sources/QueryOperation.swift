//
//  QueryOperation.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

extension Query {

    
    /// When fetching entries, you can perform `and` or `or` operation.
    public enum Operator {
        /// And Operator: <https://www.contentstack.com/docs/developers/apis/content-delivery-api/#and-operator>
        case and([Query])
        /// Or Operator: <https://www.contentstack.com/docs/developers/apis/content-delivery-api/#or-operator>
        case or([Query])

        internal var string: String {
            switch self {
            case .and:      return "$and"
            case .or:   return "$or"
            }
        }

        internal var value: [[String: Any]] {
            switch self {
            case .and(let queries):
                return queryParamArray(from: queries)
            case .or(let queries):
                return queryParamArray(from: queries)
            }
        }
        internal func queryParamArray(from queries: [Query]) -> [[String: Any]] {
            return queries.map { (query: Query) -> [String: Any] in
                return query.queryParameter
            }
        }
    }

    /// When fetching entries, you can search base on reference `$in` or `$nin`.
    public enum Reference {
        /// Reference Search Equals: <https://www.contentstack.com/docs/developers/apis/content-delivery-api/#reference-search-equals>
        case include(Query)
        /// Reference Search Not-equals: <https://www.contentstack.com/docs/developers/apis/content-delivery-api/#reference-search-not-equals>
        case notInclude(Query)

        internal var string: String {
            switch self {
            case .include:      return "$in"
            case .notInclude:   return "$nin"
            }
        }

        internal var value: String? {
            switch self {
            case .include(let query):       return query.queryParameter.jsonString
            case .notInclude(let query):    return query.queryParameter.jsonString
            }
        }

        internal var query: String? {
            return [self.string: self.value].jsonString
        }
    }
    /// When fetching entries, you can search on field key paths.
    public enum Operation {
        ///Equals Operator: <https://www.contentstack.com/docs/apis/content-delivery-api/#equals-operator>
        case equals(QueryableRange)
        ///Not-equals Operator: <https://www.contentstack.com/docs/apis/content-delivery-api/#not-equals-operator>
        case notEquals(QueryableRange)
        ///Includes content in array: <https://www.contentstack.com/docs/apis/content-delivery-api/#array-equals-operator>
        case includes([QueryableRange])
        ///Excludes content in array: <https://www.contentstack.com/docs/apis/content-delivery-api/#array-equals-operator>
        case excludes([QueryableRange])
        ///Less Than: <https://www.contentstack.com/docs/apis/content-delivery-api/#less-than>
        case isLessThan(QueryableRange)
        ///Less than or equal: <https://www.contentstack.com/docs/apis/content-delivery-api/#less-than-or-equal-to>
        case isLessThanOrEqual(QueryableRange)
        ///Greater Than: <https://www.contentstack.com/docs/apis/content-delivery-api/#greater-than>
        case isGreaterThan(QueryableRange)
        ///Greater than or equal: <https://www.contentstack.com/docs/apis/content-delivery-api/#greater-than-or-equal-to>
        case isGreaterThanOrEqual(QueryableRange)
        /// The existence operator: <https://www.contentstack.com/docs/apis/content-delivery-api/#exists>
        case exists(Bool)
        /// Search on a field by Regex. <https://www.contentstack.com/docs/apis/content-delivery-api/#search-by-regex>
        case matches(String)

        internal var string: String {
            switch self {
            case .equals:                   return ""
            case .notEquals:                return "$ne"
            case .includes:                 return "$in"
            case .excludes:                 return "$nin"
            case .isLessThan:               return "$lt"
            case .isLessThanOrEqual:        return "$lte"
            case .isGreaterThan:            return "$gt"
            case .isGreaterThanOrEqual:     return "$gte"
            case .exists:                   return "$exists"
            case .matches:                  return "$regex"
            }
        }

        internal var value: Any {
            switch self {
            case .equals(let value):
                if value is Int || value is Float || value is Double || value is Bool {
                    return value
                }
                return value.stringValue
            case .notEquals(let value):
                if value is Int || value is Float || value is Double || value is Bool {
                    return value
                }
                return value.stringValue
            case .includes(let value):              return value
            case .excludes(let value):              return value
            case .isLessThan(let value):
                if value is Int || value is Float || value is Double || value is Bool {
                    return value
                }
                return value.stringValue
            case .isLessThanOrEqual(let value):
                if value is Int || value is Float || value is Double || value is Bool {
                    return value
                }
                return value.stringValue
            case .isGreaterThan(let value):
                if value is Int || value is Float || value is Double || value is Bool {
                    return value
                }
                return value.stringValue
            case .isGreaterThanOrEqual(let value):
                if value is Int || value is Float || value is Double || value is Bool {
                    return value
                }
                return value.stringValue
            case .exists(let value):                return value
            case .matches(let value):               return value
            }
        }
        internal var query: Any {
            switch self {
            case .equals:
                return self.value
            default:
                return [self.string: self.value]
            }
        }
    }
}
