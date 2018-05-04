//
//  Stationary.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/20.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

class StageTopBar: TopBar {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    override func setNode() {
        barPositionX = fs.width * 0.01
        barLength = fs.width * 0.8
        // タイマー表示
        timeDisplayBG = SKShapeNode(rectOf: CGSize(width: fs.width * 0.08, height: fs.fsz - fs.space * 2.4), cornerRadius: fs.space)
        timeDisplayBG.fillColor = .white
        timeDisplayBG.lineWidth = 0
        timeDisplayBG.position = CGPoint(x: -fs.width * 0.445, y: -fs.space * 0.95)
        topBarBackground.addChild(timeDisplayBG)
        
        timeDisplayLabel.text = "Time"
        timeDisplayLabel.fontSize = fs.tbh
        timeDisplayLabel.verticalAlignmentMode = .center
        timeDisplayLabel.horizontalAlignmentMode = .left
        timeDisplayLabel.fontColor = .black
        timeDisplayLabel.position = CGPoint(x: -fs.width * 0.485, y: barSplit + fs.space * 0.5)
        topBarBackground.addChild(timeDisplayLabel)
        
        timeDisplay = SKLabelNode(fontNamed: font)
        timeDisplayBG.addChild(timeDisplay)
        timeDisplayBGHarfLength = timeDisplayBG.frame.width * 0.5
        resetTimerDisplay()
        
        // ゲージ表示
        barHeight = fs.tbh
        totalEmptyBar = SKShapeNode(rectOf: CGSize(width: barLength, height: barHeight))
        totalEmptyBar!.fillColor = .white
        totalEmptyBar!.lineWidth = 0
        totalEmptyBar!.strokeColor = .lightGray
        totalEmptyBar!.position = CGPoint(x: barPositionX, y: barSplit)
        topBarBackground.addChild(totalEmptyBar!)
        
        timeBar = SKShapeNode(rectOf: CGSize(width: barLength, height: barHeight))
        timeBar.fillColor = clr.xcdf
        timeBar.lineWidth = 0
        timeBar.strokeColor = clr.xcdf
        timeBar.position = CGPoint(x: barPositionX, y: -barSplit)
        topBarBackground.addChild(timeBar)
        
        emptyBar = SKShapeNode(rectOf: CGSize(width: barLength, height: barHeight))
        emptyBar.fillColor = .white
        emptyBar.lineWidth = 0
        emptyBar.strokeColor = clr.xcdf
        emptyBar.position = CGPoint(x: barPositionX, y: -barSplit)
        topBarBackground.addChild(emptyBar)
    }
    
    func remakeTimeBarAndDisplay() {
        timeBar.removeFromParent()
        
        let elapsedTimeThisQuestion = Date().timeIntervalSince(startThisQuestion)
        var rate: TimeInterval!
        switch mode! {
        case .easy:
            rate = TimeInterval(30 + stage! * 5) / TimeInterval(section! + 1)
        case .normal:
            rate = TimeInterval(50 + stage! * 5) / TimeInterval(section! + 1)
        case .hard:
            rate = TimeInterval(70 + stage! * 5) / TimeInterval(section! + 1)
        }
        scoreOfThisBar = 1000 - Int(elapsedTimeThisQuestion * rate)
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
        remakeTimeBarAndDisplay()
        
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
            if section != nil { moveTimeBarToTotal() }
            
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
    
    func moveTimeBarToTotal() {
        timeBar.alpha = 1
        let copyBar = timeBar.copy() as! SKShapeNode
        if let last = lastTotalBar {
            let emptyBarRight = barPositionX + barLength * 0.5
            let newBarRight = last.position.x + last.frame.width *  0.5 + copyBar.frame.width
            if newBarRight < emptyBarRight {
                let pointX = newBarRight - copyBar.frame.width * 0.5
                topBarBackground.addChild(copyBar)
                copyBar.run(SKAction.move(to: CGPoint(x: pointX, y: barSplit), duration: 0.48))
                lastTotalBar = copyBar
            } else {
                let newBarLength = emptyBarRight - (last.position.x + last.frame.width *  0.5)
                let pointX = last.position.x + last.frame.width *  0.5 + newBarLength * 0.5
                topBarBackground.addChild(copyBar)
                let shrinkScale: CGFloat = newBarLength / copyBar.frame.width
                let shrinkAndMove = SKAction.group([SKAction.scaleX(to: shrinkScale, duration: 0.48),
                                                    SKAction.move(to: CGPoint(x: pointX, y: barSplit), duration: 0.48)])
                copyBar.run(shrinkAndMove)
                lastTotalBar = copyBar
            }
        } else {
            let pointX = barPositionX + (-barLength + copyBar.frame.width) * 0.5
            topBarBackground.addChild(copyBar)
            copyBar.run(SKAction.move(to: CGPoint(x: pointX, y: barSplit), duration: 0.48))
            lastTotalBar = copyBar
        }
    }
}
