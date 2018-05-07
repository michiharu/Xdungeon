//
//  Block.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/07.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Kind: String {
    var description: String {
        return self.rawValue
    }
    case P = "P"// parent
    case X = "X" // x
    case C = "C" // constant
    case M = "M"// multiplier
    case E = "E"// equal
}

class Num: CustomStringConvertible {
    var description: String {
        let pm: String = isPlus ? "+" : "-"
        return pm + mole.description + "/" + deno.description
    }
    
    var isPlus: Bool, mole: Int, deno: Int
    var moleWithSign: Int {
        return mole * (isPlus ? 1 : -1)
    }
    
    init(_ isPlus: Bool,_ m: Int,_ d: Int) {
        self.isPlus = isPlus
        self.mole   = m
        self.deno   = d
    }
    
    func copy() -> Num {
        return Num(self.isPlus, self.mole, self.deno)
    }
    
    func reduce() {
        func gcd(_ a: Int, _ b: Int) -> Int { if b == 0 { return a } else { return gcd(b, a % b) } }
        let r = gcd(mole, deno)
        mole = mole/r
        deno = deno/r
    }
}
extension Num: Equatable {
    static func == (l: Num,r: Num) -> Bool {
        if l.isPlus == r.isPlus &&
            l.mole   == r.mole   &&
            l.deno   == r.deno    {
            return true
        } else {
            return false
        }
    }
}


final class NumLabel {
    
    let ut = LabelUtil()
    var shape: SKShapeNode?
    
    var all : [SKNode] = []
    var w:    CGFloat!
    
    var br1 : SKLabelNode! // bracket1
    var sign: SKLabelNode! // sign
    var mole: SKLabelNode! // mole
    var bar : SKShapeNode! // bar
    var deno: SKLabelNode! // deno
    var x   : SKLabelNode? // x
    var br2 : SKLabelNode! // bracket2
    var msyb: SKLabelNode? // Multiplication symbol
    
    init(isX: Bool = false, isMuler: Bool = false) {
        
        // bracket1
        br1  = SKLabelNode(fontNamed: bracketFont)
        br1.verticalAlignmentMode = .center
        br1.fontSize = fs.brsz
        br1.fontColor = clr.brckt
        br1.text = "("
        all.append(br1)
        
        // sign
        sign = SKLabelNode(fontNamed: font)
        sign.verticalAlignmentMode = .center
        sign.fontSize = fs.fsz
        all.append(sign)
        
        // mole
        mole = SKLabelNode(fontNamed: font)
        mole.verticalAlignmentMode = .center
        mole.fontSize = fs.fsz
        all.append(mole)
        
        // bar
        bar  = SKShapeNode(rectOf: CGSize(width: fs.barw, height: fs.barh), cornerRadius: 2)
        bar.lineWidth = 0
        all.append(bar)
        
        // deno
        deno = SKLabelNode(fontNamed: font)
        deno.verticalAlignmentMode = .center
        deno.fontSize = fs.fsz
        all.append(deno)
        
        // x
        if isX {
            x = SKLabelNode(fontNamed: xFont)
            x!.verticalAlignmentMode = .center
            x!.fontSize = fs.brsz
            x!.text = "x"
            all.append(x!)
        }
        
        // bracket2
        br2 = SKLabelNode(fontNamed: bracketFont)
        br2.verticalAlignmentMode = .center
        br2.fontSize = fs.brsz
        br2.fontColor = clr.brckt
        br2.text = ")"
        all.append(br2)
        
        if isMuler {
            msyb = SKLabelNode(fontNamed: bracketFont) // Multiplication symbol
            msyb!.verticalAlignmentMode = .center
            msyb!.fontSize = fs.fsz
            msyb!.fontColor = clr.brckt
            msyb!.text = "×"
            all.append(msyb!)
        }
    }
    
    func change(isX: Bool, num: Num) -> CGFloat  {

        let color = isX ? (num.isPlus ? clr.xplus : clr.xminu) : ( num.isPlus ? clr.cplus : clr.cminu )
        
        var a: CGFloat = fs.space
        // -
        if !num.isPlus {
            ut.showLabel(label: sign, color: color, text: "-", y: 0)
            a = ut.setPositionX(anchor: a, node: sign)
        }
        
        // 1/4
        a = ut.setNumLabel(isX: isX, a: a, num: num, label: self, color: color)
        
        
        // x
        if isX {
            if !(num.deno == 1 && num.mole == 1) { a -= fs.space }
            ut.showLabel(label: x!, color: color, text: "x", y: 0)
            a = ut.setPositionX(anchor: a, node: x!)
        }
        ut.slideHalfLengthOfAnchor(a: a, nodes: all)
        a = a < fs.minbw ? fs.minbw : a
        w = a
        return a
    }
    
    func hideAllNode() {
        ut.hideAllNode(nodes: all)
    }
}

final class NumLabels {
    
    var ns : [(num: Num, nl: NumLabel)] = []
    
    let ut = LabelUtil()
    let fh: CGFloat = fs.fsz * 0.5
    
    init(isX: Bool, num: Num) {
        ns.append((num: num, NumLabel(isX: isX)))
    }
    
    final func change(_ nb: NumBlock) -> CGFloat {
        
        var a: CGFloat = fs.space // a: anchor
        let isX = ut.checkX(nb)
        
        var isFirstMuler = true
        
        // BothかつsetMulerの場合は先頭のmulerとshapeを特別に設定
        if nb.ss == .emphasize {
            isFirstMuler = false
            a = setBothMuler(anchor: a, muler: ns.last!, isX: isX)
        }
            
        for (i, n) in ns.reversed().enumerated() { // (-3)×..
            /**--------------------------------------------------------------*/
            // BothかつsetMulerの場合は先頭のmulerは設定済みなのでスキップ
            if i == 0 && nb.ss == .emphasize { continue }
            
            // BothかつmakeParentの場合、deno = 0 を利用して空のまま
            if n.num.deno == 0 { return fs.minbw }
            /**--------------------------------------------------------------*/
            
            let color = ut.getColor(isPlus: n.num.isPlus, isX: isX)
            let isLastLoop = i == ns.count - 1
            
            // (
            if !isFirstMuler {
                n.nl.br1.isHidden = false
                a = ut.setPositionX(anchor: a, node: n.nl.br1)
            }
            
            // -
            if !(nb.isFirst && isFirstMuler && n.num.isPlus) && !(!isFirstMuler && n.num.isPlus) {
                ut.showLabel(label: n.nl.sign, color: color, text:  n.num.isPlus ? "+" : "-", y: 0)
                a = ut.setPositionX(anchor: a, node: n.nl.sign)
            }
            
            // 3
            if !(isLastLoop && isX && n.num.mole == 1 && n.num.deno == 1) {
                a = ut.setNumLabel(isX: isX, isMuler: true, a: a, num: n.num, label: n.nl, color: color)
            }
            
            // x (エックス)
            if isLastLoop && isX && n.num.mole != 0 {
                if !(n.num.deno == 1 && n.num.mole == 1) { a -= fs.space }
                ut.showLabel(label: n.nl.x!, color: color, text: "x", y: 0)
                a = ut.setPositionX(anchor: a, node: n.nl.x!)
            }
            
            // )
            if !isFirstMuler {
                n.nl.br2.isHidden = false
                a = ut.setPositionX(anchor: a, node: n.nl.br2)
            }
            
            // × (掛け算記号)
            if !isLastLoop {
                n.nl.msyb!.isHidden = false
                a = ut.setPositionX(anchor: a, node: n.nl.msyb!)
            }
            
            isFirstMuler = false
        }
        
        slideHalfLengthOfAnchor(a: a)
        if a < fs.minbw { a = fs.minbw }
        return a
    }
    
    final func setBothMuler(anchor: CGFloat, muler: (num: Num, nl: NumLabel), isX: Bool) -> CGFloat {
        var a = fs.space
        let color = ut.getColor(isPlus: muler.num.isPlus, isX: isX)
        
        if !muler.num.isPlus {
            ut.showLabel(label: muler.nl.sign, color: color, text:  "-", y: 0)
            a = ut.setPositionX(anchor: a, node: muler.nl.sign)
        }
        
        if muler.num.deno != 0 {
            a = ut.setNumLabel(isX: isX, isMuler: true, a: a, num: muler.num, label: muler.nl, color: color)
        }
        
        if a < fs.minbw {
            let delta = fs.minbw - a
            a = fs.minbw
            ut.slideHalfLengthOfAnchor(a: -delta, nodes: muler.nl.all)
        }
        muler.nl.w = a
        
        a = a + fs.space
        
        // × (掛け算記号)
        muler.nl.msyb!.isHidden = false
        a = ut.setPositionX(anchor: a, node: muler.nl.msyb!)
        
        return a
    }
    
    func getColor(isX: Bool) -> SKColor {
        if isX {
            return ns.first!.num.isPlus ? clr.xplus : clr.xminu
        } else {
            return ns.first!.num.isPlus ? clr.cplus : clr.cminu
        }
    }
    
    func hideAllNode() {
        for n in ns { ut.hideAllNode(nodes: n.nl.all) }
    }
    
    func setZPosition(z: CGFloat) {
        for n in ns { for node in n.nl.all { node.zPosition = z }}
    }
    
    func slideHalfLengthOfAnchor(a: CGFloat) {
        for n in ns { ut.slideHalfLengthOfAnchor(a: a, nodes: n.nl.all) }
    }
    
    func addMuler(_ nb: NumBlock, num: Num) -> [SKNode] {
        let nl = NumLabel(isX: ut.checkX(nb), isMuler: true)
        ns.append((num.copy(), nl))
        return nl.all
    }
}

struct LabelUtil {
    
    let fh: CGFloat = fs.fsz * 0.5
    
    func showLabel(label: SKLabelNode, color: SKColor, text: String, y: CGFloat) {
        label.isHidden = false
        label.fontColor = color
        label.text = text
        label.position.y = y
    }
    
    func setNumLabel(isX: Bool,
                     isMuler: Bool = false,
                     a: CGFloat,
                     num: Num,
                     label: NumLabel,
                     color: SKColor) -> CGFloat {
        if num.deno == 1 {
            if isX && num.mole == 1 && !isMuler {
                return a
            } else {
                showLabel(label: label.mole, color: color, text: String(num.mole), y: 0)
                return setPositionX(anchor: a, node: label.mole)
            }
        } else {
            showLabel(label: label.mole, color: color, text: String(num.mole), y: fh)
            showLabel(label: label.deno, color: color, text: String(num.deno), y: -fh)
            
            let longer = max(label.mole.frame.width, label.deno.frame.width)
            let barLength = longer + fs.space * 2
            label.bar.isHidden = false
            label.bar.run(SKAction.scaleX(to: barLength / fs.barw, duration: 0))
            label.bar.fillColor = color
            label.mole.position.x = a + barLength * 0.5
            label.deno.position.x = a + barLength * 0.5
            label.bar .position.x = a + barLength * 0.5
            return a + barLength + fs.space
        }
    }
    
    func getColor(isPlus: Bool, isX: Bool) -> SKColor {
        if isX {
            return isPlus ? clr.xplus : clr.xminu
        } else {
            return isPlus ? clr.cplus : clr.cminu
        }
    }
    
    func setPositionX(anchor: CGFloat, node: SKNode) -> CGFloat {
        node.position.x = anchor + node.frame.width * 0.5
        return anchor + node.frame.width + fs.space
    }
    
    func checkX(_ nb: NumBlock) -> Bool {
        if let c = nb as? CollectableBlock { return c.kind == .X ? true : false }
        return false
    }
    
    func slideHalfLengthOfAnchor(a: CGFloat, nodes: [SKNode]) {
        for node in nodes { node.position.x -= a * 0.5 }
    }
    
    func hideAllNode(nodes: [SKNode]) {
        for node in nodes { node.isHidden = true }
    }
}

enum ShapeState {
    case have
    case emphasize
    case none
}

class Block: SKNode {
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var parentID: String!
    var level: CGFloat!
    var isFirst = false
    var isTouched = false
    
    var ftrPoint = CGPoint(x: 0, y: 0) // future point
    
    var absPoint: CGPoint {
        get {
            if let p = self.parent as? Parnt {
                return position + p.absPoint
            } else { return position }
        }
    }
    
    var ftrAbsPoint: CGPoint {
        get {
            if let p = self.parent as? Parnt {
                return ftrPoint + p.ftrAbsPoint
            } else { return ftrPoint }
        }
    }
    
    var isChangeContent = true
    
    var width: CGFloat!
    var shape: SKShapeNode?
    var ss:    ShapeState = .have
    
    override init() {
        super.init()
    }
    
    final func addChildren(_ nodes: [SKNode]) {
        for node in nodes {
            self.addChild(node)
        }
    }
    
    func changeContent() {fatalError("このメソッドはオーバーライドされなければなりません！")}
    
    func changeShape(shapeState: ShapeState, fillColor: SKColor = clr.shape) {
        ss = shapeState
        changeShape(fillColor: fillColor)
    }
    
    func changeShape(fillColor: SKColor) {
        switch ss {
        case .have:
            resizeShape(fillColor: fillColor)
        case .emphasize:
            emphasizeLastMuler()
        case .none:
            shape?.fillColor = .clear
            shape?.lineWidth = 0
        }
    }
    
    func resizeShape(fillColor: SKColor = SKColor.clear) {
        if let s = shape {
            s.isHidden = false
            s.lineWidth = 0
            let scale = width / s.frame.width
            s.removeAllActions()
            s.run(SKAction.sequence([SKAction.scaleX(to: scale, duration: drtn!),
                                     SKAction.removeFromParent()]))
        }
        
        let newShape = SKShapeNode(rectOf: CGSize(width: width, height: fs.bsz), cornerRadius: fs.cr)
        newShape.lineWidth = 0
        newShape.fillColor = fillColor
        newShape.zPosition = level
        addChild(newShape)
        newShape.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                        SKAction.wait(forDuration: drtn!),
                                        SKAction.fadeIn(withDuration: 0)]))
        
        shape = newShape
    }
    
    func emphasizeLastMuler() {fatalError("このメソッドはオーバーライドされなければなりません！")}
    
    final func notifyParent() {
        if let p = parent as? Parnt {
            p.isChangeContent = true
        } else {
            isAdjustAllBlocks = true
        }
    }
    
    func setIsFirst(_ f: Bool) {
        self.isFirst = f
        self.isChangeContent = true
    }
    
    func setLevel(_ l: CGFloat) {
        self.level = l
    }
    
    func reverseSign() {fatalError("このメソッドはオーバーライドされなければなりません！")}
    
    final func setPositionX(anchor: CGFloat, node: SKNode) -> CGFloat {
        node.position.x = anchor + node.frame.width * 0.5
        return anchor + node.frame.width + fs.space
    }
}

class NumBlock: Block {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labels : NumLabels!
    
    var canMultiplication: Bool { get{ return labels.ns.count > 1 }}
    
    var dcl : (isConnected: Bool, line: SKShapeNode)? // deploy connection line
    
    override init(){
        super.init()
    }
    
    final override func changeContent() {
        isChangeContent = false
        labels.hideAllNode()
        width = labels.change(self)
        labels.setZPosition(z: level + 0.5)
        changeShape(fillColor: clr.shape)
        notifyParent()
    }
    
    final override func reverseSign() {
        labels.ns.last!.num.isPlus = !labels.ns.last!.num.isPlus
        isChangeContent = true
    }
    
    func addMuler(ss: ShapeState, num: Num) {
        addChildren(labels.addMuler(self, num: num))
        self.isChangeContent = true
        self.ss = ss
    }
    
    final override func emphasizeLastMuler() {
        guard let l = labels.ns.last else { return }
        
        let emphasizeWidth: CGFloat = l.nl.w
        
        if let s = shape {
            let scale = emphasizeWidth / s.frame.width
            s.removeAllActions()
            s.run(SKAction.sequence([SKAction.scaleX(to: scale, duration: 0.15),
                                     SKAction.removeFromParent()]))
        }
        
        
        let newShape = SKShapeNode(rectOf: CGSize(width: emphasizeWidth, height: fs.bsz), cornerRadius: fs.cr)
        newShape.lineWidth = 0
        newShape.fillColor = clr.shape
        newShape.position.x = -0.5 * (width - emphasizeWidth)
        newShape.zPosition = level
        newShape.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                        SKAction.wait(forDuration: 0.15),
                                        SKAction.fadeIn(withDuration: 0)]))
        addChild(newShape)
        shape = newShape
    }
    
    func removeLastMuler() {
        for node in labels.ns.last!.nl.all { node.removeFromParent() }
        labels.ns.removeLast()
        shape!.position.x = 0
        ss = .have
        isChangeContent = true
    }
    
    final func getMultiAnswer(correct: Num) {
        for (i, n) in labels.ns.enumerated() {
            if i != 0 {
                for node in n.nl.all { node.removeFromParent() }
            }
        }
        labels.ns = [(correct, labels.ns.first!.nl)]
        isChangeContent = true
    }
}

class CollectableBlock: NumBlock {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        var str: String = ""
        for n in labels.ns.reversed() {
            str += n.num.description
        }
        str += kind.rawValue + level.description
        return str
    }
    
    var kind: Kind!
    var collectID: String?
    
    override init(){
        super.init()
    }
    
    convenience init(kind: Kind, parentID: String, level: CGFloat, num: Num) {
        self.init()
        self.kind = kind; self.parentID = parentID; self.level = level
        
        labels = NumLabels(isX: kind == .X ? true : false, num: num)
        addChildren(labels.ns.first!.nl.all)
    }
    
    func checkAndSetCollectID() -> String? {
        func checkAndSetSelfGroup(blocks: [Block]) -> String? {
            if self == blocks.first! {
                if let first2 = blocks[1] as? CollectableBlock {
                    if self.kind == first2.kind && !first2.canMultiplication {
                        return setCollectID(collectID: first2.collectID)
                    }
                }
            } else if self == blocks.last! {
                if let last2 = blocks[blocks.endIndex - 2] as? CollectableBlock {
                    if self.kind == last2.kind && !last2.canMultiplication {
                        return setCollectID(collectID: last2.collectID)
                    }
                }
            } else {
                let index = blocks.index(of: self)!
                if let before = blocks[index - 1] as? CollectableBlock {
                    if self.kind == before.kind && !before.canMultiplication {
                        return setCollectID(collectID: before.collectID)
                    }
                }
                if let next = blocks[index + 1] as? CollectableBlock  {
                    if self.kind == next.kind && !next.canMultiplication {
                        return setCollectID(collectID: next.collectID)
                    }
                }
            }
            self.collectID = nil
            return nil
        }
        
        if let p = parent as? Parnt {
            return checkAndSetSelfGroup(blocks: p.childBlocks)
        } else {
            return checkAndSetSelfGroup(blocks: firstLayblocks)
        }
    }
    
    private func setCollectID(collectID: String?) -> String {
        if let cid = collectID {
            self.collectID = cid
        } else {
            self.collectID = NSUUID().uuidString
        }
        return self.collectID!
    }
}

class Multi: NumBlock {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    override var description: String {
        var str: String = ""
        for n in labels.ns.reversed() {
            str += " " + n.num.description
        }
        str += "M" + level.description
        return str
    }
    
    convenience init(parentID: String, level: CGFloat, num: Num) {
        self.init()
        self.parentID = parentID; self.level = level
        
        labels = NumLabels(isX: false, num: num)
        addChildren(labels.ns.first!.nl.all)
    }
    
    final func changeButtonMode() {
        shape!.lineWidth = 1
        shape!.glowWidth = fs.glw
        shape!.strokeColor = labels.getColor(isX: false)
        shape!.fillColor = .clear
    }
    
    final func releaseButtonMode() {
        shape!.lineWidth = 0
        shape!.fillColor = clr.shape
    }
}

class Parnt: Block {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String { return "P" + level.description }
    
    var cm: Multi! // child multi
    var childBlocks: [Block]!
    var isConnectedAll: Bool {
        get {
            var isAll = true
            for c in childBlocks {
                if let p = c as? Parnt {
                    if !p.cm.dcl!.isConnected { isAll = false }
                }
                if let nb = c as? NumBlock {
                    if !nb.dcl!.isConnected { isAll = false }
                }
            }
            return isAll
        }
    }
    
    private var l: Label!
    
    private class Label {
        var all  : [SKNode] = []
        var br1  : SKLabelNode! // bracket1
        var br2  : SKLabelNode! // bracket2
        
        init() {
            br1 = SKLabelNode(fontNamed: bracketFont) // bracket1
            br1.verticalAlignmentMode = .center
            br1.fontSize = fs.brsz; br1.text = "("
            br1.fontColor = clr.brckt
            all.append(br1)
            
            br2 = SKLabelNode(fontNamed: bracketFont) // bracket2
            br2.verticalAlignmentMode = .center
            br2.fontSize = fs.brsz; br2.text = ")"
            br2.fontColor = clr.brckt
            all.append(br2)
        }
        
        func reset(level: CGFloat) {
            for node in all {
                node.isHidden = true
                node.zPosition = level + 0.5
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(parentID: String, level: CGFloat, multi: Multi, blocks: [Block]) {
        self.init()
        
        cm = multi
        childBlocks = blocks
        addChild(cm)
        addChildren(childBlocks)
        
        self.parentID = parentID; self.level = level
        
        l = Label()
        addChildren(l.all)
    }
    
    final override func setIsFirst(_ f: Bool) {
        isFirst = f
        cm.setIsFirst(f)
    }
    
    func setIsFirstForAllChildren() {
        var isFirstChild = true
        for c in childBlocks {
            c.setIsFirst(isFirstChild)
            isFirstChild = false
            if let p = c as? Parnt { p.setIsFirstForAllChildren() }
        }
    }
    
    final override func reverseSign() {
        cm.reverseSign()
        cm.isChangeContent = true
    }
    
    final override func setLevel(_ l: CGFloat) {
        self.level = l
        self.cm.setLevel(l + 1)
        for c in childBlocks { c.setLevel(l + 1) }
    }
    
    final override func changeContent() {
        
        isChangeContent = false
        
        
        var tw: CGFloat = 0 // total width
        tw += cm.width + fs.space
        tw += l.br1.frame.width + fs.space
        for child in childBlocks { tw += child.width + fs.space }
        tw += l.br2.frame.width
        width = tw
        
        var a = (-tw * 0.5) // a: anchor
        cm.run(
            SKAction.move(to: CGPoint(x: a + (cm.width * 0.5), y: cm.ftrPoint.y), duration: drtn!))
        cm.ftrPoint.x = a + cm.width * 0.5
        a += cm.width + fs.space
        
        l.br1.run(SKAction.move(to: CGPoint(x: a + l.br1.frame.width * 0.5, y: 0), duration: drtn!))
        a += l.br1.frame.width + fs.space
        
        for c in childBlocks {
            if !c.isTouched {
                c.run(SKAction.move(to: CGPoint(x: a + c.width * 0.5, y: 0), duration: drtn!))
            }
            c.ftrPoint.x = a + c.width * 0.5
            a += c.width + fs.space
        }
        
        l.br2.run(SKAction.move(to: CGPoint(x: a + l.br2.frame.width * 0.5, y: 0), duration: drtn!))
        
        width = tw
        changeShape(fillColor: clr.shape)
        notifyParent()
    }
    
    final override func resizeShape(fillColor: SKColor = SKColor.clear) {
        if let s = shape {
            s.isHidden = false
            s.lineWidth = 0
            if abs(width - s.frame.width) < fs.space { return }
            
            let scale = width / s.frame.width
            s.removeAllActions()
            s.run(SKAction.sequence([SKAction.scaleX(to: scale, duration: drtn!),
                                     SKAction.removeFromParent()]))
        }
        
        let newShape = SKShapeNode(rectOf: CGSize(width: width, height: fs.bsz * 0.3), cornerRadius: fs.cr)
        newShape.lineWidth = 0
        newShape.fillColor = clr.shape
        newShape.zPosition = level
        newShape.position.y = -fs.bsz * 0.36 - (maxLevel - level) * (fs.bsz * 0.3 + fs.space)
        addChild(newShape)
        newShape.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                        SKAction.wait(forDuration: drtn!),
                                        SKAction.fadeIn(withDuration: 0)]))
        shape = newShape
    }
    
    func prepareDeployment() {
        for c in childBlocks {
            if let p = c as? Parnt {
                p.cm.dcl = (false, makeLine(isConnected: false, child: p.cm))
                addChild(p.cm.dcl!.line)
            }
            if let nb = c as? NumBlock {
                nb.dcl = (false, makeLine(isConnected: false, child: nb))
                addChild(nb.dcl!.line)
            }
        }
    }
    
    func connectLine(index: Int) {
        print("connectLine")
        let c = childBlocks[index]
        if let p  = c as? Parnt  { print(p);p.cm.dcl!.isConnected = true; return }
        if let nb = c as? NumBlock { nb.dcl!.isConnected = true; return }
        fatalError()
    }
    
    func remakeLines() {
        // 展開中はlineの形を変えないためのguard
        guard let _ = cm.parent else { return }
        
        for c in childBlocks {
            if let p  = c as? Parnt  {
                p.cm.dcl!.line.removeFromParent()
                p.cm.dcl!.line = makeLine(isConnected: p.cm.dcl!.isConnected, child: p.cm)
                addChild(p.cm.dcl!.line)
            }
            if let nb = c as? NumBlock {
                nb.dcl!.line.removeFromParent()
                nb.dcl!.line = makeLine(isConnected: nb.dcl!.isConnected, child: nb)
                addChild(nb.dcl!.line)
            }
        }
    }
    
    func cancelDeployment() {
        cm.releaseButtonMode()
        for c in childBlocks {
            if let p  = c as? Parnt  {
                p.cm.dcl!.line.removeFromParent()
                p.cm.dcl = nil
            }
            if let nb = c as? NumBlock {
                nb.dcl!.line.removeFromParent()
                nb.dcl = nil
            }
        }
    }
    
    func deploy() -> [Block] {
        let d4_1 = drtn! / 4
        let d4_2 = d4_1 * 2
        let d4_3 = d4_1 * 3
        
        let wait = SKAction.wait(forDuration: d4_2)
        let fadeOut = SKAction.fadeOut(withDuration: d4_1)
        
        childBlocks.first!.isFirst = isFirst
        for c in childBlocks {
            var target: NumBlock!
            if let p = c as? Parnt { target = p.cm } else { target = c as! NumBlock }
            
            let copyNode = cm.copy() as! Multi
            let follow = SKAction.follow(makePath(isLine:false, child: target),
                                         asOffset : false, orientToPath: false, duration : d4_3 * 2)
            follow.timingMode = .easeOut
            let waitAndFadeOut = SKAction.sequence([wait,fadeOut,SKAction.removeFromParent()])
            let action = SKAction.group([follow, waitAndFadeOut])
            
            copyNode.run(action)
            addChild(copyNode)
            target.addMuler(ss: .have, num: cm.labels.ns.first!.num)
            c.setLevel(c.level - 1)
        }
        
        cm.removeFromParent()
        run(SKAction.sequence([SKAction.wait   (forDuration : d4_3),
                               SKAction.fadeOut(withDuration: d4_1),
                               SKAction.removeFromParent()]))
        return childBlocks
    }
    
    private func makeLine(isConnected: Bool, child c: Block) -> SKShapeNode {
        
        let line = SKShapeNode(path: makePath(child: c))
        
        if isConnected {
            line.strokeColor = cm.labels.getColor(isX: false)
            line.glowWidth = fs.hglw
            line.lineWidth = fs.hlw
        } else {
            line.strokeColor = SKColor.gray
            line.lineWidth = fs.hlw * 0.5
        }
        line.zPosition = level + 0.5
        
        return line
    }
    
    private func makePath(isLine: Bool = true, child c: Block) -> CGMutablePath {
        var bp: CGPoint = c.position
        if c is Multi {
            let pOfC = c.parent as! Parnt
            bp = pOfC.position + c.position
        }
        
        let d = abs(cm.position.x - bp.x)
        
        let path = CGMutablePath()
        let (mAbove, blockAbove) = (CGPoint(x: cm.position.x, y: cm.position.y + fs.arc + d * 0.5),
                                    CGPoint(x: bp.x, y: bp.y + fs.arc + d * 0.5))
        
        let startCurvePoint = CGPoint(x: cm.position.x, y: cm.position.y + fs.bsz * 0.5)
        let goalCurvePoint  = CGPoint(x: bp.x, y: bp.y + fs.bsz * 0.5)
        
        if isLine {
            path.move   (to: startCurvePoint)
        } else {
            path.move   (to: cm.position)
            path.addLine(to: startCurvePoint)
        }
        path.addCurve(to: goalCurvePoint, control1: mAbove, control2: blockAbove)
        
        if !isLine {
            path.addLine(to: bp)
        }
        
        path.closeSubpath()
        return path
    }
    
    final func incrementChilrenLevel() {
        cm.level = cm.level + 1
        for c in childBlocks {
            c.level = c.level + 1
            if let p = c as? Parnt { p.incrementChilrenLevel() }
        }
    }
}

class Equal: Block {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String { return " = " }
    
    
    
    var isLast = false
    
    private var l: Label!
    
    private class Label {
        var all  : [SKNode] = []
        var equal: SKLabelNode!
        var zero : SKLabelNode!
        
        init() {
            equal = SKLabelNode(fontNamed: font)
            equal.verticalAlignmentMode = .center
            equal.fontSize = fs.brsz
            equal.fontColor = clr.eql
            equal.text = "="
            
            zero = SKLabelNode(fontNamed: font)
            zero.verticalAlignmentMode = .center
            zero.fontSize = fs.brsz
            zero.fontColor = clr.zero
            zero.text = "0"
            
            all.append(equal)
            all.append(zero)
        }
        
        func reset(level: CGFloat) {
            zero.isHidden = true
            zero.zPosition = level + 0.5
        }
    }
    
    override init() {
        super.init()
        
        isFirst = false
        level = 0
        
        l = Label()
        addChildren(l.all)
        
        shape = SKShapeNode()
    }
    
    final override func changeContent() {
        isChangeContent = false
        
        l.reset(level: self.level)
        
        var a: CGFloat = 0
        let eFW = l.equal.frame.width
        let zFW = l.zero.frame.width
        
        if (!isFirst && !isLast) {
            l.equal.position.x = 0
            a = eFW + fs.space * 2
        } else if isFirst {
            l.zero.isHidden = false
            a = eFW + zFW + fs.space * 4
            l.zero .position.x = -a * 0.5 + fs.space + zFW * 0.5
            let calc: CGFloat  = -a * 0.5 + zFW + eFW * 0.5
            l.equal.position.x = calc + fs.space * 3
        } else {
            l.zero.isHidden = false
            a = eFW + zFW + fs.space * 4
            l.equal.position.x = -a * 0.5 + fs.space + eFW * 0.5
            let calc: CGFloat  = -a * 0.5 + eFW + zFW * 0.5
            l.zero .position.x = calc + fs.space * 3
        }
        width = a
    }
    
    func setIsLast(_ l: Bool) {
        isLast = l
        isChangeContent = true
    }
}

func == (l: Block,r: Block) -> Bool { return l.name == r.name }
