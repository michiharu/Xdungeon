//
//  Operation.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/18.
//  Copyright © 2018年 michiharu. All rights reserved.
//
import SpriteKit

class Operation {
    var operation: String { get { return "Operation"}}
    let moveUp   = SKAction.moveTo(y: fs.splitBase, duration: 0.36)
    let moveOrigin = SKAction.moveTo(y: 0,      duration: 0.36)
    
    init() {
        moveUp  .timingMode = .easeInEaseOut
        moveOrigin.timingMode = .easeInEaseOut
    }
    
    func touchBegan(touch: UITouch, node: SKNode) {fatalError("このメソッドはオーバーライドされなければなりません！")}
    func touchMoved(touch: UITouch, node: SKNode) {fatalError("このメソッドはオーバーライドされなければなりません！")}
    func touchEnded(touch: UITouch, node: SKNode) {fatalError("このメソッドはオーバーライドされなければなりません！")}
    func update(_ currentTime: TimeInterval) {fatalError("このメソッドはオーバーライドされなければなりません！")}
}
