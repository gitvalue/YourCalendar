//
//  Created by Dmitry Volosach on 10.03.2024.
//

import UIKit

/// Calendar page weekday cell
public final class CalendarViewWeekdayCell: UICollectionViewCell, CalendarViewCellProtocol {
    private lazy var label = UILabel()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(model: String) {
        label.text = model
    }

    private func setupSubviews() {
        addSubview(label)
    }

    private func setupConstraints() {
        guard let labelSuperview = label.superview else { return }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: labelSuperview.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelSuperview.centerYAnchor)
        ])
    }
}
