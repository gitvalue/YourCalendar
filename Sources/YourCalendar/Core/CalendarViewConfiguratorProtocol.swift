//
//  Created by Dmitry Volosach on 10.03.2024.
//

import UIKit

/// Calendar page configurator interface
public protocol CalendarViewConfiguratorProtocol: AnyObject {
    /// Day cell model
    associatedtype Model

    /// Configures calendar page
    /// - Parameter calendarView: Calendar page
    /// - Parameter date: Base date
    func configure<Cell: CalendarViewCellProtocol>(calendarView: CalendarPageView<Cell>, withBaseDate date: Date) where Cell.ModelType == Model
}
