//
//  Session.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 21/04/20.
//

import Foundation
import Contentstack
class Session: EntryDecodable {
    public enum FieldKeys: String, CodingKey {
        case title, uid, locale, type, room, speakers, track
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case sessionId = "session_id"
        case desc = "description"
        case isPopular = "is_popular"
        case sessionTime = "session_time"
    }
    var locale: String
    var title: String
    var uid: String
    var createdAt: Date?
    var updatedAt: Date?
    var createdBy: String?
    var updatedBy: String?
    var sessionId: Int
    var desc: String
    var type: String
    var isPopular: Bool
    var track: [String]
    var speakers: [String]
    var room: [String]
    var sessionTime: DateTime?

    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: FieldKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        createdBy = try? container.decode(String.self, forKey: .createdBy)
        updatedBy = try? container.decode(String.self, forKey: .updatedBy)
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        locale = try container.decode(String.self, forKey: .locale)
        sessionId = try container.decode(Int.self, forKey: .sessionId)
        desc = try container.decode(String.self, forKey: .desc)
        type = try container.decode(String.self, forKey: .type)
        isPopular = try container.decode(Bool.self, forKey: .isPopular)
        track = try container.decode([String].self, forKey: .track)
        speakers = try container.decode([String].self, forKey: .speakers)
        room = try container.decode([String].self, forKey: .room)
        desc = try container.decode(String.self, forKey: .desc)
        sessionTime = try container.decodeIfPresent(DateTime.self, forKey: .sessionTime)
    }
}

class DateTime: Decodable {
    var startTime: Date?
    var endTime: Date?
    
    public enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
    }
    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try? container.decode(Date.self, forKey: .startTime)
        endTime = try? container.decode(Date.self, forKey: .endTime)
    }
}


class Track: EntryDecodable, ContentTypeIncludable {
    var contentType: ContentTypeModel?
    
    var locale: String
    var createdBy: String?
    var updatedBy: String?
    var title: String
    var uid: String
    var createdAt: Date?
    var updatedAt: Date?
    var sortOrder: String
    var trackColor: String
    var desc: String

    public enum FieldKeys: String, CodingKey {
        case title, uid, locale
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case desc = "description"
        case trackColor = "track_color"
        case sortOrder = "sort_order"

    }
    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: FieldKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        createdBy = try? container.decode(String.self, forKey: .createdBy)
        updatedBy = try? container.decode(String.self, forKey: .updatedBy)
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        locale = try container.decode(String.self, forKey: .locale)
        desc = try container.decode(String.self, forKey: .locale)
        trackColor = try container.decode(String.self, forKey: .trackColor)
        sortOrder = try container.decode(String.self, forKey: .sortOrder)
    }
}


class SessionWithTrackReference: EntryDecodable, ContentTypeIncludable {
    var contentType: ContentTypeModel?
    
    public enum FieldKeys: String, CodingKey {
        case title, uid, locale, type, room, speakers, track
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case sessionId = "session_id"
        case desc = "description"
        case isPopular = "is_popular"
        case sessionTime = "session_time"
    }
    var locale: String
    var title: String
    var uid: String
    var createdAt: Date?
    var updatedAt: Date?
    var createdBy: String?
    var updatedBy: String?
    var sessionId: Int
    var desc: String
    var type: String
    var isPopular: Bool
    var track: [Track]
    var speakers: [String]
    var room: [String]
    var sessionTime: DateTime?

    public required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: FieldKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        createdBy = try? container.decode(String.self, forKey: .createdBy)
        updatedBy = try? container.decode(String.self, forKey: .updatedBy)
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        locale = try container.decode(String.self, forKey: .locale)
        sessionId = try container.decode(Int.self, forKey: .sessionId)
        desc = try container.decode(String.self, forKey: .desc)
        type = try container.decode(String.self, forKey: .type)
        isPopular = try container.decode(Bool.self, forKey: .isPopular)
        track = try container.decode([Track].self, forKey: .track)
        speakers = try container.decode([String].self, forKey: .speakers)
        room = try container.decode([String].self, forKey: .room)
        desc = try container.decode(String.self, forKey: .desc)
        sessionTime = try container.decodeIfPresent(DateTime.self, forKey: .sessionTime)
    }
}
