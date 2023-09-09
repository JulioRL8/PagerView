//
//
//  Created by Julio Rodríguez on 8/9/23.
//

import Foundation
import SwiftUI

public enum PagerViewAxis {
    case vertical
    case horizontal
}

public enum PagerViewTransition {
    case smooth
    case cube
    case custom(PagerViewCustomTransition)
}
