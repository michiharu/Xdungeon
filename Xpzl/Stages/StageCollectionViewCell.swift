//
//  CollectionViewCell.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/27.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit

class StageCollectionViewCell: UICollectionViewCell {
    
    var cellSection: Int!
    var cellStage: Int!
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var clearView: UIView!
    
    private var storyboard:           UIStoryboard!
    private var stagesViewController: StagesViewController!
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let stageInfo = u.getNumsFromTag(tag: touch.view!.tag)
            section = stageInfo.section
            stage   = stageInfo.stage
            let selectMode = storyboard.instantiateViewController(withIdentifier: "SelectMode") as! SelectModeViewController
            selectMode.modalTransitionStyle = .crossDissolve
            stagesViewController.present(selectMode,animated: true, completion: nil)
        }
    }
    
    func setContext(storyboard: UIStoryboard,
                    stagesViewController: StagesViewController,
                    section: Int,
                    stage: Int) {
        
        self.storyboard           = storyboard
        self.stagesViewController = stagesViewController
        self.cellSection              = section
        self.cellStage                = stage
        
        let ud = UserDefaults.standard
        let canPlay = ud.bool(forKey: u.getKeyStageCanPlay(section, stage))
        
        // Stageラベルの設定
        stageLabel.text = section.description + " - " + stage.description
        
        // isUserInteractionEnabled の設定
        // 背景色の設定
        // New or Star or Lock の設定
        // tag の設定
        if canPlay {
            self.isUserInteractionEnabled = true
            backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            
            if ud.bool(forKey: u.getKeyStagePlayEver(cellSection, cellStage)) {
                var starCount = 0
                if ud.bool(forKey: u.getKeyStageStar(cellSection, cellStage, .easy))   { starCount += 1 }
                if ud.bool(forKey: u.getKeyStageStar(cellSection, cellStage, .normal)) { starCount += 1 }
                if ud.bool(forKey: u.getKeyStageStar(cellSection, cellStage, .hard))   { starCount += 1 }
                
                switch starCount {
                case 0:
                    state.text = "⭐️⭐️⭐️"
                    state.alpha = 0.2
                case 1:
                    state.text = "⭐️"
                case 2:
                    state.text = "⭐️⭐️"
                case 3:
                    state.text = "⭐️⭐️⭐️"
                default:
                    fatalError()
                }
            } else {
                state.text = "New!!"
                state.textColor = .red
            }
            
            clearView.tag = u.getTagNum(cellSection, cellStage)
        } else {
            self.isUserInteractionEnabled = false
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            state.text = "🔒"
        }
    }
}
