//
//  Created by Dmitry Volosach on 10/03/2024.
//

import UIKit

extension UICollectionView {
    final func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(cellType.self, forCellWithReuseIdentifier: String(describing: cellType))
    }

    final func dequeueReusableCell<T: UICollectionViewCell>(
        for indexPath: IndexPath,
        cellType: T.Type = T.self
    ) -> T {
        let bareCell = dequeueReusableCell(withReuseIdentifier: String(describing: cellType), for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(String(describing: cellType)) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly"
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
}
