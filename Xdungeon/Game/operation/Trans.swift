//
//  Trans.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/18.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class Trans: Operation {
    override var operation: String { get { return "Trans"}}
    
    private var touchBlock: Block?
    private var nextBlock: Block?, beforeBlock: Block?
    private var tPoint: CGPoint? // touch point
    private var isTransed = false
    
    private func leave() {
        fm.startAmination(duration: 0.36)
        for btn in bthbtn.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40 * 2, duration: drtn!))
        }
    }
    
    override func touchBegan(touch: UITouch, node: SKNode) {
        isTouched = true
        if let block = node.parent as? Block {
            guard !(block is Equal) else { return }
            
            if let multi = block as? Multi {
                if is1(multi) { deployForOne(multi); return }
                if multi.canMultiplication {
                    guard !fm.isAminated else { return }
                    fm.startAmination(duration: 0.36)
                    leave()
                    op = Multiplication(multi)
                    return
                }
                guard !fm.isAminated else { return }
                fm.startAmination(duration: 0)
                leave()
                op = Deployment(parent: multi.parent as! Parnt)
                op.touchBegan(touch: touch, node: node)
                
                return
            }
            
            touchBlock = block
            tPoint = touch.location(in: fm)
            block.isTouched = true
            block.zPosition = block.level + BRING_TO_FRONT
            print("touch")
            setChangeBlock(tb: block)
            isTransed = false
            return
        }
        if let btn = node.parent as? BothButton {
            op = Both(btn: btn)
            return
        }
    }
    
    override func touchMoved(touch: UITouch, node: SKNode) {
        guard let tb = touchBlock else { return }
        let tPointNow = touch.location(in: fm)
        let v = CGVector(dx: tPointNow.x - tPoint!.x, dy: tPointNow.y - tPoint!.y)
        tb.position = CGPoint(x: tb.position.x + v.dx,
                              y: tb.position.y + v.dy)
        tPoint = tPointNow
    
        // ← tb
        if let before = beforeBlock {
            if tb.position.x < before.ftrPoint.x + fs.space * 2 {
                moveBefore(touchBlock: tb, before: before)
                isTransed = true
                return
            }
        }
        
        // tb →
        if let next = nextBlock {
            if next.ftrPoint.x - fs.space * 2 < tb.position.x {
                moveNext(touchBlock: tb, next: next)
                isTransed = true
                return
            }
        }
    }
    
    override func touchEnded(touch: UITouch, node: SKNode) {
        isTouched = false
        guard let tb = touchBlock else { return }
        tb.isTouched = false
        tb.zPosition = tb.level
        fm.startAmination(duration: 0.24)
        tb.run(SKAction.move(to: CGPoint(x: tb.ftrPoint.x, y: 0), duration: drtn!))
        touchBlock = nil
        

        if !isTransed {
            guard let nb = tb as? NumBlock else { return }
            
            if nb.canMultiplication {
                fm.startAmination(duration: 0.36)
                leave()
                op = Multiplication(nb)
                return
            }
            
            if let clct = nb as? CollectableBlock {
                if let cid = clct.checkAndSetCollectID() {
                    fm.startAmination(duration: 0.36)
                    leave()
                    op = Addition(collectID: cid, cb: clct)
                    return
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) { }
    
    private func is1(_ m: Multi) -> Bool {
        let nlcount = m.labels.ns.count
        let num = m.labels.ns.first!.num
        let one = Num(true, 1, 1)
        return nlcount == 1 && num == one
    }
    
    private func deployForOne(_ m: Multi) {
        guard let p = m.parent as? Parnt else { return }
        p.cm.removeFromParent()
        
        let cbs: [Block] = p.childBlocks // child blocks
        cbs.first!.isFirst = p.isFirst
        
        if let pp = p.parent as? Parnt {
            let index = pp.childBlocks.index(of: p)!
            pp.childBlocks.remove(at: index)
            pp.childBlocks.insert(contentsOf: cbs, at: index)
            p.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.06),
                                     SKAction.run {
                                        for c in cbs {
                                            c.move(toParent: pp)
                                            c.level = c.level - 1
                                            c.isChangeContent = true
                                            c.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                                     SKAction.fadeIn(withDuration: 0.06)]))
                                        }
                },
                                     SKAction.removeFromParent()]))
        } else {
            let index = firstLayblocks.index(of: p)!
            firstLayblocks.remove(at: index)
            firstLayblocks.insert(contentsOf: cbs, at: index)
            p.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.06),
                                     SKAction.run {
                                        for c in cbs {
                                            c.move(toParent: fm)
                                            c.level = c.level - 1
                                            c.isChangeContent = true
                                            c.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                                     SKAction.fadeIn(withDuration: 0.06)]))
                                        }
                },
                                     SKAction.removeFromParent()]))
        }
        
        
        let pIndex = allBlocks.index(of: p)!
        allBlocks.remove(at: pIndex)
        let mIndex = allBlocks.index(of: p.cm)!
        allBlocks.remove(at: mIndex)
        fm.setMaxLevel()
        
        fm.startAmination(duration: 0.12)
        fm.resetBlocks()
    }
    
    private func setChangeBlock(tb: Block) {
        
        nextBlock = nil
        beforeBlock = nil
        guard !(tb is Multi) else { return } //tb is not multi
        
        if let p = tb.parent as? Parnt {
            if tb == p.childBlocks.first! { nextBlock = p.childBlocks[1] }
            else if tb == p.childBlocks.last { beforeBlock = p.childBlocks[p.childBlocks.endIndex - 2] }
            else {
                let index = p.childBlocks!.index(of: tb)!
                nextBlock   = p.childBlocks[index + 1]
                beforeBlock = p.childBlocks[index - 1]
            }
        } else {
            if tb == firstLayblocks.first     { nextBlock   = firstLayblocks[1]}
            else if tb == firstLayblocks.last { beforeBlock = firstLayblocks[firstLayblocks.endIndex - 2]}
            else {
                let index = firstLayblocks.index(of: tb)!
                nextBlock   = firstLayblocks[index + 1]
                beforeBlock = firstLayblocks[index - 1]
            }
        }
    }
    
    private func moveBefore(touchBlock tb: Block, before bf: Block) {
        print("moveBefore")
        // () 内のブロックを操作する場合
        if let p = tb.parent as? Parnt {
            let index = p.childBlocks.index(of: tb)!
            p.childBlocks[index - 1] = tb
            p.childBlocks[index]     = bf
            p.isChangeContent = true
            
            if bf.isFirst {
                tb.setIsFirst(true)
                bf.setIsFirst(false)
            }
            
            // = と同じ階層のブロックを操作する場合
        } else {
            let index = firstLayblocks.index(of: tb)!
            firstLayblocks[index - 1] = tb
            firstLayblocks[index]     = bf
            isAdjustAllBlocks = true
            
            if bf.isFirst {
                tb.setIsFirst(true)
                bf.setIsFirst(false)
            } else {
                tb.setIsFirst(false)
            }
            
            if let equal = bf as? Equal {
                tb.reverseSign()
                if let next = nextBlock {
                    next.setIsFirst(true)
                } else {
                    equal.setIsLast(true)
                }
            }
        }
        setChangeBlock(tb: tb)
        fm.startAmination(duration: 0.24)
        fm.resetBlocks()
        bthbtn.resetBothBtns()
    }
    
    private func moveNext(touchBlock tb: Block, next nx: Block) {
        print("moveNext")
        // () 内のブロックを操作する場合
        if let p = tb.parent as? Parnt {
            let index = p.childBlocks.index(of: tb)!
            p.childBlocks[index + 1] = tb
            p.childBlocks[index]     = nx
            p.isChangeContent = true
            
            if tb.isFirst {
                tb.setIsFirst(false)
                nx.setIsFirst(true)
            }
            
            // = と同じ階層のブロックを操作する場合
        } else {
            let index = firstLayblocks.index(of: tb)!
            firstLayblocks[index + 1] = tb
            firstLayblocks[index]     = nx
            isAdjustAllBlocks = true
            
            
            if tb.isFirst {
                tb.setIsFirst(false)
                nx.setIsFirst(true)
            }
            
            if let equal = nx as? Equal {
                tb.reverseSign()
                tb.setIsFirst(true)
                
                if firstLayblocks.last! == tb {
                    equal.setIsLast(false)
                } else {
                    firstLayblocks[index + 2].setIsFirst(false)
                }
            }
        }
        setChangeBlock(tb: tb)
        fm.startAmination(duration: 0.24)
        fm.resetBlocks()
        bthbtn.resetBothBtns()
    }
}
