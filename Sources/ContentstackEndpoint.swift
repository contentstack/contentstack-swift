//
//  ContentstackEndpoint.swift
//  Contentstack
//
//  Resolves Contentstack API endpoints for any region and service without
//  hardcoding host strings. Region data is fetched from the Contentstack
//  artifacts registry at runtime and cached (in memory and on disk).
//

import Foundation

/// Errors thrown while resolving a Contentstack endpoint.
public enum EndpointError: Error, CustomStringConvertible, LocalizedError, Equatable {
    /// The region argument was empty (or whitespace only).
    case emptyRegion
    /// The region did not match any known canonical ID or alias.
    case invalidRegion(String)
    /// The requested service key was not present for the resolved region.
    case serviceNotFound(service: String, region: String)
    /// The regions registry could not be loaded from cache and could not be downloaded.
    case regionsUnavailable

    public var description: String {
        switch self {
        case .emptyRegion:
            return "Empty region provided. Please provide a valid region."
        case .invalidRegion(let region):
            return "Invalid region: \(region)"
        case .serviceNotFound(let service, let region):
            return "Service \"\(service)\" not found for region \"\(region)\""
        case .regionsUnavailable:
            return "Could not load the regions registry from cache and could not download it from "
                + "\(ContentstackEndpoint.regionsURL). Check network access."
        }
    }

    public var errorDescription: String? { description }
}

/// Resolves Contentstack API endpoints for any region and service.
///
/// Resolution chain:
/// 1. **In-memory cache** — populated on the first successful load and reused for the process lifetime.
/// 2. **On-disk cache** — a previously downloaded copy stored in the caches directory, so subsequent
///    processes do not need to hit the network.
/// 3. **Live download** — fetched from ``regionsURL`` and written to the on-disk cache. Attempted at
///    most once per process.
///
/// The registry is **not** bundled with the SDK; it is downloaded on first use. Region matching is
/// case-insensitive and treats `-` and `_` as equivalent separators, so `"AZURE_NA"`, `"azure-na"`,
/// and `"Azure_NA"` all resolve to the same region.
///
/// ```swift
/// let url  = try ContentstackEndpoint.getContentstackEndpoint("eu", service: "contentDelivery")
/// // → "https://eu-cdn.contentstack.com"
///
/// let host = try ContentstackEndpoint.getContentstackEndpoint("eu", service: "contentDelivery", omitHttps: true)
/// // → "eu-cdn.contentstack.com"
///
/// let all  = try ContentstackEndpoint.getContentstackEndpoints("azure-na")
/// // → ["contentDelivery": "https://azure-na-cdn.contentstack.com", ...]
/// ```
public enum ContentstackEndpoint {

    /// The live registry URL used to download region data.
    public static let regionsURL = "https://artifacts.contentstack.com/regions.json"

    private static var regionsCache: [[String: Any]]?
    // Ensures the live download is attempted at most once per process so that genuinely
    // invalid region strings do not trigger repeated network calls.
    private static var liveRefreshDone = false
    // Allows tests to disable the network fallback.
    static var isLiveRefreshEnabled = true
    // Allows tests to bypass the on-disk cache so the download path can be exercised deterministically.
    static var isDiskCacheEnabled = true
    // The session used to download the registry. Overridable so tests can inject a DVR session.
    static var session: URLSession = .shared
    private static let lock = NSLock()

    // MARK: - Public API

    /// Returns the URL for the given region and service.
    ///
    /// - Parameters:
    ///   - region: region ID or alias (e.g. `"na"`, `"eu"`, `"azure-na"`).
    ///   - service: service key (e.g. `"contentDelivery"`, `"contentManagement"`).
    ///   - omitHttps: when `true`, returns the bare host without the `https://` prefix.
    ///   - allowDownload: when `true` (default), the registry may be downloaded if not already
    ///     cached. Pass `false` to resolve only from cache without any network access.
    /// - Returns: the full URL (or bare host when `omitHttps` is `true`).
    /// - Throws: ``EndpointError`` if the region or service is not recognised, or the registry is
    ///   unavailable.
    public static func getContentstackEndpoint(_ region: String,
                                               service: String,
                                               omitHttps: Bool = false,
                                               allowDownload: Bool = true) throws -> String {
        if region.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw EndpointError.emptyRegion
        }
        lock.lock()
        defer { lock.unlock() }
        let row = try resolveRegion(region, allowDownload: allowDownload)
        guard let endpoints = row["endpoints"] as? [String: Any] else {
            throw EndpointError.serviceNotFound(service: service, region: region)
        }
        guard let url = endpoints[service] as? String else {
            throw EndpointError.serviceNotFound(service: service, region: region)
        }
        return omitHttps ? stripHttps(url) : url
    }

    /// Returns all endpoints for the given region as a map of service key to URL.
    ///
    /// - Parameters:
    ///   - region: region ID or alias.
    ///   - omitHttps: when `true`, returns bare hosts without the `https://` prefix.
    ///   - allowDownload: when `true` (default), the registry may be downloaded if not already cached.
    /// - Returns: map of service key → URL (or bare host).
    /// - Throws: ``EndpointError`` if the region is not recognised, or the registry is unavailable.
    public static func getContentstackEndpoints(_ region: String,
                                                omitHttps: Bool = false,
                                                allowDownload: Bool = true) throws -> [String: String] {
        if region.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw EndpointError.emptyRegion
        }
        lock.lock()
        defer { lock.unlock() }
        let row = try resolveRegion(region, allowDownload: allowDownload)
        guard let endpoints = row["endpoints"] as? [String: Any] else {
            throw EndpointError.invalidRegion(region)
        }
        var result = [String: String]()
        for (key, value) in endpoints {
            if let url = value as? String {
                result[key] = omitHttps ? stripHttps(url) : url
            }
        }
        return result
    }

    /// Resets the in-memory cache and the live-refresh flag. Intended for testing only.
    static func resetCache() {
        lock.lock()
        defer { lock.unlock() }
        regionsCache = nil
        liveRefreshDone = false
    }

    // MARK: - Internals (callers must hold `lock`)

    /// Resolution chain: cache / disk, then a one-time live refresh when the region is absent and
    /// downloads are permitted.
    private static func resolveRegion(_ region: String, allowDownload: Bool) throws -> [String: Any] {
        let regions = try loadRegions(allowDownload: allowDownload)
        do {
            return try findRegion(regions, region)
        } catch let notFound {
            // Region absent from the cached data — attempt one live refresh in case Contentstack
            // added a region since the cache was written.
            if allowDownload, !liveRefreshDone, isLiveRefreshEnabled,
               let fresh = tryLiveRefresh(), let row = try? findRegion(fresh, region) {
                return row
            }
            throw notFound
        }
    }

    /// Loads regions from the in-memory cache, the on-disk cache, or a live download (in that order).
    private static func loadRegions(allowDownload: Bool) throws -> [[String: Any]] {
        if let cache = regionsCache {
            return cache
        }
        if let data = diskCacheData(), let regions = parseRegions(data) {
            regionsCache = regions
            return regions
        }
        if allowDownload, let downloaded = tryLiveRefresh() {
            return downloaded
        }
        throw EndpointError.regionsUnavailable
    }

    /// Attempts a one-time HTTP fetch of ``regionsURL``. Returns the parsed regions on success, or
    /// `nil` if skipped/unavailable. Updates the in-memory cache and the on-disk cache on success.
    private static func tryLiveRefresh() -> [[String: Any]]? {
        if liveRefreshDone || !isLiveRefreshEnabled {
            return regionsCache
        }
        liveRefreshDone = true
        guard let url = URL(string: regionsURL) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let semaphore = DispatchSemaphore(value: 0)
        var fetchedData: Data?
        let task = session.dataTask(with: request) { data, _, _ in
            fetchedData = data
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 12)

        guard let data = fetchedData, let regions = parseRegions(data) else { return nil }
        regionsCache = regions
        if isDiskCacheEnabled, let cacheURL = diskCacheURL {
            try? data.write(to: cacheURL, options: .atomic)
        }
        return regions
    }

    private static var diskCacheURL: URL? {
        guard let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent("com.contentstack.swift.regions.json")
    }

    private static func diskCacheData() -> Data? {
        guard isDiskCacheEnabled, let url = diskCacheURL else { return nil }
        return try? Data(contentsOf: url)
    }

    private static func parseRegions(_ data: Data) -> [[String: Any]]? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let regions = object["regions"] as? [[String: Any]] else {
            return nil
        }
        return regions
    }

    private static func findRegion(_ regions: [[String: Any]], _ region: String) throws -> [String: Any] {
        let normalized = normalize(region)

        // Pass 1: match canonical id.
        for row in regions {
            if let id = row["id"] as? String, normalize(id) == normalized {
                return row
            }
        }
        // Pass 2: match aliases (case-insensitive, `_` == `-`).
        for row in regions {
            guard let aliases = row["alias"] as? [String] else { continue }
            for alias in aliases where normalize(alias) == normalized {
                return row
            }
        }
        throw EndpointError.invalidRegion(region)
    }

    private static func normalize(_ value: String) -> String {
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
    }

    private static func stripHttps(_ url: String) -> String {
        if let range = url.range(of: "^https?://", options: .regularExpression) {
            return String(url[range.upperBound...])
        }
        return url
    }
}
