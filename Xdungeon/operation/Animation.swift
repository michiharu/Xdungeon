//
//  Disable.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/18.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class Animation: Operation {
    
    let next: Operation
    let duration: CFTimeInterval
    
    private var start: CFTimeInterval?
    
    init(_ nx: Operation, duration: CFTimeInterval) {
        self.next = nx
        self.duration = duration
        operationLabel.text = "Animation"
    }
    
    override func touchBegan(touch: UITouch, node: SKNode) {}
    override func touchMoved(touch: UITouch, node: SKNode) {}
    override func touchEnded(touch: UITouch, node: SKNode) {}
    
    override func update(_ currentTime: TimeInterval) {
        guard let s = start else { start = currentTime; return }
        
        if s + duration < currentTime {
            op = next
            operationLabel.text = next.operation
        }
    }
}
