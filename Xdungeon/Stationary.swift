//
//  Stationary.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/20.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

class Stationary: SKNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bothBtns: [BothButton] = []
    
    override init() {
        super.init()
    }
    
    func resetBothBtns() {
        for btn in bothBtns { btn.removeFromParent() }
        bothBtns = []
        
        var ints: [Int] = []
        for block in allBlocks {
            if let numBlock = block as? NumBlock {
                ints = appendWithoutDuplication(block: numBlock, ints: ints)
            }
        }
        
        if 6 < ints.count { return }
        
        let tw = fs.bsz * CGFloat(ints.count)
        var a = -tw * 0.5
        
        for i in ints {
            let btn = BothButton(int: i)
            bothBtns.append(btn)
            
            btn.position = CGPoint(x: a + fs.bsz * 0.5, y: -fs.h40)
            a += fs.bsz
            addChild(btn)
        }
        
    }
    
    func appendWithoutDuplication(block: NumBlock, ints: [Int]) -> [Int] {
        var results = ints
        let nums = getSelectNums(block)
        for num in nums {
            if !ints.contains(num.mole) && num.mole > 1 { results.append(num.mole) }
            if !ints.contains(num.deno) && num.deno > 1 { results.append(num.deno) }
        }
        return results
    }
    
    func getSelectNums(_ block: NumBlock) -> [Num] {
        var selectNums: [Num] = []
        for n in block.labels.ns { selectNums.append(n.num.copy()) }
        return selectNums
    }
}
