//
//  SDETransitionAnimator.swift
//  CustomCollectionViewTransition
//
//  Created by seedante on 15/7/11.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDETransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private var operation: UINavigationControllerOperation

    init(operation: UINavigationControllerOperation){
        self.operation = operation
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        switch operation{
        case .Push:
            print("Push Transition Begin: \(NSDate())")
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            transitionContext.containerView()?.addSubview(toView!)

            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UICollectionViewController

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                print("Push Transition Finish: \(NSDate())")
                print(toVC.collectionView!.visibleCells())
                transitionContext.completeTransition(true)
            })


        case .Pop:
            print("Pop Transition Begin: \(NSDate())")
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            transitionContext.containerView()?.insertSubview(toView!, belowSubview: fromView!)
            fromView?.backgroundColor = UIColor.clearColor()
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                print("Pop Transition Finish: \(NSDate())")
                transitionContext.completeTransition(true)
            })

        default:
            print("No Operation")
        }
    }
}
