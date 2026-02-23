//
//  BeaconTrigger.swift
//  ShortKit
//
//  Created by 심재빈 on 11/27/25.
//

import Foundation

struct BeaconTrigger: Identifiable, Codable, Equatable {
    enum EventType: String, CaseIterable, Codable, Identifiable {
        case enter
        case exit

        var id: String { rawValue }

        var label: String {
            switch self {
            case .enter: return "근처에 다가왔을 때"
            case .exit: return "멀어졌을 때"
            }
        }
    }

    let id: UUID
    var name: String
    var uuidString: String
    var major: Int?
    var minor: Int?
    var eventType: EventType
    var urlString: String

    init(id: UUID = UUID(), name: String, uuidString: String, major: Int?, minor: Int?, eventType: EventType, urlString: String) {
        self.id = id
        self.name = name
        self.uuidString = uuidString
        self.major = major
        self.minor = minor
        self.eventType = eventType
        self.urlString = urlString
    }
}
