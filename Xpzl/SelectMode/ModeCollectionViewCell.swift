//
//  ModeCollectionViewCell.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/29.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit

class ModeCollectionViewCell: UICollectionViewCell {
    
    var cellMode: Mode = .easy
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var starLabel: UILabel!
    
    @IBOutlet weak var clearView: UIView!
    
    private var smvc: SelectModeViewController!
    
    func setContext(selectModeViewController: SelectModeViewController) {
        self.smvc = selectModeViewController
    }
    
    func setLabels(section: Int, stage: Int) {
        switch cellMode {
        case .easy:
            modeLabel.text = NSLocalizedString("Easy", comment: "")
        case .normal:
            modeLabel.text = NSLocalizedString("Normal", comment: "")
        case .hard:
            modeLabel.text = NSLocalizedString("Hard", comment: "")
        }
        
        let ud = UserDefaults.standard
        if !ud.bool(forKey: u.getKeyStageStar(section, stage, cellMode)) {
            starLabel.alpha = 0.2
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        smvc.selectedCell.backgroundColor = smvc.nonselectColor
        smvc.selectedCell = self
        backgroundColor = smvc.selectedColor
    }
}
