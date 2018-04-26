//
//  Util.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/18.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import Foundation
import CoreGraphics

struct Util {
    func randNum(seed: Int) -> Int { return Int(arc4random_uniform(UInt32(seed)) + 1) }
    
    func randBool() -> Bool { return Int(arc4random_uniform(2)) == 0 ? true : false }
    
    func reduce(m: Int, d: Int) ->(m: Int, d: Int){
        
        func gcd(_ a: Int, _ b: Int) -> Int {
            switch b {
            case 0:
                return a
            default:
                return gcd(b, a % b)
            }
        }
        let r = gcd(m, d)
        return (m/r, d/r)
    }
}

extension CGPoint {
    public func nearlyEqual(to point: CGPoint, epsilon: CGFloat) -> Bool {
        let difference = self - point
        return fabs(difference.x) < epsilon && fabs(difference.y) < epsilon
    }
    
    public var length: CGFloat {
        return sqrt(squareLength)
    }
    
    public var squareLength: CGFloat {
        return x * x + y * y
    }
    
    public var unit: CGPoint {
        return self * (1.0 / length)
    }
    
    public var phase: CGFloat {
        return atan2(y, x)
    }
    
    public func distance(from point: CGPoint) -> CGFloat {
        return (self - point).length
    }
    
    public func squareDistance(from point: CGPoint) -> CGFloat {
        return (self - point).squareLength
    }
    
    public func angle(from point: CGPoint) -> CGFloat {
        return acos(cos(angleFrom: point))
    }
    
    public func cos(angleFrom point: CGPoint) -> CGFloat {
        return fmin(fmax(self * point / sqrt(self.squareLength * point.squareLength), -1.0), 1.0)
    }
}

extension CGPoint: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}

public prefix func + (value: CGPoint) -> CGPoint {
    return value
}

public prefix func - (value: CGPoint) -> CGPoint {
    return CGPoint(x: -value.x, y: -value.y)
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func * (left: CGPoint, right: CGPoint) -> CGFloat {
    return left.x * right.x + left.y * right.y
}

public func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

public func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: right.x * left, y: right.y * left)
}

public func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func *= (left: inout CGPoint, right: CGFloat) {
    left = left * right
}

public func /= (left: inout CGPoint, right: CGFloat) {
    left = left / right
}
