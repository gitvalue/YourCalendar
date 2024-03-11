//
//  Created by Dmitry Volosach on 10.03.2024.
//

import UIKit

/// Calendar page
final class CalendarListViewCell<DayCell: CalendarViewCellProtocol, Configurator: CalendarViewConfiguratorProtocol>: UICollectionViewCell where Configurator.Model == DayCell.ModelType {
    private lazy var calendarView = CalendarPageView<DayCell>().with {
        $0.onCellSelection = { [weak self] indexPath in
            guard let self = self, let date = self.date else { return }

            self.onDayCellSelection?(indexPath, date)
        }
    }

    private var date: Date?
    private var onDayCellSelection: ((IndexPath, Date) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Returns coordinates and size of the cell
    /// - Parameter indexPath: Row and column
    /// - Parameter view: Destination coordinate space host
    /// - Returns: Coordinates and size of the cell
    func frameForItem(atIndexPath indexPath: IndexPath, relativeToView view: UIView?) -> CGRect? {
        return calendarView.frameForItem(atIndexPath: indexPath, relativeToView: view)
    }

    func update(model: Model) {
        model.configurator.configure(calendarView: calendarView, withBaseDate: model.date)
        date = model.date
        onDayCellSelection = model.onDayCellSelection
    }

    private func setupSubviews() {
        addSubview(calendarView)
    }

    private func setupConstraints() {
        guard let calendarViewSuperview = calendarView.superview else { return }
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarViewSuperview.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarViewSuperview.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarViewSuperview.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarViewSuperview.bottomAnchor)
        ])
    }
}

// MARK: - Model

extension CalendarListViewCell {
    struct Model {
        fileprivate let configurator: Configurator
        fileprivate let date: Date
        fileprivate let onDayCellSelection: ((IndexPath, Date) -> ())?

        /// Designated initialiser
        /// - Parameters:
        ///   - configurator: Page configurator
        ///   - date: Base page date
        ///   - onDayCellSelection: Day selection cell event handler
        init(configurator: Configurator, date: Date, onDayCellSelection: ((IndexPath, Date) -> ())?) {
            self.configurator = configurator
            self.date = date
            self.onDayCellSelection = onDayCellSelection
        }
    }
}
