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
    
    // MARK: - EntryModel.toJSON() Tests

    // Decodes an entry's fields into a Codable model via JSONSerialization + JSONDecoder.
    private static func parseModel<T: Decodable>(_ model: [String: Any]) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: model)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    private struct ParsedEntry: Decodable {
        let uid: String
        let title: String
        let author_group: ParsedReferenceGroup
    }
    private struct ParsedReferenceGroup: Decodable {
        let show_author: Bool
        let authors: [ParsedReferencedEntry]
    }
    private struct ParsedReferencedEntry: Decodable {
        let uid: String
        let title: String
    }

    /// A reference field resolved (via include_all) to a full entry is decoded as an `EntryModel`
    /// inside `fields`, which is not JSON-native. `toJSON()` flattens it so it can be serialized.
    func testEntryModel_includeAll_referenceFieldIsEntry_parsesViaToJSON() throws {
        let apiResponseJSON = """
        {
            "uid": "mock_parent_uid",
            "title": "Blog Post",
            "locale": "en-us",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user",
            "updated_by": "mock_user",
            "author_group": {
                "show_author": true,
                "authors": [
                    {
                        "uid": "mock_referenced_uid",
                        "title": "Referenced Author Entry",
                        "locale": "en-us",
                        "created_at": "2024-01-01T00:00:00.000Z",
                        "updated_at": "2024-01-01T00:00:00.000Z",
                        "created_by": "mock_user",
                        "updated_by": "mock_user"
                    }
                ]
            }
        }
        """

        let data = apiResponseJSON.data(using: .utf8)!
        let entry = try JSONDecoder.dateDecodingStrategy().decode(EntryModel.self, from: data)

        // Reference field is resolved into an EntryModel inside fields.
        let group = entry.fields?["author_group"] as? [String: Any]
        let refArray = group?["authors"] as? [Any]
        XCTAssertTrue(refArray?.first is EntryModel)

        // Raw fields contain a Swift object, so they are not a valid JSON object.
        // (Avoid JSONSerialization.data on raw fields — it raises an uncatchable NSException.)
        XCTAssertFalse(JSONSerialization.isValidJSONObject(entry.fields ?? [:]))

        // toJSON() yields a valid JSON object that round-trips into a Codable struct.
        let normalized = entry.toJSON()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(normalized))

        let parsed: ParsedEntry? = DecodableTest.parseModel(normalized)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.uid, "mock_parent_uid")
        XCTAssertEqual(parsed?.author_group.show_author, true)
        XCTAssertEqual(parsed?.author_group.authors.first?.uid, "mock_referenced_uid")
        XCTAssertEqual(parsed?.author_group.authors.first?.title, "Referenced Author Entry")
    }

    // Codable models mirroring a 5-level chain: each level references the next.
    private struct DeepL1: Decodable { let uid: String; let level_2: [DeepL2] }
    private struct DeepL2: Decodable { let uid: String; let level_3: [DeepL3] }
    private struct DeepL3: Decodable { let uid: String; let level_4: [DeepL4] }
    private struct DeepL4: Decodable { let uid: String; let level_5: [DeepL5] }
    private struct DeepL5: Decodable { let uid: String; let title: String }

    /// Verifies toJSON() flattens references nested 5 levels deep (e.g. include_all_depth=5).
    /// The recursion follows the resolved object graph regardless of depth.
    func testEntryModel_toJSON_deeplyNestedReferences_5Levels() throws {
        // entry1 → entry2 → entry3 → entry4 → entry5, each resolved as a nested entry.
        let apiResponseJSON = """
        {
            "uid": "uid_1", "title": "Level 1", "locale": "en-us",
            "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user", "updated_by": "mock_user",
            "level_2": [{
                "uid": "uid_2", "title": "Level 2", "locale": "en-us",
                "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                "created_by": "mock_user", "updated_by": "mock_user",
                "level_3": [{
                    "uid": "uid_3", "title": "Level 3", "locale": "en-us",
                    "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                    "created_by": "mock_user", "updated_by": "mock_user",
                    "level_4": [{
                        "uid": "uid_4", "title": "Level 4", "locale": "en-us",
                        "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                        "created_by": "mock_user", "updated_by": "mock_user",
                        "level_5": [{
                            "uid": "uid_5", "title": "Level 5", "locale": "en-us",
                            "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                            "created_by": "mock_user", "updated_by": "mock_user"
                        }]
                    }]
                }]
            }]
        }
        """

        let data = apiResponseJSON.data(using: .utf8)!
        let entry = try JSONDecoder.dateDecodingStrategy().decode(EntryModel.self, from: data)

        // The deepest reference is decoded as an EntryModel, so raw fields are not serializable.
        XCTAssertFalse(JSONSerialization.isValidJSONObject(entry.fields ?? [:]))

        // toJSON() flattens all 5 levels into JSON-native types.
        let normalized = entry.toJSON()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(normalized))

        // Round-trip the full 5-level chain and assert the deepest entry's data survived.
        let parsed: DeepL1? = DecodableTest.parseModel(normalized)
        XCTAssertNotNil(parsed)
        let level5 = parsed?
            .level_2.first?
            .level_3.first?
            .level_4.first?
            .level_5.first
        XCTAssertEqual(level5?.uid, "uid_5")
        XCTAssertEqual(level5?.title, "Level 5")
    }

    /// An asset (file/image) field also decodes into a non-JSON `AssetModel` inside fields.
    /// toJSON() must flatten it the same way it flattens nested entries.
    func testEntryModel_toJSON_assetReference_isJSONSerializable() throws {
        let apiResponseJSON = """
        {
            "uid": "mock_parent_uid", "title": "Entry With Image", "locale": "en-us",
            "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user", "updated_by": "mock_user",
            "hero_image": {
                "uid": "mock_asset_uid",
                "title": "hero.png",
                "filename": "hero.png",
                "url": "https://images.contentstack.io/mock/hero.png",
                "content_type": "image/png",
                "file_size": "20480",
                "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                "created_by": "mock_user", "updated_by": "mock_user"
            }
        }
        """

        let data = apiResponseJSON.data(using: .utf8)!
        let entry = try JSONDecoder.dateDecodingStrategy().decode(EntryModel.self, from: data)

        XCTAssertTrue(entry.fields?["hero_image"] is AssetModel)
        XCTAssertFalse(JSONSerialization.isValidJSONObject(entry.fields ?? [:]))

        let normalized = entry.toJSON()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(normalized))

        let asset = normalized["hero_image"] as? [String: Any]
        XCTAssertEqual(asset?["uid"] as? String, "mock_asset_uid")
        XCTAssertEqual(asset?["url"] as? String, "https://images.contentstack.io/mock/hero.png")
    }

    /// A standalone asset (e.g. fetched via the assets endpoint) round-trips through toJSON().
    func testAssetModel_toJSON_isJSONSerializable() throws {
        let apiResponseJSON = """
        {
            "uid": "mock_asset_uid",
            "title": "hero.png",
            "filename": "hero.png",
            "url": "https://images.contentstack.io/mock/hero.png",
            "content_type": "image/png",
            "file_size": "20480",
            "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user", "updated_by": "mock_user"
        }
        """

        let data = apiResponseJSON.data(using: .utf8)!
        let asset = try JSONDecoder.dateDecodingStrategy().decode(AssetModel.self, from: data)

        let normalized = asset.toJSON()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(normalized))
        XCTAssertEqual(normalized["uid"] as? String, "mock_asset_uid")
        XCTAssertEqual(normalized["filename"] as? String, "hero.png")
        XCTAssertEqual(normalized["url"] as? String, "https://images.contentstack.io/mock/hero.png")
        XCTAssertNoThrow(try JSONSerialization.data(withJSONObject: normalized))
    }

    /// An entry containing BOTH a nested entry reference and an asset reference.
    func testEntryModel_toJSON_mixedEntryAndAssetReferences() throws {
        let apiResponseJSON = """
        {
            "uid": "mock_parent_uid", "title": "Mixed Entry", "locale": "en-us",
            "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user", "updated_by": "mock_user",
            "related_entry": [{
                "uid": "mock_ref_uid", "title": "Related", "locale": "en-us",
                "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                "created_by": "mock_user", "updated_by": "mock_user"
            }],
            "attachment": {
                "uid": "mock_asset_uid", "title": "file.pdf", "filename": "file.pdf",
                "url": "https://images.contentstack.io/mock/file.pdf", "content_type": "application/pdf",
                "file_size": "10240",
                "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
                "created_by": "mock_user", "updated_by": "mock_user"
            }
        }
        """

        let data = apiResponseJSON.data(using: .utf8)!
        let entry = try JSONDecoder.dateDecodingStrategy().decode(EntryModel.self, from: data)

        // Both reference types present as non-JSON Swift objects.
        let relatedArray = entry.fields?["related_entry"] as? [Any]
        XCTAssertTrue(relatedArray?.first is EntryModel)
        XCTAssertTrue(entry.fields?["attachment"] is AssetModel)
        XCTAssertFalse(JSONSerialization.isValidJSONObject(entry.fields ?? [:]))

        let normalized = entry.toJSON()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(normalized))

        let related = (normalized["related_entry"] as? [Any])?.first as? [String: Any]
        XCTAssertEqual(related?["uid"] as? String, "mock_ref_uid")
        let attachment = normalized["attachment"] as? [String: Any]
        XCTAssertEqual(attachment?["uid"] as? String, "mock_asset_uid")
    }

    /// toJSON() on an entry with no resolved references is a no-op that stays serializable.
    func testEntryModel_toJSON_noReferences_isUnchangedAndSerializable() throws {
        let apiResponseJSON = """
        {
            "uid": "mock_uid", "title": "Plain Entry", "locale": "en-us",
            "created_at": "2024-01-01T00:00:00.000Z", "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user", "updated_by": "mock_user",
            "body": "Some text", "views": 10
        }
        """

        let data = apiResponseJSON.data(using: .utf8)!
        let entry = try JSONDecoder.dateDecodingStrategy().decode(EntryModel.self, from: data)

        // No references → raw fields are already JSON-native.
        XCTAssertTrue(JSONSerialization.isValidJSONObject(entry.fields ?? [:]))

        let normalized = entry.toJSON()
        XCTAssertTrue(JSONSerialization.isValidJSONObject(normalized))
        XCTAssertEqual(normalized["body"] as? String, "Some text")
        XCTAssertEqual(normalized["views"] as? Int, 10)
    }

    func testEntryModel_toJSON_preservesScalarValues() throws {
        let jsonString = """
        {
            "uid": "mock_uid",
            "title": "Test Entry",
            "locale": "en-us",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z",
            "created_by": "mock_user",
            "updated_by": "mock_user",
            "is_active": true,
            "count": 42,
            "name": "Test"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let entry = try JSONDecoder.dateDecodingStrategy().decode(EntryModel.self, from: data)
        let json = entry.toJSON()

        XCTAssertEqual(json["uid"] as? String, "mock_uid")
        XCTAssertEqual(json["title"] as? String, "Test Entry")
        XCTAssertEqual(json["is_active"] as? Bool, true)
        XCTAssertEqual(json["count"] as? Int, 42)
        XCTAssertEqual(json["name"] as? String, "Test")
        XCTAssertNoThrow(try JSONSerialization.data(withJSONObject: json))
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
        ("testKeyedDecodingContainer_decodeMixedTypes", testKeyedDecodingContainer_decodeMixedTypes),
        ("testEntryModel_includeAll_referenceFieldIsEntry_parsesViaToJSON", testEntryModel_includeAll_referenceFieldIsEntry_parsesViaToJSON),
        ("testEntryModel_toJSON_deeplyNestedReferences_5Levels", testEntryModel_toJSON_deeplyNestedReferences_5Levels),
        ("testEntryModel_toJSON_assetReference_isJSONSerializable", testEntryModel_toJSON_assetReference_isJSONSerializable),
        ("testAssetModel_toJSON_isJSONSerializable", testAssetModel_toJSON_isJSONSerializable),
        ("testEntryModel_toJSON_mixedEntryAndAssetReferences", testEntryModel_toJSON_mixedEntryAndAssetReferences),
        ("testEntryModel_toJSON_noReferences_isUnchangedAndSerializable", testEntryModel_toJSON_noReferences_isUnchangedAndSerializable),
        ("testEntryModel_toJSON_preservesScalarValues", testEntryModel_toJSON_preservesScalarValues)
    ]
}

