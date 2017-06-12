//
//  Even-OddView.swift
//  shapeLayer
//
//  Created by wkk on 2017/6/9.
//  Copyright © 2017年 TaikangOnline. All rights reserved.
//

import UIKit

class Even_OddView: UIView {
    fileprivate var type: DiscernType = .identiCard
    
    fileprivate var tipRect: CGRect = CGRect.zero
    init(frame: CGRect,tipType: DiscernType) {
        super.init(frame: frame)
        type = tipType
        backgroundColor = UIColor.clear
        let shapeLayer = CAShapeLayer()
        tipRect = getTipRect()
        shapeLayer.path = UIBezierPath(roundedRect:tipRect, cornerRadius: 5).cgPath
        shapeLayer.strokeColor = #colorLiteral(red: 0.1595295668, green: 0.9977020621, blue: 0.07541743666, alpha: 1).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.lineWidth = 2
        layer.addSublayer(shapeLayer)
        
        
        let tipLabel = UILabel()
        tipLabel.text = "请将卡片至于框内"
        tipLabel.textColor = #colorLiteral(red: 0.1595295668, green: 0.9977020621, blue: 0.07541743666, alpha: 1)
        tipLabel.sizeToFit()
        tipLabel.center = CGPoint(x: center.x, y: tipRect.origin.y - 20)
        addSubview(tipLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        
        let path1 = UIBezierPath(rect: bounds)
        let path2 =  UIBezierPath(roundedRect: tipRect, cornerRadius: 5)
        context?.addPath(path1.cgPath)
        context?.addPath(path2.cgPath)
        context?.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context?.drawPath(using: .eoFill)
    }
    
    func getTipRect()->CGRect{
        let width: CGFloat
        let height: CGFloat
        let x: CGFloat
        let y: CGFloat
        switch type {
        case .identiCard:
            width = bounds.width - 20
            height = width / 1.6
            x = 10
            y = 200
        case .bankCard:
            width = bounds.width - 20
            height = width * 1.6
            x = 10
            y = (bounds.height - height) * 0.5
        }
        return  CGRect(x: x, y: y, width: width, height: height)
    }

}
