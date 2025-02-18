//
//  UIApplication+Ext.swift
//  CircleMenu
//
//  Created by Thanh Hoang on 17/2/25.
//

import SwiftUI

extension UIApplication {
    
    var keyWindow: UIWindow {
        UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
        ??
        UIWindow()
    }
    
    var screenWidth: CGFloat {
        keyWindow.bounds.size.width
    }
    
    var screenHeight: CGFloat {
        keyWindow.bounds.size.height
    }
    
    var topPadding: CGFloat {
        keyWindow.safeAreaInsets.top
    }
    
    var bottomPadding: CGFloat {
        keyWindow.safeAreaInsets.bottom
    }
    
    var leftPadding: CGFloat {
        keyWindow.safeAreaInsets.left
    }
    
    var rightPadding: CGFloat {
        keyWindow.safeAreaInsets.right
    }
}
