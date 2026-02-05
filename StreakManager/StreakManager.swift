//
//  StreakManager.swift
//  StreakManager
//
//  Created by Godbless Mensah Osei  on 28/01/2026.
//

import Foundation
import SwiftData

import WidgetKit

@MainActor
class StreakDataManager {
    static let shared = StreakDataManager()
    
    let container: ModelContainer
    var context: ModelContext { container.mainContext }
    
    private init() {
        let schema = Schema([GymVisit.self])
        let config = ModelConfiguration(
            "StreakManager",
            schema: schema,
            groupContainer: .identifier("group.streakmanager")
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Actions
    
    func logVisitToday() {
        let today = Calendar.current.startOfDay(for: .now)
        
        let predicate = #Predicate<GymVisit> { visit in
            visit.date == today
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }
        
        let visit = GymVisit(date: today)
        context.insert(visit)
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func removeVisitToday() {
        let today = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<GymVisit> { visit in
            visit.date == today
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let visits = try? context.fetch(descriptor) {
            visits.forEach { context.delete($0) }
            try? context.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func hasVisitedToday() -> Bool {
        let today = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<GymVisit> { visit in
            visit.date == today
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? context.fetch(descriptor))?.isEmpty == false
    }
    
    // MARK: - Streak Calculation
    
    func currentStreak() -> Int {
        let descriptor = FetchDescriptor<GymVisit>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        guard let visits = try? context.fetch(descriptor), !visits.isEmpty else {
            return 0
        }
        
        let calendar = Calendar.current
        var streak = 0
        var expectedDate = calendar.startOfDay(for: .now)
        
        if visits.first?.date != expectedDate {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                return 0
            }
            expectedDate = yesterday
        }
        
        for visit in visits {
            if visit.date == expectedDate {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                    break
                }
                expectedDate = previousDay
            } else if visit.date < expectedDate {
                break
            }
        }
        
        return streak
    }
    
    func allVisitedDates() -> Set<Date> {
        let descriptor = FetchDescriptor<GymVisit>()
        guard let visits = try? context.fetch(descriptor) else { return [] }
        return Set(visits.map { $0.date })
    }
}
