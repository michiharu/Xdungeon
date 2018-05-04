//
//  ModeCollectionViewCell.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/29.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit

class ModeCollectionViewCell: UICollectionViewCell {
    
    var cellMode: Mode!
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var starLabel: UILabel!
    
    @IBOutlet weak var clearView: UIView!
    
    private var smvc: SelectModeViewController!
    
    func setContext(selectModeViewController: SelectModeViewController) {
        self.smvc = selectModeViewController
    }
    
    func setLabels(section: Int, stage: Int) {
        modeLabel.text = cellMode.rawValue
        let ud = UserDefaults.standard
        let key = u.getKeyStageStar(section, stage, cellMode)
        if !ud.bool(forKey: key) {
            starLabel.alpha = 0.1
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        smvc.selectedCell.backgroundColor = smvc.nonselectColor
        smvc.selectedCell = self
        backgroundColor = smvc.selectedColor
    }
}
