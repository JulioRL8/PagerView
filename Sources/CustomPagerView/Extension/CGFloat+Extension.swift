//
//  CGFloat+Extension.swift
//  
//
//  Created by Julio Rodríguez on 8/9/23.
//

import Foundation

extension CGFloat {
    var isInteger: Bool {
        let integer = Int(self)
        return self == CGFloat(integer)
    }
}
