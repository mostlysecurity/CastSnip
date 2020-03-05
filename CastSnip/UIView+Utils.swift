//
//  UIView+Utils.swift
//  CastSnip
//
//  Created by ewuehler on 1/27/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func imageCapture() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil) {
            return image!
        } else {
            return UIImage()
        }
    }
    
}
