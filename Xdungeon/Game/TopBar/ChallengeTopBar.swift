//
//  Stationary.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/20.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

class ChallengeTopBar: TopBar {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init() {
        super.init()
    }
    
    override func setNode() {
        barPositionX = fs.width * 0.08
        barLength = fs.width * 0.65
        // スコア表示
        scoreCountBG = SKShapeNode(rectOf: CGSize(width: fs.width * 0.14, height: fs.fsz - fs.space * 2.4), cornerRadius: fs.space)
        scoreCountBG.fillColor = .white
        scoreCountBG.lineWidth = 0
        scoreCountBG.position = CGPoint(x: -fs.width * 0.42, y: -fs.space * 0.95)
        topBarBackground.addChild(scoreCountBG)
        
        
        scoreLabel.text = "Score"
        scoreLabel.fontSize = fs.tbh * 0.8
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: -fs.width * 0.49, y: barSplit + fs.space * 0.5)
        topBarBackground.addChild(scoreLabel)
        
        scoreCountLabel.text = String(score)
        scoreCountLabel.fontSize = fs.tbh * 1.7
        scoreCountLabel.verticalAlignmentMode = .center
        scoreCountLabel.horizontalAlignmentMode = .right
        scoreCountLabel.fontColor = clr.xcdf
        scoreCountBGHarfLength = scoreCountBG.frame.width * 0.5
        scoreCountLabel.position = CGPoint(x: scoreCountBGHarfLength - fs.space, y: 0)
        scoreCountBG.addChild(scoreCountLabel)
        
        // タイマー表示
        timeDisplayBG = SKShapeNode(rectOf: CGSize(width: fs.width * 0.08, height: fs.fsz - fs.space * 2.4), cornerRadius: fs.space)
        timeDisplayBG.fillColor = .white
        timeDisplayBG.lineWidth = 0
        timeDisplayBG.position = CGPoint(x: -fs.width * 0.30, y: -fs.space * 0.95)
        topBarBackground.addChild(timeDisplayBG)
        
        timeDisplayLabel.text = "Time"
        timeDisplayLabel.fontSize = fs.tbh
        timeDisplayLabel.verticalAlignmentMode = .center
        timeDisplayLabel.horizontalAlignmentMode = .left
        timeDisplayLabel.fontColor = .black
        timeDisplayLabel.position = CGPoint(x: -fs.width * 0.34, y: barSplit + fs.space * 0.5)
        topBarBackground.addChild(timeDisplayLabel)
        
        timeDisplay = SKLabelNode(fontNamed: font)
        timeDisplayBG.addChild(timeDisplay)
        timeDisplayBGHarfLength = timeDisplayBG.frame.width * 0.5
        resetTimerDisplay()
        
        // ゲージ表示
        barHeight = fs.tbh * 2.8
        timeBar = SKShapeNode(rectOf: CGSize(width: barLength, height: barHeight))
        timeBar.fillColor = clr.xcdf
        timeBar.lineWidth = 0
        timeBar.position = CGPoint(x: barPositionX, y: 0)
        topBarBackground.addChild(timeBar)
        
        emptyBar = SKShapeNode(rectOf: CGSize(width: barLength, height: barHeight))
        emptyBar.fillColor = .white
        emptyBar.lineWidth = 0
        emptyBar.position = CGPoint(x: barPositionX, y: 0)
        topBarBackground.addChild(emptyBar)
    }
    
    override func remakeDisplay() {
        timeBar.removeFromParent()
        
        let elapsedTimeThisQuestion = Date().timeIntervalSince(startThisQuestion)
        scoreOfThisBar = 1000 - Int(elapsedTimeThisQuestion * 20)
        let nextBarLength = barLength * CGFloat(scoreOfThisBar) / 1000
        timeBar = SKShapeNode(rectOf: CGSize(width: nextBarLength, height: barHeight))
        timeBar.fillColor = clr.xcdf
        timeBar.lineWidth = 0
        timeBar.strokeColor = clr.xcdf
        timeBar.position.x = barPositionX - (barLength - nextBarLength) * 0.5
        timeBar.position.y = (section != nil) ? -barSplit : 0
        
        
        if let e = elapsedPenaltyTime {
            timeBar.fillColor = .red
            if barAlpha < 0.2 { isIncreasing = true }
            if 0.98 < barAlpha { isIncreasing = false }
            if isIncreasing { barAlpha += 0.06 } else { barAlpha -= 0.06 }
            
            if 2 < Date().timeIntervalSince(e) { elapsedPenaltyTime = nil }
        } else {
            if barAlpha < 0.2 { isIncreasing = true }
            if 0.98 < barAlpha { isIncreasing = false }
            if isIncreasing { barAlpha += 0.01 } else { barAlpha -= 0.01 }
        }
        
        timeBar.alpha = barAlpha
        topBarBackground.addChild(timeBar)
        
        let elapsedTimeStartGame = Date().timeIntervalSince(startGame)
        timerCount = timeLimit - Int(elapsedTimeStartGame)
        resetTimerDisplay()
    }
    
    func resetTimerDisplay() {
        timeDisplay.removeFromParent()
        timeDisplay = SKLabelNode(fontNamed: font)
        timeDisplay.text = String(timerCount)
        timeDisplay.fontColor = clr.xcdf
        timeDisplay.fontSize = fs.tbh * 2
        timeDisplay.verticalAlignmentMode = .center
        timeDisplay.horizontalAlignmentMode = .right
        timeDisplay.position = CGPoint(x: timeDisplayBGHarfLength - fs.space, y: 0)
        timeDisplayBG.addChild(timeDisplay)
    }
    
    override func update(_ gameViewController: GameViewController) {
        remakeDisplay()
        
        if timerCount == 0 || scoreOfThisBar < 0 {
            if section != nil {
                gameViewController.finish(state: .gameOver)
                return
            } else {
                gameViewController.finish(state: .finish, score: score)
                return
            }
        }
        
        guard !op.isTouched else { return }
        if fm.isOneQuestiunFinished() {
            calcScore()
            
            if section != nil && score > 1000 {
                gameViewController.finish(state: .clearStage)
                return
            }
            displayNext()
            fm.newQuestion()
        }
    }
    
    func calcScore() {
        var currentScore: Int = Int(maxScore * timeBar.frame.width / barLength)
        currentScore = currentScore > 999 ? 999 : currentScore
        score += currentScore
        scoreCountLabel.text = String(score)
    }
    
    func displayNext() {
        let newLabel = nextLabel.copy() as! SKLabelNode
        newLabel.run(sceneChangeAction)
        addChild(newLabel)
    }
}
