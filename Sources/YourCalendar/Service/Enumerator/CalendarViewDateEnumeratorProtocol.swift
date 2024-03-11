//
//  Created by Dmitry Volosach on 10/03/2024.
//

import Foundation

/// Calendar list dates enumerator interface
public protocol CalendarViewDateEnumeratorProtocol: AnyObject {
    /// Sets the base date
    /// - Parameter base: Base date
    func set(base: Date)

    /// Moves to next date
    /// - Returns: Next date
    func moveToNext() -> Date?

    /// Gets date by index
    /// - Parameter index: Date index
    /// - Returns: Date at index
    func date(atIndex index: Int) -> Date?
}
