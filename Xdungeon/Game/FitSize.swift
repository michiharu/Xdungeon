//
//  FitSize.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/16.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import SpriteKit

struct FitSize {
    
    let width:  CGFloat
    let height: CGFloat
    let splitBase: CGFloat
    let h40:    CGFloat
    
    let bsz:   CGFloat   // block size
    let blw:   CGFloat   // block line width
    let fsz:   CGFloat   // font size
    let barw:  CGFloat   // bar width
    let barh:  CGFloat   // bar height
    let barc:  CGFloat   // bar corner radius
    let space: CGFloat
    let cr:    CGFloat   // corner radius
    let brsz:  CGFloat   // bracket size
    let hlw:   CGFloat   // hint line width
    let arc:   CGFloat   // arch
    let glw:   CGFloat   // glow width
    let hglw:  CGFloat   // hint flow width
    let minbw: CGFloat   // mini block width
    let minSc: CGFloat   // mini scale
    let lncrv: CGFloat   // line curve
    let bothsr: CGFloat
    let tbh:   CGFloat   // time bar height
    
    init(w: CGFloat, h: CGFloat) {
        height = h
        width  = w
        splitBase = h * 0.18
        h40    = h * 0.40
        
        bsz   = h * 0.240
        blw   = h * 0.005
        fsz   = h * 0.116
        barw  = h * 0.150
        barh  = h * 0.008
        barc  = h * 0.002
        space = h * 0.020
        cr    = h * 0.030
        brsz  = h * 0.140
        hlw   = h * 0.002
        arc   = h * 0.080
        glw   = h * 0.010
        hglw  = h * 0.004
        minbw = h * 0.180
        minSc = 0.5
        lncrv = h * 0.080
        bothsr = h * 0.25
        tbh = h * 0.03
    }
}
