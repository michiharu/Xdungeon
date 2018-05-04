//
//  SelectModeViewController.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/26.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit

class SelectModeViewController: UIViewController, UICollectionViewDataSource  {
    
    @IBAction func backToStages(_ sender: UIButton) {
        let stages = storyboard!.instantiateViewController(withIdentifier: "Stages")
        stages.modalTransitionStyle = .crossDissolve
        self.present(stages,animated: true, completion: nil)
    }
    
    @IBAction func startPuzzle(_ sender: UIButton) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: u.getKeyStagePlayEver(section!, stage!))
        let game = storyboard!.instantiateViewController(withIdentifier: "StageGame")
        game.modalTransitionStyle = .crossDissolve
        mode = selectedCell.cellMode
        self.present(game, animated: true, completion: nil)
    }
    
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var hint1: UILabel!
    @IBOutlet weak var hint2: UILabel!
    
    var selectedCell: ModeCollectionViewCell!
    let selectedColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
    let nonselectColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
    
    let levels: [String] = [
        String(format: NSLocalizedString("Easy", comment: "")),
        String(format: NSLocalizedString("Normal", comment: "")),
        String(format: NSLocalizedString("Hard", comment: ""))
    ]
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModeCell",
                                                      for: indexPath) as! ModeCollectionViewCell
        cell.setContext(selectModeViewController: self)
        let index: Int = indexPath.last! + 1
        
        switch index {
        case 1:
            cell.cellMode = .easy
            cell.backgroundColor = selectedColor
            selectedCell = cell
        case 2:
            cell.cellMode = .normal
            cell.backgroundColor = nonselectColor
        case 3:
            cell.cellMode = .hard
            cell.backgroundColor = nonselectColor
        default:
            fatalError()
        }
        cell.setLabels(section: section!, stage: stage!)
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stageLabel.text = "Stage " + section!.description + " - " + stage!.description
        hint1.isHidden = true
        hint2.isHidden = true
        if stage == 1 {
            switch section {
            case 1:
                hint1.isHidden = false
                hint1.text = "\" x = ? \"という式の形になるよう、ブロックを指でスライドさせましょう。"
            case 2:
                hint1.isHidden = false
                hint2.isHidden = false
                hint1.text = "下段に表示されている数字のボタンを長押しして、両辺に数字を掛けましょう"
                hint2.text = "掛け算があるブロックはタップすると計算できます。"
            case 3:
                let _ = 1 // ヒントは表示しない
            case 4:
                hint1.isHidden = false
                hint1.text = "( ) の前のブロックをスライドさせて、( ) の中の数字それぞれに近づけましょう。"
            default:
                fatalError("sectionは1-4")
            }
        }
        
        if section == 1 && stage == 2 {
            hint1.isHidden = false
            hint1.text = "計算できるブロックが隣り合っているときに、それぞれをタップすると計算できます。"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
