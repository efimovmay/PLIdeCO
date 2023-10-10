//
//  CustomBallView.swift
//  PLIdeCO
//
//  Created by Aleksey Efimov on 04.10.2023.
//

import UIKit

class CustomBallView: UIImageView {
    
    override public var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
}
