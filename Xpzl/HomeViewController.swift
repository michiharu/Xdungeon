//
//  TopViewController.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/26.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBAction func playStart(_ sender: UIButton) {
        section = nil
        stage   = nil
        mode    = nil
        let game = storyboard!.instantiateViewController(withIdentifier: "ChallengeGame") as! GameViewController
        game.modalTransitionStyle = .crossDissolve
        self.present(game, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var playStartButton: UIButton!
    @IBOutlet weak var highScore: UILabel!
    
    
    @IBOutlet weak var stageSelectButton: UIButton!
    @IBAction func moveToStages(_ sender: UIButton) {
        let stages = storyboard!.instantiateViewController(withIdentifier: "Stages")
        stages.modalTransitionStyle = .crossDissolve
        self.present(stages,animated: true, completion: nil)
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var percent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        playStartButton.setTitle(NSLocalizedString("start!", comment: ""), for: .normal)
        stageSelectButton.setTitle(NSLocalizedString("Stage Select", comment: ""), for: .normal)
        
        let ud = UserDefaults.standard
        ud.register(defaults: [u.getKeyForHighScore(): 0])
        ud.set(true, forKey: u.getKeyStageCanPlay(1, 1))
        ud.register(defaults: [u.getKeyStageComplete(): 0])
        
        let high = ud.integer(forKey: u.getKeyForHighScore())
        highScore.text = NSLocalizedString("High Score: ", comment: "") + high.description
        
        let complete = ud.integer(forKey: u.getKeyStageComplete())
        let rate: Float = Float(complete) / 120
        progressBar.progress = rate
        let per: Int = Int(rate * 100)
        percent.text = per.description + "%"
        
        if per < 100 { playStartButton.isHidden = true; highScore.isHidden = true }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
