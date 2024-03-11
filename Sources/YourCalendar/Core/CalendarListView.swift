//
//  Created by Dmitry Volosach on 10.03.2024.
//

import UIKit

/// Displays horizontal scrolling list of calendar pages
public final class CalendarListView<
    DayCell: CalendarViewCellProtocol, 
    Configurator: CalendarViewConfiguratorProtocol
>: UIView, UpdatableView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout where DayCell.ModelType == Configurator.Model {
    /// End of scrolling event handler
    public var onDecelerationEnd: ((Date) -> ())?

    /// Day selection event handler. Receives day coordinates (row, column) and a corresponding date.
    public var onDayCellSelection: ((IndexPath, Date) -> ())?

    private typealias Cell = CalendarListViewCell<DayCell, Configurator>

    private let collectionViewLayout = UICollectionViewFlowLayout().with {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 0.0
        $0.minimumLineSpacing = 0.0
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).with {
        $0.isPagingEnabled = true
        $0.register(cellType: Cell.self)
        $0.dataSource = self
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = apperance.backgroundColor
    }

    private var dates: [Date] = []

    private var dateShifter: CalendarViewDateShifterProtocol?
    private var configurator: Configurator?

    private var toCenter: Bool = false

    private let apperance = Appearance()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if toCenter {
            collectionView.scrollToItem(at: .init(row: 1, section: 0), at: .centeredHorizontally, animated: false)
            toCenter = false
        }
    }

    /// Gets coordinates and size of the cell on the current page
    /// - Parameter indexPath: Row and column
    /// - Parameter view: Destination coordinate space host
    /// - Returns: Coordinates and size of the cell
    public func frameForItem(atIndexPath indexPath: IndexPath, relativeToView view: UIView?) -> CGRect? {
        return (collectionView.visibleCells.first as? Cell)?.frameForItem(atIndexPath: indexPath, relativeToView: view)
    }

    /// Redraws the calendar
    public func reload() {
        collectionView.reloadData()
    }

    public func update(model: Model) {
        dates = [
            model.dateShifter.date(byShiftingDate: model.date, byNumberOfSteps: -1),
            model.date,
            model.dateShifter.date(byShiftingDate: model.date, byNumberOfSteps: 1),
        ]

        dateShifter = model.dateShifter
        configurator = model.configurator

        // As we don't know in which state
        // calendar layout will be when model gets updated
        // we set the 'center' flag which means that view
        // neads to scroll to the 'middle' page and rebuild the layout
        // as `.scrollToItem(at:, at:, animated:)` will work correctly only
        // when layout is built
        toCenter = true
        collectionView.reloadData()
        setNeedsLayout()
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dates.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let configurator = configurator else { return UICollectionViewCell() }

        let cell: Cell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(
            model: .init(
                configurator: configurator,
                date: dates[indexPath.row],
                onDayCellSelection: onDayCellSelection
            )
        )

        return cell
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return frame.size
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        guard let dateShifter = dateShifter else { return }

        let pageWidth = frame.width
        let pageLeftBound = scrollView.contentOffset.x
        let pageRightBound = pageLeftBound + pageWidth
        let leftBound: CGFloat = 0.0
        let rightBound = scrollView.contentSize.width

        if pageLeftBound - leftBound < pageWidth {
            let leftBoundDate = dates[0]
            dates = [dateShifter.date(byShiftingDate: leftBoundDate, byNumberOfSteps: -1)] + dates
            collectionView.contentOffset = .init(x: pageLeftBound + pageWidth, y: 0.0)
        }
        if rightBound - pageRightBound < pageWidth {
            let rightBoundDate = dates[dates.count - 1]
            dates = dates + [dateShifter.date(byShiftingDate: rightBoundDate, byNumberOfSteps: 1)]
        }

        collectionView.reloadData()
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        if let cell = collectionView.visibleCells.first,
           let indexPath = collectionView.indexPath(for: cell),
           let date = dates[safe: indexPath.row] {
            onDecelerationEnd?(date)
        }
    }

    private func setupSubviews() {
        addSubview(collectionView)
    }

    private func setupConstraints() {
        guard let collectionViewSuperview = collectionView.superview else { return }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: collectionViewSuperview.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: collectionViewSuperview.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionViewSuperview.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: collectionViewSuperview.bottomAnchor)
        ])
    }
}

// MARK: - Model

public extension CalendarListView {
    struct Model {
        fileprivate let date: Date
        fileprivate let dateShifter: CalendarViewDateShifterProtocol
        fileprivate let configurator: Configurator

        /// Designated initialiser
        /// - Parameters:
        ///   - date: Base date
        ///   - dateShifter: Base date shifting algorithm
        ///   - configurator: Calendar page configurator
        public init(date: Date, dateShifter: CalendarViewDateShifterProtocol, configurator: Configurator) {
            self.date = date
            self.dateShifter = dateShifter
            self.configurator = configurator
        }
    }
}

// MARK: - Appearance

private extension CalendarListView {
    struct Appearance {
        let backgroundColor: UIColor = .clear
    }
}
