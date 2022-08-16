//
//  Stack.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation

public enum Host {
    /// The path for the Contentstack Delivery API.
    public static let delivery = "cdn.contentstack.io"
}

public typealias ResultsHandler<T> = (_ result: Result<T, Error>, ResponseType) -> Void

/// Stack is instance for performing Contentstack Delivery API request.
public class Stack: CachePolicyAccessible {
    internal var urlSession: URLSession

    private let config: ContentstackConfig

    /// `API Key` is a unique key assigned to each stack.
    public let apiKey: String
    /// `Delivery Token` is a read-only credential that you can create for different environments of your stack.
    public let deliveryToken: String
    /// `Environment` can be defined as one or more content delivery destinations
    public let environment: String
    /// The domain host to perform requests against. Defaults to `Host.delivery` i.e. `"cdn.contentstack.com"`.
    public let host: String
    /// `Region` refers to the location of the data centers where your organization's data resides.
    public let region: ContentstackRegion
    /// Stack api version point
    public let apiVersion: String
    /// `Branch` is a
    public let branch: String?
    /// `CachePolicy` allows you to cache request
    public var cachePolicy: CachePolicy = .networkOnly
    /// The JSONDecoder that the receiving client instance uses to deserialize JSON. The SDK will
    /// inject information about the locales to this decoder and use this information to normalize
    /// the fields dictionary of entries and assets.
    public private(set) var jsonDecoder: JSONDecoder

    internal init(apiKey: String,
                  deliveryToken: String,
                  environment: String,
                  region: ContentstackRegion,
                  host: String,
                  apiVersion: String,
                  branch: String? = nil,
                  config: ContentstackConfig) {

        self.apiKey = apiKey
        self.deliveryToken = deliveryToken
        self.environment = environment

        self.host = host
        self.region = region
        self.apiVersion = apiVersion
        self.branch = branch
        self.config = config

        self.jsonDecoder = JSONDecoder.dateDecodingStrategy()
        if let dateDecodingStrategy = config.dateDecodingStrategy {
            jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
        }
        if let timeZone = config.timeZone {
            jsonDecoder.userInfo[.timeZoneContextKey] = timeZone
        }
        var contentstackHTTPHeaders = [
            "api_key": apiKey,
            "access_token": deliveryToken,
            "X-User-Agent": config.sdkVersionString(),
            "User-Agent": config.userAgentString()
        ]
        
        if let branchId = branch {
            contentstackHTTPHeaders["branch"] = branchId
        }
        self.config.sessionConfiguration.httpAdditionalHeaders = contentstackHTTPHeaders
        self.urlSession = URLSession(configuration: config.sessionConfiguration)

        URLCache.shared = CSURLCache.default
    }

    /// Get instance of `ContentType` to fetch content-types and schema or fetch entries of specific content-type.
    ///
    /// - Parameters:
    ///   - uid: The UId of `ContentType` you want to fetch data,
    /// - Returns: `ContentType` instance
    ///
    /// Example usage:
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///```
    /// // To perform `ContentType` query:
    /// let query = stack.contentType().query()
    /// // To fetch specific `ContentType` entries:
    /// let entry = stack.contentType(uid: contentTypeUid).entry()
    ///```
    public func contentType(uid: String? = nil) -> ContentType {
        return ContentType(uid, stack: self)
    }

    /// Get instance of `Asset` to fetch `Assets` or fetch specific `Asset`.
    ///
    /// - Parameters:
    ///   - uid: The UId of `Asset` you want to fetch data,
    /// - Returns: `Asset` instance
    ///
    /// Example usage:
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///```
    /// // To perform `Asset` query:
    /// let query = stack.asset().query()
    /// // To get specific `Asset` instance from uid:
    /// let asset = stack.asset(uid: assetUid)
    ///```
    public func asset(uid: String? = nil) -> Asset {
        return Asset(uid, stack: self)
    }

    private func url(endpoint: Endpoint, parameters: Parameters = [:]) -> URL {
        var urlComponents: URLComponents = URLComponents(string: "https://\(self.host)/\(self.apiVersion)")!
        switch endpoint {
        case .entries:
            urlComponents.path = "\(urlComponents.path)/\(Endpoint.contenttype.pathComponent)/\(String(describing: parameters[QueryParameter.contentType]!))"
        default: break
        }
        urlComponents.path = "\(urlComponents.path)/\(endpoint.pathComponent)"

        if let uid = parameters[QueryParameter.uid] {
            urlComponents.path = "\(urlComponents.path)/\(uid)"
        }

        //To Remove not required parameters
        var queryParameter = parameters
        queryParameter.removeValue(forKey: QueryParameter.contentType)
        queryParameter.removeValue(forKey: QueryParameter.uid)

        if let query = parameters[QueryParameter.query] as? String {
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: QueryParameter.query, value: query))
            queryParameter.removeValue(forKey: QueryParameter.query)
            urlComponents.queryItems = queryItems
        }

        if !queryParameter.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "")
                + queryParameter.query()
            urlComponents.percentEncodedQuery = percentEncodedQuery
        }
        let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "")
            + "environment=\(self.environment)"
        urlComponents.percentEncodedQuery = percentEncodedQuery

        return urlComponents.url!
    }

    internal func fetch<ResourceType>(endpoint: Endpoint,
                                      cachePolicy: CachePolicy,
                                      parameters: Parameters = [:],
                                      then completion: @escaping ResultsHandler<ResourceType>)
        where ResourceType: Decodable {
        let url = self.url(endpoint: endpoint, parameters: parameters)
            self.fetchUrl(url,
                          cachePolicy: cachePolicy,
                          then: { (result: Result<Data, Error>, responseType: ResponseType) in
            switch result {
            case .success(let data):
                do {
                    let jsonParse = try self.jsonDecoder.decode(ResourceType.self, from: data)
                    completion(Result.success(jsonParse), responseType)
                } catch let error {
                    completion(Result.failure(error), responseType)
                }
            case .failure(let error):
                completion(Result.failure(error), responseType)
            }
        })
    }

    private func fetchUrl(_ url: URL, cachePolicy: CachePolicy, then completion: @escaping ResultsHandler<Data>) {
        var dataTask: URLSessionDataTask?
        let request = URLRequest(url: url)
        dataTask = urlSession.dataTask(with: request,
                                       completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        if cachePolicy == .networkElseCache,
                            self.canFullfillRequestWithCache(request) {
                            self.fullfillRequestWithCache(request, then: completion)
                            return
                        }
                        completion(Result.failure(
                            APIError.handleError(for: url,
                                                 jsonDecoder: self.jsonDecoder,
                                                 data: data,
                                                 response: response)),
                                   .network
                        )
                        return
                    }
                    let successMessage = "Success: 'GET' (\(response.statusCode)) \(url.absoluteString)"
                    ContentstackLogger.log(.info, message: successMessage)

                    URLCache.shared.storeCachedResponse(
                        CachedURLResponse(response: response,
                                          data: data),
                        for: request
                    )
                }
                completion(Result.success(data), .network)
                return
            }

            if let error = error {
                if self.cachePolicy == .networkElseCache,
                    self.canFullfillRequestWithCache(request) {
                    self.fullfillRequestWithCache(request, then: completion)
                    return
                }
                let errorMessage = """
                Errored: 'GET' \(url.absoluteString)
                Message: \(error.localizedDescription)
                """
                ContentstackLogger.log(.error, message: errorMessage)
                completion(Result.failure(error), .network)
                return
            }

        })
        performDataTask(dataTask!, request: request, cachePolicy: cachePolicy, then: completion)
    }

    private func performDataTask(_ dataTask: URLSessionDataTask,
                                 request: URLRequest,
                                 cachePolicy: CachePolicy,
                                 then completion: @escaping ResultsHandler<Data>) {
        switch cachePolicy {
        case .networkOnly:
            dataTask.resume()
        case .cacheOnly:
            fullfillRequestWithCache(request, then: completion)
        case .cacheElseNetwork:
            fullfillRequestWithCache(
            request
            ) { (cacheResult: Result<Data, Error>, responseType: ResponseType) in
                switch cacheResult {
                case Result.success(_):
                    completion(cacheResult, responseType)
                case Result.failure(_):
                    dataTask.resume()
                }
            }
        case .networkElseCache:
            dataTask.resume()
        case .cacheThenNetwork:
            fullfillRequestWithCache(
            request
            ) { (cacheResult: Result<Data, Error>, responseType: ResponseType) in
                completion(cacheResult, responseType)
                dataTask.resume()
            }
        }
    }
    //Cache handling methods
    private func fullfillRequestWithCache(_ request: URLRequest, then completion: @escaping ResultsHandler<Data>) {
        if let data = self.cachedResponse(for: request) {
            completion(Result.success(data), .cache)
            return
        }
        completion(Result.failure(SDKError.cacheError), .cache)
    }

    private func canFullfillRequestWithCache(_ request: URLRequest) -> Bool {
        return self.cachedResponse(for: request) != nil ? true : false
    }

    private func cachedResponse(for request: URLRequest) -> Data? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response.data
        }
        return nil
    }
}

extension Stack {

    /// The Initial Sync request performs a complete sync of your app data.
    /// It returns all the published entries and assets of the specified stack in response.
    /// The response also contains a `sync_token`, which you get in `SyncStack`,
    /// since this token is used to get subsequent delta updates later.
    ///
    /// - Parameters:
    ///   - syncStack: The relevant `SyncStack` to perform the subsequent sync on.
    ///   Defaults to a new empty instance of `SyncStack`.
    ///   -  syncTypes: `SyncableTypes` that can be sync.
    ///   - completion: A handler which will be called on completion of the operation.
    ///
    /// Example usage:
    ///```
    /// let stack = Contentstack.stack(apiKey: apiKey,
    ///             deliveryToken: deliveryToken,
    ///             environment: environment)
    ///
    /// stack.sync { (result: Result<SyncStack, Error>) in
    ///    switch result {
    ///    case .success(let syncStack):
    ///         let items = syncStack.items
    ///    case .failure(let error):
    ///         print(error)
    ///    }
    /// }
    ///```
    public func sync(_ syncStack: SyncStack = SyncStack(),
                     syncTypes: [SyncStack.SyncableTypes] = [.all],
                     then completion: @escaping (_ result: Result<SyncStack, Error>) -> Void) {
        var parameter = syncStack.parameter
        if syncStack.isInitialSync {
            for syncType in syncTypes {
                parameter = parameter + syncType.parameters
            }
        }
        let url = self.url(endpoint: SyncStack.endpoint, parameters: parameter)

        fetchUrl(url,
                 cachePolicy: .networkOnly) { (result: Result<Data, Error>, _: ResponseType) in
            switch result {
            case .success(let data):
                do {
                    let syncStack = try self.jsonDecoder.decode(SyncStack.self, from: data)
                    completion(.success(syncStack))
                    if  syncStack.hasMorePages {
                        self.sync(syncStack, then: completion)
                    }
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
