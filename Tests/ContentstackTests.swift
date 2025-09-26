import XCTest
@testable import ContentstackSwift

final class ContentstackTests: XCTestCase {

    func testStackToken_RequireFieldProvided_ReturnStack() {
        let apiKey = "api_key"
        let deliveryToken = "delivery_token"
        let environment = "environment"
        let stack = makeStackSut(apiKey: apiKey, deliveryToken: deliveryToken, environment: environment)
        XCTAssertNotNil(stack)
        XCTAssertEqual(stack.apiKey, apiKey)
        XCTAssertEqual(stack.deliveryToken, deliveryToken)
        XCTAssertEqual(stack.environment, environment)
    }

    func testStack_DefaultHostRegion_ReturnStackWithDefaultValue () {
        let stack = makeStackSut()

        XCTAssertEqual(stack.host, Host.delivery)
        XCTAssertEqual(stack.region, ContentstackRegion.us)
        XCTAssertNil(stack.branch)
    }

    func testStack_EUHostRegion_ReturnStackWithEUValue () {
        let stack = makeStackSut(region: .eu)
        XCTAssertEqual(stack.host, "eu-cdn.contentstack.com")
        XCTAssertEqual(stack.region, ContentstackRegion.eu)
        XCTAssertNil(stack.branch)
    }
    
    func testStack_AZURE_NAHostRegion_ReturnStackWithEUValue () {
        let stack = makeStackSut(region: .azure_na)
        XCTAssertEqual(stack.host, "azure-na-cdn.contentstack.com")
        XCTAssertEqual(stack.region, ContentstackRegion.azure_na)
        XCTAssertNil(stack.branch)
    }
    
    func testStack_GCP_NAHostRegion_ReturnStackWithGCPValue () {
        let stack = makeStackSut(region: .gcp_na)
        XCTAssertEqual(stack.host, "gcp-na-cdn.contentstack.com")
        XCTAssertEqual(stack.region, ContentstackRegion.gcp_na)
        XCTAssertNil(stack.branch)
    }
    
    func testStack_AUHostRegion_ReturnStackWithAUValue () {
        let stack = makeStackSut(region: .au)
        XCTAssertEqual(stack.host, "au-cdn.contentstack.com")
        XCTAssertEqual(stack.region, ContentstackRegion.au)
        XCTAssertNil(stack.branch)
    }

    func testStack_NewHost_ReturnStackWithNewHost () {
        let host = "api.contentstack.com"
        let stack = makeStackSut(host: host)
        XCTAssertEqual(stack.host, host)
    }


    func testStack_DecodingStrategy_tobesetToJsonDecoder () {
        var config = ContentstackConfig.default
        config.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom(Date.variableISO8601Strategy)
        let stack = makeStackSut(config: config)
        XCTAssertNotNil(stack.jsonDecoder.dateDecodingStrategy)
    }

    static var allTests = [
        ("testStackToken_RequireFieldProvided_ReturnStack", testStackToken_RequireFieldProvided_ReturnStack),
        ("testStack_DefaultHostRegion_ReturnStackWithDefaultValue",
         testStack_DefaultHostRegion_ReturnStackWithDefaultValue),
        ("testStack_EUHostRegion_ReturnStackWithEUValue", testStack_EUHostRegion_ReturnStackWithEUValue),
        ("testStack_NewHost_ReturnStackWithNewHost", testStack_NewHost_ReturnStackWithNewHost)
    ]
}
