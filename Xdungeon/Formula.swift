//
//  BlockOperation.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/12.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

class Formula: SKNode {
    
    private var qptn: [[Kind]] = [] // question pattern
    private var sqb : [Kind] = []   // sequence of blocks
    
    var scale:  CGFloat!
    
    var originX: CGFloat { get { return -fs.width  * 0.5 / scale }}
    var originY: CGFloat { get { return -fs.height * 0.5 / scale }}
    var limitX:  CGFloat { get { return  fs.width  * 0.5 / scale }}
    var limitY:  CGFloat { get { return  fs.height * 0.5 / scale }}
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        buildQuestionPattern()
        newQuestion()
    }
    
    func update() {
        resetBlocks()
    }
    
    func resetBlocks() {
        var currentLevel : CGFloat = 3
        while 0 <= currentLevel {
            for block in allBlocks {
                if block.level == currentLevel {
                    if block.isChangeContent {
                        block.changeContent()
                    }
                }
            }
            currentLevel -= 1
        }
        if isAdjustAllBlocks {
            adjustFirstLayPosition()
            
            if isClear() {
                
            }
        }
    }
    
    func adjustFirstLayPosition() {
        isAdjustAllBlocks = false
        var tw = fs.space
        for block in firstLayblocks { tw += block.width + fs.space }
        scale = min(fs.width / (tw + fs.bsz), 1)
        
        var a = (-tw * 0.5) + fs.space
        for block in firstLayblocks {
            block.ftrPoint.x = a + block.width * 0.5
            if !block.isTouched {
                block.run(SKAction.move(to: CGPoint(x: a + block.width * 0.5, y: block.ftrPoint.y), duration: 0.24))
            }
            a += block.width + fs.space
        }
        run(SKAction.scale(to: scale, duration: 0.24))
    }
    
    func isClear() -> Bool {
        guard allBlocks.count == 3 else { return false }
        guard let clct = firstLayblocks.first! as? CollectableBlock else { return false }
        guard clct.labels.ns.count == 1 else { return false }
        return clct.kind == Kind.X  && clct.labels.ns.first!.num == Num(true, 1, 1)
    }
    
    
    func newQuestion(){
        
        sqb = qptn[14]//Int(arc4u.random_uniform(18))
        print(sqb)
        
        var firstX_plus = true, firstX_m = 0, firstX_d = 0, afterEqual = false, isFirst = true
        
        func createParentBlock() {
            var mPlusMinus = u.randBool(), (e_m, e_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
            while mPlusMinus && e_m == 1 && e_d == 1 {
                mPlusMinus = u.randBool(); (e_m, e_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
            }
            var xPlusMinus = u.randBool(), (x_m, x_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
            let cPlusMinus = u.randBool(), (c_m, c_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
            if firstX_d == 0 {
                firstX_plus = (xPlusMinus && mPlusMinus) || (!xPlusMinus && !mPlusMinus)
                let firstX = u.reduce(m: x_m * e_m, d: x_d * e_d); firstX_m = firstX.m; firstX_d = firstX.d
            } else {
                var isXPlus = (xPlusMinus == mPlusMinus)
                var x = u.reduce(m: x_m * e_m, d: x_d * e_d), m = x.0, d = x.1
                while firstX_plus == isXPlus && firstX_m == m && firstX_d == d {
                    xPlusMinus = u.randBool(); (x_m, x_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
                    isXPlus = (xPlusMinus == mPlusMinus); x = u.reduce(m: x_m * e_m, d: x_d * e_d); m = x.0; d = x.1
                }
            }
            let parentID = NSUUID().uuidString
            
            
            let mBlock = Multi(parentID: parentID,
                               isFirst: (isFirst || afterEqual),
                               level: 1,
                               num: Num(mPlusMinus, e_m, e_d))
            
            let xBlock = CollectableBlock(
                                kind: .X,
                                parentID: parentID,
                                isFirst: true,
                                level: 1,
                                num: Num(xPlusMinus, x_m, x_d))
            
            let cBlock = CollectableBlock(
                                kind: .C,
                                parentID: parentID,
                                isFirst: false,
                                level: 1,
                                num: Num(cPlusMinus, c_m, c_d))
            
            
            let pBlock = Parnt(parentID: "",
                               isFirst: (isFirst || afterEqual),
                               level: 0,
                               multi: mBlock,
                               blocks: [xBlock, cBlock])
            
            pBlock.name = parentID
            mBlock.name = NSUUID().uuidString
            xBlock.name = NSUUID().uuidString
            cBlock.name = NSUUID().uuidString
            
            addChild(pBlock)
            allBlocks.append(contentsOf: [pBlock, mBlock, xBlock, cBlock])
            firstLayblocks.append(pBlock)
            isFirst = false
            afterEqual = false
        }
        
        func createXBlock() {
            var xPlusMinus = u.randBool(), (x_m, x_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
            if firstX_d == 0 { firstX_plus = xPlusMinus; firstX_m = x_m; firstX_d = x_d }
            else {
                while firstX_plus == xPlusMinus && firstX_m == x_m && firstX_d == x_d {
                    xPlusMinus = u.randBool(); (x_m, x_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
                }
            }
            let xBlock = CollectableBlock(
                                kind: .X,
                                parentID: "",
                                isFirst: (isFirst || afterEqual),
                                level: 0,
                                num:Num(xPlusMinus, x_m, x_d))
            
            xBlock.name = NSUUID().uuidString
            
            addChild(xBlock)
            allBlocks.append(xBlock)
            firstLayblocks.append(xBlock)
            isFirst = false
            afterEqual = false
        }
        
        func createConstBlock() {
            let cPlusMinus = u.randBool(), (c_m, c_d) = u.reduce(m: u.randNum(seed: 6), d: u.randNum(seed: 6))
            
            let cBlock = CollectableBlock(
                                kind: .C,
                                parentID: "",
                                isFirst: (isFirst || afterEqual),
                                level: 0,
                                num: Num(cPlusMinus, c_m, c_d))
            
            cBlock.name = NSUUID().uuidString
            
            addChild(cBlock)
            allBlocks.append(cBlock)
            firstLayblocks.append(cBlock)
            isFirst = false
            afterEqual = false
        }
        
        func createEqualBlock() {
            let equalBlock = Equal()
            equalBlock.name = "="
            
            addChild(equalBlock)
            allBlocks.append(equalBlock)
            firstLayblocks.append(equalBlock)
            isFirst = false
            afterEqual = true
        }
        
        
        for kind in sqb {
            
            switch kind {
            case .P:
                createParentBlock()
            case .X:
                createXBlock()
            case .C:
                createConstBlock()
            case .E:
                createEqualBlock()
            default:
                fatalError("Mはクエスチョンパターンに含まれない。")
            }
        }
        setMaxLevel()
    } // newQuestion()
    
    func buildQuestionPattern(){
        qptn.append([Kind.X, Kind.E, Kind.C])
        qptn.append([Kind.X, Kind.E, Kind.C, Kind.C])
        qptn.append([Kind.X, Kind.C, Kind.E, Kind.C])
        qptn.append([Kind.C, Kind.X, Kind.E, Kind.C])
        qptn.append([Kind.X, Kind.E, Kind.X, Kind.C])
        qptn.append([Kind.X, Kind.E, Kind.C, Kind.X])
        qptn.append([Kind.X, Kind.C, Kind.E, Kind.X, Kind.C])
        qptn.append([Kind.X, Kind.C, Kind.E, Kind.C, Kind.X])
        qptn.append([Kind.C, Kind.X, Kind.E, Kind.X, Kind.C])
        qptn.append([Kind.C, Kind.X, Kind.E, Kind.C, Kind.X])
        qptn.append([Kind.P, Kind.E, Kind.X])
        qptn.append([Kind.P, Kind.E, Kind.C])
        qptn.append([Kind.P, Kind.E, Kind.C, Kind.X])
        qptn.append([Kind.P, Kind.E, Kind.X, Kind.C])
        qptn.append([Kind.P, Kind.E, Kind.P])
        qptn.append([Kind.X, Kind.E, Kind.P])
        qptn.append([Kind.C, Kind.E, Kind.P])
        qptn.append([Kind.X, Kind.C, Kind.E, Kind.P])
        qptn.append([Kind.C, Kind.X, Kind.E, Kind.P])
    }
    
    func setMaxLevel() {
        maxLevel = 0
        for b in allBlocks {
            if maxLevel < b.level { maxLevel = b.level }
        }
    }
}
