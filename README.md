# StreakManager

A simple iOS app for tracking your gym streak with a calendar view and an accompanying Home Screen widget.

## Features

- Daily gym visit logging with one-tap undo
- Current streak counter with flame badge
- Monthly calendar view highlighting visited days
- Home Screen widget (small and medium) showing streak and today’s status
- Local persistence using SwiftData with App Group sharing for widget updates

## Tech Stack

- SwiftUI
- SwiftData
- WidgetKit
- App Intents (Control Widget sample)

## Installation

```bash
git clone <repo-url>
cd StreakManager-1
open StreakManager.xcodeproj
```

In Xcode:

1. Set your Team under Signing & Capabilities for both the app and widget targets.
2. Ensure the App Group identifier (group.streakmanager) is enabled for both targets.
3. Build and run on a simulator or device.

## Widget Setup

The widget reads shared data via an App Group container and refreshes at midnight to keep the streak accurate. Add the widget from the iOS Home Screen widget gallery and choose the size you prefer.

## Data Model

Each gym visit is stored as a date-only entry (midnight) to ensure streak calculations remain consistent.

## Notes

- The control widget included is a template example and is not wired to the app’s data.
- No network access is required; all data is stored locally on-device.

