public struct Contentstack {

    /// Create a new Stack instance with stack's apikey, token, environment name and config.
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
    public static func stack(apiKey: String,
                             deliveryToken: String,
                             environment: String,
                             region: ContentstackRegion = ContentstackRegion.us,
                             host: String = Host.delivery,
                             apiVersion: String = "v3",
                             config: ContentstackConfig = ContentstackConfig.default) -> Stack {
        let regionBaseHost = host != Host.delivery ? host : (region != .us ? "cdn.contentstack.com": host)
        return Stack(apiKey: apiKey,
                     deliveryToken: deliveryToken,
                     environment: environment,
                     region: region,
                     host: regionBaseHost,
                     apiVersion: apiVersion,
                     config: config)
    }
}
