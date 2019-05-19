//
//  Choice.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/20.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class Choice: Operation {
    
    fileprivate var selects: [NumBlock] = []
    fileprivate var targetX:  CGFloat!
    fileprivate var correct:  Num!
    fileprivate var choices:  [ChoiceButton] = []
    fileprivate var strokeColor: SKColor!
    
    
    
    override init() {
        super.init()
    }
    
    final func prepareChoices() {
        targetX = getTargetX()
        prepareFormula()
        correct = getCorrect(getSelectNums())
        choices = getChoices()
        setChoicesPosition()
    }
    
    fileprivate func getTargetX() -> CGFloat                { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func getSelectNums() -> [Num]               { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func getCorrect(_ nums: [Num]) -> Num       { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer1(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer2(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer3(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer4(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer5(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer6(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func makeWrongAnswer7(_ nums: [Num]) -> Num { fatalError("このメソッドはオーバーライドされなければなりません！") }
    fileprivate func changeFormula()                        { fatalError("このメソッドはオーバーライドされなければなりません！") }
    
    func prepareFormula() {
        let moveUp = SKAction.moveTo(y: fs.splitBase, duration: 0.36)
        for b in allBlocks {
            b.ss = .none
            for s in selects { if b == s { b.ss = .have }}
            b.changeShape(fillColor: clr.shape)
            
            if b.level == 0 {
                b.run(moveUp)
                b.ftrPoint.y = fs.splitBase
            }
        }
    }
    
    fileprivate final func getChoices() -> [ChoiceButton] {
        var btns: [ChoiceButton] = []
        
        let answers = returnAnswers(nums: getSelectNums())
        var max: CGFloat = 0
        var isX = false
        if let varx = selects.first as? CollectableBlock {
            isX = varx.kind == .X
        }
        
        for answer in answers {
            let btn = ChoiceButton(isX: isX, num: answer, color: strokeColor)
            if answer == correct { btn.isCorrect = true }
            if max < btn.width { max = btn.width }
            btns.append(btn)
        }
        
        for btn in btns {
            btn.width = max
            btn.setShape(w: max)
        }
        return btns
    }
    
    fileprivate final func setChoicesPosition() {
        let positions = getBtnX(seed: targetX, bw: choices.first!.width, count: choices.count)
        
        for (i, btn) in choices.enumerated() {
            btn.position.x = targetX
            let move = SKAction.move(to: CGPoint(x: positions[i], y: -fs.splitBase), duration: 0.3)
            move.timingMode = .easeInEaseOut
            let fadeInAndMove = SKAction.group([SKAction.fadeIn(withDuration: 0.1), move])
            
            btn.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                       SKAction.wait(forDuration: 0.1 * Double(i)),
                                       SKAction.run { btn.position.y = self.selects.first!.absPoint.y },
                                       fadeInAndMove]))
            fm.addChild(btn)
            
            let seedPoint = CGPoint(x: targetX,       y:  fs.splitBase - fs.bsz * 0.5)
            let cbPoint   = CGPoint(x: positions[i], y: -fs.splitBase + fs.bsz * 0.5)
            
            btn.line = makeLine(seed: seedPoint, cb: cbPoint)
            btn.line!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                             SKAction.wait(forDuration:     0.3),
                                             SKAction.fadeIn(withDuration:  0.6)]))
            fm.addChild(btn.line!)
        }
    }
    
    fileprivate final func returnAnswers(nums: [Num]) -> [Num] {
        var answers: [Num] = [correct, makeWrongAnswer1(nums)]
        
        let wrong2 = makeWrongAnswer2(nums)
        if !answers.contains(wrong2) { answers.append(wrong2) }
        
        if answers.count < choiceCount {
            let wrong3 = makeWrongAnswer3(nums)
            if !answers.contains(wrong3) { answers.append(wrong3) }
        }
        
        if answers.count < choiceCount {
            let wrong4 = makeWrongAnswer4(nums)
            if !answers.contains(wrong4) { answers.append(wrong4) }
        }
        
        if answers.count < choiceCount {
            let wrong5 = makeWrongAnswer5(nums)
            if !answers.contains(wrong5) { answers.append(wrong5) }
        }
        
        if answers.count < choiceCount {
            let wrong6 = makeWrongAnswer6(nums)
            if !answers.contains(wrong6) { answers.append(wrong6) }
        }
        
        if answers.count < choiceCount {
            let wrong7 = makeWrongAnswer6(nums)
            if !answers.contains(wrong7) { answers.append(wrong7) }
        }
    
        return answers.shuffled
    }
    
    fileprivate final func getBtnX(seed: CGFloat, bw: CGFloat, count: Int) -> [CGFloat] {
        
        let tw: CGFloat = (bw + fs.space * 2) * CGFloat(count)
        fm.changeScale(contentWidth: tw)
        var positions: [CGFloat] = []
        var a: CGFloat
        
        if seed - tw * 0.5 < fm.originX {
            a = fm.originX + fs.space
        } else if fm.limitX < seed + tw * 0.5 {
            a = fm.limitX - tw + fs.space
        } else {
            a = seed - tw * 0.5 + fs.space
        }
        
        for _ in 1...count {
            positions.append(a + bw * 0.5)
            a += bw + fs.space * 2
        }
        return positions
    }
    
    final func makeLine(seed: CGPoint, cb: CGPoint) -> SKShapeNode {
        let path = makePath(start: seed, goal: cb)
        let line = SKShapeNode(path: path)
        line.strokeColor = strokeColor
        line.glowWidth = fs.hglw
        line.lineWidth = fs.hlw
        return line
    }
    
    fileprivate final func makePath(isFirst: Bool = true, start: CGPoint, goal: CGPoint) -> CGMutablePath {
        
        let path = CGMutablePath()
        let scrv = CGPoint(x: start.x, y: start.y + (isFirst ? -fs.lncrv :  fs.lncrv))
        let gcrv = CGPoint(x: goal.x , y: goal.y  + (isFirst ?  fs.lncrv : -fs.lncrv))
        
        path.move    (to: start)
        path.addCurve(to: goal , control1: scrv, control2: gcrv)
        path.closeSubpath()
        return path
    }
    
    fileprivate final func ansewredCorrect(choice: ChoiceButton) {
        changeFormula()
        
        // ボタンの移動と削除
        choice.line!.removeFromParent()
        let move = SKAction.move(to: CGPoint(x: targetX, y: 0), duration: drtn!)
        move.timingMode = .easeInEaseOut
        let moveAndFadeOut = SKAction.group([move, SKAction.fadeOut(withDuration: drtn!)])
        
        choice.run(SKAction.sequence([moveAndFadeOut, SKAction.removeFromParent()]))
        for c in choices { if !c.isCorrect { c.removeFromParent() }}
        let moveOrigin = SKAction.moveTo(y: 0, duration: drtn!)
        for b in allBlocks {
            if !(b is Equal) { b.changeShape(shapeState: .have,fillColor: clr.shape) }
            b.run(moveOrigin)
            b.ftrPoint.y = 0
        }
        
        bthbtn.run(SKAction.sequence([SKAction.wait(forDuration: drtn!),
                                     SKAction.run { bthbtn.resetBothBtns()}]))
        for btn in bthbtn.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: drtn!))
        }
    }
    
    fileprivate func leave() {
        for cb in choices { cb.removeFromParent() }
        let moveOrigin = SKAction.moveTo(y: 0, duration: drtn!)
        for b in allBlocks {
            if !(b is Equal) { b.changeShape(shapeState: .have,fillColor: clr.shape)}
            b.run(moveOrigin)
            b.ftrPoint.y = 0
        }
        
        // Bothボタンを表示
        for btn in bthbtn.bothBtns {
            btn.run(SKAction.moveTo(y: -fs.h40, duration: drtn!))
        }
    }
}

class Multiplication: Choice {
    override var operation: String { get { return "Multiplication"}}
    
    override init() {
        super.init()
    }
    
    convenience init(_ nb: NumBlock) {
        self.init()
        self.strokeColor = clr.chln
        nb.shape!.strokeColor = strokeColor
        nb.shape!.lineWidth = fs.hlw / fm.scale
        nb.shape!.glowWidth = fs.hglw / fm.scale
        self.selects.append(nb)
        prepareChoices()
    }
    
    override func prepareFormula() {
        super.prepareFormula()
        selects.first!.shape!.strokeColor = strokeColor
        selects.first!.shape!.lineWidth = fs.hlw / fm.scale
        selects.first!.shape!.glowWidth = fs.hglw / fm.scale
    }
    
    override func touchBegan(touch: UITouch, node: SKNode) {
        isTouched = true
        if let nb = node.parent as? NumBlock {
            if nb.canMultiplication {
                for cb in choices { cb.removeFromParent() }
                selects.first!.shape!.fillColor = clr.shape
                selects[0] = nb
                fm.startAmination(duration: 0.36)
                prepareChoices()
                return
            }
        }
        
        guard let choice = node.parent as? ChoiceButton else {
            fm.startAmination(duration: 0.24)
            leave()
            op = Trans()
            
            op.touchBegan(touch: touch, node: node)
            return
        }
        
        if choice.isCorrect {
            fm.startAmination(duration: 0.24)
            ansewredCorrect(choice: choice)
            op = Trans()
        } else {
            choice.becomeThin()
            top.penalty()
        }
    }
    
    final override func getSelectNums() -> [Num] {
        guard let selected = self.selects.first else { return [] }
        
        var selectNums: [Num] = []
        for n in selected.labels.ns { selectNums.append(n.num.copy()) }
        return selectNums
    }
    
    
    final override func getCorrect(_ nums: [Num]) -> Num {
        var isPlus = true
        var tmpMole = 1
        var tmpDeno = 1
        for num in nums {
            if !num.isPlus { isPlus = !isPlus }
            tmpMole = tmpMole * num.mole
            tmpDeno = tmpDeno * num.deno
        }
        let (mole, deno) = u.reduce(m: tmpMole, d: tmpDeno)
        return Num(isPlus, mole, deno)
    }
    
    // 符号間違い
    final override func makeWrongAnswer1(_ nums: [Num]) -> Num {
        return Num(!correct.isPlus, correct.mole, correct.deno)
    }
    
    // 約分忘れ
    final override func makeWrongAnswer2(_ nums: [Num]) -> Num {
        var isPlus = true
        var mole = 1
        var deno = 1
        for n in nums {
            if !n.isPlus { isPlus = !isPlus }
            mole = mole * n.mole
            deno = deno * n.deno
        }
        return Num(isPlus, mole, deno)
    }
    
    // 逆数間違い
    final override func makeWrongAnswer3(_ nums: [Num]) -> Num {
        return Num(correct.isPlus, correct.deno, correct.mole)
    }
    
    // nlを逆数として計算
    final override func makeWrongAnswer4(_ nums: [Num]) -> Num {
        var isPlus =  nums.first!.isPlus
        var tmpMole = nums.first!.deno
        var tmpDeno = nums.first!.mole
        var mls: [Num] = nums
        mls.removeFirst()
        for num in mls {
            if !num.isPlus { isPlus = !isPlus }
            tmpMole = tmpMole * num.mole
            tmpDeno = tmpDeno * num.deno
        }
        let (mole, deno) = u.reduce(m: tmpMole, d: tmpDeno)
        return Num(isPlus, mole, deno)
    }
    
    // 符号間違い&nlを逆数として計算
    final override func makeWrongAnswer5(_ nums: [Num]) -> Num {
        var isPlus = !nums.first!.isPlus
        var tmpMole = nums.first!.deno
        var tmpDeno = nums.first!.mole
        var mls: [Num] = nums
        mls.removeFirst()
        for num in mls {
            if !num.isPlus { isPlus = !isPlus }
            tmpMole = tmpMole * num.mole
            tmpDeno = tmpDeno * num.deno
        }
        let (mole, deno) = u.reduce(m: tmpMole, d: tmpDeno)
        return Num(isPlus, mole, deno)
    }
    
    // mlsのいくつかを逆数として計算
    final override func makeWrongAnswer6(_ nums: [Num]) -> Num {
        var isPlus =  nums.first!.isPlus
        var tmpMole = nums.first!.mole
        var tmpDeno = nums.first!.deno
        var mls: [Num] = nums
        mls.removeFirst()
        var isUpSideDown = false
        for (i, num) in mls.enumerated() {
            if !num.isPlus { isPlus = !isPlus }
            if u.randBool() || (i == mls.count - 1 && !isUpSideDown) {
                isUpSideDown = true
                tmpMole = tmpMole * num.deno
                tmpDeno = tmpDeno * num.mole
            } else {
                tmpMole = tmpMole * num.mole
                tmpDeno = tmpDeno * num.deno
            }
        }
        let (mole, deno) = u.reduce(m: tmpMole, d: tmpDeno)
        return Num(isPlus, mole, deno)
    }
    
    // 符号間違い&mlsのいくつかを逆数として計算
    final override func makeWrongAnswer7(_ nums: [Num]) -> Num {
        var isPlus = !nums.first!.isPlus
        var tmpMole = nums.first!.mole
        var tmpDeno = nums.first!.deno
        var mls: [Num] = nums
        mls.removeFirst()
        var isUpSideDown = false
        for (i, num) in mls.enumerated() {
            if !num.isPlus { isPlus = !isPlus }
            if u.randBool() || (i == mls.count - 1 && !isUpSideDown) {
                isUpSideDown = true
                tmpMole = tmpMole * num.deno
                tmpDeno = tmpDeno * num.mole
            } else {
                tmpMole = tmpMole * num.mole
                tmpDeno = tmpDeno * num.deno
            }
        }
        let (mole, deno) = u.reduce(m: tmpMole, d: tmpDeno)
        return Num(isPlus, mole, deno)
    }
    
    final override func getTargetX() -> CGFloat {
        guard let selected = self.selects.first else { fatalError() }
        return selected.ftrAbsPoint.x
    }
    
    final override func changeFormula() {
        guard let selected = self.selects.first else { return }
        selected.getMultiAnswer(correct: correct)
        selected.isChangeContent = true
        
        fm.startAmination(duration: 0.24)
        fm.run(SKAction.sequence([SKAction.wait(forDuration: 0.24),
                                  SKAction.run { fm.startAmination(duration: 0.12); fm.resetBlocks() }]))
        
    }
    
    final override func leave() {
        super.leave()
        self.selects.first!.shape!.lineWidth = 0
    }
    
    override func touchMoved(touch: UITouch, node: SKNode) { }
    override func touchEnded(touch: UITouch, node: SKNode) { isTouched = false }
    override func update(_ currentTime: TimeInterval) { }
}

class Addition: Choice {
    override var operation: String { get { return "Addition"}}
    
    private var collectID: String!
    private var unionShape: SKShapeNode?
    
    override init() {
        super.init()
    }

    convenience init(collectID: String, cb: CollectableBlock) {
        self.init()
        self.strokeColor = clr.chadd
        self.collectID = collectID
        cb.shape!.strokeColor = strokeColor
        cb.shape!.lineWidth = fs.hlw / fm.scale
        cb.shape!.glowWidth = fs.hglw / fm.scale
        selects.append(cb)
    }
    
    func reselect(collectID: String, cb: CollectableBlock) {
        for cb in choices { cb.removeFromParent() }
        choices = []
        
        let moveOrigin = SKAction.moveTo(y: 0, duration: 0.36)
        for b in allBlocks {
            if !(b is Equal) { b.changeShape(shapeState: .have,fillColor: clr.shape)}
            b.run(moveOrigin)
            b.ftrPoint.y = 0
        }
        
        self.collectID = collectID
        cb.shape!.fillColor = clr.shape
        selects = [cb]
        unionShape?.removeFromParent()
    }
    
    override func touchBegan(touch: UITouch, node: SKNode) { isTouched = true }
    override func touchMoved(touch: UITouch, node: SKNode) { }
    override func touchEnded(touch: UITouch, node: SKNode) {
        isTouched = false
        if let cb = node.parent as? CollectableBlock {
            guard cb.name != selects.first!.name else { return }
            if !cb.canMultiplication {
                if let cid = cb.checkAndSetCollectID() {
                    if cid == collectID {
                        if !selects.contains(where: { e in return e.name == cb.name }) {
                            selects.append(cb)
                            fm.startAmination(duration: 0.48)
                            unionShape?.removeFromParent()
                            for cb in choices { cb.removeFromParent() }
                            prepareChoices()
                            return
                        }
                    } else {
                        fm.startAmination(duration: 0.48)
                        reselect(collectID: cid, cb: cb)
                        return
                    }
                }
            }
        }
        
        if let choice = node.parent as? ChoiceButton {
            if choice.isCorrect {
                fm.startAmination(duration: 0.48)
                ansewredCorrect(choice: choice)
                op = Trans()
            } else {
                choice.becomeThin()
                top.penalty()
            }
            return
        }
        fm.startAmination(duration: 0.48)
        leave()
        op = Trans()
        return
    }
    override func update(_ currentTime: TimeInterval) { }
    
    final override func prepareFormula() {
        let moveUp = SKAction.moveTo(y: fs.splitBase, duration: 0.36)
        for b in allBlocks {
            b.ss = .none
            b.changeShape(fillColor: clr.shape)
            
            if b.level == 0 {
                b.run(moveUp)
                b.ftrPoint.y = fs.splitBase
            }
        }
        
        var tw = -fs.space
        for s in selects {
            s.changeShape(shapeState: .none)
            tw += fs.space + s.width
        }
        
        unionShape = SKShapeNode(rectOf: CGSize(width: tw, height: fs.bsz), cornerRadius: fs.cr)
        unionShape!.strokeColor = strokeColor
        unionShape!.lineWidth = fs.hlw / fm.scale
        unionShape!.glowWidth = fs.hglw / fm.scale
        unionShape!.fillColor = clr.shape
        unionShape!.position = CGPoint(x: targetX, y: selects.first!.absPoint.y)
        fm.addChild(unionShape!)
        unionShape!.run(moveUp)
    }
    
    final override func getSelectNums() -> [Num] {
        var selectNums: [Num] = []
        for b in selects { selectNums.append(b.labels.ns.first!.num.copy()) }
        return selectNums
    }
    
    final override func getCorrect(_ nums: [Num]) -> Num {
        var tmpDeno: Int = 1
        for num in nums { tmpDeno *= num.deno }
        for num in nums {
            num.mole = num.mole * (tmpDeno / num.deno) * (num.isPlus ? 1 : -1)
        }
        var tmpMole: Int = 0
        for num in nums { tmpMole += num.mole }
        let isPlus = 0 <= tmpMole ? true : false
        let (m, d) = u.reduce(m: abs(tmpMole), d: tmpDeno)
        return Num(isPlus, m, d)
    }
    
    // 正解より分子が１多い
    final override func makeWrongAnswer1(_ nums: [Num]) -> Num {
        return Num(correct.isPlus, correct.mole + 1, correct.deno)
    }
    
    // 約分忘れ
    final override func makeWrongAnswer2(_ nums: [Num]) -> Num {
        var deno: Int = 1
        for num in nums { deno *= num.deno }
        for num in nums {
            num.mole = num.mole * (deno / num.deno) * (num.isPlus ? 1 : -1)
        }
        var mole: Int = 0
        for num in nums { mole += num.mole }
        return Num(correct.isPlus, abs(mole), deno)
    }
    
    // 約分前の分子を１増やして約分
    final override func makeWrongAnswer3(_ nums: [Num]) -> Num {
        var deno: Int = 1
        for num in nums { deno *= num.deno }
        for num in nums {
            num.mole = num.mole * (deno / num.deno) * (num.isPlus ? 1 : -1)
        }
        var mole: Int = 0
        for num in nums { mole += num.mole }
        let (m, d) = u.reduce(m: abs(mole) + 1, d: deno)
        return Num(correct.isPlus, m, d)
    }
    
    // 分母同士、分子同士、単に足し算、または引き算（符号による）
    final override func makeWrongAnswer4(_ nums: [Num]) -> Num {
        var mole = 0
        var deno = 0
        for num in nums {
            if num.isPlus {
                mole += num.mole
                deno += num.deno
            } else {
                mole -= num.mole
                deno -= num.deno
            }
        }
        let (m, d) = u.reduce(m: abs(mole), d: abs(deno))
        let isPlus = 0 <= m ? true : false
        return Num(isPlus, m, d)
    }
    
    // 正解より分子が１少ない（または２多い）
    final override func makeWrongAnswer5(_ nums: [Num]) -> Num {
        if correct.mole != 0 {
            let (m, d) = u.reduce(m: correct.mole - 1, d: correct.deno)
            return Num(correct.isPlus, m, d)
        } else {
            let (m, d) = u.reduce(m: correct.mole + 2, d: correct.deno)
            return Num(correct.isPlus, m, d)
        }
    }
    
    // 分母はかけ算、分子は単に足し算
    final override func makeWrongAnswer6(_ nums: [Num]) -> Num {
        var mole = 0
        var deno = 1
        for num in nums {
            mole += num.isPlus ? num.mole : -num.mole
            deno *= num.deno
        }
        let (m, d) = u.reduce(m: abs(mole), d: deno)
        let isPlus = 0 <= m ? true : false
        return Num(isPlus, m, d)
    }
    
    // 掛け算
    final override func makeWrongAnswer7(_ nums: [Num]) -> Num {
        var isPlus =  true
        var tmpMole = 1
        var tmpDeno = 1
        for num in nums {
            if !num.isPlus { isPlus = !isPlus }
            tmpMole = tmpMole * num.mole
            tmpDeno = tmpDeno * num.deno
        }
        let (mole, deno) = u.reduce(m: tmpMole, d: tmpDeno)
        return Num(isPlus, mole, deno)
    }
    
    final override func getTargetX() -> CGFloat {
        var tw = fs.space
        var leftEndX: CGFloat = 10000
        for b in selects {
            tw += b.width + fs.space
            if b.ftrAbsPoint.x - b.width * 0.5 < leftEndX { leftEndX = b.ftrAbsPoint.x - b.width * 0.5 }
        }
        return leftEndX - fs.space + tw * 0.5
    }
    
    final override func leave() {
        super.leave()
        unionShape?.removeFromParent()
    }
    
    final override func changeFormula() {
        
        func removeMyParent(p: Parnt, ifCount: Int) {
            if p.childBlocks.count == ifCount {
                allBlocks.remove(at: allBlocks.index(of: p)!)
                allBlocks.remove(at: allBlocks.index(of: p.cm)!)
                if p.level == 0 { firstLayblocks.remove(at: firstLayblocks.index(of: p)!) }
                if let pp = p.parent as? Parnt {
                    removeMyParent(p: pp, ifCount: 1)
                }
                p.removeFromParent()
            }
        }
        
        var leave: NumBlock?
        if correct.mole != 0 {
            // isFirst = true を残すブロックにする
            for s in selects { if s.isFirst { leave = s }}
            if leave == nil { leave = selects.first! }
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.7 * drtn!)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3 * drtn!)
        let fadeOutAndRemove = SKAction.sequence([SKAction.moveTo(y: 0, duration: 0.7 * drtn!),
                                                  fadeOut,
                                                  SKAction.removeFromParent()])
        
        if let l = leave {
            // 残すブロックの処理
            let changeLabel = SKAction.run {
                l.labels.ns = [l.labels.ns.first!]
                l.isChangeContent = true
            }
            l.run(SKAction.sequence([fadeOut, changeLabel, fadeIn]))
            
            // 消すブロックの処理
            for s in selects {
                if s != l {
                    s.run(fadeOutAndRemove)
                    allBlocks.remove(at: allBlocks.index(of: s)!)
                }
            }
            
            if let p = l.parent as? Parnt {
                for s in selects {
                    if s != l { p.childBlocks.remove(at: p.childBlocks.index(of: s)!)}
                }
            } else {
                for s in selects {
                    if s != l { firstLayblocks.remove(at: firstLayblocks.index(of: s)!)}
                }
            }
        } else {
            for s in selects {
                s.run(fadeOutAndRemove)
                allBlocks.remove(at: allBlocks.index(of: s)!)
            }
            
            if let p = selects.first!.parent as? Parnt {
                for s in selects { p.childBlocks.remove(at: p.childBlocks.index(of: s)!) }
                removeMyParent(p: p, ifCount: 0)
            } else {
                for s in selects { firstLayblocks.remove(at: firstLayblocks.index(of: s)!) }
            }
        }
        unionShape!.run(fadeOutAndRemove)
        fm.setIsFirstForAllBlocks()
        
        fm.run(SKAction.sequence([SKAction.wait(forDuration: drtn!),
                                  SKAction.run {
                                    fm.startAmination(duration: 0.24)
                                    fm.resetBlocks()
                                    if section != 1 { bthbtn.resetBothBtns() }
            }]))
    }
}
