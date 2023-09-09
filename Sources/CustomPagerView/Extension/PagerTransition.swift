//
//  PagerTransition.swift
//  
//
//  Created by Julio Rodríguez on 8/9/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func pagerTransition(transition: PagerViewTransition,
                         index: Int,
                         offset: CGFloat,
                         geometry: GeometryProxy,
                         axis: PagerViewAxis) -> some View {
        switch transition {
        case .smooth:
            self
                .modifier(SmoothModifier(index: index, offset: offset, geometry: geometry, axis: axis))
        case .cube:
            self
                .modifier(CubePagerViewElementModifier(index: index, offset: offset, geometry: geometry, axis: axis))
        case .custom(let modifier):
            AnyView(modifier.getModifier(
                view: self,
                index: index,
                offset: offset,
                geometry: geometry,
                axis: axis
            ))
        }
    }
}
