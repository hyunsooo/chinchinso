//
//  Color.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 10. 20..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import Foundation
import UIKit

final class Color: NSObject {
    static let shared = Color()
    
    let darkTransparent = UIColor.init(white: 0, alpha: 0.5)
    let menuBackground = UIColor.init(r: 255, g: 253, b: 248)
    let background = UIColor.init(r: 232, g: 229, b: 226)
    let darkGreen = UIColor.init(r: 141, g: 168, b: 141)
    let orangeYellow = UIColor.init(r: 245, g: 128, b: 39)
    let transparentOrangeYellow = UIColor.init(r: 245, g: 128, b: 39, a: 0.5)
    
    let font = UIColor.init(r: 100, g: 100, b: 100)
    
    let chatBackground = UIColor.init(r: 237, g: 237, b: 237)

    let userMessageBackground = UIColor.init(r: 0, g: 137, b: 249)
    let blindMessageBackground = UIColor.init(r: 220, g: 220, b: 220)
    
}
