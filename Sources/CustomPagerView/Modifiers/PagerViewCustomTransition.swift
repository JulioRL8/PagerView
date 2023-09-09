//
//  PagerViewCustomTransition.swift
//  
//
//  Created by Julio Rodríguez on 9/9/23.
//

import SwiftUI

public protocol PagerViewCustomTransition {
    func getModifier<Content: View>(view: Content,
                                    index: Int,
                                    offset: CGFloat,
                                    geometry: GeometryProxy,
                                    axis: PagerViewAxis) -> any View
}
