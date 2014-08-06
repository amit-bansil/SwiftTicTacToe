//
//  T4View.swift
//  T4
//
//  Created by Amit D. Bansil on 7/23/14.
//  Copyright (c) 2014 Amit D. Bansil. All rights reserved.
//

import UIKit

class T4BoardView: UIView {
    var model: T4Model?
    var board = [[T4PlayerView]]()
    var pointCount = 0
    
    override func layoutSubviews() {
        if let model = self.model {
            if(board.count == 0){
                for column in 0..<model.width {
                    board += [T4PlayerView]()
                    for row in 0..<model.height {
                        let cell = T4PlayerView()
                        cell.backgroundColor = UIColor.clearColor()
                        cell.addGestureRecognizer(UITapGestureRecognizzle() {
                            let coords = T4Point(x:column, y:row)
                            if !model.getPlayerAt(coords) {
                                model.move(coords)
                                dropIn(cell, 0)
                                cell.player = model.getPlayerAt(coords)
                                cell.setNeedsDisplay()
                                self.bringSubviewToFront(cell)
                                let lines = model.hits
                                for line in lines[self.pointCount..<lines.count] {
                                    self.drawLine(line)
                                }
                                self.pointCount = lines.count
                            }
                        })
                        addSubview(cell)
                        board[column] += cell
                    }
                }
            }
            
            let bounds = self.bounds
            let w = bounds.width / CGFloat(model.width)
            let h = bounds.height / CGFloat(model.height)
            for column in 0..<model.width {
                for row in 0..<model.height {
                    board[column][row].frame = CGRect(
                        x:CGFloat(column) * w + bounds.minX,
                        y:CGFloat(row) * h + bounds.minY,
                        width:w,
                        height:h)
                }
            }

        }
    }
    func drawLine(line: T4Line) {
        if let model = self.model {
            let w = bounds.width / CGFloat(model.width)
            let h = bounds.height / CGFloat(model.height)
            let points = model.pointsFromLine(line)
            for i in 0..<points.count - 1 {
                let (x0, y0) = points[i].destructure()
                let (x1, y1) = points[i+1].destructure()
                let start = ((CGFloat(x0) + 0.5) * w, (CGFloat(y0) + 0.5) * h)
                let end = ((CGFloat(x1) + 0.5) * w, (CGFloat(y1) + 0.5) * h)
                drawPoint(line.player, start:start, end:end, delta:0.42, delay:Double(i) * 0.3)
                drawPoint(line.player, start:start, end:end, delta:0.58, delay:Double(i) * 0.3 + 0.2)
            }
        }
    }
    typealias Point = (x: CGFloat, y: CGFloat)
    func drawPoint(player:T4Player, start:Point, end:Point, delta:CGFloat, delay: NSTimeInterval){
        let w = CGFloat(5.0), h = CGFloat(5.0)
        let p = (start.x + (end.x - start.x) * delta, start.y + (end.y - start.y) * delta)
        let v = T4DotView(frame:CGRect(x:p.0 - w / 2.0, y: p.1 - h / 2.0, width: w, height: h), player:player)
        addSubview(v)
        dropIn(v, delay)
    }
}

func dropIn(view: UIView, delay: NSTimeInterval) {
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.5, 2.5);
    view.hidden = true
    UIView.animateWithDuration(delay,
        delay:0.0,
        options:.CurveEaseOut,
        animations:{},
        completion:{
            (t: Bool) in
            view.hidden = false
            UIView.animateWithDuration(0.15,
                delay:0.0,
                options:.CurveEaseOut,
                animations:{
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                },
                completion:{
                    (t: Bool) in
                }
            )
        }
    )
}

class UITapGestureRecognizzle : UITapGestureRecognizer {
    var target : () -> ()
    
    init(target: () -> ()) {
        self.target = target
        
        super.init(target: self, action: "invokeTarget:")
    }
    
    func invokeTarget(nizer: UITapGestureRecognizer!) {
        target()
    }
}