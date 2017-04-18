//
//  DrawView.swift
//  TouchTracker ch 18 and 19
//
//  Created by Alex Louzao on 4/1/17.
//  Copyright © 2017 ALcsc2310. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate{
    
    //var currentLine: Line?
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    
    var currentCircle = Circle()
    var finishedCircle = [Circle]()
    
    var selectedLineIndex: Int? {
        didSet{
            if selectedLineIndex == nil{
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    var moveRecognizer: UIPanGestureRecognizer!
    
    required init? (coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    func doubleTap(_ gestureRecognizer: UIGestureRecognizer){
        print("Double Tap")
        selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
    }
    
    func tap(_ gestureRecognizer: UIGestureRecognizer){
        print("A Tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        let menu = UIMenuController.shared
        if selectedLineIndex != nil{
            becomeFirstResponder()
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setMenuVisible(true, animated: true)
            menu.setTargetRect(targetRect, in: self)
        } else {
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    func longPress(_ gestureRecognizer: UIGestureRecognizer){
        print("A Long Press")
        
        if gestureRecognizer.state == .began{
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            if selectedLineIndex != nil{
                currentLines.removeAll()
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }
        setNeedsDisplay()
    }
    
    func moveLine(_ gestureRecognizer: UIPanGestureRecognizer){
        print("Recognize a Pan")
        
        if let index = selectedLineIndex{
            if gestureRecognizer.state == .changed{
                let translation = gestureRecognizer.translation(in: self)
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                setNeedsDisplay()
            }
        } else {
            return
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneousWithotherGestureRecognizer: UIGestureRecognizer) -> Bool{
    
       return true
    }
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func deleteLine(_ sender: UIMenuController){
        if let index = selectedLineIndex{
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.blue{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var currentLineColor: UIColor = UIColor.black{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 10{
        didSet{
            setNeedsDisplay()
        }
    }
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        //path.lineWidth = 10
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        //UIColor.black.setStroke()
        finishedLineColor.setStroke()
        for line in finishedLines{
            line.color.setStroke() // update the color of the line on start
            stroke(line)
        }
        
        /*if let line = currentLine{
            UIColor.red.setStroke()
            stroke(line)
        }*/
        
        //UIColor.red.setStroke()
        currentLineColor.setStroke()
        for(_, line) in currentLines{
            line.color.setStroke() // update color of the line on end
            stroke(line)
        }
        
        if let index = selectedLineIndex{
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
        // Draw Circles
        finishedLineColor.setStroke()
        for circle in finishedCircle {
            let path = UIBezierPath(ovalIn: circle.rect)
            path.lineWidth = lineThickness
            path.stroke()
        }
        currentLineColor.setStroke()
        UIBezierPath(ovalIn: currentCircle.rect).stroke()
        
    }
    
    func indexOfLine(at point: CGPoint) -> Int? {
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end  = line.end
            
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05){
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                if hypot(x - point.x, y - point.y) < 20.0{
                    return index
                }
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*let touch = touches.first!
        let location = touch.location(in: self)
        currentLine = Line(begin: location, end: location)*/
        print(#function)
        if touches.count == 2 {
            let touchesArray = Array(touches)
            let location1 = touchesArray[0].location(in: self)
            let location2 = touchesArray[1].location(in: self)
            currentCircle = Circle(point1: location1, point2: location2)
        } else {
        for touch in touches {
            let location = touch.location(in: self)
            let newLine = Line(begin: location, end: location)
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*let touch = touches.first!
        let location = touch.location(in: self)
        currentLine?.end = location*/
        
        print(#function)
        if touches.count == 2 {
            let touchesArray = Array(touches)
            let location1 = touchesArray[0].location(in: self)
            let location2 = touchesArray[1].location(in: self)
            currentCircle = Circle(point1: location1, point2: location2)
        } else {
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
        }
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*if var line = currentLine{
            let touch = touches.first!
            let location = touch.location(in: self)
            line.end = location
            finishedLines.append(line)
        }
        currentLine = nil*/
        if touches.count == 2 {
            let touchesArray = Array(touches)
            let location1 = touchesArray[0].location(in: self)
            let location2 = touchesArray[1].location(in: self)
            currentCircle = Circle(point1: location1, point2: location2)
            finishedCircle.append(currentCircle)
            currentCircle = Circle()
        } else {
        for touch in touches{
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.location(in: self)
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
        }
        }
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        currentLines.removeAll()
        currentCircle = Circle()
        setNeedsDisplay()
    }
    
}
