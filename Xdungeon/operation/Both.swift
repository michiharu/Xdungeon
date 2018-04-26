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
    
    private var start: CFTimeInterval?
    private var isPrepared = false
    
    var waitAndMove: SKAction!
    
    // empty = Num(true, 1, 0)
    
    override init() {
        super.init()
    }
    
    convenience init(btn: BothButton) {
        self.init()
        bothBtn = btn
        bothBtn.isSelected = true
        
        /**--------------------------------------------------------------*/
        let initFadeIn = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                        SKAction.wait(forDuration: 0.02),
                                        SKAction.fadeIn(withDuration: 0.1)])
        let initMove = SKAction.moveTo(y: 0, duration: 0.24)
        waitAndMove = SKAction.sequence([initFadeIn,initMove])
        /**--------------------------------------------------------------*/
        
        
        let move = SKAction.moveTo(y: fs.splitBase, duration: 0.24)
        
        let wait    = SKAction.wait(forDuration: 0.12)
        let fadeout = SKAction.fadeOut(withDuration: 0.12)
        let fadeIn = SKAction.fadeIn(withDuration: 0.12)
        
        let moveAndFadeOut = SKAction.group([move, SKAction.sequence([wait, fadeout])])
        let action = SKAction.sequence([moveAndFadeOut, fadeIn])
        
        for b in firstLayblocks {
            b.run(action)
            b.ftrPoint.y = fs.splitBase
        }
        
        for btn in stnry.bothBtns {
            if !btn.isSelected { btn.run(SKAction.moveTo(y: -fs.h40 * 2, duration: 0.24)) }
        }
        makeSelect()
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
        let cm = Multi(parentID: parentID, isFirst: true, level: 0, num: Num(true, 1, 0))
        cm.name = NSUUID().uuidString
        
        for c in children {
            c.position.y = 0
            c.ftrPoint.y = 0
            c.removeAllActions()
            c.run(SKAction.fadeIn(withDuration: 0))
        }
        let p = Parnt(parentID: "", isFirst: true, level: 0, multi: cm, blocks: children)
        p.name = parentID
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
        selects.append(BothSelect(num: Num(true, i, 1)))
        selects.append(BothSelect(num: Num(false, i, 1)))
        selects.append(BothSelect(num: Num(true, 1, i)))
        selects.append(BothSelect(num: Num(false, 1, i)))
        
        let isLeft = bothBtn.position.x < 0
        
        let resultV = getStartVector(isLeft: isLeft)
        let startPosition = getStartPosition(vector: resultV)
        let points = get4Positions(isLeft: isLeft, start: startPosition)
        var sequences: [ArraySlice<CGPoint>] = []
        
        for i in 0...3 { sequences.append(points.prefix(4 - i)) }
        
        if isLeft {
            for (i, btn) in selects.enumerated() {
                stnry.addChild(btn)
                btn.position = bothBtn.position

                let follow = makeMoveActions(points: sequences[i], d: 0.05)
                let fadeInAndMove = SKAction.group([SKAction.fadeIn(withDuration: 0.06), follow])
                let action = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                SKAction.wait(forDuration: 0.06 * Double(i)),
                                                fadeInAndMove])
                btn.run(action)
            }
        } else {
            for (i, btn) in selects.reversed().enumerated() {
                stnry.addChild(btn)
                btn.position = bothBtn.position
                
                let follow = makeMoveActions(points: sequences[i], d: 0.05)
                let fadeInAndMove = SKAction.group([SKAction.fadeIn(withDuration: 0.06), follow])
                let action = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                SKAction.wait(forDuration: 0.06 * Double(i)),
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
    
    private func makeMoveActions(points: ArraySlice<CGPoint>, d: TimeInterval) -> SKAction {
        var moveActs: [SKAction] = []
        for p in points { moveActs.append(SKAction.move(to: p, duration: d)) }
        return SKAction.sequence(moveActs)
    }
    
    override func touchBegan(touch: UITouch, node: SKNode) { }
    
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
        guard nowSelect != nil else { leave(); op = Trans(); return }
        let targets = getTargetBlock()
        for t in targets {
            t.changeShape(shapeState: .have, fillColor: clr.shape)
            t.isChangeContent = true
        }
        
        for b in allBlocks {
            if !(b is Equal) {
                b.changeShape(shapeState: .have)
            }
            if b.level == 0  {
                b.run(waitAndMove)
                b.ftrPoint.y = 0
            }
        }
        
        bothBtn.isSelected = false
        for btn in stnry.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: 0.24))
        }
        
        for s in selects { s.removeFromParent() }
        
        op = Trans()
    }
    
    private func leave() {
        if let l = left {
            undo(side: l)
        }
        
        if let r = right {
            undo(side: r)
        }
        
        let fadeIn = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                        SKAction.wait(forDuration: 0.02),
                                        SKAction.fadeIn(withDuration: 0.1)])
        let move = SKAction.moveTo(y: 0, duration: 0.24)
        let waitAndMove = SKAction.sequence([fadeIn,move])
        
        for b in allBlocks {
            if !(b is Equal) {
                b.ss = .have
                b.shape!.fillColor = clr.shape
            }
            if b.level == 0  {
                b.run(waitAndMove)
                b.ftrPoint.y = 0
            }
        }
        
        bothBtn.isSelected = false
        for btn in stnry.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: 0.24))
        }
        
        for s in selects { s.removeFromParent() }
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
                p.cm.removeLastMuler(duration: 0.12)
            } else {
                guard let nb = side.block as? NumBlock else { fatalError("Parnt以外であれば必ずNumBlock") }
                nb.removeLastMuler(duration: 0.12)
            }
        } else {
            guard let p = side.block as? Parnt else { fatalError("ここでは必ずmakeParent済み") }
            removeParnt(p: p)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let s = start else { start = currentTime; return }
        if s + 0.24 < currentTime && !isPrepared {
            isPrepared = true
            prepareFormula()
        }
    }
}
