//
//  Both.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/18.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class Both: Operation {
    
    override var operation: String { get { return "Both"}}
    
    private var bothBtn: BothButton!
    private var selects: [BothSelect] = []
    private var nowSelect: BothSelect?
    private var left:  (isSetMuler: Bool, block: Block)?
    private var right: (isSetMuler: Bool, block: Block)?
    
    var waitAndMove: SKAction!
    
    convenience init(btn: BothButton) {
        self.init()
        bothBtn = btn
        bothBtn.isSelected = true
        
        fm.startAmination(duration: 0.24)
        
        let move = SKAction.moveTo(y: fs.splitBase, duration: drtn!)
        for b in firstLayblocks { b.run(move); b.ftrPoint.y = fs.splitBase }
        for btn in bthbtn.bothBtns {
            if !btn.isSelected { btn.run(SKAction.moveTo(y: -fs.h40 * 2, duration: drtn!)) }
        }
        makeSelect()
        let nextAction = SKAction.run {
            fm.startAmination(duration: 0.12)
            self.prepareFormula()
            fm.resetBlocks()
        }
        fm.run(SKAction.sequence([SKAction.wait(forDuration: 0.24),
                                  nextAction]))
    }
    
    func prepareFormula() {
        var equal: Equal?
        var leftBlocks : [Block] = []
        var rightBlocks: [Block] = []

        for b in firstLayblocks {
            if let e = b as? Equal {
                equal = e
            } else {
                b.removeFromParent()
                if equal == nil { leftBlocks.append(b) } else { rightBlocks.append(b) }
            }
        }
        guard let e = equal else { fatalError() }
        
        for b in allBlocks {
            b.changeShape(shapeState: .none)
        }
        
        firstLayblocks = []
        
        if 1 < leftBlocks.count {
            let parent = makeParent(children: leftBlocks)
            parent.position.y = fs.splitBase
            parent.ftrPoint.y = fs.splitBase
            left = (false,parent)
            firstLayblocks.append(left!.block)
            fm.addChild(left!.block)
            
            allBlocks.append(left!.block)
            allBlocks.append(parent.cm)
        } else if leftBlocks.count == 1 {
            left = (true, setEmptyMuler(block: leftBlocks.first!))
            firstLayblocks.append(left!.block)
            fm.addChild(left!.block)
        } else {
            e.isFirst = true
            e.isLast  = false
        }
        
        firstLayblocks.append(e)
        
        if 1 < rightBlocks.count {
            let parent = makeParent(children: rightBlocks)
            parent.position.y = fs.splitBase
            parent.ftrPoint.y = fs.splitBase
            right = (false, parent)
            firstLayblocks.append(right!.block)
            fm.addChild(right!.block)
            
            allBlocks.append(right!.block)
            allBlocks.append(parent.cm)
        } else if rightBlocks.count == 1 {
            right = (true, setEmptyMuler(block: rightBlocks.first!))
            firstLayblocks.append(right!.block)
            fm.addChild(right!.block)
        } else {
            e.isFirst = false
            e.isLast  = true
        }
        
        fm.setMaxLevel()
    }
    
    func makeParent(children: [Block]) -> Parnt {
        guard children.count > 1 else { fatalError() }
        let parentID = NSUUID().uuidString
        let cm = Multi(parentID: parentID, level: 0, num: Num(true, 1, 0))
        cm.name = NSUUID().uuidString
        cm.setIsFirst(true)
        
        for c in children {
            c.position.y = 0
            c.ftrPoint.y = 0
        }
        let p = Parnt(parentID: "", level: 0, multi: cm, blocks: children)
        p.name = parentID
        p.setIsFirst(true)
        p.changeShape(shapeState: .none)
        p.incrementChilrenLevel()
        return p
    }
    
    func setEmptyMuler(block: Block) -> Block {
        if let p = block as? Parnt {
            p.cm.addMuler(ss: .emphasize, num: Num(true, 1, 0))
            return p
        } else if let nb = block as? NumBlock {
            nb.addMuler(ss: .emphasize, num: Num(true, 1, 0))
            return nb
        }
        fatalError()
    }
    
    func makeSelect() {
        let i: Int = bothBtn.int
        let isLeft = bothBtn.position.x < 0
        
        if i == 1 {
            selects.append(BothSelect(num: Num(false, 1, 1)))
            bthbtn.addChild(selects.first!)
            let unitV = (CGPoint(x: 0, y: fs.width) - bothBtn.position).unit
            let btnPoint = bothBtn.position + unitV * fs.bothsr
            selects.first!.position = bothBtn.position
            let fadeInAndMove = SKAction.group([SKAction.fadeIn(withDuration: drtn! * 0.2),
                                                SKAction.move(to: btnPoint, duration: drtn! * 0.2)])
            let action = SKAction.sequence([SKAction.fadeOut(withDuration: 0), fadeInAndMove])
            selects.first!.run(action)
            return
        }
        
        selects.append(BothSelect(num: Num(true, i, 1)))
        selects.append(BothSelect(num: Num(false, i, 1)))
        selects.append(BothSelect(num: Num(true, 1, i)))
        selects.append(BothSelect(num: Num(false, 1, i)))
        
        let resultV = getStartVector(isLeft: isLeft)
        let startPosition = getStartPosition(vector: resultV)
        let points = get4Positions(isLeft: isLeft, start: startPosition)
        
        if isLeft {
            for (i, btn) in selects.enumerated() {
                bthbtn.addChild(btn)
                btn.position = bothBtn.position

                let follow = SKAction.move(to: points[i], duration: drtn! * 0.2)
                let fadeInAndMove = SKAction.group([SKAction.fadeIn(withDuration: drtn! * 0.2), follow])
                let action = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                SKAction.wait(forDuration: drtn! * 0.2 * Double(i)),
                                                fadeInAndMove])
                btn.run(action)
            }
        } else {
            for (i, btn) in selects.reversed().enumerated() {
                bthbtn.addChild(btn)
                btn.position = bothBtn.position
                
                let follow = SKAction.move(to: points[i], duration: drtn! * 0.2)
                let fadeInAndMove = SKAction.group([SKAction.fadeIn(withDuration: drtn! * 0.2), follow])
                let action = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                SKAction.wait(forDuration: drtn! * 0.2 * Double(i)),
                                                fadeInAndMove])
                btn.run(action)
            }
        }
    }
    
    func getStartVector(isLeft: Bool) -> CGPoint {
        
        let unitV = (CGPoint(x: 0, y: fs.width) - bothBtn.position).unit
        let vrtclV = CGPoint(x: -unitV.y, y: unitV.x) * tan(CGFloat.pi * 0.35)
        let turn: CGPoint = !isLeft ? vrtclV : -vrtclV
        
        return (unitV + turn).unit
    }
    
    func getStartPosition(vector: CGPoint) -> CGPoint {
        return bothBtn.position + vector * fs.bothsr
    }
    
    private func get4Positions(isLeft: Bool, start: CGPoint) -> [CGPoint] {
        
        let angle: CGFloat = CGFloat.pi * 0.235
        
        var baseVector:  CGPoint = start - bothBtn.position
        var tmpVrtcl:    CGPoint = CGPoint(x: -baseVector.y, y: baseVector.x) * tan(angle)
        var vrtclVector: CGPoint = isLeft ? tmpVrtcl : -tmpVrtcl
        
        var points: [CGPoint] = [start]
        
        for _ in 0...2 {
            let long = baseVector + vrtclVector
            baseVector = long.unit * fs.bothsr
            points.append(baseVector + bothBtn.position)
            
            tmpVrtcl = CGPoint(x: baseVector.y, y: -baseVector.x) * tan(angle)
            vrtclVector = !isLeft ? tmpVrtcl : -tmpVrtcl
        }
        
        return points
    }
    
    override func touchBegan(touch: UITouch, node: SKNode) { isTouched = true }
    
    override func touchMoved(touch: UITouch, node: SKNode) {
        if let bs = node.parent as? BothSelect {
            guard nowSelect?.num != bs.num else { return }
            
            nowSelect = bs
            
            let targets = getTargetBlock()
            for t in targets {
                t.labels.ns[t.labels.ns.count - 1].num = bs.num.copy()
                t.isChangeContent = true
            }
        } else {
            guard nowSelect != nil else { return }
            
            nowSelect = nil
            let targets = getTargetBlock()
            for t in targets {
                t.labels.ns[t.labels.ns.count - 1].num = Num(true, 1, 0)
                t.isChangeContent = true
            }
        }
        fm.startAmination(duration: 0.06)
        fm.resetBlocks()
    }
    
    func getTargetBlock() -> [NumBlock] {
        var targets: [NumBlock] = []
        if let l = left {
            if let p = l.block as? Parnt {
                targets.append(p.cm)
            } else {
                let nb = l.block as! NumBlock
                targets.append(nb)
            }
        }
        if let r = right {
            if let p = r.block as? Parnt {
                targets.append(p.cm)
            } else {
                let nb = r.block as! NumBlock
                targets.append(nb)
            }
        }
        return targets
    }
    
    override func touchEnded(touch: UITouch, node: SKNode) {
        isTouched = false
        guard nowSelect != nil else { leave(); op = Trans(); return }
        
        bothBtn.isSelected = false
        for btn in bthbtn.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: 0.24))
        }
        
        for s in selects { s.removeFromParent() }
        
        
        let targets = getTargetBlock()
        for t in targets { t.ss = .have; t.isChangeContent = true }
        
        let nextAction = SKAction.run {
            fm.startAmination(duration: 0.12)
            for b in allBlocks {
                if b.level == 0  {
                    b.run(SKAction.moveTo(y: 0, duration: drtn!))
                    b.ftrPoint.y = 0
                }
            }
        }
        
        fm.startAmination(duration: 0.12)
        for b in allBlocks { if !(b is Equal) { b.ss = .have; b.isChangeContent = true }}
        fm.resetBlocks()
        fm.run(SKAction.sequence([SKAction.wait(forDuration: 0.12), nextAction]))
        
        op = Trans()
    }
    
    private func leave() {
        
        bothBtn.isSelected = false
        for btn in bthbtn.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: 0.24))
        }
        
        for s in selects { s.removeFromParent() }
        
        if let l = left {
            undo(side: l)
        }
        
        if let r = right {
            undo(side: r)
        }
        let nextAction = SKAction.run {
            fm.startAmination(duration: 0.12)
            for b in allBlocks {
                if !(b is Equal) {
                    b.ss = .have
                    b.shape!.fillColor = clr.shape
                }
                if b.level == 0  {
                    b.run(SKAction.moveTo(y: 0, duration: drtn!))
                    b.ftrPoint.y = 0
                }
            }
        }
        
        fm.startAmination(duration: 0.12)
        fm.resetBlocks()
        fm.run(SKAction.sequence([SKAction.wait(forDuration: 0.12), nextAction]))
    }
    
    func removeParnt(p: Parnt) {
        guard let cbs = p.childBlocks else { return }
        
        p.setLevel(p.level - 1)
        
        if let pp = p.parent as? Parnt {
            let index = pp.childBlocks.index(of: p)!
            pp.childBlocks.remove(at: index)
            pp.childBlocks.insert(contentsOf: cbs, at: index)
            for c in cbs {
                
                c.move(toParent: pp)
                c.position = c.absPoint
            }
        } else {
            let index = firstLayblocks.index(of: p)!
            firstLayblocks.remove(at: index)
            firstLayblocks.insert(contentsOf: cbs, at: index)
            for c in cbs {
                
                print(c.absPoint.description)
                c.move(toParent: fm)
                c.position = c.absPoint
            }
        }
        let pIndex = allBlocks.index(of: p)!
        allBlocks.remove(at: pIndex)
        let mIndex = allBlocks.index(of: p.cm)!
        allBlocks.remove(at: mIndex)
        
        p.removeFromParent()
        fm.run(SKAction.sequence([SKAction.wait(forDuration: 0.24),
                                  SKAction.run { isAdjustAllBlocks = true }]))
        
        fm.setMaxLevel()
    }
    
    func undo(side:(isSetMuler: Bool, block: Block)) {
        if side.isSetMuler {
            if let p = side.block as? Parnt {
                p.cm.removeLastMuler()
            } else {
                guard let nb = side.block as? NumBlock else { fatalError("Parnt以外であれば必ずNumBlock") }
                nb.removeLastMuler()
            }
        } else {
            guard let p = side.block as? Parnt else { fatalError("ここでは必ずmakeParent済み") }
            removeParnt(p: p)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
