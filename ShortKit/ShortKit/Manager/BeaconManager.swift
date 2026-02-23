//
//  BeaconManager.swift
//  ShortKit
//
//  Created by 심재빈 on 11/27/25.
//

import UIKit
import SwiftUI
import CoreLocation
import UserNotifications
import Combine


// MARK: - Beacon Manager

final class BeaconManager: NSObject, ObservableObject {
    static let shared = BeaconManager()

    @Published private(set) var triggers: [BeaconTrigger] = []
    @Published private(set) var registeredBeacons: [RegisteredBeacon] = []

    struct RegisteredBeacon: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let uuidString: String
        let major: Int?
        let minor: Int?
    }

    private let locationManager = CLLocationManager()
    private let storageKey = "BeaconTriggersStorageKey"

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        loadTriggers()
        requestPermissionsIfNeeded()
        reconfigureMonitoring()
    }

    func allTriggers() -> [BeaconTrigger] {
        triggers
    }

    func allRegisteredBeacons() -> [RegisteredBeacon] {
        registeredBeacons
    }

    func addRegisteredBeacon(_ beacon: RegisteredBeacon) {
        registeredBeacons.append(beacon)
    }

    func removeRegisteredBeacons(at offsets: IndexSet) {
        registeredBeacons.remove(atOffsets: offsets)
    }

    func addTrigger(_ trigger: BeaconTrigger) {
        triggers.append(trigger)
        saveTriggers()
        reconfigureMonitoring()
    }

    func removeTriggers(at offsets: IndexSet) {
        let removed = offsets.map { triggers[$0] }
        triggers.remove(atOffsets: offsets)
        saveTriggers()
        stopMonitoring(for: removed)
    }

    // MARK: Storage

    private func loadTriggers() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([BeaconTrigger].self, from: data)
            self.triggers = decoded
        } catch {
            print("[BeaconManager] Failed to decode triggers: \(error)")
        }
    }

    private func saveTriggers() {
        do {
            let data = try JSONEncoder().encode(triggers)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("[BeaconManager] Failed to encode triggers: \(error)")
        }
    }

    // MARK: Permissions

    private func requestPermissionsIfNeeded() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("[BeaconManager] Notification auth error: \(error)")
                    } else {
                        print("[BeaconManager] Notification auth granted: \(granted)")
                    }
                }
            }
        }
    }

    // MARK: Monitoring

    private func reconfigureMonitoring() {
        for region in locationManager.monitoredRegions {
            if let beaconRegion = region as? CLBeaconRegion {
                locationManager.stopMonitoring(for: beaconRegion)
            }
        }

        for trigger in triggers {
            configureRegion(uuidString: trigger.uuidString, major: trigger.major, minor: trigger.minor, identifier: trigger.id.uuidString)
        }
    }

    private func configureRegion(uuidString: String, major: Int?, minor: Int?, identifier: String) {
        guard let uuid = UUID(uuidString: uuidString) else { return }

        let region: CLBeaconRegion
        if let major = major, let minor = minor {
            region = CLBeaconRegion(uuid: uuid, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
        } else if let major = major {
            region = CLBeaconRegion(uuid: uuid, major: CLBeaconMajorValue(major), identifier: identifier)
        } else {
            region = CLBeaconRegion(uuid: uuid, identifier: identifier)
        }

        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true

        locationManager.startMonitoring(for: region)
    }

    private func stopMonitoring(for triggers: [BeaconTrigger]) {
        let ids = Set(triggers.map { $0.id.uuidString })
        for region in locationManager.monitoredRegions {
            guard let beaconRegion = region as? CLBeaconRegion else { continue }
            if ids.contains(beaconRegion.identifier) {
                locationManager.stopMonitoring(for: beaconRegion)
            }
        }
    }

    private func handleEvent(for region: CLRegion, isEnter: Bool) {
        guard let beaconRegion = region as? CLBeaconRegion else { return }
        guard let trigger = triggers.first(where: { $0.id.uuidString == beaconRegion.identifier }) else { return }

        switch trigger.eventType {
        case .enter where isEnter:
            fire(trigger: trigger)
        case .exit where !isEnter:
            fire(trigger: trigger)
        default:
            break
        }
    }

    private func fire(trigger: BeaconTrigger) {
        // 1) Local notification
        scheduleNotification(for: trigger)

        // 2) Optional: background URL call (best effort)
        if let url = URL(string: trigger.urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    print("[BeaconManager] URL call failed: \(error)")
                } else {
                    print("[BeaconManager] URL triggered for beacon: \(trigger.name)")
                }
            }
            task.resume()
        }
    }

    private func scheduleNotification(for trigger: BeaconTrigger) {
        let content = UNMutableNotificationContent()
        content.title = trigger.name
        content.body = "비콘 이벤트 감지됨 · URL 실행을 완료했어요."
        content.sound = .default

        let request = UNNotificationRequest(identifier: "beacon-\(trigger.id.uuidString)-\(Date().timeIntervalSince1970)",
                                            content: content,
                                            trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[BeaconManager] Failed to schedule notification: \(error)")
            }
        }
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            reconfigureMonitoring()
        case .denied, .restricted:
            print("[BeaconManager] Location authorization denied or restricted.")
        case .authorizedWhenInUse:
            print("[BeaconManager] authorizedWhenInUse — 'Always' authorization is recommended for reliable background behavior.")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("[BeaconManager] didEnterRegion: \(region.identifier)")
        handleEvent(for: region, isEnter: true)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("[BeaconManager] didExitRegion: \(region.identifier)")
        handleEvent(for: region, isEnter: false)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[BeaconManager] Monitoring failed for region: \(region?.identifier ?? "nil") error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[BeaconManager] Location manager failed: \(error)")
    }
}
