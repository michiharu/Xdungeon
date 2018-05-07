//
//  TopBar.swift
//  Xdungeon
//
//  Created by michiharu on 2018/05/03.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class TopBar: SKNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var headerHeight: CGFloat!
    var topBarBackground: SKShapeNode!
    
    var scoreCountBG: SKShapeNode!
    let scoreLabel = SKLabelNode(fontNamed: font)
    let scoreCountLabel  = SKLabelNode(fontNamed: font)
    var scoreCountBGHarfLength: CGFloat!
    
    var timeDisplayBG: SKShapeNode!
    var timeDisplay: SKLabelNode!
    var timeDisplayLabel = SKLabelNode(fontNamed: font)
    var timeDisplayBGHarfLength: CGFloat!
    
    var lastTotalBar:  SKShapeNode?
    var totalEmptyBar: SKShapeNode?
    
    var timeBar:  SKShapeNode!
    var emptyBar: SKShapeNode!
    var barHeight: CGFloat!
    
    var barPositionX: CGFloat!
    let barSplit = fs.space * 1.3
    var barLength: CGFloat!
    
    var barAlpha: CGFloat = 1
    var isIncreasing: Bool = false
    
    var bothBtns: [BothButton] = []
    
    var startGame: Date!
    var startThisQuestion: Date!
    var elapsedPenaltyTime: Date?
    let timeLimit: Int = 100
    var timerCount: Int = 100 // timeLimitと同じ値をセットセット
    
    let maxScore: CGFloat = 1000
    var scoreOfThisBar: Int!
    
    let nextLabel:SKLabelNode = SKLabelNode(fontNamed: font)
    var sceneChangeAction: SKAction!
    
    override init() {
        super.init()
        startGame = Date()
        
        headerHeight = fs.fsz + fs.space
        
        topBarBackground = SKShapeNode(rectOf: CGSize(width: fs.width, height: headerHeight))
        topBarBackground.fillColor = clr.shape
        topBarBackground.lineWidth = 0
        topBarBackground.position = CGPoint(x: 0, y: (fs.height - fs.fsz - fs.space) * 0.5)
        addChild(topBarBackground)
        
        setNode()
        
        // ゲーム開始や次の問題表示のメッセージ
        let spread = SKAction.scale(to: 1.5, duration: 1)
        let fadeOutAndRemove = SKAction.sequence([SKAction.fadeOut(withDuration: 0),
                                                  SKAction.fadeIn(withDuration: 0.24),
                                                  SKAction.fadeOut(withDuration: 0.6),
                                                  SKAction.removeFromParent()])
        sceneChangeAction = SKAction.group([spread, fadeOutAndRemove])
        
        let startAnimationLabel: SKLabelNode = SKLabelNode(fontNamed: font)
        startAnimationLabel.text = "Start!"
        startAnimationLabel.fontSize = fs.splitBase
        startAnimationLabel.fontColor = clr.xcdf
        startAnimationLabel.verticalAlignmentMode = .center
        startAnimationLabel.position = CGPoint(x: 0, y: fs.bsz)
        startAnimationLabel.run(sceneChangeAction)
        addChild(startAnimationLabel)
        
        nextLabel.text = "Next!"
        nextLabel.fontSize = fs.splitBase
        nextLabel.fontColor = clr.xcdf
        nextLabel.verticalAlignmentMode = .center
        nextLabel.position = CGPoint(x: 0, y: fs.bsz)
    }
    
    func setNode() { fatalError("このメソッドはオーバーライドされなければなりません。") }
    
    func remakeDisplay() { fatalError("このメソッドはオーバーライドされなければなりません。") }
    
    func update(_ gameViewController: GameViewController) { fatalError("このメソッドはオーバーライドされなければなりません。") }
    
    func penalty() {
        startGame = startGame - TimeInterval(5)
        startThisQuestion = startThisQuestion - TimeInterval(5)
        elapsedPenaltyTime = Date()
    }
}
