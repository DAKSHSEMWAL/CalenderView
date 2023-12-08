//
//  ContentView.swift
//  CalenderView
//
//  Created by Daksh Semwal on 08/12/23.
//


import Foundation
import SwiftUI

struct Holiday {
    var date: Date
    var occasion: String
}

struct OnLeave {
    var date: Date
    var count: Int
}

extension Date {
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    func yearMonthDayComponents() -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
    
    var year: Int {
        self.yearMonthDayComponents().year!
    }
    
    var month: Int {
        self.yearMonthDayComponents().month!
    }
    
    
    var day: Int {
        self.yearMonthDayComponents().day!
    }
}


class CalendarViewModel: ObservableObject {
    @Published var days: [Date?] = []
    @Published var currentDate = Date()
    var holidays: [Holiday]
    var onLeave: [OnLeave]
    
    init(holidays: [Holiday], onLeave: [OnLeave]) {
        self.holidays = holidays
        self.onLeave = onLeave
        generateCalendar()
    }
    
    func generateCalendar() {
        days.removeAll()
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        
        let components = currentDate.yearMonthDayComponents()
        let startOfMonth = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1))!
        
        let dayOfWeek = calendar.component(.weekday, from: startOfMonth)
        
        // Determine the number of leading/trailing days to show from the previous/next month
        let leadingDays = (dayOfWeek + 6) % 7
        let firstDay = calendar.date(byAdding: .day, value: -leadingDays, to: startOfMonth)!
        
        var day = firstDay
        for _ in 0..<42 {  // 6 weeks of 7 days
            days.append(day)
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
    }
    
    // Check if the date is within the current month
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        let currentMonth = currentDate.yearMonthDayComponents().month
        let month = date.yearMonthDayComponents().month
        return month == currentMonth
    }
}

struct ContentView: View {
    @StateObject var viewModel: CalendarViewModel
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // Month and Year header
            Text("\(viewModel.currentDate.monthName), \(viewModel.currentDate.year)")
                .font(.title)
            
            // Days of the week headers
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
            }
            
            // Day cells
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.days, id: \.self) { date in
                    if let date = date {
                        DayView(
                            day: Calendar.current.component(.day, from: date),
                            today: viewModel.currentDate,
                            date: date,
                            holidays: viewModel.holidays,
                            yearMonth: viewModel.currentDate,
                            onLeave: viewModel.onLeave
                        )
                    } else {
                        DayView(
                            day: nil,
                            today: viewModel.currentDate,
                            date: nil,
                            holidays: viewModel.holidays,
                            yearMonth: viewModel.currentDate,
                            onLeave: viewModel.onLeave
                        )
                    }
                }
            }
        }
        .padding()
    }
}



struct DayView: View {
    let day: Int?
    let today: Date
    let date: Date?
    let holidays: [Holiday]
    let yearMonth: Date
    let onLeave: [OnLeave]
    
    private var isToday: Bool {
        date?.yearMonthDayComponents() == today.yearMonthDayComponents()
    }
    
    private var isCurrentMonth: Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(date, equalTo: yearMonth, toGranularity: .month)
    }
    
    private var holiday: Holiday? {
        holidays.first(where: { $0.date.yearMonthDayComponents() == date?.yearMonthDayComponents() })
    }
    
    private var leave: OnLeave? {
        onLeave.first(where: { $0.date.yearMonthDayComponents() == date?.yearMonthDayComponents() })
    }
    
    var body: some View {
        ZStack {
            if let holiday =  holiday {
                // Background for holiday
                Color(hex: 0xEFFFEE)
            }
            
            VStack(alignment: .leading) {
                if let day = day {
                    Text("\(day)")
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                        .padding(3)
                        .foregroundColor(isToday ? Color(hex:0xFF5C8AFF) : (isCurrentMonth ? .primary : .gray))
                }
                
                Spacer()
                
                if let holiday = holiday {
                    Text(holiday.occasion)
                        .font(.system(size: 10))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding(.bottom, 8)
                }
            }
            
            if let leave = leave {
                Circle()
                    .fill(Color(hex:0xFFE7E8EA))
                    .frame(width: 20, height: 20, alignment: .leading)
                    .overlay(
                        Text("\(leave.count)")
                            .font(.system(size: 10))
                            .foregroundColor(.primary)
                    )
            }
        }
        .frame(width: 56, height: 66)
    }
}


struct ContentView_Previews: PreviewProvider {
    static let sampleHolidays: [Holiday] = [
        Holiday(date: Date().addingTimeInterval(86400 * 5), occasion: "New Year's Day"), // 5 days from today
        Holiday(date: Date().addingTimeInterval(86400 * 15), occasion: "Republic Day")   // 15 days from today
    ]
    
    // Sample list of on leave
    static let sampleOnLeave: [OnLeave] = [
        OnLeave(date: Date().addingTimeInterval(86400 * 10), count: 3), // 10 days from today, 3 people on leave
        OnLeave(date: Date().addingTimeInterval(86400 * 20), count: 2)  // 20 days from today, 2 people on leave
    ]
    
    static var previews: some View {
        ContentView(viewModel: CalendarViewModel(holidays: sampleHolidays, onLeave: sampleOnLeave))
    }
}


extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
