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
    public typealias PagerViewTransitionCustomModifier = (_ view: any View,
                                                          _ index: Int,
                                                          _ offset: CGFloat,
                                                          _ geometry: GeometryProxy,
                                                          _ axis: PagerViewAxis) -> any View
    case smooth
    case cube
    case custom(PagerViewCustomTransition)
}
