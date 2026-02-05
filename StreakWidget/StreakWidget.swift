//
//  StreakWidget.swift
//  StreakWidget
//
//  Created by Godbless Mensah Osei  on 28/01/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
// This holds the data for a single "snapshot" of your widget

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let loggedToday: Bool
}

// MARK: - Timeline Provider
// This tells iOS what to display and when to refresh

struct StreakTimelineProvider: TimelineProvider {
    
    // Placeholder shown while widget loads
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, streak: 0, loggedToday: false)
    }
    
    // Quick snapshot for widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(date: .now, streak: 7, loggedToday: true)
        completion(entry)
    }
    
    // The actual timeline - this is where real data comes in
        func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
            Task { @MainActor in
                // Fetch current data from shared storage
                let streak = StreakDataManager.shared.currentStreak()
                let loggedToday = StreakDataManager.shared.hasVisitedToday()
                
                let entry = StreakEntry(
                    date: .now,
                    streak: streak,
                    loggedToday: loggedToday
                )
                
                // Refresh at midnight (when streak status could change)
                let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
                
                let timeline = Timeline(entries: [entry], policy: .after(midnight))
                completion(timeline)
            }
        }
}

// MARK: - Widget Views

struct StreakWidgetView: View {
    var entry: StreakEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }
    
    private var smallWidget: some View {
        VStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
            
            Text("\(entry.streak)")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(entry.streak == 1 ? "day" : "days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private var mediumWidget: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Gym Streak")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.streak)")
                        .font(.system(size: 56, weight: .bold))
                    Text(entry.streak == 1 ? "day" : "days")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                if entry.loggedToday {
                    Label("Logged today", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("Not logged yet", systemImage: "circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "flame.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Gym Streak")
        .description("Track your gym consistency streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, streak: 5, loggedToday: true)
}

#Preview(as: .systemMedium) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, streak: 12, loggedToday: false)
}
