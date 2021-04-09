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
                             config: ContentstackConfig = ContentstackConfig.default) -> Stack {
        let regionBaseHost = host != Host.delivery ? host : (region != .us ? "eu-cdn.contentstack.com": host)
        return Stack(apiKey: apiKey,
                     deliveryToken: deliveryToken,
                     environment: environment,
                     region: region,
                     host: regionBaseHost,
                     apiVersion: apiVersion,
                     config: config)
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
