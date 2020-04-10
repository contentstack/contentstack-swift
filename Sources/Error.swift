//
//  Error.swift
//  Contentstack iOS
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import Foundation

/// Possible errors being thrown by the SDK
public enum SDKError: Error, CustomDebugStringConvertible {

    /// Thrown when receiving an invalid HTTP response.
    /// - Parameter response: Optional URL response that has triggered the error.
    case invalidHTTPResponse(response: URLResponse?)

    /// Thrown when attempting to construct an invalid URL.
    /// - Parameter string: The invalid URL string.
    case invalidURL(string: String)

    /// Thrown when attempting to construct an invalid URL.
    /// - Parameter string: The invalid URL string.
    case invalidUID(string: String)

    /// Thrown when receiving unparseable JSON responses.
    /// - Parameters:
    ///   - data: The data being parsed.
    ///   - errorMessage: The message from the error which occured during parsing.
    case unparseableJSON(data: Data?, errorMessage: String)

    case stackError

    case cacheError

    case syncError

    public var debugDescription: String {
        return message
    }

    internal var message: String {
        switch self {
        case .invalidHTTPResponse(let response):
            return "The HTTP request returned a corrupted HTTP response: \(response.debugDescription)"
        case .invalidURL(let string):
            return string
        case .invalidUID(let string):
            return "The uid \(string) is not valid."
        case .stackError:
            return "The Stack not found."
        case .syncError:
            return "The Stack sync faile to retrive."
        case .cacheError:
            return "Failed to retreive data from Cache."
        case .unparseableJSON( _, let errorMessage):
            return errorMessage
        }
    }
}

/// Information regarding an error received from Contentful's API.
public class APIError: Decodable, Error, CustomDebugStringConvertible {
    public var debugDescription: String {
        let statusCodeString = "HTTP status code " + String(statusCode)
        let detailMessage = """
        Contentstack error message \(self.errorMessage)
        Contentstack error code \(self.errorCode)
        Contentstack error \((self.errorInfo != nil) ? self.errorInfo!.debugDescription : "")
        """
        let debugDescription =
        """
        \(statusCodeString)
        \(detailMessage)
        """
        return debugDescription
    }

    public let errorMessage: String

    public let errorCode: Int

    public let errorInfo: ErrorInfo!

    public var statusCode: Int!

    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        self.errorInfo  = try container.decode(ErrorInfo.self, forKey: .errorInfo)
        self.errorMessage = try container.decode(String.self, forKey: APIError.CodingKeys.errorMessage)
        self.errorCode = try container.decode(Int.self, forKey: APIError.CodingKeys.errorCode)
    }

    private enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case errorCode = "error_code"
        case errorInfo = "errors"
    }

    public class ErrorInfo: Decodable, CustomDebugStringConvertible {
        public var debugDescription: String {
            var debugDescription = ""

            if let apiKey = self.apiKey {
                debugDescription += "API Key \(apiKey.joined(separator: ", ")) \n"
            }

            if let accessToken = self.accessToken {
                debugDescription += "Access token \(accessToken.joined(separator: ", ")) \n"
            }

            if let environment = self.environment {
                debugDescription += "Environment \(environment.joined(separator: ", ")) \n"
            }
            if let uid = self.uid {
                debugDescription += "UID \(uid.joined(separator: ", ")) \n"
            }
            return debugDescription
        }
        public let apiKey: [String]?

        public let accessToken: [String]?

        public let environment: [String]?

        public let uid: [String]?
        public required init(from decoder: Decoder) throws {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            var api  = try container.decodeIfPresent([String].self, forKey: .apiKey)
            if api == nil {
                api  = try container.decodeIfPresent([String].self, forKey: .authtoken)
            }
            self.apiKey = api
            self.accessToken = try container.decodeIfPresent([String].self, forKey: .accessToken)
            self.environment = try container.decodeIfPresent([String].self, forKey: .environment)
            self.uid = try container.decodeIfPresent([String].self, forKey: .uid)
        }

        private enum CodingKeys: String, CodingKey {
            case apiKey = "api_key"
            case accessToken = "access_token"
            case environment, authtoken, uid
        }
    }

    // API Errors from the Contentstack Delivery API are special cased for JSON deserialization:
    // Rather than throw an error and trigger a Swift error breakpoint in Xcode,
    // we use failable initializers so that consumers don't experience error breakpoints when
    // no error was returned from the API.
    internal static func error(with decoder: JSONDecoder, data: Data, statusCode: Int) -> APIError? {
        if let error = try? decoder.decode(APIError.self, from: data) {
            // An error must have these things.
            guard error.errorInfo != nil else {
                return nil
            }
            error.statusCode = statusCode
            return error
        }
        return nil
    }

    static func handleError(for url: URL, jsonDecoder: JSONDecoder, data: Data, response: HTTPURLResponse) -> Error {
        if let apiError = APIError.error(with: jsonDecoder, data: data, statusCode: response.statusCode) {
            let errorMessage = """
            Errored: 'GET' (\(response.statusCode)) \(url.absoluteString)
            Message: \(apiError.errorMessage)"
            """
            ContentstackLogger.log(.error, message: errorMessage)
            return apiError
        } else {
            let errorMessage = "An API error was returned that the SDK was unable to parse"
            let logMessage = """
            Errored: 'GET' \(url.absoluteString). \(errorMessage)
            Message: \(errorMessage)
            """
            ContentstackLogger.log(.error, message: logMessage)
            return SDKError.unparseableJSON(data: data, errorMessage: errorMessage)
        }

    }
}
