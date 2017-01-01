//
//  FaceView.swift
//  FaceIt
//
//  Created by Ben Allgeier on 12/14/16.
//  Copyright © 2016 ballgeier. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {

    @IBInspectable var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth : CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    @IBInspectable var mouthCurvature: Double = 0.67 { didSet { setNeedsDisplay() } } // 1 full smile, -1 full frown
    @IBInspectable var eyesOpen: Bool = false { didSet { setNeedsDisplay() } }
    @IBInspectable var eyeBrowTilt: Double = 0.4 { didSet { setNeedsDisplay() } } // -1 full furrow, 1 fully relaxed
    @IBInspectable var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        } // end switch recognizer.state
    } // end changeScale(_:)
    
    private var skullRadius: CGFloat {
        return min(bounds.width, bounds.height) / 2 * scale
    } // end skullRadius
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
        // alternative way: 
        // var skullCenter = convert(center, from: superview)
    } // end skullCenter
    
    private struct Ratios {
        static let SkullRadiusToEyeOffset: CGFloat = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
        static let SkullRadiusToBrowOffset: CGFloat = 5
    } // end struct Ratios
    
    private enum Eye {
        case Left
        case Right
    } // end enum Eye
    
    private func pathForCircleCenteredAtPoint(_ midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(
            arcCenter: midPoint,
            radius: radius,
            startAngle: 0.0,
            endAngle: CGFloat(2 * M_PI),
            clockwise: true
        )
        path.lineWidth = lineWidth
        return path
    } // end pathForCircleCenteredAtPoint(_:withRadius:)
    
    private func getEyeCenter(of eye: Eye) -> CGPoint {
        let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
        var eyeCenter = skullCenter
        eyeCenter.y -= eyeOffset
        switch eye {
        case .Left: eyeCenter.x -= eyeOffset
        case .Right : eyeCenter.x += eyeOffset
        } // end switch eye
        return eyeCenter
    } // end getEyeCenter(of:)
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let eyeCenter = getEyeCenter(of: eye)
        if eyesOpen {
            return pathForCircleCenteredAtPoint(eyeCenter, withRadius: eyeRadius)
        } else {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = lineWidth
            return path
        } // end if/else
        
    } // end pathForEye(_:)
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
        
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth/2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
//        return UIBezierPath(rect: mouthRect)
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        
        return path
    } // end pathForMouth()
    
    private func pathForBrow(above eye: Eye) -> UIBezierPath {
        var tilt = eyeBrowTilt
        switch eye {
        case .Left: tilt *= -1.0
        case .Right: break
        } // end switch eye
        var browCenter = getEyeCenter(of: eye)
        browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let tiltOffset = CGFloat(max(-1, min(tilt, 1))) * eyeRadius / 2
        let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
        let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
        let path = UIBezierPath()
        path.move(to: browStart)
        path.addLine(to: browEnd)
        path.lineWidth = lineWidth
        return path
    } // end pathForBrow(above:)
    
    override func draw(_ rect: CGRect) {
        color.set()
        pathForCircleCenteredAtPoint(skullCenter, withRadius: skullRadius).stroke()
        pathForEye(.Left).stroke()
        pathForEye(.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(above: .Left).stroke()
        pathForBrow(above: .Right).stroke()
    } // end draw(_:)

} // end class FaceView
