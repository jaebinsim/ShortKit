# ShortKit

🇰🇷 [한국어 README 보기](README.ko.md)

[![Platform: iOS](https://img.shields.io/badge/platform-iOS%2016%2B-black.svg)](#requirements--permissions)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-orange.svg)](https://developer.apple.com/xcode/swiftui/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

ShortKit is an iOS application that uses iBeacon events (Enter/Exit) as triggers to automatically execute a pre-configured **URL (Webhook / Control URL)**.  
It aims to make “precise location-based automation” (e.g., approaching your front door) easy to set up with minimal configuration.

---

## Screenshots

<p align="center">
  <img src="docs/images/screenshot-1.png" width="45%" alt="ShortKit Screenshot 1" />
  <img src="docs/images/screenshot-2.png" width="45%" alt="ShortKit Screenshot 2" />
</p>

> The UUID/Major/Minor values and automation names shown in the screenshots are demo-only dummy data.

---

This app was designed as a trigger-focused companion app for the [**IntentCP**](https://github.com/jaebinsim/IntentCP) project.

- **ShortKit (Trigger Plane)**: Detects physical proximity (beacon) events and calls a URL
- **IntentCP (Control Plane)**: Receives the URL call, analyzes intent, and executes local actions

By separating “physical event detection” from “actual action execution,” this structure enables more reliable location-based automation.

That said, ShortKit is not tied to any specific server. At its core, it is a **general-purpose trigger app that calls arbitrary URLs (webhooks) based on iBeacon events**.  
IntentCP is simply one representative integration. As long as a URL endpoint is available, ShortKit can be connected to Home Assistant, IFTTT, personal servers (FastAPI), internal systems, logging/monitoring endpoints, and more.

Example extensions include:
- Room/door-level automation triggers (lights, air conditioner, security mode)
- Check-in and event logging based on entry/exit (Notion/Sheets/DB)
- Triggering server jobs when entering a specific area (PC lock, start/stop workflows, notifications)
- Calling deployment/test hooks using physical triggers in dev or internal environments

---

## Why iBeacon

For scenarios such as door automation that require a narrow trigger range (“right in front of the door”), iBeacon is often more suitable than GPS/geofencing.

- **Precise trigger range**: Enables “near a specific point” behavior even in indoor/corridor environments
- **Background-friendly**: Uses iOS Region Monitoring to detect Enter/Exit even when the app is inactive
- **Low power**: BLE (Bluetooth Low Energy) reduces battery overhead compared to frequent polling approaches

---

## Key Features

- **iBeacon registration and management**
  - Register beacons using UUID and optional Major/Minor values
- **Automation (Trigger) creation**
  - Configure a URL to run for Enter/Exit events (currently GET)
- **Execution feedback**
  - Local notifications when events are detected and the URL is triggered
- **General compatibility**
  - Works with any service that supports webhooks (IntentCP, Home Assistant, IFTTT, personal servers, etc.)

---

## Use Cases

- **Door lock automation near the entrance**
  - Call a Control URL on Enter → server validates conditions → performs open/close
- **Home arrival automation**
  - Trigger preset endpoints for lights/AC/humidifier, etc.
- **Logging / tracking**
  - Send Enter/Exit events to the server for logging (including Notion/Sheets integrations)

---

## Requirements & Permissions

### Requirements
- iOS 16.0+
- A beacon transmitter (physical beacon hardware or an app/device that can transmit iBeacon)
- A real iOS device (simulator support for beacon detection is limited)

### Permissions
- **Location**: “Always Allow” is recommended for background detection
- **Notifications**: Required for execution feedback
- **Background Modes**: Enable `Location updates` in Xcode (recommended)

---

## Roadmap

- Conditional logic improvements
  - More granular conditions based on Proximity (Immediate/Near/Far)
  - (Optional) Threshold-based conditions using RSSI / estimated distance (Accuracy)
    - e.g., only trigger when RSSI is above -65 dBm / estimated distance is within 1.5 m
  - Duplicate-trigger prevention (cooldown/debounce) and retry/backoff policies

- Action expansion
  - Support POST in addition to GET
  - Custom HTTP headers/body configuration
  - Multiple actions per trigger (chaining)

- Security and safety measures (recommended for door automation)
  - Do not open immediately on Enter; send only a `pre-open` state to the server
  - Confirm “open” only when additional conditions are satisfied on the server
    - e.g., confirm only when the phone is connected to the home Wi-Fi SSID
    - e.g., confirm after additional device authentication/token verification
  - Add API Key/Token-based authentication headers for URL calls (client/server)

---