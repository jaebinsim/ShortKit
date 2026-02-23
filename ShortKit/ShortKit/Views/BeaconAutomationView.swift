//
//  BeaconAutomationView.swift
//  ShortKit
//
//  Created by 심재빈 on 11/27/25.
//

import UIKit
import SwiftUI
import CoreLocation
import UserNotifications
import Combine

struct BeaconAutomationView: View {
    @ObservedObject var beaconManager: BeaconManager

    @State private var beaconName: String = ""
    @State private var beaconUUIDString: String = ""
    @State private var beaconMajorString: String = ""
    @State private var beaconMinorString: String = ""

    @State private var triggerName: String = ""
    @State private var selectedBeacon: BeaconManager.RegisteredBeacon?
    @State private var eventType: BeaconTrigger.EventType = .enter
    @State private var urlString: String = ""

    var body: some View {
        List {
            Section("등록된 비콘") {
                if beaconManager.allRegisteredBeacons().isEmpty {
                    Text("아직 등록된 비콘이 없어요.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(beaconManager.allRegisteredBeacons()) { beacon in
                        VStack(alignment: .leading, spacing: 4) {
                            Label(beacon.name, systemImage: "dot.radiowaves.left.and.right")

                            Text("UUID: \(beacon.uuidString)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let major = beacon.major {
                                Text("Major: \(major)" + (beacon.minor != nil ? ", Minor: \(beacon.minor!)" : ""))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        beaconManager.removeRegisteredBeacons(at: offsets)
                    }
                }
            }

            Section("등록된 비콘 자동화") {
                if beaconManager.allTriggers().isEmpty {
                    Text("아직 등록된 비콘 자동화가 없어요.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(beaconManager.allTriggers()) { trigger in
                        VStack(alignment: .leading, spacing: 4) {
                            Label(trigger.name, systemImage: "bolt.badge.clock")

                            Text("UUID: \(trigger.uuidString)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let major = trigger.major {
                                Text("Major: \(major)" + (trigger.minor != nil ? ", Minor: \(trigger.minor!)" : ""))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Text("이벤트: \(trigger.eventType.label)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Text("URL: \(trigger.urlString)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .onDelete { offsets in
                        beaconManager.removeTriggers(at: offsets)
                    }
                }
            }

            Section("새 비콘 등록") {
                TextField("비콘 이름 (예: 현관 비콘)", text: $beaconName)

                TextField("Beacon UUID", text: $beaconUUIDString)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()

                HStack {
                    TextField("Major (선택)", text: $beaconMajorString)
                        .keyboardType(.numberPad)
                    TextField("Minor (선택)", text: $beaconMinorString)
                        .keyboardType(.numberPad)
                }

                Button {
                    addBeacon()
                } label: {
                    Label("비콘 추가", systemImage: "antenna.radiowaves.left.and.right")
                }
                .disabled(!canAddBeacon)
            }

            Section("새 자동화 추가") {
                TextField("자동화 이름 (예: 집 도착 시 문 열기)", text: $triggerName)

                Picker("사용할 비콘", selection: $selectedBeacon) {
                    Text("비콘 선택").tag(Optional<BeaconManager.RegisteredBeacon>.none)

                    ForEach(beaconManager.allRegisteredBeacons()) { beacon in
                        Text(beacon.name)
                            .tag(Optional(beacon))
                    }
                }

                Picker("이벤트", selection: $eventType) {
                    ForEach(BeaconTrigger.EventType.allCases) { type in
                        Text(type.label).tag(type)
                    }
                }

                TextField("실행할 URL (예: https://example.com/hook)", text: $urlString)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button {
                    addTrigger()
                } label: {
                    Label("자동화 추가", systemImage: "plus.circle.fill")
                }
                .disabled(!canAddTrigger)
            }
        }
        .navigationTitle("비콘 자동화")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canAddBeacon: Bool {
        guard !beaconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard UUID(uuidString: beaconUUIDString) != nil else { return false }
        return true
    }

    private var canAddTrigger: Bool {
        guard !triggerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard selectedBeacon != nil else { return false }
        guard URL(string: urlString) != nil else { return false }
        return true
    }

    private func addTrigger() {
        guard let beacon = selectedBeacon else { return }

        let trigger = BeaconTrigger(
            name: triggerName.trimmingCharacters(in: .whitespacesAndNewlines),
            uuidString: beacon.uuidString.trimmingCharacters(in: .whitespacesAndNewlines),
            major: beacon.major,
            minor: beacon.minor,
            eventType: eventType,
            urlString: urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        beaconManager.addTrigger(trigger)

        triggerName = ""
        urlString = ""
        eventType = .enter
        selectedBeacon = nil
    }

    private func addBeacon() {
        let major = Int(beaconMajorString)
        let minor = Int(beaconMinorString)

        let beacon = BeaconManager.RegisteredBeacon(
            name: beaconName.trimmingCharacters(in: .whitespacesAndNewlines),
            uuidString: beaconUUIDString.trimmingCharacters(in: .whitespacesAndNewlines),
            major: major,
            minor: minor
        )

        beaconManager.addRegisteredBeacon(beacon)

        beaconName = ""
        beaconUUIDString = ""
        beaconMajorString = ""
        beaconMinorString = ""
    }
}
