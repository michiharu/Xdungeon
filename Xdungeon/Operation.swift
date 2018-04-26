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
    
    private var isMoved = false
    var scale:  CGFloat!
    
    var originX: CGFloat { get { return -fs.width  * 0.5 / scale }}
    var originY: CGFloat { get { return -fs.height * 0.5 / scale }}
    var limitX:  CGFloat { get { return  fs.width  * 0.5 / scale }}
    var limitY:  CGFloat { get { return  fs.height * 0.5 / scale }}
    
    private var touchBlock: Block?
    private var nextBlock: Block?, beforeBlock: Block?
    private var tPoint: CGPoint? // touch point in operation zone
    private var depParnt: Parnt?
    
    private var selectMuler: NumBlock?
    private var selectsPlus: [NumBlock] = []
    
    private var choiceButtons: [ChoiceButton] = []
            var correct: Num!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        buildQuestionPattern()
        newQuestion()
    }
    
    func touchBegan(touch: UITouch, node: SKNode) {
        if let block = node.parent as? Block {
            touchBlockBegan(touch: touch, block: block)
        }
    }
    
    func touchBlockBegan(touch: UITouch, block: Block) {
        guard !(block is Equal) else { return }
        
        touchBlock = block
        tPoint = touch.location(in: self)
        block.zPosition = block.level + BRING_TO_FRONT
        if let m = block as? Multi {
            if let d = depParnt {
                if m.parent != d {
                    depParnt!.cancelDeployment()
                    depParnt = (m.parent as! Parnt)
                    depParnt!.prepareDeployment()
                } else if m.canDeploy {
                    changeStructure(p: d)
                }
            } else {
                depParnt = (m.parent as! Parnt)
                depParnt!.prepareDeployment()
            }
            return
        }
        if let sm = selectMuler {
            if block != sm { releaseMulti() }
        }
        
        /*
         *  展開実行中の親ブロックを触った場合は touchBlock = nil
         *  展開実効開始時にcmはremoveFromParent()しているため親を持たない
         */
        if touchBlock == depParnt && depParnt?.cm.parent == nil {
            touchBlock = nil
        } else {
            depParnt?.cancelDeployment()
            depParnt = nil
            setChangeBlock(tb: block)
        }
        isMoved = false
    }
    
//    func touchMultiButton(_ multi: MultiButton) {
//        guard let numBlock = multi.parent as? NumBlock else { return }
//        numBlock.isMultiCalc = true
//
//        state = .calculation
//        calc.prepareCalc()
//
//        let moveTo = SKAction.moveTo(y: fs.height * 0.3125, duration: 0.3)
//        let minScale = SKAction.scale(to: min(fs.minSc, scale), duration: 0.3)
//        formula.run(SKAction.group([moveTo,minScale]))
//        for b in allBlocks { if numBlock != b { b.shape?.run(SKAction.fadeAlpha(to: 0, duration: 0.3)) }}
//    }
    
//    func returnFromMultiCalc(blockName: String) {
//        var changeBlock: NumBlock!
//        for b in allBlocks {
//            if b.name == blockName { if let nb = b as? NumBlock { changeBlock = nb }}
//            b.shape?.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
//        }
//        for label in changeBlock.nl.all {
//            label.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5),
//                                         SKAction.fadeIn(withDuration: 0.5)]))
//        }
//        changeBlock.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                           SKAction.run { changeBlock.getMultiAnswer(correct: calc.correct) }]))
//
//        let moveTo = SKAction.moveTo(y: 0, duration: 0.3)
//        let minScale = SKAction.scale(to: scale, duration: 0.3)
//        formula.run(SKAction.group([moveTo,minScale]))
//    }
    
    func touchMoved(touch: UITouch) {
        let tPointNow = touch.location(in: self)
        
        if let tb = touchBlock {
            let v = CGVector(dx: tPointNow.x - tPoint!.x, dy: tPointNow.y - tPoint!.y)
            tb.position = CGPoint(x: tb.position.x + v.dx,
                                  y: tb.position.y + v.dy)
            tPoint = tPointNow
            
            // 展開関連処理
            if let p = depParnt {
                connectDeploymentLine(touchBlock: tb, parent: p)
                return
            }
            
            // ← tb
            if let before = beforeBlock {
                if tb.position.x < before.futureX + fs.space * 2 {
                    moveBefore(touchBlock: tb, before: before)
                    isMoved = true
                    return
                }
            }
            
            // tb →
            if let next = nextBlock {
                if next.futureX - fs.space * 2 < tb.position.x {
                    moveNext(touchBlock: tb, next: next)
                    isMoved = true
                    return
                }
            }
        }
    }
    
    func touchEnded() {
        if let tb = touchBlock {
            tb.zPosition = tb.level
            tb.run(SKAction.move(to: CGPoint(x: tb.futureX, y: 0), duration: 0.15))
            touchBlock = nil
            if let n = tb as? NumBlock {
                if n.isMultiCalc && !isMoved { selectMulti(n: n)}
            }
        }
    }
    
    func selectMulti(n: NumBlock) {
        n.selected()
        selectMuler = n
        let moveUp = SKAction.moveTo(y: fs.h25, duration: 0.3)
        moveUp.timingMode = .easeInEaseOut
        for b in allBlocks {
            if let p = b as? Parnt {p.shape!.fillColor = .clear }
            if b.level == 0 { b.run(moveUp) }
        }
        makeMultiChoice()
    }
    
    func releaseMulti() {
        selectMuler = nil
        for cb in choiceButtons { cb.removeFromParent() }
        choiceButtons = []
        for b in allBlocks { if !(b is Equal) { b.shape!.fillColor = clr.shape }}
    }
    
    func makeMultiChoice() {
        guard let sb = selectMuler else { return } // unwrap
        
        let answers = returnAnswers(labels: sb.labels)
        
        var max: CGFloat = 0
        for answer in answers {
            let btn = ChoiceButton(isFirst: true, isX: sb.labels.isX, isMulti: sb.labels.isMulti, num: answer)
            if answer == correct { btn.isCorrect = true }
            
            btn.position.y =  -fs.h25
            btn.setLabels()
            if max < btn.width { max = btn.width }
            choiceButtons.append(btn)
        }
        
        let positions = returnButtonPositionX(seed:       sb.position.x,
                                             buttonWidth: max,
                                             numOfButton: choiceButtons.count)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait   = SKAction.wait(forDuration: 0.3)
        
        for (i, btn) in choiceButtons.enumerated() {
            btn.setShape(w: max)
            let path = makePath(seed: sb.position, cb: CGPoint(x: positions[i], y: -fs.h25 - fs.barc))
            let follow = SKAction.follow(path, asOffset: false, orientToPath: false, duration: 0.6)
            follow.timingMode = .easeInEaseOut
            let fadeInAndFollow = SKAction.group([fadeIn, follow])
            
            let stop   = SKAction.run {
                btn.removeAllActions()
                btn.run(SKAction.move(to: CGPoint(x: positions[i], y: -fs.h25), duration: 0.3))
            }
            
            let waitAndStop = SKAction.sequence([wait, stop])
            
            let followAndStop = SKAction.group([fadeInAndFollow, waitAndStop])
            
            btn.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                       SKAction.wait(forDuration: 0.1 * Double(i)),
                                       followAndStop]))
            addChild(btn)
            
            let seedPoint = CGPoint(x: sb.position.x, y:  fs.h25 - fs.bsz * 0.5)
            let cbPoint   = CGPoint(x: positions[i],  y: -fs.h25 + fs.bsz * 0.5)
            
            btn.line = makeLine(seed: seedPoint, cb: cbPoint)
            btn.line!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                             SKAction.wait(forDuration: 0.3),
                                             SKAction.fadeIn(withDuration: 0.6)]))
            addChild(btn.line!)
        }
    }
    
    func setMultiCorrectAnswer(_ n: NumLabels) {
        var isPlus =  n.nl.num.isPlus
        var tmpMole = n.nl.num.mole
        var tmpDeno = n.nl.num.deno
        for ml in n.mls {
            if !ml.num.isPlus { isPlus = !isPlus }
            tmpMole = tmpMole * ml.num.mole
            tmpDeno = tmpDeno * ml.num.deno
        }
        let (mole, deno) = reduce(m: tmpMole, d: tmpDeno)
        correct = Num(isPlus, mole, deno)
    }
    
    func returnAnswers(labels: NumLabels) -> [Num] {
        // 符号間違い
        func makeMultiWrongAnswer1(_ n: NumLabels) -> Num {
            return Num(!correct.isPlus, correct.mole, correct.deno)
        }
        
        // 逆数間違い
        func makeMultiWrongAnswer2(_ n: NumLabels) -> Num {
            return Num(correct.isPlus, correct.deno, correct.mole)
        }
        
        // nlを逆数として計算
        func makeMultiWrongAnswer3(_ n: NumLabels) -> Num {
            var isPlus =  n.nl.num.isPlus
            var tmpMole = n.nl.num.deno
            var tmpDeno = n.nl.num.mole
            for ml in n.mls {
                if !ml.num.isPlus { isPlus = !isPlus }
                tmpMole = tmpMole * ml.num.mole
                tmpDeno = tmpDeno * ml.num.deno
            }
            let (mole, deno) = reduce(m: tmpMole, d: tmpDeno)
            return Num(isPlus, mole, deno)
        }
        
        // 符号間違い&nlを逆数として計算
        func makeMultiWrongAnswer4(_ n: NumLabels) -> Num {
            var isPlus = !n.nl.num.isPlus
            var tmpMole = n.nl.num.deno
            var tmpDeno = n.nl.num.mole
            for ml in n.mls {
                if !ml.num.isPlus { isPlus = !isPlus }
                tmpMole = tmpMole * ml.num.mole
                tmpDeno = tmpDeno * ml.num.deno
            }
            let (mole, deno) = reduce(m: tmpMole, d: tmpDeno)
            return Num(isPlus, mole, deno)
        }
        // mlsのいくつかを逆数として計算
        func makeMultiWrongAnswer5(_ n: NumLabels) -> Num {
            var isPlus =  n.nl.num.isPlus
            var tmpMole = n.nl.num.mole
            var tmpDeno = n.nl.num.deno
            var isUpSideDown = false
            for (i, ml) in n.mls.enumerated() {
                if !ml.num.isPlus { isPlus = !isPlus }
                if randBool() || (i == n.mls.count - 1 && !isUpSideDown) {
                    isUpSideDown = true
                    tmpMole = tmpMole * ml.num.deno
                    tmpDeno = tmpDeno * ml.num.mole
                } else {
                    tmpMole = tmpMole * ml.num.mole
                    tmpDeno = tmpDeno * ml.num.deno
                }
            }
            let (mole, deno) = reduce(m: tmpMole, d: tmpDeno)
            return Num(isPlus, mole, deno)
        }
        
        // 符号間違い&mlsのいくつかを逆数として計算
        func makeMultiWrongAnswer6(_ n: NumLabels) -> Num {
            var isPlus =  n.nl.num.isPlus
            var tmpMole = n.nl.num.mole
            var tmpDeno = n.nl.num.deno
            var isUpSideDown = false
            for (i, ml) in n.mls.enumerated() {
                if !ml.num.isPlus { isPlus = !isPlus }
                if randBool() || (i == n.mls.count - 1 && !isUpSideDown) {
                    isUpSideDown = true
                    tmpMole = tmpMole * ml.num.deno
                    tmpDeno = tmpDeno * ml.num.mole
                } else {
                    tmpMole = tmpMole * ml.num.mole
                    tmpDeno = tmpDeno * ml.num.deno
                }
            }
            let (mole, deno) = reduce(m: tmpMole, d: tmpDeno)
            return Num(isPlus, mole, deno)
        }
        setMultiCorrectAnswer(labels)
        
        var answers: [Num] = [correct, makeMultiWrongAnswer1(labels)]
        let wrong2 = makeMultiWrongAnswer2(labels)
        if !answers.contains(wrong2) { answers.append(wrong2) }
        
        let wrong3 = makeMultiWrongAnswer3(labels)
        if !answers.contains(wrong3) { answers.append(wrong3) }
        
        if answers.count < 4 {
            let wrong4 = makeMultiWrongAnswer4(labels)
            if !answers.contains(wrong4) { answers.append(wrong4) }
        }
        
        if answers.count < 4 {
            let wrong5 = makeMultiWrongAnswer5(labels)
            if !answers.contains(wrong5) { answers.append(wrong5) }
        }
        
        if answers.count < 4 {
            let wrong6 = makeMultiWrongAnswer6(labels)
            if !answers.contains(wrong6) { answers.append(wrong6) }
        }
        
        for (i, _) in answers.enumerated() {
            answers.swapAt(answers.count - (i + 1), (randNum(seed: answers.count - i) - 1))
        }
        return answers
    }
    
    func returnButtonPositionX(seed: CGFloat, buttonWidth bw: CGFloat, numOfButton: Int) -> [CGFloat] {
        
        let tw: CGFloat = (bw + fs.space * 2) * CGFloat(numOfButton)
        var positions: [CGFloat] = []
        var a: CGFloat
        
        if seed - tw * 0.5 < originX {
            a = originX + fs.space
        } else if limitX < seed + tw * 0.5 {
            a = limitX - tw + fs.space
        } else {
            a = seed - tw * 0.5 + fs.space
        }

        for _ in 1...numOfButton {
            positions.append(a + bw * 0.5)
            a += bw + fs.space * 2
        }
        return positions
    }
    
    
    func makeLine(seed: CGPoint, cb: CGPoint) -> SKShapeNode {
        let path = makePath(seed: seed, cb: cb)
        let line = SKShapeNode(path: path)
        line.strokeColor = clr.chln
        line.glowWidth = fs.hglw
        line.lineWidth = fs.hlw
        return line
    }
    
    func makePath(seed: CGPoint, cb: CGPoint) -> CGMutablePath {
        
        let path = CGMutablePath()
        let (seedBelow, cbAbove) = (CGPoint(x: seed.x, y: seed.y - fs.lncrv),
                                    CGPoint(x: cb.x  , y: cb.y   + fs.lncrv))
        
        let start = CGPoint(x: seed.x, y: seed.y )
        let goal  = CGPoint(x: cb.x  , y: cb.y)
        
        path.move   (to: start)
        path.addCurve(to: goal , control1: seedBelow, control2: cbAbove)
        path.closeSubpath()
        return path
    }
    
//    func getFirstAndLastSideLines() -> (CGFloat, CGFloat) {
//        
//    }
    
    func releasePlus() {
        selectsPlus = []
        for b in allBlocks { b.shape!.fillColor = clr.shape }
    }
    
    func update() {
        depParnt?.remakeLines()
        resetBlocks()
        if let tb = touchBlock { tb.removeAllActions() }
    }
    
    func setChangeBlock(tb: Block) {
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
            if tb == firstLayblocks.first! { nextBlock = firstLayblocks[1] }
            else if tb == firstLayblocks.last { beforeBlock = firstLayblocks[firstLayblocks.endIndex - 2]}
            else {
                let index = firstLayblocks.index(of: tb)!
                nextBlock   = firstLayblocks[index + 1]
                beforeBlock = firstLayblocks[index - 1]
            }
        }
    }
    
    func connectDeploymentLine(touchBlock tb: Block, parent p: Parnt) {
        var count = 0
        for (i, c) in p.childBlocks.enumerated() {
            let distance = pow(tb.position.x - c.position.x, 2) + pow(tb.position.y - c.position.y, 2)
            if distance < fs.bsz * fs.bsz / 4 && !c.cl!.isConnected {
                p.connectLine(index: i)
                tb.run(
                    SKAction.sequence([SKAction.move(to: CGPoint(x: tb.futureX, y: 0), duration: 0),
                                       SKAction.run({ tb.zPosition = tb.level })]))
                touchBlock = nil
                break
            }
            count += 1
        }
        if p.isConnectedAll { p.cm.changeButtonMode() }
        return
    }
    
    func moveBefore(touchBlock tb: Block, before bf: Block) {
        // () 内のブロックを操作する場合
        if let p = tb.parent as? Parnt {
            let index = p.childBlocks.index(of: tb)!
            p.childBlocks[index - 1] = tb
            p.childBlocks[index]     = bf
            p.isChangeContent = true
            
            if bf.isFirst {
                tb.setIsFirst(isFirst: true)
                bf.setIsFirst(isFirst: false)
            }
            
            // = と同じ階層のブロックを操作する場合
        } else {
            let index = firstLayblocks.index(of: tb)!
            firstLayblocks[index - 1] = tb
            firstLayblocks[index]     = bf
            isAdjustAllBlocks = true
            
            if bf.isFirst {
                tb.setIsFirst(isFirst: true)
                bf.setIsFirst(isFirst: false)
            } else {
                tb.setIsFirst(isFirst: false)
            }
            
            if let equal = bf as? Equal {
                tb.reverseSign()
                if let next = nextBlock {
                    next.setIsFirst(isFirst: true)
                } else {
                    equal.setIsLast(isLast: true)
                }
            }
        }
        setChangeBlock(tb: tb)
    }
    
    func moveNext(touchBlock tb: Block, next nx: Block) {
        // () 内のブロックを操作する場合
        if let p = tb.parent as? Parnt {
            let index = p.childBlocks.index(of: tb)!
            p.childBlocks[index + 1] = tb
            p.childBlocks[index]     = nx
            p.isChangeContent = true
            
            if tb.isFirst {
                tb.setIsFirst(isFirst: false)
                nx.setIsFirst(isFirst: true)
            }
            
            // = と同じ階層のブロックを操作する場合
        } else {
            let index = firstLayblocks.index(of: tb)!
            firstLayblocks[index + 1] = tb
            firstLayblocks[index]     = nx
            isAdjustAllBlocks = true
            
            
            if tb.isFirst {
                tb.setIsFirst(isFirst: false)
                nx.setIsFirst(isFirst: true)
            }
            
            if let equal = nx as? Equal {
                tb.reverseSign()
                tb.setIsFirst(isFirst: true)
                
                if firstLayblocks.last! == tb {
                    equal.setIsLast(isLast: false)
                } else {
                    firstLayblocks[index + 2].setIsFirst(isFirst: false)
                }
            }
        }
        setChangeBlock(tb: tb)
    }
    
    func resetBlocks() {
        var currentLevel : CGFloat = 3
        while 0 <= currentLevel {
            for block in allBlocks {
                if block.level == currentLevel && block.isChangeContent {
                    block.changeContent()
                }
            }
            currentLevel -= 1
        }
        if isAdjustAllBlocks { adjustFirstLayPosition() }
    }
    
    var firstLine: SKShapeNode!
    
    func adjustFirstLayPosition() {
        isAdjustAllBlocks = false
        var tw = fs.space
        for block in firstLayblocks { tw += block.width + fs.space }
        scale = min(fs.width / (tw + fs.bsz), 1)
        
        var a = (-tw * 0.5) + fs.space
        for block in firstLayblocks {
            block.futureX = a + block.width * 0.5
            block.run(SKAction.move(to: CGPoint(x: a + block.width * 0.5, y: 0), duration: 0.15))
            a += block.width + fs.space
        }
        
        run(SKAction.scale(to: scale, duration: 0.15))
    }
    
    func changeStructure(p: Parnt) {
        let cbs = p.deploy() // child blocks
        if let pp = p.parent as? Parnt {
            let index = pp.childBlocks.index(of: p)!
            pp.childBlocks.remove(at: index)
            pp.childBlocks.insert(contentsOf: cbs, at: index)
            for c in cbs { c.move(toParent: pp) }
        } else {
            let index = firstLayblocks.index(of: p)!
            firstLayblocks.remove(at: index)
            firstLayblocks.insert(contentsOf: cbs, at: index)
            for c in cbs { c.move(toParent: self) }
        }
        let pIndex = allBlocks.index(of: p)!
        allBlocks.remove(at: pIndex)
        let mIndex = allBlocks.index(of: p.cm)!
        allBlocks.remove(at: mIndex)
    }
    
    func newQuestion(){
        
        sqb = qptn[14]//Int(arc4random_uniform(18))
        print(sqb)
        
        var firstX_plus = true, firstX_m = 0, firstX_d = 0, afterEqual = false, isFirst = true
        
        func createParentBlock() {
            var mPlusMinus = randBool(), (e_m, e_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
            while mPlusMinus && e_m == 1 && e_d == 1 {
                mPlusMinus = randBool(); (e_m, e_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
            }
            var xPlusMinus = randBool(), (x_m, x_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
            let cPlusMinus = randBool(), (c_m, c_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
            if firstX_d == 0 {
                firstX_plus = (xPlusMinus && mPlusMinus) || (!xPlusMinus && !mPlusMinus)
                let firstX = reduce(m: x_m * e_m, d: x_d * e_d); firstX_m = firstX.m; firstX_d = firstX.d
            } else {
                var isXPlus = (xPlusMinus == mPlusMinus)
                var x = reduce(m: x_m * e_m, d: x_d * e_d), m = x.0, d = x.1
                while firstX_plus == isXPlus && firstX_m == m && firstX_d == d {
                    xPlusMinus = randBool(); (x_m, x_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
                    isXPlus = (xPlusMinus == mPlusMinus); x = reduce(m: x_m * e_m, d: x_d * e_d); m = x.0; d = x.1
                }
            }
            let parentID = NSUUID().uuidString
            
            
            let mBlock = Multi(parentID: parentID,
                               isFirst: (isFirst || afterEqual),
                               level: 1,
                               num: Num(mPlusMinus, e_m, e_d))
            
            let xBlock = VarX (parentID: parentID,
                               isFirst: true,
                               level: 1,
                               num: Num(xPlusMinus, x_m, x_d))
            
            let cBlock = Const(parentID: parentID,
                               isFirst: false,
                               level: 1,
                               num: Num(cPlusMinus, c_m, c_d))
            
            
            let pBlock = Parnt(parentID: "",
                               isFirst: (isFirst || afterEqual),
                               level: 0,
                               muler: mBlock,
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
            var xPlusMinus = randBool(), (x_m, x_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
            if firstX_d == 0 { firstX_plus = xPlusMinus; firstX_m = x_m; firstX_d = x_d }
            else {
                while firstX_plus == xPlusMinus && firstX_m == x_m && firstX_d == x_d {
                    xPlusMinus = randBool(); (x_m, x_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
                }
            }
            let xBlock = VarX(parentID: "",
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
            let cPlusMinus = randBool(), (c_m, c_d) = reduce(m: randNum(seed: 6), d: randNum(seed: 6))
            
            let cBlock = Const(parentID: "",
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
    
//    func setNumForBothSides(){
//        var numbers:[Int] = []
//        for b in allBlocks {
//
//        }
//    }
    
    
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
