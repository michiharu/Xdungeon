//
//  GameScene.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/04.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

var section: Int?
var stage: Int?
var mode: Mode?

class StageGameScene: SKScene {
    
    var storyboard: UIStoryboard!
    var gvc: GameViewController!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    convenience init(storyboard: UIStoryboard, gvc: GameViewController,size: CGSize) {
        self.init(size: size)
        self.storyboard = storyboard
        self.gvc = gvc
    }
    
    override func didMove(to view: SKView) {
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        
        initValues()
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
        if tn.parent is PauseButton { gvc.pause() }
        
        op.touchEnded(touch: tf, node: tn)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tf = touches.first!
        let tn = self.atPoint(tf.location(in: self))
        op.touchEnded(touch: tf, node: tn)
    }
    
    override func update(_ currentTime: TimeInterval) {
        op.update(currentTime)
        guard !fm.isAminated else { return }
        top.update(gvc)
        
    }
    
    func initValues() {
        fs = FitSize(w: self.frame.width, h: self.frame.height)
        clr.mode = WhiteBase()
        switch mode! {
        case .easy:
            choiceCount = 3
        case .normal:
            choiceCount = 4
        case .hard:
            choiceCount = 5
        }
        score = 0
        drtn = 0
    }
    
    func initField() {
        backgroundColor = clr.bgc
        
        let pause: PauseButton = PauseButton()
        pause.position = CGPoint(x: fs.width - fs.fsz * 0.5 - fs.space, y: fs.height - (fs.fsz + fs.space) * 0.5)
        self.addChild(pause)
        
        top = StageTopBar()
        top.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(top)
        
        fm = Formula()
        fm.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(fm)
        
        bthbtn = BothButtonController()
        bthbtn.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(bthbtn)
        
        fm.newQuestion()
    }
}
