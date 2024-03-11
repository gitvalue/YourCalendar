//
//  Created by Dmitry Volosach on 10/03/2024.
//

import Foundation

/// Month days enumerator algorithm
public final class MonthlyCalendarViewDateEnumerator: CalendarViewDateEnumeratorProtocol {
    private var base: Date?
    private var firstDayOfMonth: Date?
    private var firstDayOfMonthWeekdayIndex: Int?
    private var index: Int?

    private let weekdaysCount = Constants.weekdaysCount
    private let maxWeeksCount = 6
    
    /// Designated initialiser
    public init() {}

    public func set(base: Date) {
        self.base = base

        var firstDayOfMonthComponents = Constants.calendar.dateComponents([.year, .month], from: base)
        firstDayOfMonthComponents.day = 1

        if let firstDayOfMonth = Constants.calendar.date(from: firstDayOfMonthComponents) {
            self.firstDayOfMonth = firstDayOfMonth

            let firstDayOfMonthWeekday = Constants.calendar.component(.weekday, from: firstDayOfMonth)
            let firstWeekday = Constants.calendar.firstWeekday
            let displacement = firstDayOfMonthWeekday - firstWeekday
            firstDayOfMonthWeekdayIndex = (weekdaysCount + displacement) % weekdaysCount
        }

        index = 0
    }

    public func moveToNext() -> Date? {
        guard
            let index = index,
            index < weekdaysCount * maxWeeksCount,
            let day = date(atIndex: index)
        else {
            return nil
        }

        self.index? += 1

        return day
    }

    public func date(atIndex index: Int) -> Date? {
        if let firstDayOfMonth = firstDayOfMonth, let firstDayOfMonthWeekdayIndex = firstDayOfMonthWeekdayIndex {
            return Constants.calendar.date(
                byAdding: .day,
                value: index - firstDayOfMonthWeekdayIndex,
                to: firstDayOfMonth
            )
        } else {
            return nil
        }
    }
}
