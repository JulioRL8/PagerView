//
//  PagerControl.swift
//  
//
//  Created by Julio Rodríguez on 10/9/23.
//

import SwiftUI

public extension PagerView {
    @ViewBuilder
    func addPagerControl(alignment: Alignment = .center,
                         @ViewBuilder _ content: (Int, Int) -> some View) -> some View {
        self
            .overlay(alignment: alignment) {
                content(self.index, self.content.count)
            }
    }
}
