//
//  Button.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/15.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

class Button: SKNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    func addChildren(_ nodes: [SKNode]) {
        for node in nodes {
            self.addChild(node)
        }
    }
}

class ChoiceButton: Button {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isX: Bool!
    
    var shape: SKShapeNode!
    var line : SKShapeNode!
    var color: SKColor!
    
    var width: CGFloat = 0
    var num  : Num!
    var label: NumLabel!
    var isCorrect = false
    var isMistaken = false
    
    let fh: CGFloat = fs.fsz * 0.5
    
    override init() {
        super.init()
    }
    
    convenience init(isX: Bool = false, num: Num, color: SKColor) {
        self.init()
        self.isX = isX
        self.num = num
        self.color = color
        label = NumLabel(isX: isX)
        addChildren(label.all)
        label.hideAllNode()
        width = label.change(isX: isX, num: num)
    }
    
    func becomeThin() {
        alpha = 0.2
        line?.alpha = 0.2
    }
    
    func setShape(w: CGFloat) {
        width = w < fs.minbw ? fs.minbw : w

        shape = SKShapeNode(rectOf: CGSize(width: width, height: fs.bsz), cornerRadius: fs.cr)
        shape.lineWidth = fs.hlw
        shape.glowWidth = fs.hglw
        shape.strokeColor = color
        shape.fillColor = clr.shape
        shape.zPosition = 0
        shape.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                    SKAction .wait   (forDuration:  0.15),
                                    SKAction .fadeIn (withDuration: 0)]))
        addChild(shape)
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        line.removeFromParent()
    }
}

class BothButton: Button {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var shape: SKShapeNode!
    
    var int: Int!
    let label = SKLabelNode(fontNamed: font)
    
    var isSelected = false
    
    let fh: CGFloat = fs.fsz * 0.5
    
    override init() {
        super.init()
    }
    
    convenience init(int: Int) {
        self.init()
        setScale(0.7)
        
        shape = SKShapeNode(rectOf: CGSize(width: fs.bsz, height: fs.bsz), cornerRadius: fs.bsz * 0.5)
        shape.lineWidth = fs.hlw
        shape.glowWidth = fs.hglw
        shape.strokeColor = clr.both
        shape.fillColor = .clear
        addChild(shape)
        
        self.int = int
        label.verticalAlignmentMode = .center
        label.text = String(int)
        label.fontColor = clr.bothf
        label.fontSize = fs.fsz
        let labelWidth = label.frame.width + fs.space * 2
        if fs.bsz < labelWidth {
            label.setScale(fs.bsz / labelWidth)
        }
        addChild(label)
    }
}

class BothSelect: Button {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var shape: SKShapeNode!
    
    var num: Num!
    let nl = NumLabel()
    
    var isSelected = false
    
    let fh: CGFloat = fs.fsz * 0.5
    
    override init() {
        super.init()
        addChildren(nl.all)
    }
    
    convenience init(num: Num) {
        self.init()
        self.num = num
        setScale(0.7)
        
        shape = SKShapeNode(rectOf: CGSize(width: fs.bsz, height: fs.bsz), cornerRadius: fs.bsz * 0.5)
        shape.lineWidth = fs.hlw
        shape.glowWidth = fs.hglw
        shape.strokeColor = clr.both
        shape.fillColor = .clear
        addChild(shape)
        
        nl.hideAllNode()
        let _ = nl.change(isX: false, num: self.num)
    }
}
