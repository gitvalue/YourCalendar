//
//  Created by Dmitry Volosach on 10.03.2024.
//

import Foundation

/// Base calendar date shifting algorithm interface
public protocol CalendarViewDateShifterProtocol: AnyObject {
    /// Shifts date by specified number of steps
    /// - Parameters:
    ///   - date: Base dae
    ///   - steps: Number of steps
    /// - Returns: Shifted date
    func date(byShiftingDate date: Date, byNumberOfSteps steps: Int) -> Date
}
