//
//  BlockOperation.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/12.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit
import GameplayKit

let font = "Arial"
let bracketFont = "Baskerville"
let xFont = "Cochin-BoldItalic"
let BRING_TO_FRONT: CGFloat = 10

let u = Util()

var fs: FitSize!
var op: Operation!
var isAdjustAllBlocks = true
var maxLevel: CGFloat!
var allBlocks: [Block] = []
var firstLayblocks: [Block] = []
var clr = Color()
var choiceCount = 3
var score: Int = 0
var drtn: TimeInterval?

var fm    : Formula!
var top   : TopBar!
var bthbtn: BothButtonController!

class Formula: SKNode {
    
    var questions:Array<[(kind: Kind, num: Num)]>!
    
    var tw: CGFloat = 0
    var scale:  CGFloat!
    var isAminated = false
    
    var originX: CGFloat { get { return -fs.width  * 0.5 / scale }}
    var originY: CGFloat { get { return -fs.height * 0.5 / scale }}
    var limitX:  CGFloat { get { return  fs.width  * 0.5 / scale }}
    var limitY:  CGFloat { get { return  fs.height * 0.5 / scale }}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        if section == nil {
            self.buildQuestions(sct: 5, stg: 1)
        } else {
            self.buildQuestions(sct: section!, stg: stage!)
        }
    }
    
    func startAmination(duration: TimeInterval) {
        isAminated = true
        drtn = duration
        self.removeAllActions()
        
        let animationFinish = SKAction.run {
            self.isAminated = false
            top.startGame         = top.startGame + drtn!
            top.startThisQuestion = top.startThisQuestion + drtn!
            drtn = nil
        }
        run(SKAction.sequence([SKAction.wait(forDuration: drtn!),
                               animationFinish]))
    }
    
    func resetBlocks() {
        print("fm.resetBlocks()")
        var currentLevel : CGFloat = 3
        while 0 <= currentLevel {
            for block in allBlocks {
                if block.level == currentLevel {
                    if block.isChangeContent {
                        block.changeContent()
                    }
                }
            }
            currentLevel -= 1
        }
        adjustFirstLayPosition()
    }
    
    func adjustFirstLayPosition() {
        isAdjustAllBlocks = false
        tw = fs.space
        for block in firstLayblocks { tw += block.width + fs.space }
        changeScale(contentWidth: tw)
        var a = (-tw * 0.5) + fs.space
        for block in firstLayblocks {
            block.ftrPoint.x = a + block.width * 0.5
            if !block.isTouched {
                block.run(SKAction.move(to: CGPoint(x: a + block.width * 0.5, y: block.ftrPoint.y), duration: drtn!))
            }
            a += block.width + fs.space
        }
    }
    
    func changeScale(contentWidth w: CGFloat) {
        scale = min(fs.width / w, fs.width / (tw + fs.bsz), 1)
        run(SKAction.scale(to: scale, duration: drtn!))
    }
    
    func setIsFirstForAllBlocks() {
        var afterEqual = false, isFirst = true
        for b in firstLayblocks {
            if isFirst || afterEqual { b.setIsFirst(true); isFirst = false; afterEqual = false }
            if let p = b as? Parnt { p.setIsFirstForAllChildren() }
            if b is Equal { afterEqual = true }
        }
        if let e = firstLayblocks.last! as? Equal { e.setIsLast(true) }
    }
    
    func isOneQuestiunFinished() -> Bool {
        guard allBlocks.count < 4 else { return false }
        guard let clct = firstLayblocks.first! as? CollectableBlock else { return false }
        guard clct.kind == Kind.X
            && clct.labels.ns.count == 1
            && clct.labels.ns.first!.num == Num(true, 1, 1) else { return false }
        
        if allBlocks.count == 2 { return true }
        else {
            guard let right = firstLayblocks.last! as? CollectableBlock else { return false }
            return right.labels.ns.count == 1
        }
        
    }
    
    
    func newQuestion(){
        /** ------------------------------------------------------ */
        for b in firstLayblocks { b.removeFromParent() }
        op = Trans()
        isAdjustAllBlocks = true
        allBlocks = []
        firstLayblocks = []
        top.startThisQuestion = Date()
        /** ------------------------------------------------------ */
        
        var question: [(kind: Kind, num: Num)]!
        
        if questions.count == 0 {
            if section == 1 || section == 2 {
                buildQuestions(sct: section!, stg: u.randNum(10, avoid:[1]))
            } else {
                buildQuestions(sct: section!, stg: stage!)
            }
        }
        
        question = questions.first!
        questions.removeFirst()
        
        var afterEqual = false, isFirst = true
        
        func createXBlock(num: Num) {
            let xBlock = CollectableBlock( kind: .X, parentID: "", level: 0, num:num)
            xBlock.name = NSUUID().uuidString
            addChild(xBlock)
            allBlocks.append(xBlock)
            firstLayblocks.append(xBlock)
            isFirst = false
            afterEqual = false
        }
        
        func createConstBlock(num: Num) {
            let cBlock = CollectableBlock(kind: .C, parentID: "", level: 0, num: num)
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
        
        func createParentBlock(multi: Num, brother: [(kind: Kind, num: Num)]) {
            let parentID = NSUUID().uuidString

            let mBlock = Multi(parentID: parentID, level: 1, num: multi)
            mBlock.name = NSUUID().uuidString
            
            var brotherBlocks: [Block] = []
            for b in brother {
                let block = CollectableBlock(kind: b.kind, parentID: parentID, level: 1, num: b.num)
                block.name = NSUUID().uuidString
                brotherBlocks.append(block)
            }
            let pBlock = Parnt(parentID: "", level: 0, multi: mBlock, blocks: brotherBlocks)
            addChild(pBlock)
            allBlocks.append(contentsOf: [pBlock, mBlock])
            allBlocks.append(contentsOf: brotherBlocks)
            firstLayblocks.append(pBlock)
            
            isFirst = false
            afterEqual = true
        }
        
        var multi: Num?
        var brother: [(kind: Kind, num: Num)] = []
        print(question)
        
        for block in question {
            if let m = multi {
                switch block.kind {
                case .X:
                    brother.append(block)
                case .C:
                    brother.append(block)
                case .P:
                    createParentBlock(multi: m, brother: brother)
                    multi   = nil
                    brother = []
                default:
                    fatalError()
                }
            } else {
                switch block.kind {
                case .X:
                    createXBlock(num: block.num)
                case .C:
                    createConstBlock(num: block.num)
                case .E:
                    createEqualBlock()
                case .M:
                    multi = block.num
                default:
                    fatalError()
                }
            }
        }
        setIsFirstForAllBlocks()
        startAmination(duration: 0.24)
        setMaxLevel()
        resetBlocks()
        bthbtn.resetBothBtns()
    } // newQuestion()
    
    func setMaxLevel() {
        maxLevel = 0
        for b in allBlocks {
            if maxLevel < b.level { maxLevel = b.level }
        }
    }
    
    func buildQuestions(sct: Int, stg: Int){
        switch sct {
        case 1:
            questions = Section1.get(stage: stg)
        case 2:
            questions = Section2.get(stage: stg)
        case 3:
            questions = Section3.get(stage: stg)
        case 4:
            questions = Section4.get(stage: stg)
        default:
            questions = Section4.getQuestions(stage: 10)
        }
    }
}
