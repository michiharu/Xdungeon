//
//  Color.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/16.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

class Color {
    var mode: ColorMode = WhiteBase()
    
    var bgc:    SKColor { get { return mode.bgc   }}
    var mdlbg:  SKColor { get { return mode.mdlbg }}
    var xcdf:   SKColor { get { return mode.xcdf  }}
    
    var shape:  SKColor { get { return mode.shape }}
    
    var eql:    SKColor { get { return mode.eql   }}
    var brckt:  SKColor { get { return mode.brckt }}
    var zero:   SKColor { get { return mode.zero  }}
    var quest:   SKColor { get { return mode.quest }}
    
    var xplus:  SKColor { get { return mode.xplus }} // x plus color
    var xminu:  SKColor { get { return mode.xminu }} // x minus color
    var cplus:  SKColor { get { return mode.cplus }} // constant plus color
    var cminu:  SKColor { get { return mode.cminu }} // constant minus color
    
    var slctd:  SKColor { get { return mode.slctd }}
    var chln :  SKColor { get { return mode.chln  }}
    var chadd:  SKColor { get { return mode.chadd }}
    var chbtn:  SKColor { get { return mode.chbtn }}
    var both :  SKColor { get { return mode.both  }}
    var bothf:  SKColor { get { return mode.bothf }}
    var btslc:  SKColor { get { return mode.btslc }}
}

class ColorMode {
    
    var bgc:    SKColor { get { return SKColor.black }}
    var mdlbg:  SKColor { get { return SKColor.black }}
    var xcdf:   SKColor { get { return SKColor.black }}
    
    var shape:  SKColor { get { return SKColor.black }}
    var eql:    SKColor { get { return SKColor.black }}
    var brckt:  SKColor { get { return SKColor.black }}
    var zero:   SKColor { get { return SKColor.black }}
    var quest:  SKColor { get { return SKColor.black }}
    
    var xplus:  SKColor { get { return SKColor.black }}
    var xminu:  SKColor { get { return SKColor.black }}
    var cplus:  SKColor { get { return SKColor.black }}
    var cminu:  SKColor { get { return SKColor.black }}
    
    var slctd:  SKColor { get { return SKColor.black }}
    var chln :  SKColor { get { return SKColor.black }}
    var chadd:  SKColor { get { return SKColor.black }}
    var chbtn:  SKColor { get { return SKColor.black }}
    var both :  SKColor { get { return SKColor.black }}
    var bothf:  SKColor { get { return SKColor.black }}
    var btslc:  SKColor { get { return SKColor.black }}
}


class Neon: ColorMode {
    override var bgc: SKColor { get { return SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)}}
    override var mdlbg: SKColor { get { return SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.5)}}
    
    
    override var shape: SKColor { get { return SKColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 0.15) }}
    override var eql:   SKColor { get { return SKColor.white }}
    override var brckt: SKColor { get { return SKColor.white }}
    override var zero:  SKColor { get { return SKColor.white }}
    override var quest: SKColor { get { return SKColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0) }}
    
    override var xplus: SKColor { get { return SKColor(red: 1.00, green: 0.25, blue: 0.40, alpha: 1.0) }}
    override var xminu: SKColor { get { return SKColor(red: 0.00, green: 0.80, blue: 1.00, alpha: 1.0) }}
    override var cplus: SKColor { get { return SKColor(red: 1.00, green: 0.35, blue: 0.55, alpha: 1.0) }}
    override var cminu: SKColor { get { return SKColor(red: 0.20, green: 0.90, blue: 1.00, alpha: 1.0) }}
    
    
    override var slctd: SKColor { get { return SKColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 0.3) }}
    override var chln : SKColor { get { return SKColor(red: 0.30, green: 1.00, blue: 0.50, alpha: 1.0) }}
    override var chadd: SKColor { get { return SKColor(red: 1.00, green: 0.40, blue: 0.70, alpha: 1.0) }}
    override var chbtn: SKColor { get { return SKColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 0.15) }}
    override var both : SKColor { get { return SKColor(red: 0.10, green: 0.60, blue: 1.00, alpha: 1.0) }}
    override var bothf: SKColor { get { return SKColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.0) }}
    override var btslc: SKColor { get { return SKColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0) }}
}

class Material: ColorMode {
    
}

class WhiteBase: ColorMode {
    override var bgc: SKColor { get { return SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)}}
    override var xcdf: SKColor  { get { return SKColor(red: 0, green: 0.5, blue: 1, alpha: 1) }}
    
    override var shape: SKColor { get { return SKColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 0.05) }}
    override var eql:   SKColor { get { return SKColor.black }}
    override var brckt: SKColor { get { return SKColor.black }}
    override var zero:  SKColor { get { return SKColor.black }}
    override var quest: SKColor { get { return SKColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0) }}
    
    override var xplus: SKColor { get { return SKColor(red: 0.50, green: 0.00, blue: 0.15, alpha: 1.0) }}
    override var xminu: SKColor { get { return SKColor(red: 0.00, green: 0.30, blue: 0.50, alpha: 1.0) }}
    override var cplus: SKColor { get { return SKColor(red: 0.60, green: 0.00, blue: 0.20, alpha: 1.0) }}
    override var cminu: SKColor { get { return SKColor(red: 0.00, green: 0.45, blue: 0.60, alpha: 1.0) }}
    
    
    override var slctd: SKColor { get { return SKColor(red: 0.40, green: 1.00, blue: 0.20, alpha: 1.0) }}
    override var chln : SKColor { get { return SKColor(red: 0.30, green: 1.00, blue: 0.50, alpha: 1.0) }}
    override var chadd: SKColor { get { return SKColor(red: 1.00, green: 0.40, blue: 0.70, alpha: 1.0) }}
    override var chbtn: SKColor { get { return SKColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 0.15) }}
    override var both : SKColor { get { return SKColor(red: 1.00, green: 0.45, blue: 0.60, alpha: 1.0) }}
    override var bothf: SKColor { get { return SKColor(red: 0.20, green: 0.20, blue: 1.00, alpha: 1.0) }}
    override var btslc: SKColor { get { return SKColor(red: 0.20, green: 0.20, blue: 1.00, alpha: 1.0) }}
}

class Classic: ColorMode {
    
}
