//
//  Created by Dmitry Volosach on 10.03.2024.
//

import UIKit

/// Calendar page day cell
public final class CalendarViewDayCell: UICollectionViewCell, CalendarViewCellProtocol {
    private lazy var label = UILabel()

    private lazy var markView = UIView().with {
        $0.layer.cornerRadius = appearance.markCornerRadius
        $0.backgroundColor = appearance.markColor
    }

    private lazy var backView = UIView().with {
        $0.layer.cornerRadius = appearance.backgroundViewCornerRadius
        $0.layer.borderWidth = appearance.backgroundViewBorderWidth
    }

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

    public func update(model: Model) {
        label.textColor = model.style.color
        label.text = model.text
        markView.isHidden = model.isMarkHidden
        backView.backgroundColor = model.fillColor
        backView.layer.borderColor = model.strokeColor.cgColor
    }

    private func setupSubviews() {
        addSubview(backView)
        addSubview(label)
        addSubview(markView)
    }

    private func setupConstraints() {
        guard let labelSuperview = label.superview else { return }
            
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: labelSuperview.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelSuperview.centerYAnchor)
        ])
        
        guard let markViewSuperview = markView.superview else { return }

        markView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            markView.widthAnchor.constraint(equalToConstant: appearance.markSize.width),
            markView.heightAnchor.constraint(equalToConstant: appearance.markSize.height),
            markView.centerXAnchor.constraint(equalTo: markViewSuperview.centerXAnchor),
            markView.bottomAnchor.constraint(
                equalTo: markViewSuperview.bottomAnchor,
                constant: -appearance.markBottom
            )
        ])
        
        guard let backViewSuperview = backView.superview else { return }
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(
                equalTo: backViewSuperview.topAnchor,
                constant: appearance.backgroundViewInsets.top
            ),
            backView.leadingAnchor.constraint(
                equalTo: backViewSuperview.leadingAnchor,
                constant: appearance.backgroundViewInsets.left
            ),
            backView.trailingAnchor.constraint(
                equalTo: backViewSuperview.trailingAnchor,
                constant: -appearance.backgroundViewInsets.right
            ),
            backView.bottomAnchor.constraint(
                equalTo: backViewSuperview.bottomAnchor,
                constant: -appearance.backgroundViewInsets.bottom
            )
        ])
    }
}

// - MARK: Model

public extension CalendarViewDayCell {
    /// Text style
    enum Style {
        /// Weedkay
        case weekday

        /// Weekend/holiday
        case holiday

        /// Day out of current period (e.g. month or week) bounds
        case outOfBounds
    }

    struct Model {
        fileprivate let text: String
        fileprivate let style: Style
        fileprivate let isMarkHidden: Bool
        fileprivate let fillColor: UIColor
        fileprivate let strokeColor: UIColor

        /// Designated initialiser
        /// - Parameters:
        ///   - text: Text string
        ///   - style: Text style
        ///   - isMarkHidden: Controls mark visibility
        ///   - fillColor: Cell fill color
        ///   - strokeColor: Cell stroke color
        public init(text: String, style: Style, isMarkHidden: Bool, fillColor: UIColor, strokeColor: UIColor) {
            self.text = text
            self.style = style
            self.isMarkHidden = isMarkHidden
            self.fillColor = fillColor
            self.strokeColor = strokeColor
        }
    }
}

// MARK: - Appearance

private extension CalendarViewDayCell {
    struct Appearance {
        let markSize: CGSize = .init(width: 6.12, height: 6.12)
        var markCornerRadius: CGFloat { markSize.width * 0.5 }
        let markColor: UIColor = .brown
        let markBottom: CGFloat = 6.12
        let backgroundViewInsets: UIEdgeInsets = .init(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        let backgroundViewCornerRadius: CGFloat = 4.0
        let backgroundViewBorderWidth: CGFloat = 1.0
    }
}

private extension CalendarViewDayCell.Style {
    var color: UIColor {
        switch self {
        case .weekday:
            return .black
        case .holiday:
            return .red
        case .outOfBounds:
            return .gray
        }
    }
}
