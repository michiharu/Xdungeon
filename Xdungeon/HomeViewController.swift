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
        let ud = UserDefaults.standard
        ud.register(defaults: [u.getKeyForHighScore(): 0])
        ud.set(true, forKey: u.getKeyStageCanPlay(1, 1))
        ud.register(defaults: [u.getKeyStageComplete(): 0])
        
        let high = ud.integer(forKey: u.getKeyForHighScore())
        highScore.text = "High Score: " + high.description
        
        let complete = ud.integer(forKey: u.getKeyStageComplete())
        let per: Float = Float(complete) / 120
        progressBar.progress = per
        percent.text = Int(per * 100).description + "%"
        
        if per < 0.2 { playStartButton.isHidden = true; highScore.isHidden = true }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
