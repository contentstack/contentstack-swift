//
//  QueryOperation.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

extension Query {

    public enum Operation {
        ///Equals Operator: <https://www.contentstack.com/docs/apis/content-delivery-api/#equals-operator>
        case equals(String)
        ///Not-equals Operator: <https://www.contentstack.com/docs/apis/content-delivery-api/#not-equals-operator>
        case notEquals(String)
        ///Includes content in array: <https://www.contentstack.com/docs/apis/content-delivery-api/#array-equals-operator>
        case includes([String])
        ///Excludes content in array: <https://www.contentstack.com/docs/apis/content-delivery-api/#array-equals-operator>
        case excludes([String])
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

        internal var value: String {
            switch self {
            case .equals(let value):                return value
            case .notEquals(let value):             return value
            case .includes(let value):              return value.joined(separator: ",")
            case .excludes(let value):              return value.joined(separator: ",")
            case .isLessThan(let value):            return value.stringValue
            case .isLessThanOrEqual(let value):     return value.stringValue
            case .isGreaterThan(let value):         return value.stringValue
            case .isGreaterThanOrEqual(let value):  return value.stringValue
            case .exists(let value):                return String(value)
            case .matches(let value):               return value
            }
        }
    }
}
