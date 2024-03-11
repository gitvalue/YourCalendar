//
//  Created by Dmitry Volosach on 10.03.2024.
//

import UIKit

/// Displays calendar page
public final class CalendarPageView<Cell: CalendarViewCellProtocol>: UIView, UpdatableView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// Cell selection event handler
    public var onCellSelection: ((IndexPath) -> ())?

    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).with {
        $0.isScrollEnabled = false
        $0.register(cellType: CalendarViewWeekdayCell.self)
        $0.register(cellType: Cell.self)
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = appearance.backgroundColor
        $0.backgroundView = nil
    }

    private var weekdays: [String] = []
    private var days: [Cell.ModelType] = []

    private let appearance = Appearance()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Gets coordinates and size of the cell
    /// - Parameter indexPath: Row and column
    /// - Parameter view: Destination coordinate space host
    /// - Returns: Coordinates and size of the cell
    func frameForItem(atIndexPath indexPath: IndexPath, relativeToView view: UIView?) -> CGRect? {
        return collectionView.layoutAttributesForItem(at: indexPath).map {
            collectionView.convert($0.frame, to: view)
        }
    }

    public func update(model: Model) {
        collectionViewFlowLayout.minimumInteritemSpacing = model.columnSpacing
        collectionViewFlowLayout.minimumLineSpacing = model.rowSpacing

        weekdays = model.weekdays
        days = model.days

        collectionView.reloadData()
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

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in _: UICollectionView) -> Int {
        guard !weekdays.isEmpty else { return 0 }

        return (days.count / weekdays.count) + 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return weekdays.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let result: UICollectionViewCell!

        if indexPath.section == 0 {
            let weekdayCell: CalendarViewWeekdayCell = collectionView.dequeueReusableCell(for: indexPath)
            weekdayCell.update(model: weekdays[indexPath.row])
            result = weekdayCell
        } else {
            let dayCell: Cell = collectionView.dequeueReusableCell(for: indexPath)
            let index = (indexPath.section - 1) * weekdays.count + indexPath.row
            dayCell.update(model: days[index])

            result = dayCell
        }

        return result
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let columnSpacingsCount = CGFloat(weekdays.count - 1)
        let columnsCount = CGFloat(weekdays.count)
        let size = (frame.width - columnSpacingsCount * collectionViewFlowLayout.minimumInteritemSpacing) / columnsCount

        return CGSize(width: size, height: size)
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }

        onCellSelection?(IndexPath(row: indexPath.row, section: indexPath.section - 1))
    }
}

// MARK: - Model

public extension CalendarPageView {
    struct Model {
        fileprivate let weekdays: [String]
        fileprivate let days: [Cell.ModelType]
        fileprivate let rowSpacing: CGFloat
        fileprivate let columnSpacing: CGFloat

        /// Designated initialiser
        /// - Parameters:
        ///   - weekdays: Columns headers
        ///   - days: Cells models
        ///   - rowSpacing: Minimal distance between rows
        ///   - columnSpacing: Minimal distance between columns
        public init(
            weekdays: [String],
            days: [Cell.ModelType],
            rowSpacing: CGFloat,
            columnSpacing: CGFloat
        ) {
            self.weekdays = weekdays
            self.days = days
            self.rowSpacing = rowSpacing
            self.columnSpacing = columnSpacing
        }
    }
}

// MARK: - Appearance

private extension CalendarPageView {
    struct Appearance {
        let backgroundColor: UIColor = .clear
    }
}
