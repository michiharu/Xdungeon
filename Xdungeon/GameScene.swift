//
//  GameScene.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/04.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

let font = "Arial"
let bracketFont = "Baskerville"
let xFont = "Cochin-BoldItalic"
let BRING_TO_FRONT: CGFloat = 10

var fs: FitSize!
let u = Util()
let dr = Duration()

var clr = Color()
var choiceCount = 3

var op: Operation = Trans()
let operationLabel = SKLabelNode(fontNamed: font)

var isAdjustAllBlocks = true
var maxLevel: CGFloat!
var allBlocks: [Block] = []
var firstLayblocks: [Block] = []

var fm    : Formula!
var stnry : Stationary!

var pause : SKShapeNode!
var clear : SKShapeNode!

var start: Date!

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        initField()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let tf = touches.first!
        let tn = self.atPoint(tf.location(in: self))
        
        op.touchBegan(touch: tf, node: tn)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tf = touches.first!
        let tn = self.atPoint(tf.location(in: self))
        op.touchMoved(touch: tf, node: tn)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tf = touches.first!
        let tn = self.atPoint(tf.location(in: self))
        op.touchEnded(touch: tf, node: tn)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tf = touches.first!
        let tn = self.atPoint(tf.location(in: self))
        op.touchEnded(touch: tf, node: tn)
    }
    
    override func update(_ currentTime: TimeInterval) {
        op.update(currentTime)
        fm.update()
    }
    
    func initField() {
        clr.mode = Neon()
        backgroundColor = clr.bgc
        fs = FitSize(w: self.frame.width, h: self.frame.height)
        
        operationLabel.position = CGPoint(x: fs.bsz, y: fs.height - fs.fsz)
        addChild(operationLabel)
        
        fm = Formula()
        fm.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        fm.name = "formula"
        self.addChild(fm)
        
        stnry = Stationary()
        stnry.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        stnry.name = "stationary"
        self.addChild(stnry)
    }
}
