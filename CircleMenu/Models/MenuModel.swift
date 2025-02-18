//
//  MenuModel.swift
//  CircleMenu
//
//  Created by Thanh Hoang on 17/2/25.
//

import SwiftUI

struct MenuModel: Identifiable, Hashable {
    
    var id: Int = 0
    var angle: Double = 0.0
    let icon: String
    let color: Color
    var zIndex: Double = 1.0
}
