//
//  PagerViewModifier.swift
//
//  Created by Julio Rodríguez on 8/9/23.
//

import SwiftUI

struct CubePagerViewElementModifier: ViewModifier {
    let index: Int
    let offset: CGFloat
    let geometry: GeometryProxy
    let axis: PagerViewAxis

    func getAnchor() -> UnitPoint {
        let currentOffset = offset
        let position: CGFloat
        if axis == .horizontal {
            position = currentOffset / geometry.size.width * -1
        } else {
            position = currentOffset / geometry.size.height * -1
        }
        
        if position.isInteger {
            if Int(position) == index {
                return .center
            } else {
                if axis == .horizontal {
                    return position < CGFloat(index) ? .leading : .trailing
                } else {
                    return position < CGFloat(index) ? .top : .bottom
                }
            }
        } else if Int(position.rounded(.up)) == index {
            return axis == .horizontal ? .leading : .top
        } else if Int(position.rounded(.down)) == index {
            return axis == .horizontal ? .trailing : .bottom
        } else {
            return .center
        }
    }

    func getAngle() -> CGFloat {
        let angleToRotate = 90.0
        let currentOffset = offset
        let position: CGFloat
        if axis == .horizontal {
            position = currentOffset / geometry.size.width * -1
        } else {
            position = currentOffset / geometry.size.height * -1
        }
        let difference = position - position.rounded(.down)
        let leftAngle = angleToRotate * difference

        if position.isInteger {
            if Int(position) == index {
                return .zero
            } else if Int(position) == index + 1 {
                return angleToRotate
            } else if Int(position) == index - 1 {
                return -angleToRotate
            } else {
                return .zero
            }
        } else if Int(position.rounded(.down)) == index {
            return leftAngle
        } else if Int(position.rounded(.up)) == index {
            return -angleToRotate + leftAngle
        } else { return .zero }
    }

    func getAxis() -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        return (x: axis == .horizontal ? .zero : 1,
                y: axis == .horizontal ? -1 : .zero,
                z: .zero)
    }

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
            .rotation3DEffect(Angle(degrees: getAngle()),
                              axis: getAxis(),
                              anchor: getAnchor())
    }
}
