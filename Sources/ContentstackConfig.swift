//
//  ContentstackConfig.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public struct ContentstackConfig {

    /// The singleton instance of 'ContentstackConfig'.
    public static let `default` = ContentstackConfig()
    public var earlyAccess: [String]?

    /// Initialize 'ContentstackConfig' default values.
    public init() {}

    /// An optional configuration to override the date decoding strategy that is provided by the the SDK.
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?

    /// An optional configuration to override the `TimeZone` the SDK will use to decode `Date` instances. The SDK will
    /// use a `TimeZone` with 0 seconds offset from GMT if this configuration is omitted.
    public var timeZone: TimeZone?

    /// The configuration for the URLSession.
    /// Note that HTTP headers will be overwritten internally by the SDK so that requests can be authorized correctly.
    public var sessionConfiguration: URLSessionConfiguration = .default
    
    /// Delegate for handling SSL pinning and URL session customization
    public var urlSessionDelegate: CSURLSessionDelegate?

    /// Computed version of the user agent, including OS name and version
    internal func userAgentString() -> String {
        // Inspired by Alamofire
        // https://github.com/Alamofire/Alamofire/blob/25d8fdd8a36f510a2bc4fe98289f367ec385d337/Source/SessionManager.swift

        var userAgentString = ""

        // Fail gracefully in case any information is inaccessible.
        // App info.
        if let appVersionString = appVersionString() {
            userAgentString = "app \(appVersionString); "
        }
        // SDK info.
        userAgentString += " sdk \(sdkVersionString());"
        // Platform/language info.
        if let platformVersionString = platformVersionString() {
            userAgentString += " platform \(platformVersionString);"
        }

        // Operating system info.
        if let operatingSystemVersionString = operatingSystemVersionString() {
            userAgentString += " os \(operatingSystemVersionString);"
        }

        return userAgentString
    }
    public mutating func setEarlyAccess(_ earlyAccess: [String]) {
         self.earlyAccess = earlyAccess
    }

    // MARK: Private
    private func platformVersionString() -> String? {
        var swiftVersionString: String?
        // The project is only compatible with swift >=4.0
        #if swift(>=5.0)
        swiftVersionString = "5.0"
        #endif

        guard let swiftVersion = swiftVersionString else { return nil }
        return "Swift/\(swiftVersion)"
    }

    private func operatingSystemVersionString() -> String? {
        guard let osName = operatingSystemPlatform() else { return nil }

        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString = String(osVersion.majorVersion) + "." +
            String(osVersion.minorVersion) + "." +
            String(osVersion.patchVersion)
        return "\(osName)/\(osVersionString)"
    }

    private func operatingSystemPlatform() -> String? {
        let osName: String? = {
            #if os(iOS)
            return "iOS"
            #elseif os(OSX)
            return "macOS"
            #elseif os(tvOS)
            return "tvOS"
            #elseif os(watchOS)
            return "watchOS"
            #elseif os(Linux)
            return "Linux"
            #else
            return nil
            #endif
        }()
        return osName
    }

    internal func sdkVersionString() -> String {
        guard
            let bundleInfo = Bundle(for: Stack.self).infoDictionary,
            let versionNumberString = bundleInfo["CFBundleShortVersionString"] as? String
            else { return "Unknown" }

        return "contentstack-swift/\(versionNumberString)"
    }

    private func appVersionString() -> String? {
        guard
            let bundleInfo = Bundle.main.infoDictionary,
            let versionNumberString = bundleInfo["CFBundleShortVersionString"] as? String,
            let appBundleId = Bundle.main.bundleIdentifier else { return nil }

        return appBundleId + "/" + versionNumberString
    }
    
    /// Internal method to get headers including early access
     internal func getHeaders() -> [String: String] {
         var headers: [String: String] = [
             "X-User-Agent": sdkVersionString(),
             "User-Agent": userAgentString()
         ]
         
         if let earlyAccess = earlyAccess, !earlyAccess.isEmpty {
             headers["x-header-ea"] = earlyAccess.joined(separator: ",")
         }
         
         return headers
     }
}
