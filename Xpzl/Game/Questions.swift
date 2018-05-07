//
//  Questions.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/30.
//  Copyright © 2018年 michiharu. All rights reserved.
//

struct Section1 { // 35題
    static let t: Bool = true
    static let f: Bool = false
    static let ____equal____: (Kind, Num) = (.E,Num(true,1,0))
    static let x: (Kind, Num) = (.X,Num(t,1,1))
    
    static let stage1: Array<[(Kind, Num)]> = [
        [x,(.C,Num(t, 3, 1)),____equal____],
        [x,(.C,Num(f, 9, 1)),____equal____],
        [(.C,Num(t,15, 1)),x,____equal____],
        [x,(.C,Num(t, 2, 3)),____equal____],
        [(.C,Num(f,15, 7)),x,____equal____],
        [(.C,Num(t, 6, 1)),x,____equal____],
        [x,(.C,Num(f, 2, 1)),____equal____],
        [(.C,Num(f, 5, 1)),____equal____,(.X,Num(f, 1, 1))],
        [(.C,Num(f, 2, 1)),____equal____,(.X,Num(f, 1, 1))]]
    
    static let stage2: Array<[(Kind, Num)]> = [
        [x,(.C,Num(f, 7, 1)),____equal____,(.C,Num(t, 3, 1))],
        [x,(.C,Num(f, 2, 1)),____equal____,(.C,Num(t,13, 1))],
        [x,(.C,Num(f, 4, 1)),____equal____,(.C,Num(t, 8, 5))],
        [x,(.C,Num(t, 2, 3)),____equal____,(.C,Num(t, 1, 1))],
        [x,(.C,Num(f, 2, 7)),____equal____,(.C,Num(t, 6, 7))],
        [x,(.C,Num(f, 3, 1)),____equal____,(.C,Num(t, 9, 5))],
        [x,(.C,Num(t, 5, 1)),____equal____,(.C,Num(t,14, 1))],
        [(.C,Num(t, 6, 1)),x,____equal____,(.C,Num(t, 2, 1))],
        [x,(.C,Num(f, 7, 1)),____equal____,(.C,Num(t, 5, 1))],
        [x,(.C,Num(t,10, 1)),____equal____,(.C,Num(t, 5, 1))],
        [(.C,Num(t, 8, 1)),x,____equal____,(.C,Num(t, 8, 1))],
        [(.C,Num(t,37,10)),x,____equal____,(.C,Num(f,13,10))],
        [x,(.C,Num(f, 5, 1)),____equal____,(.C,Num(t, 8, 1))],
        [x,(.C,Num(t,12, 1)),____equal____,(.C,Num(t, 4, 1))],
        [x,(.C,Num(f, 6, 1)),____equal____,(.C,Num(f,13, 1))]]
    
    static func get(stage: Int) -> Array<[(Kind, Num)]> {
        switch stage {
        case 1:
            return stage1
        case 2:
            return stage2
        default:
            return getQuestions(stage:stage)
        }
    }
    
    static func getQuestions(stage: Int) -> Array<[(Kind, Num)]> {
        var result: Array<[(Kind, Num)]> = []
        for _ in 0...9 {
            result.append(makeQuestion(stage: stage))
        }
        return result
    }
    
    static func makeQuestion(stage: Int) -> [(Kind, Num)] {
        
        let dfclt = stage + 5
        
        // 答えをつくる
        var x      = Num(true, 1, 1)
        let isFraction = u.randBool(40 + stage * 5)
        let deno = isFraction ? u.randNum(dfclt) : 1
        let answer = Num(u.randBool(), u.randNum(dfclt), deno)
        // 項の数を決める
        let cCount = u.randNum(2) + 1
        
        func getNumArray(answer: Num, count: Int) -> [Num] {
            var array: [Num] = []
            var targetX: Int = answer.moleWithSign
            for _ in 1..<count {
                var splitNum: Int
                repeat { splitNum = u.randNum(dfclt) * u.randP1M1() } while splitNum == targetX
                targetX = targetX - splitNum
                array.append(Num(0 < splitNum, abs(splitNum), answer.deno))
            }
            array.append(Num(0 < targetX, abs(targetX),  answer.deno))
            return array
        }
        
        // 決めた項の数になるようにx、cそれぞれ分解する
        let cArray: [Num] = getNumArray(answer: answer, count: cCount)
        
        // 左辺、右辺を用意する
        var left:  [(Kind, Num)] = []
        var right: [(Kind, Num)] = []
        
        // x、cの項を左辺、右辺に振り分ける
        // xを右辺に振る際、cを左辺に振る際は項の符号を反転させる
        if u.randBool() { left.append((.X, x)) } else { right.append((.X, Num(false,1,1))) }
        
        for c in cArray {
            if u.randBool() {
                let reverseNum: Num = Num(!x.isPlus, x.mole, x.deno)
                left.append((.C, reverseNum))
            } else {
                right.append((.C, c))
            }
        }
        left .shuffle()
        right.shuffle()
        
        var result: [(Kind, Num)] = []
        result.append(contentsOf: left)
        result.append((.E,Num(true,1,0)))
        result.append(contentsOf: right)
        
        return result
    }
}

struct Section2 {
    static let t: Bool = true
    static let f: Bool = false
    static let ______equal______: (Kind, Num) = (.E,Num(true,1,0))
    
    static let stage1: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 3, 1)),______equal______,(.C,Num(t,15, 1))],
        [(.X,Num(t, 4, 1)),______equal______,(.C,Num(t,24, 1))],
        [(.X,Num(t, 6, 1)),______equal______,(.C,Num(f,18, 1))]]
    
    static let stage2: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 8, 1)),______equal______,(.C,Num(t, 4, 1))],
        [(.X,Num(t,15, 1)),______equal______,(.C,Num(t,20, 1))],
        [(.X,Num(f, 9, 1)),______equal______,(.C,Num(t,27, 1))]]
    
    static let stage3: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 1, 6)),______equal______,(.C,Num(t, 3, 1))],
        [(.X,Num(t, 4, 1)),______equal______,(.C,Num(f, 3, 1))],
        [(.X,Num(f, 1, 7)),______equal______,(.C,Num(t, 6, 1))]]
    
    static let stage4: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 3, 5)),______equal______,(.C,Num(t, 2, 1))],
        [(.X,Num(t, 3, 4)),______equal______,(.C,Num(f, 6, 1))],
        [(.X,Num(f, 5, 8)),______equal______,(.C,Num(t,10, 3))]]
    
    static let stage5: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 2, 1)),______equal______,(.C,Num(t,18, 1))],
        [(.X,Num(f, 3, 1)),______equal______,(.C,Num(t,21, 3))],
        [(.X,Num(f, 9, 1)),______equal______,(.C,Num(t, 3, 1))]]

    static let stage6: Array<[(Kind, Num)]> = [
        [(.X,Num(t,12, 1)),______equal______,(.C,Num(t,15, 1))],
        [(.X,Num(t, 1, 4)),______equal______,(.C,Num(t, 2, 1))],
        [(.X,Num(t, 1, 5)),______equal______,(.C,Num(f, 6, 1))]]

    static let stage7: Array<[(Kind, Num)]> = [
        [(.X,Num(f, 8, 1)),______equal______,(.C,Num(t, 7, 1))],
        [(.X,Num(t, 2, 9)),______equal______,(.C,Num(f, 4, 1))],
        [(.X,Num(t, 2, 1)),______equal______,(.C,Num(t,10, 1))]]

    static let stage8: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 2, 3)),______equal______,(.C,Num(f, 8, 1))],
        [(.C,Num(f,12, 1)),______equal______,(.X,Num(t, 2, 3))],
        [(.C,Num(t, 8, 1)),______equal______,(.X,Num(f, 2, 1))]]

    static let stage9: Array<[(Kind, Num)]> = [
        [(.X,Num(f, 4, 1)),______equal______,(.C,Num(t,24, 1))],
        [(.X,Num(t, 2, 5)),(.C,Num(t, 6, 1)),______equal______],
        [(.X,Num(f, 2, 1)),(.C,Num(t, 7, 1)),______equal______]]
    
    static let stage10: Array<[(Kind, Num)]> = [
        [(.X,Num(f, 8, 1)),______equal______,(.C,Num(t,48, 1))],
        [(.X,Num(f,12, 1)),______equal______,(.C,Num(f,72, 1))],
        [(.X,Num(t, 5, 4)),______equal______,(.C,Num(f,10, 1))],
        [(.X,Num(t, 3, 7)),______equal______,(.C,Num(t,12, 1))],
        [(.X,Num(f,18, 1)),______equal______,(.C,Num(f,15, 1))],
        [(.C,Num(t, 3,10)),______equal______,(.X,Num(f, 6, 1))],
        [(.C,Num(f, 3, 2)),(.X,Num(f, 1, 2)),______equal______],
        [(.C,Num(t, 7, 1)),______equal______,(.X,Num(t, 7,10))]]
    
    static func get(stage: Int) -> Array<[(Kind, Num)]> {
        switch stage {
        case 1:
            return stage1
        case 2:
            return stage2.shuffled
        case 3:
            return stage3.shuffled
        case 4:
            return stage4.shuffled
        case 5:
            return stage5.shuffled
        case 6:
            return stage6.shuffled
        case 7:
            return stage7.shuffled
        case 8:
            return stage8.shuffled
        case 9:
            return stage9.shuffled
        case 10:
            return stage10.shuffled
        default:
            fatalError("stageは１〜１０")
        }
    }
}

struct Section3 {
    static let t: Bool = true
    static let f: Bool = false
    static let ______equal______: (Kind, Num) = (.E,Num(true,1,0))
    
    static let stage1: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 2, 1)),(.C,Num(t, 3, 1)),______equal______,(.C,Num(f, 8, 1))],
        [(.X,Num(t, 4, 1)),______equal______,(.C,Num(t,24, 1))],
        [(.X,Num(t, 3, 1)),(.C,Num(t, 8, 1)),______equal______,(.C,Num(t,14, 1))],
        [(.C,Num(t,13, 1)),(.X,Num(f, 4, 1)),______equal______,(.C,Num(f, 7, 1))],
        [(.C,Num(t,15, 1)),______equal______,(.C,Num(f, 3, 1)),(.X,Num(f, 2, 1))],
        [(.X,Num(t, 7, 1)),______equal______,(.C,Num(t,24, 1)),(.X,Num(f, 1, 1))],
        [(.C,Num(t,28, 1)),(.X,Num(f, 2, 1)),______equal______,(.X,Num(t, 5, 1))],
        [(.X,Num(t, 4, 1)),(.C,Num(f,18, 1)),______equal______,(.X,Num(f, 2, 1))],
        [(.C,Num(t, 8, 1)),(.X,Num(t, 1, 1)),______equal______,(.X,Num(f, 7, 1))],
        [(.X,Num(t, 8, 1)),______equal______,(.X,Num(t, 9, 1)),(.X,Num(t, 5, 1))]]
    
    static let stage2: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 3, 1)),(.C,Num(f, 2, 1)),______equal______,(.C,Num(t, 4, 1))],
        [(.X,Num(t, 2, 1)),(.C,Num(t, 7, 1)),______equal______,(.C,Num(t,13, 1))],
        [(.C,Num(t,10, 1)),(.X,Num(t, 4, 1)),______equal______,(.C,Num(t, 2, 1))],
        [(.C,Num(t,11, 1)),(.X,Num(f, 2, 1)),______equal______,(.C,Num(f, 5, 1))],
        [(.C,Num(t, 4, 1)),______equal______,(.C,Num(t,16, 1)),(.X,Num(f, 3, 1))],
        [(.C,Num(t, 5, 1)),______equal______,(.C,Num(t,19, 1)),(.X,Num(t, 2, 1))],
        [(.X,Num(t, 5, 1)),______equal______,(.C,Num(t,12, 1)),(.X,Num(f, 1, 1))],
        [(.C,Num(t,24, 1)),(.X,Num(f, 5, 1)),______equal______,(.X,Num(t, 3, 1))],
        [(.X,Num(t, 3, 1)),(.X,Num(f,30, 1)),______equal______,(.X,Num(f, 2, 1))],
        [(.C,Num(t, 9, 1)),(.X,Num(f, 8, 1)),______equal______,(.X,Num(t, 1, 1))]]
    
    static let stage3: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 1, 1)),(.C,Num(f,12, 1)),______equal______,(.X,Num(t, 4, 1))],
        [(.X,Num(t, 5, 1)),______equal______,(.X,Num(t, 6, 1)),(.C,Num(t, 7, 1))],
        [(.X,Num(t, 2, 1)),(.C,Num(t, 6, 1)),______equal______,(.C,Num(t,20, 1))],
        [(.X,Num(f, 1, 1)),(.C,Num(f,12, 1)),______equal______,(.C,Num(f, 9, 1))],
        [(.X,Num(f, 4, 1)),(.C,Num(t,14, 1)),______equal______,(.C,Num(f,26, 1))],
        [(.X,Num(t, 5, 1)),(.C,Num(f,15, 1)),______equal______,(.X,Num(t,45, 1))],
        [(.X,Num(t, 4, 1)),______equal______,(.C,Num(f,18, 1)),(.X,Num(f, 5, 1))],
        [(.X,Num(f, 1, 1)),______equal______,(.C,Num(t,27, 1)),(.X,Num(t, 2, 1))],
        [(.X,Num(t, 1, 1)),(.C,Num(t, 7, 5)),______equal______,(.X,Num(f,21,10))],
        [(.C,Num(f,27,10)),(.X,Num(t, 1, 1)),______equal______,(.C,Num(t,63,10))]]
    
    static let stage4: Array<[(Kind, Num)]> = [
        [(.X,Num(t, 1, 1)),(.C,Num(t,14, 5)),______equal______,(.C,Num(t,14, 5))],
        [(.X,Num(t,13, 5)),(.C,Num(f,24, 5)),______equal______,(.X,Num(t, 7, 5))],
        [(.X,Num(t, 1, 1)),(.C,Num(f, 1, 4)),______equal______,(.C,Num(t, 3, 4))],
        [(.C,Num(f, 2, 5)),(.X,Num(t, 1, 1)),______equal______,(.C,Num(f, 3,10))],
        [(.C,Num(t, 1, 6)),(.X,Num(f, 1, 1)),______equal______,(.C,Num(f, 2, 3))],
        [(.X,Num(t, 2, 1)),(.C,Num(f, 1, 2)),______equal______,(.X,Num(f, 1, 1))],
        [(.C,Num(f, 1, 1)),______equal______,(.X,Num(f, 4, 1)),(.C,Num(f,13, 1))],
        [(.X,Num(t, 1, 1)),(.C,Num(t,21, 1)),______equal______,(.X,Num(f, 2, 1))],
        [(.X,Num(f, 6, 1)),(.C,Num(t, 2, 1)),______equal______,(.C,Num(f,34,10))],
        [(.X,Num(f, 7, 1)),(.C,Num(t, 6, 1)),______equal______,(.C,Num(f,50, 1))]]
    
    static func get(stage: Int) -> Array<[(Kind, Num)]> {
        switch stage {
        case 1:
            return stage1.shuffled
        case 2:
            return stage2.shuffled
        case 3:
            return stage3.shuffled
        case 4:
            return stage4.shuffled
        default:
            return getQuestions(stage:stage)
        }
    }
    
    static func getQuestions(stage: Int) -> Array<[(Kind, Num)]> {
        var result: Array<[(Kind, Num)]> = []
        for _ in 0...9 {
            result.append(makeQuestion(stage: stage))
        }
        return result
    }
    
    static func makeQuestion(stage: Int) -> [(Kind, Num)] {
        
        let dfclt = stage + 5
        
        // 答えをつくる
        let isFraction = u.randBool(30 + stage * 5)
        let deno = isFraction ? u.randNum(dfclt) : 1
        let answer = Num(u.randBool(), u.randNum(dfclt), u.randNum(dfclt))
        // 項の数を決める
        let xCount = u.randNum(2) + 1
        let cCount = u.randNum(2) + 1
        
        func getNumArray(answer:Int, count: Int) -> [Num] {
            var array: [Num] = []
            var targetX: Int = answer
            for _ in 1..<count {
                var splitNum: Int
                repeat { splitNum = u.randNum(dfclt) * u.randP1M1() } while splitNum == targetX
                targetX = targetX - splitNum
                array.append(Num(0 < splitNum, abs(splitNum), 1))
            }
            array.append(Num(0 < targetX, abs(targetX), 1))
            return array
        }
        
        // 決めた項の数になるようにx、cそれぞれ分解する
        var xArray: [Num] = getNumArray(answer: answer.deno, count: xCount)
        var cArray: [Num] = getNumArray(answer: answer.moleWithSign, count: cCount)
        
        // 左辺、右辺を用意する
        var left:  [(Kind, Num)] = []
        var right: [(Kind, Num)] = []
        
        // x、cの項を左辺、右辺に振り分ける
        // xを右辺に振る際、cを左辺に振る際は項の符号を反転させる
        for x in xArray {
            if u.randBool() {
                left.append((.X, x))
            } else {
                let reverseNum: Num = Num(!x.isPlus, x.mole, x.deno)
                right.append((.X, reverseNum))
            }
        }
        
        for c in cArray {
            if u.randBool() {
                let reverseNum: Num = Num(!c.isPlus, c.mole, c.deno)
                left.append((.C, reverseNum))
            } else {
                right.append((.C, c))
            }
        }
        left .shuffle()
        right.shuffle()
        
        var moles: [Int] = []
        for n in left  { moles.append(n.1.mole) }
        for n in right { moles.append(n.1.mole) }
        moles.sort()
        
        func getDivisors(n: Int) -> [Int] {
            guard 1 < n else { return [1] }
            var divisors: Set<Int> = []
            for i in 2...n {
                guard i * i < n else { break }
                if n % i == 0 { divisors.insert(i); divisors.insert(n/i) }
            }
            if divisors.isEmpty { // 要素がからの場合は n が素数
                return [n]
            } else {
                return Array(divisors)
            }
        }
        
        let divisers = getDivisors(n: moles.last!)
        var divisor = divisers[u.randNum(divisers.count) - 1]
        if divisor == moles.last! {
            divisor = moles[moles.count - 2]
        }
        
        let reverseSign = u.randBool()
        
        for n in left  { n.1.deno = divisor; n.1.reduce(); n.1.isPlus = reverseSign ? !n.1.isPlus : n.1.isPlus}
        for n in right { n.1.deno = divisor; n.1.reduce();  }
        
        var result: [(Kind, Num)] = []
        result.append(contentsOf: left)
        result.append((.E,Num(true,1,0)))
        result.append(contentsOf: right)
        
        return result
    }
}


struct Section4 {

    static func get(stage: Int) -> Array<[(Kind, Num)]> {
        return getQuestions(stage:stage)
    }
    
    static func getQuestions(stage: Int) -> Array<[(Kind, Num)]> {
        var result: Array<[(Kind, Num)]> = []
        for _ in 0...9 {
            result.append(makeQuestion(stage: stage))
        }
        return result
    }
    
    static func makeQuestion(stage: Int) -> [(Kind, Num)] {
        
        let dfclt = stage + 5
        
        // 答えをつくる
        let isFraction = u.randBool(30 + stage * 5)
        let deno = isFraction ? u.randNum(dfclt) : 1
        let answer = Num(u.randBool(), u.randNum(dfclt), deno)
        // 項の数を決める
        let xCount = u.randNum(2) + 1
        let cCount = u.randNum(2) + 1
        
        func getNumArray(answer:Int, count: Int) -> [Num] {
            var array: [Num] = []
            var targetX: Int = answer
            for _ in 1..<count {
                var splitNum: Int
                repeat { splitNum = u.randNum(dfclt) * u.randP1M1() } while splitNum == targetX
                targetX = targetX - splitNum
                array.append(Num(0 < splitNum, abs(splitNum), 1))
            }
            array.append(Num(0 < targetX, abs(targetX), 1))
            return array
        }
        
        // 決めた項の数にるようにx、cそれぞれ分解する
        var xArray: [Num] = getNumArray(answer: answer.deno, count: xCount)
        var cArray: [Num] = getNumArray(answer: answer.moleWithSign, count: cCount)
        
        // 左辺、右辺を用意する
        var left:  [(Kind, Num)] = []
        var right: [(Kind, Num)] = []
        
        // x、cの項を左辺、右辺に振り分ける
        // xを右辺に振る際、cを左辺に振る際は項の符号を反転させる
        for x in xArray {
            if u.randBool() {
                left.append((.X, x))
            } else {
                let reverseNum: Num = Num(!x.isPlus, x.mole, x.deno)
                right.append((.X, reverseNum))
            }
        }
        
        for c in cArray {
            if u.randBool() {
                let reverseNum: Num = Num(!c.isPlus, c.mole, c.deno)
                left.append((.C, reverseNum))
            } else {
                right.append((.C, c))
            }
        }
        left .shuffle()
        right.shuffle()
        
        var moles: [Int] = []
        for n in left  { moles.append(n.1.mole) }
        for n in right { moles.append(n.1.mole) }
        moles.sort()
        
        func getDivisors(n: Int) -> [Int] {
            guard 1 < n else { return [1] }
            var divisors: Set<Int> = []
            for i in 2...n {
                guard i * i < n else { break }
                if n % i == 0 { divisors.insert(i); divisors.insert(n/i) }
            }
            if divisors.isEmpty { // 要素がからの場合は n が素数
                return [n]
            } else {
                return Array(divisors)
            }
        }
        
        let divisers = getDivisors(n: moles.last!)
        var divisor = divisers[u.randNum(divisers.count) - 1]
        if divisor == moles.last! {
            divisor = moles[moles.count - 2]
        }
        
        let reverseSign = u.randBool()
        
        for n in left  { n.1.deno = divisor; n.1.reduce(); n.1.isPlus = reverseSign ? !n.1.isPlus : n.1.isPlus}
        for n in right { n.1.deno = divisor; n.1.reduce(); n.1.isPlus = reverseSign ? !n.1.isPlus : n.1.isPlus  }
        
        func makeTermWithBrackets(side: [(Kind, Num)]) -> [(Kind, Num)] {
            guard 1 < side.count else { return side }
            
            // どこからどの項までを括弧で括るか決める
            let start = u.randNum(side.count - 1) - 1
            let end   = start + u.randNum(side.count - (start + 1))
            let terms = side[start...end].map { $0 }
            
            // 括る数を決める
            let m = Num(u.randBool(), u.randNum(dfclt), u.randNum(dfclt))
            m.reduce()
            
            // 括る数の逆数を掛ける
            for n in terms {
                n.1.isPlus = m.isPlus ? n.1.isPlus : !n.1.isPlus
                n.1.mole *= m.deno
                n.1.deno *= m.mole
                n.1.reduce()
            }
            
            // 括られない数（前半）、括る数、括られる数、bracket、括られない数（後半）の順で配列をつくる
            var new: [(Kind, Num)] = []
            // 括られない数（前半）
            new.append(contentsOf: side[0..<start].map { $0 })
            // 括る数
            new.append((.M, m))
            // 括られる数
            new.append(contentsOf: terms)
            // bracket
            new.append((.P, Num(true,1,1)))
            // 括られない数（後半）
            new.append(contentsOf: side[(end + 1)..<side.count].map { $0 })
            return new
        }
        
        left  = makeTermWithBrackets(side: left)
        right = makeTermWithBrackets(side: right)
        
        var result: [(Kind, Num)] = []
        result.append(contentsOf: left)
        result.append((.E,Num(true,1,0)))
        result.append(contentsOf: right)
        
        return result
    }
}
