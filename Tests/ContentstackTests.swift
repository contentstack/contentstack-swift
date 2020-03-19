import XCTest
@testable import Contentstack

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
    }

    func testStack_EUHostRegion_ReturnStackWithEUValue () {
        let stack = makeStackSut(region: .eu)
        XCTAssertEqual(stack.host, "cdn.contentstack.com")
        XCTAssertEqual(stack.region, ContentstackRegion.eu)
    }

    func testStack_NewHost_ReturnStackWithNewHost () {
        let host = "api.contentstack.com"
        let stack = makeStackSut(host: host)
        XCTAssertEqual(stack.host, host)
    }

    static var allTests = [
        ("testStackToken_RequireFieldProvided_ReturnStack", testStackToken_RequireFieldProvided_ReturnStack),
        ("testStack_DefaultHostRegion_ReturnStackWithDefaultValue",
         testStack_DefaultHostRegion_ReturnStackWithDefaultValue),
        ("testStack_EUHostRegion_ReturnStackWithEUValue", testStack_EUHostRegion_ReturnStackWithEUValue),
        ("testStack_NewHost_ReturnStackWithNewHost", testStack_NewHost_ReturnStackWithNewHost)
    ]
}
