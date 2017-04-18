//
//  Line.swift
//  TouchTracker
//
//  Created by Alex Louzao on 4/1/17.
//  Copyright © 2017 ALcsc2310. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

struct Line{
    var begin = CGPoint.zero
    var end = CGPoint.zero
    
    var angle: Measurement<UnitAngle> {
        guard begin != end else {
            return Measurement(value: 0.0, unit: .radians)
        }
        let dy = Double(end.y - begin.y) // difference in y position for the location of line
        let dx = Double(end.x - begin.x) // difference in x position for the location of line
        let angleInRadian: Measurement<UnitAngle> = Measurement(value: atan2(dy, dx), unit: .radians)
        return angleInRadian
    }
    
    var color: UIColor {
        let colors = [UIColor.black, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.darkGray, UIColor.gray, UIColor.green, UIColor.lightGray, UIColor.magenta, UIColor.orange, UIColor.purple, UIColor.red, UIColor.yellow] // array containing a list of colors to assign to the angle
        let ratio = (self.angle.value + Double.pi) / (Double.pi * 2)   // cycle the colors for the 360 circle
        let colorIndex = Int( Double(colors.count - 1) * ratio) // determine the color index based on angle
        return colors[colorIndex]
    }
}

