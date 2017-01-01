//
//  FacialExpression.swift
//  FaceIt
//
//  Created by Ben Allgeier on 12/14/16.
//  Copyright © 2016 ballgeier. All rights reserved.
//

import Foundation

// UI-independent representation of a facial expression

struct FacialExpression {
    
    enum Eyes: Int {
        case Open
        case Closed
        case Squinting
    } // enum Eyes
    
    enum EyeBrows: Int {
        case Relaxed
        case Normal
        case Furrowed
        
        func moreRelaxedBrow() -> EyeBrows {
            return EyeBrows(rawValue: rawValue - 1) ?? .Relaxed
        } // end moreRelaxedBrow()
        
        func moreFurrowedBrow() -> EyeBrows {
            return EyeBrows(rawValue: rawValue + 1) ?? .Furrowed
        } // end moreFurrowedBrow()
    } // end enum EyeBrows
    
    enum Mouth: Int {
        case Frown
        case Smirk
        case Neutral
        case Grin
        case Smile
        
        func sadderMouth() -> Mouth {
            return Mouth(rawValue: rawValue - 1) ?? .Frown
        } // end sadderMouth()
        
        func happierMouth() -> Mouth {
            return Mouth(rawValue: rawValue + 1) ?? .Smile
        } // end happierMouth()
    } // end enum Mouth
    
    var eyes: Eyes
    var eyeBrows: EyeBrows
    var mouth: Mouth
} // end struct FacialExpression
