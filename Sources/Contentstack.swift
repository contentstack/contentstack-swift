/// [Contentstack](https://www.contentstack.com/) is a content management system
/// that facilitates the process of publication by separating the content from
/// site-related programming and design.

import ContentstackUtils

public struct Contentstack {

    /// Create a new Stack instance with stack's `apikey`, `deliveryToken`, `environment` name and `config`.
    ///
    /// - Parameters:
    ///   - apiKey: stack apiKey.
    ///   - accessToken: stack delivery token.
    ///   - environment: environment name in which to perform action.
    ///   - region: Contentstack region
    ///   - host: name of Contentstack api server.
    ///   - apiVersion: API version of Contentstack api server.
    ///   - config: config of stack.
    /// - Returns: Stack instance
    ///
    /// Example usage:
    /// ```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// // Initiate Stack instance for `EU` region:
    ///
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment,
    ///             region: .eu)
    /// ```
    public static func stack(apiKey: String,
                             deliveryToken: String,
                             environment: String,
                             region: ContentstackRegion = ContentstackRegion.us,
                             host: String = Host.delivery,
                             apiVersion: String = "v3",
                             branch: String? = nil,
                             config: ContentstackConfig = ContentstackConfig.default) -> Stack {
        let regionBaseHost = resolveDeliveryHost(region: region, host: host)
        return Stack(apiKey: apiKey,
                     deliveryToken: deliveryToken,
                     environment: environment,
                     region: region,
                     host: regionBaseHost,
                     apiVersion: apiVersion,
                     branch: branch,
                     config: config)
    }
    
    /// Resolves the content-delivery host for the given region.
    ///
    /// An explicitly provided `host` (anything other than the default `Host.delivery`) always wins.
    /// Otherwise the host is resolved from ``ContentstackEndpoint`` using only already-cached data
    /// (`allowDownload: false`) so stack creation never blocks on the network. When nothing is cached
    /// yet, the legacy `<region>-cdn.contentstack.com` pattern is used — it produces the same
    /// content-delivery host as the registry for every current region.
    private static func resolveDeliveryHost(region: ContentstackRegion, host: String) -> String {
        if host != Host.delivery {
            return host
        }
        if let resolved = try? ContentstackEndpoint.getContentstackEndpoint(region.rawValue,
                                                                            service: "contentDelivery",
                                                                            omitHttps: true,
                                                                            allowDownload: false) {
            return resolved
        }
        // Nothing cached / unrecognised region: fall back to the legacy prefix pattern.
        return region != .us ? "\(region.rawValue)-cdn.contentstack.com" : host
    }

    /// Returns the Contentstack API URL for the given region and service.
    ///
    /// - Parameters:
    ///   - region: region ID or alias (e.g. `"na"`, `"eu"`, `"azure-na"`).
    ///   - service: service key (e.g. `"contentDelivery"`, `"contentManagement"`).
    ///   - omitHttps: when `true`, returns the bare host without the `https://` prefix.
    /// - Returns: the URL (or bare host when `omitHttps` is `true`).
    /// - Throws: ``EndpointError`` if the region or service is not recognised.
    public static func getContentstackEndpoint(region: String,
                                               service: String,
                                               omitHttps: Bool = false) throws -> String {
        return try ContentstackEndpoint.getContentstackEndpoint(region, service: service, omitHttps: omitHttps)
    }

    /// Returns all service endpoints for the given region as a map of service key to URL.
    ///
    /// - Parameters:
    ///   - region: region ID or alias.
    ///   - omitHttps: when `true`, returns bare hosts without the `https://` prefix.
    /// - Returns: map of service key → URL (or bare host).
    /// - Throws: ``EndpointError`` if the region is not recognised.
    public static func getContentstackEndpoints(region: String,
                                                omitHttps: Bool = false) throws -> [String: String] {
        return try ContentstackEndpoint.getContentstackEndpoints(region, omitHttps: omitHttps)
    }

    public struct Utils {
        public static func render(content: String, option: Option) throws -> String {
            return try ContentstackUtils.render(content: content, option)
        }
        
        public static func render(contents: [String], option: Option) throws -> [String] {
            return try ContentstackUtils.render(contents: contents, option)
        }
    }
}
