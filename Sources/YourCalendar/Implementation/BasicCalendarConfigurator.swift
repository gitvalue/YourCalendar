//
//  Created by Dmitry Volosach on 10/03/2024.
//

import UIKit

/// Standard calendar configurator implementation
public final class BasicCalendarViewConfigurator: CalendarViewConfiguratorProtocol {
    public typealias Predicate = (Date) -> Bool
    public typealias Model = CalendarViewDayCell.Model
    
    /// Selected day model
    private(set) var selectedDay: Date?
    
    private var formatter = DateFormatter().with {
        $0.dateFormat = "d"
    }

    private lazy var holidayPredicate: Predicate = { [weak self] date in
        Constants.calendar.isDateInWeekend(date) == true
    }

    private lazy var markVisibilityPredicate: Predicate = { _ in false }
    private let dateEnumerator: CalendarViewDateEnumeratorProtocol
    private lazy var firstWeekdayIndex = Constants.calendar.firstWeekday - 1

    private lazy var weekdays = (firstWeekdayIndex..<firstWeekdayIndex + Constants.weekdaysCount).map {
        (Constants.calendar.shortWeekdaySymbols[safe: $0 % Constants.weekdaysCount] ?? "").uppercased()
    }

    /// Designated initialiser
    /// - Parameter enumerator: Calendar page dates enumerator
    public init(enumerator: CalendarViewDateEnumeratorProtocol) {
        dateEnumerator = enumerator
    }

    /// Assigns date formatter
    /// - Parameter formatter: Date formatter
    public func set(formatter: DateFormatter) {
        self.formatter = formatter
    }

    /// Assigns holiday/weekend predicate
    /// - Parameter holidayPredicate: Holiday/weekday predicate
    public func set(holidayPredicate: @escaping Predicate) {
        self.holidayPredicate = holidayPredicate
    }

    /// Assigns mark visibility predicate
    /// - Parameter markVisibilityPredicate: Mark visibility predicate
    public func set(markVisibilityPredicate: @escaping Predicate) {
        self.markVisibilityPredicate = markVisibilityPredicate
    }

    /// Selects a day
    /// - Parameter date: Date
    /// - Parameter resetIfSame: If true, consequent selection will invert the previous one
    public func set(selectedDay date: Date?, resetIfSame: Bool) {
        if resetIfSame, let currentSelection = selectedDay, let date = date, Constants.calendar.isDate(date, inSameDayAs: currentSelection) {
            selectedDay = nil
        } else {
            selectedDay = date
        }
    }

    /// Calculates date from cell coordinates and base date
    /// - Parameters:
    ///   - date: Base date
    ///   - indexPath: Day cell coordinates (row, column)
    /// - Returns: Date corresponding to a cell at specified position
    public func date(fromBase date: Date, indexPath: IndexPath) -> Date? {
        dateEnumerator.set(base: date)
        let index = indexPath.section * Constants.weekdaysCount + indexPath.row

        return dateEnumerator.date(atIndex: index)
    }

    public func configure<Cell>(calendarView: CalendarPageView<Cell>, withBaseDate date: Date) where Cell: CalendarViewCellProtocol, Cell.ModelType == Model {
        let dateComponents = Constants.calendar.dateComponents([.year, .month], from: date)

        dateEnumerator.set(base: date)

        var days: [Model] = []

        while let day = dateEnumerator.moveToNext() {
            let dayComponents = Constants.calendar.dateComponents([.month], from: day)
            let text = formatter.string(from: day)
            let isWeekend = holidayPredicate(day)

            let style: CalendarViewDayCell.Style

            if dayComponents.month != dateComponents.month {
                style = .outOfBounds
            } else if isWeekend {
                style = .holiday
            } else {
                style = .weekday
            }

            let fillColor: UIColor = Constants.calendar.isDate(day, inSameDayAs: Date()) ? .yellow : .clear
            let isSelected: Bool? = selectedDay.map { Constants.calendar.isDate(day, inSameDayAs: $0) }
            let strokeColor: UIColor = isSelected == true ? .gray : .clear

            let model = Model(
                text: text,
                style: style,
                isMarkHidden: !markVisibilityPredicate(day),
                fillColor: fillColor,
                strokeColor: strokeColor
            )

            days.append(model)
        }

        calendarView.update(
            model: .init(
                weekdays: weekdays,
                days: days,
                rowSpacing: 0.0,
                columnSpacing: 0.0
            )
        )
    }
}
