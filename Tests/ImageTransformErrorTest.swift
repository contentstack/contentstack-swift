//
//  ImageTransformErrorTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class ImageTransformErrorTest: XCTestCase {
    
    // MARK: - ImageTransformError Tests
    
    func testImageTransformError_initialization() {
        let errorMessage = "Invalid image URL"
        let error = ImageTransformError(message: errorMessage)
        
        XCTAssertEqual(error.message, errorMessage)
    }
    
    func testImageTransformError_debugDescription() {
        let errorMessage = "Transform operation failed"
        let error = ImageTransformError(message: errorMessage)
        
        XCTAssertEqual(error.debugDescription, errorMessage)
    }
    
    func testImageTransformError_asError() {
        let errorMessage = "Test error"
        let error: Error = ImageTransformError(message: errorMessage)
        
        XCTAssertTrue(error is ImageTransformError)
        if let transformError = error as? ImageTransformError {
            XCTAssertEqual(transformError.message, errorMessage)
        } else {
            XCTFail("Error should be of type ImageTransformError")
        }
    }
    
    func testImageTransformError_emptyMessage() {
        let error = ImageTransformError(message: "")
        
        XCTAssertEqual(error.message, "")
        XCTAssertEqual(error.debugDescription, "")
    }
    
    func testImageTransformError_longMessage() {
        let longMessage = String(repeating: "a", count: 1000)
        let error = ImageTransformError(message: longMessage)
        
        XCTAssertEqual(error.message, longMessage)
        XCTAssertEqual(error.debugDescription, longMessage)
    }
    
    func testImageTransformError_specialCharacters() {
        let errorMessage = "Error with special chars: @#$%^&*()"
        let error = ImageTransformError(message: errorMessage)
        
        XCTAssertEqual(error.message, errorMessage)
    }
    
    static var allTests = [
        ("testImageTransformError_initialization", testImageTransformError_initialization),
        ("testImageTransformError_debugDescription", testImageTransformError_debugDescription),
        ("testImageTransformError_asError", testImageTransformError_asError),
        ("testImageTransformError_emptyMessage", testImageTransformError_emptyMessage),
        ("testImageTransformError_longMessage", testImageTransformError_longMessage),
        ("testImageTransformError_specialCharacters", testImageTransformError_specialCharacters)
    ]
}

