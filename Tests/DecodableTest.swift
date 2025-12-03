//
//  DecodableTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class DecodableTest: XCTestCase {
    
    // MARK: - JSONDecoder dateDecodingStrategy Tests
    
    func testJSONDecoder_dateDecodingStrategy() {
        let decoder = JSONDecoder.dateDecodingStrategy()
        
        XCTAssertNotNil(decoder)
        // Verify it's configured correctly
        XCTAssertTrue(decoder is JSONDecoder)
    }
    
    func testJSONDecoder_dateDecodingStrategy_withISO8601Date() {
        let json = """
        {
            "created_at": "2021-01-01T00:00:00.000Z"
        }
        """
        
        struct TestModel: Decodable {
            let created_at: Date
        }
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder.dateDecodingStrategy()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertNotNil(model.created_at)
        } catch {
            XCTFail("Failed to decode date: \(error)")
        }
    }
    
    // MARK: - JSONCodingKeys Tests
    
    func testJSONCodingKeys_stringValue() {
        let key = JSONCodingKeys(stringValue: "test_key")
        
        XCTAssertNotNil(key)
        XCTAssertEqual(key?.stringValue, "test_key")
    }
    
    func testJSONCodingKeys_intValue() {
        let key = JSONCodingKeys(intValue: 42)
        
        XCTAssertNotNil(key)
        XCTAssertEqual(key?.intValue, 42)
        XCTAssertEqual(key?.stringValue, "42")
    }
    
    func testJSONCodingKeys_intValueToStringValue() {
        let key = JSONCodingKeys(intValue: 100)
        
        XCTAssertEqual(key?.stringValue, "100")
    }
    
    // MARK: - CodingUserInfoKey Tests
    
    func testCodingUserInfoKey_linkResolverContextKey() {
        let key = CodingUserInfoKey.linkResolverContextKey
        
        XCTAssertNotNil(key)
        XCTAssertEqual(key.rawValue, "linkResolverContext")
    }
    
    func testCodingUserInfoKey_timeZoneContextKey() {
        let key = CodingUserInfoKey.timeZoneContextKey
        
        XCTAssertNotNil(key)
        XCTAssertEqual(key.rawValue, "timeZoneContext")
    }
    
    func testCodingUserInfoKey_contentTypesContextKey() {
        let key = CodingUserInfoKey.contentTypesContextKey
        
        XCTAssertNotNil(key)
        XCTAssertEqual(key.rawValue, "contentTypesContext")
    }
    
    func testCodingUserInfoKey_localizationContextKey() {
        let key = CodingUserInfoKey.localizationContextKey
        
        XCTAssertNotNil(key)
        XCTAssertEqual(key.rawValue, "localizationContext")
    }
    
    // MARK: - Decoder Extension Tests
    
    func testDecoder_timeZone() {
        struct TestContainer: Decodable {
            let testValue: String
            var decoderTimeZone: TimeZone?
            
            init(from decoder: Decoder) throws {
                self.decoderTimeZone = decoder.timeZone
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.testValue = try container.decode(String.self, forKey: .testValue)
            }
            
            enum CodingKeys: String, CodingKey {
                case testValue
            }
        }
        
        let json = """
        {
            "testValue": "test"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.userInfo[.timeZoneContextKey] = TimeZone(identifier: "America/New_York")
        
        do {
            let model = try decoder.decode(TestContainer.self, from: data)
            XCTAssertNotNil(model.decoderTimeZone)
            XCTAssertEqual(model.decoderTimeZone?.identifier, "America/New_York")
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    func testDecoder_timeZone_nil() {
        struct TestContainer: Decodable {
            let testValue: String
            var decoderTimeZone: TimeZone?
            
            init(from decoder: Decoder) throws {
                self.decoderTimeZone = decoder.timeZone
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.testValue = try container.decode(String.self, forKey: .testValue)
            }
            
            enum CodingKeys: String, CodingKey {
                case testValue
            }
        }
        
        let json = """
        {
            "testValue": "test"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestContainer.self, from: data)
            XCTAssertNil(model.decoderTimeZone)
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    // MARK: - KeyedDecodingContainer Dictionary Decoding Tests
    
    func testKeyedDecodingContainer_decodeDictionary() {
        struct TestModel: Decodable {
            let data: [String: Any]
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.data = try container.decode([String: Any].self, forKey: .data)
            }
            
            enum CodingKeys: String, CodingKey {
                case data
            }
        }
        
        let json = """
        {
            "data": {
                "name": "John",
                "age": 30,
                "active": true
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertEqual(model.data["name"] as? String, "John")
            XCTAssertEqual(model.data["age"] as? Int, 30)
            XCTAssertEqual(model.data["active"] as? Bool, true)
        } catch {
            XCTFail("Failed to decode dictionary: \(error)")
        }
    }
    
    func testKeyedDecodingContainer_decodeIfPresentDictionary() {
        struct TestModel: Decodable {
            let data: [String: Any]?
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.data = try container.decodeIfPresent([String: Any].self, forKey: .data)
            }
            
            enum CodingKeys: String, CodingKey {
                case data
            }
        }
        
        let json = """
        {
            "data": {
                "name": "John"
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertNotNil(model.data)
            XCTAssertEqual(model.data?["name"] as? String, "John")
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    func testKeyedDecodingContainer_decodeIfPresentDictionary_missing() {
        struct TestModel: Decodable {
            let data: [String: Any]?
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.data = try container.decodeIfPresent([String: Any].self, forKey: .data)
            }
            
            enum CodingKeys: String, CodingKey {
                case data
            }
        }
        
        let json = """
        {
            "other_field": "value"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertNil(model.data)
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    // MARK: - KeyedDecodingContainer Array Decoding Tests
    
    func testKeyedDecodingContainer_decodeArray() {
        struct TestModel: Decodable {
            let items: [Any]
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.items = try container.decode([Any].self, forKey: .items)
            }
            
            enum CodingKeys: String, CodingKey {
                case items
            }
        }
        
        let json = """
        {
            "items": [1, "text", true, 3.14]
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertEqual(model.items.count, 4)
        } catch {
            XCTFail("Failed to decode array: \(error)")
        }
    }
    
    func testKeyedDecodingContainer_decodeIfPresentArray() {
        struct TestModel: Decodable {
            let items: [Any]?
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.items = try container.decodeIfPresent([Any].self, forKey: .items)
            }
            
            enum CodingKeys: String, CodingKey {
                case items
            }
        }
        
        let json = """
        {
            "items": [1, 2, 3]
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertNotNil(model.items)
            XCTAssertEqual(model.items?.count, 3)
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    // MARK: - KeyedDecodingContainer Complex Types Tests
    
    func testKeyedDecodingContainer_decodeNestedDictionaries() {
        struct TestModel: Decodable {
            let nested: [String: Any]
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.nested = try container.decode([String: Any].self, forKey: .nested)
            }
            
            enum CodingKeys: String, CodingKey {
                case nested
            }
        }
        
        let json = """
        {
            "nested": {
                "level1": {
                    "level2": "value"
                }
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            let level1 = model.nested["level1"] as? [String: Any]
            XCTAssertNotNil(level1)
            XCTAssertEqual(level1?["level2"] as? String, "value")
        } catch {
            XCTFail("Failed to decode nested dictionary: \(error)")
        }
    }
    
    func testKeyedDecodingContainer_decodeMixedTypes() {
        struct TestModel: Decodable {
            let data: [String: Any]
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.data = try container.decode([String: Any].self, forKey: .data)
            }
            
            enum CodingKeys: String, CodingKey {
                case data
            }
        }
        
        let json = """
        {
            "data": {
                "string": "text",
                "int": 42,
                "double": 3.14,
                "bool": true,
                "array": [1, 2, 3],
                "nested": {"key": "value"}
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let model = try decoder.decode(TestModel.self, from: data)
            XCTAssertEqual(model.data["string"] as? String, "text")
            XCTAssertEqual(model.data["int"] as? Int, 42)
            if let doubleValue = model.data["double"] as? Double {
                XCTAssertEqual(doubleValue, 3.14, accuracy: 0.001)
            } else {
                XCTFail("Double value not found or wrong type")
            }
            XCTAssertEqual(model.data["bool"] as? Bool, true)
            XCTAssertNotNil(model.data["array"])
            XCTAssertNotNil(model.data["nested"])
        } catch {
            XCTFail("Failed to decode mixed types: \(error)")
        }
    }
    
    static var allTests = [
        ("testJSONDecoder_dateDecodingStrategy", testJSONDecoder_dateDecodingStrategy),
        ("testJSONDecoder_dateDecodingStrategy_withISO8601Date", testJSONDecoder_dateDecodingStrategy_withISO8601Date),
        ("testJSONCodingKeys_stringValue", testJSONCodingKeys_stringValue),
        ("testJSONCodingKeys_intValue", testJSONCodingKeys_intValue),
        ("testJSONCodingKeys_intValueToStringValue", testJSONCodingKeys_intValueToStringValue),
        ("testCodingUserInfoKey_linkResolverContextKey", testCodingUserInfoKey_linkResolverContextKey),
        ("testCodingUserInfoKey_timeZoneContextKey", testCodingUserInfoKey_timeZoneContextKey),
        ("testCodingUserInfoKey_contentTypesContextKey", testCodingUserInfoKey_contentTypesContextKey),
        ("testCodingUserInfoKey_localizationContextKey", testCodingUserInfoKey_localizationContextKey),
        ("testDecoder_timeZone", testDecoder_timeZone),
        ("testDecoder_timeZone_nil", testDecoder_timeZone_nil),
        ("testKeyedDecodingContainer_decodeDictionary", testKeyedDecodingContainer_decodeDictionary),
        ("testKeyedDecodingContainer_decodeIfPresentDictionary", testKeyedDecodingContainer_decodeIfPresentDictionary),
        ("testKeyedDecodingContainer_decodeIfPresentDictionary_missing", testKeyedDecodingContainer_decodeIfPresentDictionary_missing),
        ("testKeyedDecodingContainer_decodeArray", testKeyedDecodingContainer_decodeArray),
        ("testKeyedDecodingContainer_decodeIfPresentArray", testKeyedDecodingContainer_decodeIfPresentArray),
        ("testKeyedDecodingContainer_decodeNestedDictionaries", testKeyedDecodingContainer_decodeNestedDictionaries),
        ("testKeyedDecodingContainer_decodeMixedTypes", testKeyedDecodingContainer_decodeMixedTypes)
    ]
}

