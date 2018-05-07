//
//  SelectLevelViewController.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/26.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit

class StagesViewController: UIViewController, UICollectionViewDataSource {
    
    @IBAction func backToHome(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "Home")
        next.modalTransitionStyle = .crossDissolve
        self.present(next,animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    let sectionIndex: [String] = [NSLocalizedString("Stage", comment: "") + " 1",
                                  NSLocalizedString("Stage", comment: "") + " 2",
                                  NSLocalizedString("Stage", comment: "") + " 3",
                                  NSLocalizedString("Stage", comment: "") + " 4"]
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionView: StageCollectionReusableView = collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                              withReuseIdentifier: "StageSection",
                                              for: indexPath as IndexPath) as! StageCollectionReusableView
        
        
        sectionView.sectionLabel.text = sectionIndex[indexPath.section]
        
        return sectionView
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StageCell",
                                                      for: indexPath) as! StageCollectionViewCell
        
        let section = indexPath.section + 1
        let stage   = indexPath.row + 1
        cell.setContext(storyboard: storyboard!, stagesViewController: self, section: section, stage: stage)
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
