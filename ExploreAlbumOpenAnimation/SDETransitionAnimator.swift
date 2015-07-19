//
//  SDETransitionAnimator.swift
//  CustomCollectionViewTransition
//
//  Created by seedante on 15/7/11.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDETransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var delay: NSTimeInterval?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        print("Transition Begin: \(NSDate())")
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        transitionContext.containerView()?.addSubview(toView!)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay! * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            print("Transition Finish: \(NSDate())")
            
            transitionContext.completeTransition(true)
        })
    }
}
