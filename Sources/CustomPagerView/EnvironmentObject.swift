//
//  EnviromentObject.swift
//
//  Created by Julio Rodríguez on 8/9/23.
//

import SwiftUI

public class PagerViewScrollInfo: ObservableObject {
    @Published var scrolling: PagerViewAxis?
}

public struct PagerViewScrollInfoEnvironmentKey: EnvironmentKey {
    // this is the default value that SwiftUI will fallback to if you don't pass the object
    public static var defaultValue: PagerViewScrollInfo = .init()
}

public extension EnvironmentValues {
    // the new key path to access your object (\.object)
    var scrollInfo: PagerViewScrollInfo {
        get { self[PagerViewScrollInfoEnvironmentKey.self] }
        set { self[PagerViewScrollInfoEnvironmentKey.self] = newValue }
    }
}

public extension View {
    // this is just an elegant wrapper to set your object into the environment
    func object(_ value: PagerViewScrollInfo) -> some View {
        environment(\.scrollInfo, value)
    }
}
