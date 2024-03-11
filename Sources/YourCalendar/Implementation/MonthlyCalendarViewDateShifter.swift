//
//  Created by Dmitry Volosach on 10/03/2024.
//

import Foundation

/// Month calendar page shifter algorithm
public final class MonthlyCalendarViewDateShifter: CalendarViewDateShifterProtocol {
    /// Designated initialiser
    public init() {}
    
    /// Shifts date by specified number of months
    /// - Parameters:
    ///   - date: Base date
    ///   - steps: Numer of steps
    /// - Returns: Shifted date
    /// - Note: In case `Calendar.date(byAdding:value:to:)` somehow returns `nil` — base date will be not shifted
    public func date(byShiftingDate date: Date, byNumberOfSteps steps: Int) -> Date {
        return Constants.calendar.date(byAdding: .month, value: steps, to: date) ?? date
    }
}
