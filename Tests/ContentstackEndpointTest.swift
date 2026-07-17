//
//  ContentstackEndpointTest.swift
//  Contentstack
//
//  Tests for region/service endpoint resolution via ContentstackEndpoint.
//

import XCTest
import DVR
@testable import ContentstackSwift

class ContentstackEndpointTest: XCTestCase {

    override func setUp() {
        super.setUp()
        ContentstackEndpoint.resetCache()
        // Resolve region data offline by replaying the recorded artifacts.contentstack.com response
        // through a DVR cassette, exactly like the other API tests. Disable the on-disk cache so the
        // download path is exercised deterministically every run.
        ContentstackEndpoint.isDiskCacheEnabled = false
        ContentstackEndpoint.isLiveRefreshEnabled = true
        let dvrSession = DVR.Session(cassetteName: "Regions")
        dvrSession.recordingEnabled = false
        ContentstackEndpoint.session = dvrSession
    }

    override func tearDown() {
        ContentstackEndpoint.resetCache()
        ContentstackEndpoint.session = .shared
        ContentstackEndpoint.isDiskCacheEnabled = true
        ContentstackEndpoint.isLiveRefreshEnabled = true
        super.tearDown()
    }

    // MARK: - Basic resolution

    func testContentDelivery_na() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("na", service: "contentDelivery"),
                       "https://cdn.contentstack.io")
    }

    func testContentDelivery_eu() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("eu", service: "contentDelivery"),
                       "https://eu-cdn.contentstack.com")
    }

    func testContentManagement_azureNa() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("azure-na", service: "contentManagement"),
                       "https://azure-na-api.contentstack.com")
    }

    func testGraphqlDelivery_gcpEu() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("gcp-eu", service: "graphqlDelivery"),
                       "https://gcp-eu-graphql.contentstack.com")
    }

    // MARK: - omitHttps

    func testOmitHttps_stripsScheme() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("eu", service: "contentDelivery", omitHttps: true),
                       "eu-cdn.contentstack.com")
    }

    func testOmitHttps_naDefault() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("na", service: "contentDelivery", omitHttps: true),
                       "cdn.contentstack.io")
    }

    // MARK: - Alias / normalization

    func testAliases_resolveToNa() throws {
        for alias in ["na", "us", "aws-na", "aws_na", "NA", "US", "AWS-NA", "AWS_NA"] {
            XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint(alias, service: "contentDelivery"),
                           "https://cdn.contentstack.io", "alias \(alias) should resolve to na")
        }
    }

    func testAliases_underscoreEqualsHyphen() throws {
        let hyphen = try ContentstackEndpoint.getContentstackEndpoint("azure-na", service: "contentDelivery")
        let underscore = try ContentstackEndpoint.getContentstackEndpoint("azure_na", service: "contentDelivery")
        XCTAssertEqual(hyphen, underscore)
    }

    func testWhitespaceTrimmed() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("  eu  ", service: "contentDelivery"),
                       "https://eu-cdn.contentstack.com")
    }

    // MARK: - All endpoints

    func testGetAllEndpoints_containsKeys() throws {
        let all = try ContentstackEndpoint.getContentstackEndpoints("eu")
        XCTAssertEqual(all["contentDelivery"], "https://eu-cdn.contentstack.com")
        XCTAssertEqual(all["contentManagement"], "https://eu-api.contentstack.com")
        XCTAssertEqual(all["auth"], "https://eu-auth-api.contentstack.com")
    }

    func testGetAllEndpoints_omitHttps() throws {
        let all = try ContentstackEndpoint.getContentstackEndpoints("eu", omitHttps: true)
        XCTAssertEqual(all["contentDelivery"], "eu-cdn.contentstack.com")
    }

    func testAssetManagement_naOnly() throws {
        XCTAssertEqual(try ContentstackEndpoint.getContentstackEndpoint("na", service: "assetManagement"),
                       "https://am-api.contentstack.com")
        // assetManagement is not present for eu.
        XCTAssertThrowsError(try ContentstackEndpoint.getContentstackEndpoint("eu", service: "assetManagement"))
    }

    // MARK: - Errors

    func testEmptyRegionThrows() {
        XCTAssertThrowsError(try ContentstackEndpoint.getContentstackEndpoint("", service: "contentDelivery")) { error in
            XCTAssertEqual(error as? EndpointError, .emptyRegion)
        }
    }

    func testUnknownServiceThrows() {
        XCTAssertThrowsError(try ContentstackEndpoint.getContentstackEndpoint("na", service: "cms")) { error in
            XCTAssertEqual(error as? EndpointError, .serviceNotFound(service: "cms", region: "na"))
        }
    }

    func testInvalidRegionThrows() {
        XCTAssertThrowsError(try ContentstackEndpoint.getContentstackEndpoint("asia-pacific", service: "contentDelivery")) { error in
            XCTAssertEqual(error as? EndpointError, .invalidRegion("asia-pacific"))
        }
    }

    // MARK: - Contentstack convenience proxy

    func testContentstackProxy_matchesEndpoint() throws {
        XCTAssertEqual(try Contentstack.getContentstackEndpoint(region: "eu", service: "contentDelivery"),
                       try ContentstackEndpoint.getContentstackEndpoint("eu", service: "contentDelivery"))
    }

    func testContentstackProxy_allEndpoints() throws {
        let all = try Contentstack.getContentstackEndpoints(region: "na")
        XCTAssertEqual(all["contentDelivery"], "https://cdn.contentstack.io")
    }

    // MARK: - Stack host wiring

    func testStackHost_resolvedFromRegion() {
        let regions: [(ContentstackRegion, String)] = [
            (.us, "cdn.contentstack.io"),
            (.eu, "eu-cdn.contentstack.com"),
            (.au, "au-cdn.contentstack.com"),
            (.azure_na, "azure-na-cdn.contentstack.com"),
            (.azure_eu, "azure-eu-cdn.contentstack.com"),
            (.gcp_na, "gcp-na-cdn.contentstack.com"),
            (.gcp_eu, "gcp-eu-cdn.contentstack.com")
        ]
        for (region, expectedHost) in regions {
            let stack = makeStackSut(region: region)
            XCTAssertEqual(stack.host, expectedHost, "host for region \(region)")
        }
    }

    func testStackHost_explicitHostWins() {
        let stack = makeStackSut(region: .eu, host: "custom.example.com")
        XCTAssertEqual(stack.host, "custom.example.com")
    }

    static var allTests = [
        ("testContentDelivery_na", testContentDelivery_na),
        ("testContentDelivery_eu", testContentDelivery_eu),
        ("testContentManagement_azureNa", testContentManagement_azureNa),
        ("testGraphqlDelivery_gcpEu", testGraphqlDelivery_gcpEu),
        ("testOmitHttps_stripsScheme", testOmitHttps_stripsScheme),
        ("testOmitHttps_naDefault", testOmitHttps_naDefault),
        ("testAliases_resolveToNa", testAliases_resolveToNa),
        ("testAliases_underscoreEqualsHyphen", testAliases_underscoreEqualsHyphen),
        ("testWhitespaceTrimmed", testWhitespaceTrimmed),
        ("testGetAllEndpoints_containsKeys", testGetAllEndpoints_containsKeys),
        ("testGetAllEndpoints_omitHttps", testGetAllEndpoints_omitHttps),
        ("testAssetManagement_naOnly", testAssetManagement_naOnly),
        ("testEmptyRegionThrows", testEmptyRegionThrows),
        ("testUnknownServiceThrows", testUnknownServiceThrows),
        ("testInvalidRegionThrows", testInvalidRegionThrows),
        ("testContentstackProxy_matchesEndpoint", testContentstackProxy_matchesEndpoint),
        ("testContentstackProxy_allEndpoints", testContentstackProxy_allEndpoints),
        ("testStackHost_resolvedFromRegion", testStackHost_resolvedFromRegion),
        ("testStackHost_explicitHostWins", testStackHost_explicitHostWins)
    ]
}
