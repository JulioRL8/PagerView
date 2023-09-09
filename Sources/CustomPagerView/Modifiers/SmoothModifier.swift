//
//  IdentityModifier.swift
//  
//
//  Created by Julio Rodríguez on 8/9/23.
//

import SwiftUI

struct SmoothModifier: ViewModifier {
    let index: Int
    let offset: CGFloat
    let geometry: GeometryProxy
    let axis: PagerViewAxis

    var opacity: CGFloat {
        let position: CGFloat
        if axis == .horizontal {
            position = offset / geometry.size.width * -1
        } else {
            position = offset / geometry.size.height * -1
        }
        return (position.rounded(.down)...position.rounded(.up)) ~= CGFloat(index) ? 1 : 0
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }
}
