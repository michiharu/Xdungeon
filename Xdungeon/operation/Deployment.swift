//
//  Deploy.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/18.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class Deployment: Operation {
    override var operation: String { get { return "Deploy"}}
    
    private var touchBlock: Block?
    private var tPoint:     CGPoint? // touch point
    private var parent:     Parnt!
    
    private let drtin: TimeInterval = 0.6
    
    init(_ parent: Parnt) {
        super.init()
        self.parent = parent
        
        parent.prepareDeployment()
    }
    
    // prepare -> init:       parent.prepareDeployment()
    // leave   -> touchBegan: parent.cancelDeployment()
    
    override func touchBegan(touch: UITouch, node: SKNode) {
        guard let block = node.parent as? Block else { return }
        guard let multi = block as? Multi else {
            parent.cancelDeployment()
            op = Trans()
            op.touchBegan(touch: touch, node: node)
            operationLabel.text = op.operation
            for btn in stnry.bothBtns { btn.run(SKAction.moveTo(y: -fs.h40, duration: drtin))}
            return
        }
        
        touchBlock = block
        tPoint = touch.location(in: fm)
        
        if multi.parent != parent {
            parent.cancelDeployment()
            parent = multi.parent as! Parnt
            parent.prepareDeployment()
        }
    }
    
    private func changeStructure(p: Parnt) {
        let cbs = p.deploy(duration: drtin) // child blocks
        if let pp = p.parent as? Parnt {
            let index = pp.childBlocks.index(of: p)!
            pp.childBlocks.remove(at: index)
            pp.childBlocks.insert(contentsOf: cbs, at: index)
            for c in cbs { c.move(toParent: pp) }
        } else {
            let index = firstLayblocks.index(of: p)!
            firstLayblocks.remove(at: index)
            firstLayblocks.insert(contentsOf: cbs, at: index)
            for c in cbs { c.move(toParent: fm) }
        }
        let pIndex = allBlocks.index(of: p)!
        allBlocks.remove(at: pIndex)
        let mIndex = allBlocks.index(of: p.cm)!
        allBlocks.remove(at: mIndex)
        fm.setMaxLevel()
        for btn in stnry.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: drtin))
        }
        op = Animation(Trans(), duration: drtin)
    }
    
    override func touchMoved(touch: UITouch, node: SKNode) {
        guard let tb = touchBlock else { return }
        let tPointNow = touch.location(in: fm)
        let v = CGVector(dx: tPointNow.x - tPoint!.x, dy: tPointNow.y - tPoint!.y)
        tb.position = CGPoint(x: tb.position.x + v.dx, y: tb.position.y + v.dy)
        tPoint = tPointNow
        connectLine(touchBlock: tb, parent: parent)
    }
    
    private func connectLine(touchBlock tb: Block, parent p: Parnt) {
        for (i, child) in p.childBlocks.enumerated() {
            if let p = child as? Parnt {
                let c = p.cm!
                let distance = pow(tb.position.x - c.position.x, 2) + pow(tb.position.y - c.position.y, 2)
                if distance < fs.bsz * fs.bsz / 4 && !c.dcl!.isConnected {
                    p.connectLine(index: i)
                    let move = SKAction.move(to: CGPoint(x: tb.ftrPoint.x, y: 0), duration: 0)
                    let setZ = SKAction.run({ tb.zPosition = tb.level })
                    tb.run(SKAction.sequence([move, setZ]))
                    touchBlock = nil
                    break
                }
            }
            if let c = child as? NumBlock {
                let distance = pow(tb.position.x - c.position.x, 2) + pow(tb.position.y - c.position.y, 2)
                if distance < fs.bsz * fs.bsz / 4 && !c.dcl!.isConnected {
                    p.connectLine(index: i)
                    let move = SKAction.move(to: CGPoint(x: tb.ftrPoint.x, y: 0), duration: 0)
                    let setZ = SKAction.run({ tb.zPosition = tb.level })
                    tb.run(SKAction.sequence([move, setZ]))
                    touchBlock = nil
                    break
                }
            }
        }
        if p.isConnectedAll {
            tb.position = tb.ftrPoint
            parent.remakeLines()
            p.cm.changeButtonMode()
            changeStructure(p: p)
        }
    }
    
    override func touchEnded(touch: UITouch, node: SKNode) {
        guard let tb = touchBlock else { return }
        tb.zPosition = tb.level
        tb.run(SKAction.move(to: CGPoint(x: tb.ftrPoint.x, y: 0), duration: 0.15))
        touchBlock = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        parent.remakeLines()
        touchBlock?.removeAllActions()
    }
}
