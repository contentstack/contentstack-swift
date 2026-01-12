//
//  ErrorTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class ErrorTest: XCTestCase {
    
    // MARK: - SDKError Tests
    
    func testSDKError_invalidHTTPResponse() {
        let response = URLResponse(url: URL(string: "https://example.com")!,
                                   mimeType: nil,
                                   expectedContentLength: 0,
                                   textEncodingName: nil)
        let error = SDKError.invalidHTTPResponse(response: response)
        
        XCTAssertTrue(error.message.contains("corrupted HTTP response"))
        XCTAssertEqual(error.debugDescription, error.message)
    }
    
    func testSDKError_invalidHTTPResponse_nil() {
        let error = SDKError.invalidHTTPResponse(response: nil)
        
        XCTAssertTrue(error.message.contains("corrupted HTTP response"))
        XCTAssertTrue(error.message.contains("nil"))
    }
    
    func testSDKError_invalidURL() {
        let invalidURLString = "not a valid url"
        let error = SDKError.invalidURL(string: invalidURLString)
        
        XCTAssertEqual(error.message, invalidURLString)
        XCTAssertEqual(error.debugDescription, invalidURLString)
    }
    
    func testSDKError_invalidUID() {
        let invalidUID = "invalid_uid_123"
        let error = SDKError.invalidUID(string: invalidUID)
        
        XCTAssertEqual(error.message, "The uid \(invalidUID) is not valid.")
        XCTAssertTrue(error.message.contains(invalidUID))
    }
    
    func testSDKError_unparseableJSON() {
        let data = "invalid json".data(using: .utf8)
        let errorMessage = "Failed to parse JSON"
        let error = SDKError.unparseableJSON(data: data, errorMessage: errorMessage)
        
        XCTAssertEqual(error.message, errorMessage)
    }
    
    func testSDKError_unparseableJSON_nilData() {
        let errorMessage = "Failed to parse JSON with nil data"
        let error = SDKError.unparseableJSON(data: nil, errorMessage: errorMessage)
        
        XCTAssertEqual(error.message, errorMessage)
    }
    
    func testSDKError_stackError() {
        let error = SDKError.stackError
        
        XCTAssertEqual(error.message, "The Stack not found.")
    }
    
    func testSDKError_syncError() {
        let error = SDKError.syncError
        
        XCTAssertEqual(error.message, "The Stack sync faile to retrive.")
    }
    
    func testSDKError_cacheError() {
        let error = SDKError.cacheError
        
        XCTAssertEqual(error.message, "Failed to retreive data from Cache.")
    }
    
    // MARK: - APIError Tests
    
    func testAPIError_decoding() {
        let json = """
        {
            "error_message": "The access token is invalid.",
            "error_code": 104,
            "errors": {
                "access_token": ["Invalid access token"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            XCTAssertEqual(apiError.errorMessage, "The access token is invalid.")
            XCTAssertEqual(apiError.errorCode, 104)
            XCTAssertNotNil(apiError.errorInfo)
            XCTAssertEqual(apiError.errorInfo.deliveryToken?.first, "Invalid access token")
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_withAPIKey() {
        let json = """
        {
            "error_message": "Invalid API key",
            "error_code": 105,
            "errors": {
                "api_key": ["The API key is not valid"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            XCTAssertEqual(apiError.errorMessage, "Invalid API key")
            XCTAssertEqual(apiError.errorCode, 105)
            XCTAssertNotNil(apiError.errorInfo.apiKey)
            XCTAssertEqual(apiError.errorInfo.apiKey?.first, "The API key is not valid")
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_withEnvironment() {
        let json = """
        {
            "error_message": "Invalid environment",
            "error_code": 106,
            "errors": {
                "environment": ["The environment is not valid"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            XCTAssertNotNil(apiError.errorInfo.environment)
            XCTAssertEqual(apiError.errorInfo.environment?.first, "The environment is not valid")
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_withUID() {
        let json = """
        {
            "error_message": "Invalid UID",
            "error_code": 107,
            "errors": {
                "uid": ["The UID is not valid"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            XCTAssertNotNil(apiError.errorInfo.uid)
            XCTAssertEqual(apiError.errorInfo.uid?.first, "The UID is not valid")
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_withAuthtoken() {
        let json = """
        {
            "error_message": "Invalid authtoken",
            "error_code": 108,
            "errors": {
                "authtoken": ["The authtoken is not valid"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            // authtoken should map to apiKey
            XCTAssertNotNil(apiError.errorInfo.apiKey)
            XCTAssertEqual(apiError.errorInfo.apiKey?.first, "The authtoken is not valid")
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_debugDescription() {
        let json = """
        {
            "error_message": "Test error",
            "error_code": 999,
            "errors": {
                "api_key": ["Error 1"],
                "access_token": ["Error 2"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            apiError.statusCode = 400
            
            let debugDescription = apiError.debugDescription
            XCTAssertTrue(debugDescription.contains("HTTP status code 400"))
            XCTAssertTrue(debugDescription.contains("Test error"))
            XCTAssertTrue(debugDescription.contains("999"))
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_errorInfo_debugDescription() {
        let json = """
        {
            "error_message": "Multiple errors",
            "error_code": 999,
            "errors": {
                "api_key": ["API Key Error"],
                "access_token": ["Token Error"],
                "environment": ["Env Error"],
                "uid": ["UID Error"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: data)
            let errorInfoDebug = apiError.errorInfo.debugDescription
            
            XCTAssertTrue(errorInfoDebug.contains("API Key"))
            XCTAssertTrue(errorInfoDebug.contains("Delivery token"))
            XCTAssertTrue(errorInfoDebug.contains("Environment"))
            XCTAssertTrue(errorInfoDebug.contains("UID"))
        } catch {
            XCTFail("Failed to decode APIError: \(error)")
        }
    }
    
    func testAPIError_errorWithDecoder() {
        let json = """
        {
            "error_message": "Test error",
            "error_code": 999,
            "errors": {
                "api_key": ["Error"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let apiError = APIError.error(with: decoder, data: data, statusCode: 400)
        
        XCTAssertNotNil(apiError)
        XCTAssertEqual(apiError?.errorMessage, "Test error")
        XCTAssertEqual(apiError?.statusCode, 400)
    }
    
    func testAPIError_errorWithDecoder_invalidData() {
        let invalidData = "not valid json".data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let apiError = APIError.error(with: decoder, data: invalidData, statusCode: 400)
        
        XCTAssertNil(apiError)
    }
    
    func testAPIError_errorWithDecoder_missingErrorInfo() {
        let json = """
        {
            "error_message": "Test error",
            "error_code": 999
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // This should fail because errorInfo is required
        do {
            _ = try decoder.decode(APIError.self, from: data)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected to fail
            XCTAssertTrue(true)
        }
    }
    
    func testAPIError_handleError_withValidAPIError() {
        let json = """
        {
            "error_message": "Test API error",
            "error_code": 999,
            "errors": {
                "api_key": ["Error"]
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let url = URL(string: "https://api.contentstack.io/v3/content_types")!
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!
        
        let error = APIError.handleError(for: url, jsonDecoder: decoder, data: data, response: response)
        
        XCTAssertTrue(error is APIError)
        if let apiError = error as? APIError {
            XCTAssertEqual(apiError.errorMessage, "Test API error")
            XCTAssertEqual(apiError.statusCode, 400)
        }
    }
    
    func testAPIError_handleError_withInvalidData() {
        let invalidData = "not valid json".data(using: .utf8)!
        let decoder = JSONDecoder()
        let url = URL(string: "https://api.contentstack.io/v3/content_types")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        let error = APIError.handleError(for: url, jsonDecoder: decoder, data: invalidData, response: response)
        
        XCTAssertTrue(error is SDKError)
        if let sdkError = error as? SDKError {
            if case let .unparseableJSON(_, errorMessage) = sdkError {
                XCTAssertTrue(errorMessage.contains("unable to parse"))
            } else {
                XCTFail("Expected unparseableJSON error")
            }
        }
    }
    
    static var allTests = [
        ("testSDKError_invalidHTTPResponse", testSDKError_invalidHTTPResponse),
        ("testSDKError_invalidHTTPResponse_nil", testSDKError_invalidHTTPResponse_nil),
        ("testSDKError_invalidURL", testSDKError_invalidURL),
        ("testSDKError_invalidUID", testSDKError_invalidUID),
        ("testSDKError_unparseableJSON", testSDKError_unparseableJSON),
        ("testSDKError_unparseableJSON_nilData", testSDKError_unparseableJSON_nilData),
        ("testSDKError_stackError", testSDKError_stackError),
        ("testSDKError_syncError", testSDKError_syncError),
        ("testSDKError_cacheError", testSDKError_cacheError),
        ("testAPIError_decoding", testAPIError_decoding),
        ("testAPIError_withAPIKey", testAPIError_withAPIKey),
        ("testAPIError_withEnvironment", testAPIError_withEnvironment),
        ("testAPIError_withUID", testAPIError_withUID),
        ("testAPIError_withAuthtoken", testAPIError_withAuthtoken),
        ("testAPIError_debugDescription", testAPIError_debugDescription),
        ("testAPIError_errorInfo_debugDescription", testAPIError_errorInfo_debugDescription),
        ("testAPIError_errorWithDecoder", testAPIError_errorWithDecoder),
        ("testAPIError_errorWithDecoder_invalidData", testAPIError_errorWithDecoder_invalidData),
        ("testAPIError_errorWithDecoder_missingErrorInfo", testAPIError_errorWithDecoder_missingErrorInfo),
        ("testAPIError_handleError_withValidAPIError", testAPIError_handleError_withValidAPIError),
        ("testAPIError_handleError_withInvalidData", testAPIError_handleError_withInvalidData)
    ]
}

