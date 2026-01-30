//
//  ContentView.swift
//  StreakManager
//
//  Created by Godbless Mensah Osei  on 28/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var streak: Int = 0
    @State private var didGoToday: Bool = false
    @State private var visitedDates: Set<Date> = []
    @State private var currentMonth: Date = Date()
    
    var body: some View {
        VStack(spacing: 24) {
            // Streak display
            streakHeader
            
            // Calendar
            calendarView
            
            Spacer()
            
            // Log button
            logButton
            
            // Undo option (only shows if logged today)
            if didGoToday {
                undoButton
            }
        }
        .padding()
        .onAppear {
            refreshData()
        }
    }
    
    // MARK: - Subviews
    
    private var streakHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading) {
                Text("\(streak)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.primary)
                Text(streak == 1 ? "day streak" : "days streak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var calendarView: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.title3.bold())
                
                Spacer()
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            // Day labels
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Text("")
                            .frame(height: 36)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func dayCell(for date: Date) -> some View {
        let isVisited = visitedDates.contains(date)
        let isToday = Calendar.current.isDateInToday(date)
        let isFuture = date > Date()
        
        return Text("\(Calendar.current.component(.day, from: date))")
            .font(.system(size: 14, weight: isToday ? .bold : .regular))
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(isVisited ? Color.orange : Color.clear)
            )
            .foregroundStyle(
                isVisited ? .white :
                isFuture ? .secondary.opacity(0.3) :
                isToday ? .orange :
                .primary
            )
            .overlay(
                Circle()
                    .stroke(isToday ? Color.orange : Color.clear, lineWidth: 2)
            )
    }
    
    private var logButton: some View {
        Button {
            if !didGoToday {
                StreakDataManager.shared.logVisitToday()
                refreshData()
            }
        } label: {
            HStack {
                Image(systemName: didGoToday ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(didGoToday ? "Logged today ✓" : "Log gym visit")
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(didGoToday ? Color.green : Color.orange)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(didGoToday)
    }
    
    private var undoButton: some View {
        Button {
            StreakDataManager.shared.removeVisitToday()
            refreshData()
        } label: {
            Text("Undo today's log")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helper Functions
    
    private func refreshData() {
        streak = StreakDataManager.shared.currentStreak()
        didGoToday = StreakDataManager.shared.hasVisitedToday()
        visitedDates = StreakDataManager.shared.allVisitedDates()
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return [] }
        
        // Get the weekday of the first day (0 = Sunday in our grid)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        // Get the number of days in the month
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        let numDays = range.count
        
        // Build the array with leading nils for empty cells
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(calendar.startOfDay(for: date))
            }
        }
        
        return days
    }
}

#Preview {
    ContentView()
}
