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
    func randNum(_ max: Int, avoid: Set<Int>) -> Int {
        guard avoid.max()! < max else { fatalError("maxより大きな値がavoid配列に含まれています。")}
        let rand = randNum(max - avoid.count)
        let avoidArray = Array(avoid).sorted()
        for (i, avoid) in avoidArray.enumerated() {
            if rand < avoid {
                return rand + i
            }
        }
        return rand + avoid.count
    }
    
    func randNum(_ max: Int) -> Int { return Int(arc4random_uniform(UInt32(max)) + 1) }
    
    func randBool() -> Bool { return Int(arc4random_uniform(2)) == 0 ? true : false }
    
    func randBool(_ per: Int) -> Bool { return Int(arc4random_uniform(100)) < per ? true : false }
    
    func randP1M1() -> Int { return randBool() ? 1 : -1 }
    
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
    
    let digit: Int = 1000
    
    func getKeyForHighScore() -> String {
        return "HighScore"
    }
    
    func getKeyStageComplete() -> String {
        return "StageComplete"
    }
    
    func getKeyStageStar(_ section: Int,_ stage: Int,_  mode: Mode) -> String {
        return getTagNum(section, stage).description + mode.rawValue
    }
    
    func getKeyStageCanPlay(_ section: Int,_ stage: Int) -> String {
        return getTagNum(section, stage).description + "CanPlay"
    }
    
    func getKeyStagePlayEver(_ section: Int,_ stage: Int) -> String {
        return getTagNum(section, stage).description + "Ever"
    }
    
    func getTagNum(_ section: Int,_ stage: Int) -> Int {
        return section * digit + stage
    }
    
    func getNumsFromTag(tag: Int) -> (section: Int, stage: Int) {
        return (section: tag / digit, stage: tag % digit)
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
extension Array {
    mutating func shuffle() {
        for i in 0..<self.count {
            let j = Int(arc4random_uniform(UInt32(self.indices.last!)))
            if i != j { self.swapAt(i, j) }
        }
    }
    
    var shuffled: Array {
        var copied = Array<Element>(self)
        copied.shuffle()
        return copied
    }
}
