//
//  ViewController.swift
//  FaceIt
//
//  Created by Ben Allgeier on 12/14/16.
//  Copyright © 2016 ballgeier. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {
    
    // MARK: Model
    
    var expression = FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk) {
        didSet {
            updateUI()
        } // because FacialExpression is a struct a value type, changes to any of the properties will cause this didSet to be called (not true for classes)
    } // end var FacialExpression
    
    
    // MARK: View
    
    // the didSet here is called only once
    // when the outlet is connected up by iOS
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView,
                action: #selector(FaceView.changeScale(_:))
                )
            )
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(FaceViewController.increaseHappiness
                )
            )
            happierSwipeGestureRecognizer.direction = .up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(FaceViewController.decreaseHappiness
                )
            )
            sadderSwipeGestureRecognizer.direction = .down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            faceView.addGestureRecognizer(UIRotationGestureRecognizer(
                target: self,
                action: #selector(FaceViewController.changeBrows(_:))
                )
            )
            
            updateUI()
        }
    } // end var faceView
    
    
    // here the Controller is doing its job
    // of interpreting the Model (expression) for the View (faceView)
    
    private func updateUI() {
        if faceView != nil {
            switch expression.eyes {
            case .Open: faceView.eyesOpen = true
            case .Closed: faceView.eyesOpen = false
            case .Squinting: faceView.eyesOpen = false
            } // end switch expression.eyes
            faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
            faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
        } // end if
    } // end updateUI()
    
    private let mouthCurvatures = [FacialExpression.Mouth.Frown:-1.0, .Grin:0.5, .Smile:1.0, .Smirk:-0.5, .Neutral:0.0]
    
    private let eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed:0.5, .Furrowed:-0.5, .Normal:0.0]
    

    
    // MARK: Gesture Handlers
    
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    } // end increaseHappiness()
    
    func decreaseHappiness() {
        expression.mouth = expression.mouth.sadderMouth()
    } // end decreaseHappiness()
    
    // gesture handler for taps
    //
    // toggles the open/closed state of the eyes in the Model
    // and all changes to the Model automatically updateUI()
    // (see the didSet for the Model var expression above)
    // so our faceView will also change its eyes
    //
    // this handler was added directly in the storyboard
    // by dragging a UITapGestureHandler onto the faceView
    // then ctrl-dragging from the tap gesture
    // (at the top of the scene in the storyboard)
    // here to our Controller
    // (so there's no need to call addGestureRecognizer)
    
    @IBAction func toggleEyes(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            switch expression.eyes {
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            case .Squinting: break
            } // end switch expression.eyes
        } // end if
    } // end toggleEyes(_:)
    
    // gesture handler to change the Model's brows with a rotation gesture
    func changeBrows(_ recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            if recognizer.rotation > CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreRelaxedBrow()
                recognizer.rotation = 0.0
            } else if recognizer.rotation < -CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreFurrowedBrow()
                recognizer.rotation = 0.0
            } // end if/else
        default:
            break
        } // end switch recognizer.state
    } // end changeBrows(_:)
    
} // end class FaceViewController

