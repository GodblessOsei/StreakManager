//
//  GymVisit.swift
//  StreakManager
//
//  Created by Godbless Mensah Osei  on 28/01/2026.
//

import Foundation
import SwiftData

@Model
class GymVisit {
    var date: Date
    
    init(date: Date = .now) {
        // Store just the date part (midnight), not the exact time
        self.date = Calendar.current.startOfDay(for: date)
    }
}
