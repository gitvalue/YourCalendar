//
//  Created by Dmitry Volosach on 10/03/2024.
//

import Foundation

// Updatable view interface
public protocol UpdatableView: AnyObject {
    associatedtype ModelType
    func update(model: ModelType)
}
